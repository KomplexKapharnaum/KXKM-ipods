//
//  remoteplayv2AppDelegate.m
//  remoteplayv2
//
//  Created by Pierre Hoezelle and Thomas Bohl
//  Copyright 2011 KXKM. Creative Commons BY-NC-SA.
//

#import "remoteplayv2AppDelegate.h"
#import "remoteplayv2ViewController.h"
#import "remoteplayv2TableViewController.h"
#import "remoteplayv2UserViewController.h"

@implementation remoteplayv2AppDelegate

@synthesize window;
@synthesize _secondWindow;
@synthesize blackview;
@synthesize tabBarController;
@synthesize moviePlayer;
@synthesize manager;
@synthesize outPort;
@synthesize movieURL;
@synthesize timermouvement;
@synthesize remotemoviepath;
@synthesize pathformovie;
@synthesize remotemoviename,screenstate,playerstate, flashcolor,message;
@synthesize gomovie,stopmovie,gomute,gounmute,gofadeblack,gofadewhite,goflash,gocolorflash,gomessage;
@synthesize movieIsPlaying;



#pragma mark -
#pragma mark Application lifecycle

//###########################################################
//STARTUP

//APPLICATION START
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    //VUES : pointeur vers l'objet de chacune des vues pour un accès rapide depuis le delegate
        //TABS : Add the view controller's view to the window and display.
        [self.window addSubview:tabBarController.view];
    
        //VUE 1 : remote control
        viewController = (remoteplayv2ViewController*)[ self.tabBarController.viewControllers objectAtIndex:0];
    
        //VUE 2 : controle manuel
        userViewController = (remoteplayv2UserViewController*) [self.tabBarController.viewControllers objectAtIndex:1];
        [userViewController loadView];
    
        //VUE 3 : media liste
        tableViewController = (remoteplayv2TableViewController*) [self.tabBarController.viewControllers objectAtIndex:2];
        [self.window makeKeyAndVisible];
	
    //Ipod Properties
        //Get ipod name 
        myName = [[NSUserDefaults standardUserDefaults] stringForKey:@"osc_id_name_key"];
    
    //OSC Communication
        //MANAGER add osc manager object
        manager = [[OSCManager alloc] init];
        [manager setDelegate:self];    
	
        //INPUT create an input port for receiving OSC data
        inPort = [[NSUserDefaults standardUserDefaults] stringForKey:@"osc_port_in_key"];
        [manager createNewInputForPort:[inPort intValue]];
	
        //OUTPUT create outPort to the server
        NSString *ipServerValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"osc_ip_server_key"];
        NSString *platform = [self platform];
        // choose when using simulator on Thomas' laptop and server on Jeremie's mac at kxkm
        if ([platform isEqualToString:@"i386"]) ipServerValue = @"192.168.174.255";
        // choose when using simulator on other' mac and the server is in
        //if ([platform isEqualToString:@"i386"]) ipServerValue = @"127.0.0.1";
        NSString *portServerValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"osc_port_server_key"];
        outPort = [manager createNewOutputToAddress:ipServerValue atPort:[portServerValue intValue]];
    
    
    //APP Info and States
        //initiatisations ordres
        gomovie = NO;
        stopmovie = NO;
        movieIsPlaying = NO;
        
        //initiatisations états
        playerMode = @"auto"; 
        playerState = @"waiting";
        screenState = @"noscreen";
    
        //display info
        [viewController setInfoscreenText: @"Warning no second screen"];
        [viewController setInfoipText: [@"IP : " stringByAppendingString: [self getIPAddress]]];
    
	
    //APP init
        //Get ipod IP 
        //myIp = [self getIPAddress];
        
        //list media
        [self listMedia];
    
        //set up the timer
        [self topDepartMouvement: timermouvement];
	
        //Send a initial info on app startup
        [self sendInfo];
    
    
	//end of startup
    return YES;
}

//###########################################################
// COMMUNICATION

//OSC Message maker : return an OSCMessage beginning with "/ipodname state"
-(OSCMessage*)oscNewMsg:(NSString*)state{
	OSCMessage *newMsg = [OSCMessage createWithAddress:[@"/" stringByAppendingString: myName]];
    [newMsg addString:state];
    return newMsg;
}

//Info message : IP, media list
-(void)sendInfo{
    OSCMessage *newMsg = [self oscNewMsg:@"initinfo"];
    [newMsg addString:[self getIPAddress]];
    for (NSString *movies in mediaList) 
        [newMsg addString:movies];
    [outPort sendThisMessage:newMsg];
}


//Sync message : send player state message
-(void)sendSync{
    
    //Player Mode : Auto, Manu, Streaming, ... 
    OSCMessage *newMsg = [self oscNewMsg:playerMode];
    
    //Player State : waiting, playing, 
    [newMsg addString:playerState];
    
//TODO construct detailed state message 
//TODO construct detailed state message
//TODO construct detailed state message
    
    [newMsg addInt:(int)[moviePlayer currentPlaybackTime]];
    [newMsg addBOOL:[userViewController isMute]];
    
    [outPort sendThisMessage:newMsg];
}

//send SOS
-(void) sendSOS {
    OSCMessage *newMsg = [self oscNewMsg:@"SOS"];
    [outPort sendThisMessage:newMsg];
}

//###########################################################
//FILES MANAGER

//MEDIA list
-(void)listMedia{
    //les vidéos sont dorénavent a placer dans le dossier Documents de l'App KXKM
    //ne pas activer icloud sous peine de synchronisation des vidéos (ralentissement)
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);  
    pathformovie = [[paths objectAtIndex:0] copy];
    
    //simulator path (dev only)
    NSString *platform = [self platform];
    if ([platform isEqualToString:@"i386"]) pathformovie = @"/Media/Video/";
    
    //list compatible video files
    NSArray *extensions = [NSArray arrayWithObjects:@"mp4", @"mov", @"m4v", nil];
    NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:pathformovie error:nil];
    mediaList = [dirContents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"pathExtension IN %@", extensions]];
    
    //VUE update media list 
    tableViewController.moviesList = [mediaList copy];
    [tableViewController.moviesTable reloadData];
}


//###########################################################
//WORKERS

//lancer le timer
-(void)topDepartMouvement: (NSTimer*)timer{
	timer = [NSTimer scheduledTimerWithTimeInterval:0.01 //10ms
											 target:self 
										   selector:@selector(topHorloge) 
										   userInfo:nil 
											repeats:YES];
	timermouvement = timer;
}


- (void)topHorloge{
    //CHECK SCREEN
	[self checkScreen];
    if(movieIsPlaying && !userViewController.timeSlider.touchInside){
        userViewController.timeSlider.maximumValue=(CGFloat)[moviePlayer duration];
        userViewController.timeSlider.value = (CGFloat)[moviePlayer currentPlaybackTime];
    }
    if (movieIsPlaying && userViewController.timeSlider.touchInside) {
        [moviePlayer setCurrentPlaybackTime:(double)userViewController.timeSlider.value];
    }
	
	//STOP VIDEO IF NO SCREEN
	if (screenState == @"noscreen") {
		if(movieIsPlaying){
			[self.moviePlayer stop];
            [self removeMovieNotificationHandlers];
			[self.moviePlayer release];
			movieIsPlaying = NO;
            [self sendSync];
		}
	}
	
    //play movie
	if (gomovie) {
		if(movieIsPlaying){
			[self.moviePlayer stop];
			printf("stop current");
            [self removeMovieNotificationHandlers];
			[self.moviePlayer release];
			printf("release current");
			movieIsPlaying = NO;
			playerState = @"waiting";
            [viewController setInfoText:@"waiting"];
		}
        
        NSURL *mymovieURL = [NSURL fileURLWithPath:self.remotemoviepath];
        MPMoviePlayerController *mp = [[MPMoviePlayerController alloc] initWithContentURL:mymovieURL];
        if (mp) {
            
            //set player on second screen
            [[mp view] setFrame: [_secondWindow bounds]];
            mp.controlStyle = MPMovieControlStyleNone;
            self.moviePlayer = mp;
            [_secondWindow insertSubview:[self.moviePlayer view] belowSubview:blackview];
            // Play the movie!
            [self.moviePlayer play];
            NSString *s = @"playing";
            [viewController setInfoText:[ s stringByAppendingString: remotemoviename ]];
            [userViewController setMovieTitle:remotemoviename];
            playerState = remotemoviename;
            //add observers
            [self installMovieNotificationObservers];
            //unmute on start video
            if([userViewController isMute]){
                [userViewController muting:self];
            }
            //init slider
            userViewController.timeSlider.continuous=NO;
            userViewController.timeSlider.minimumValue=0.0;
            movieIsPlaying = YES;
        }
		[self sendSync];	
        stopmovie=NO;
		gomovie=NO;
	}
    
    //stop movie
	if (stopmovie && movieIsPlaying){
		[self.moviePlayer stop];
		printf("stop ");
        [self removeMovieNotificationHandlers];
		[self.moviePlayer release];
		printf("release ");
		movieIsPlaying = NO;
        [(remoteplayv2ViewController*)[ self.tabBarController.viewControllers objectAtIndex:0] setInfoText:@"waiting"];
        playerState = @"waiting";
        [self sendSync];
		stopmovie=NO;
	}
    
    //mute
    if (gomute) {
		if (![userViewController isMute]) {
            [userViewController muting:self];
        }
        gomute=NO;
    }
    //unmute
    if (gounmute) {
		if ([userViewController isMute]) {
            [userViewController muting:self];
        }
        gounmute=NO;
    }
    //fade to black
    if (gofadeblack) {
		[userViewController fadeBlack:self];
        gofadeblack=NO;
    }
    //fade to black
    if (gofadewhite) {
		[userViewController fadeWhite:self];
        gofadewhite=NO;
    }
    //white flash
    if (goflash) {
		[userViewController flash:self];
        goflash=NO;
    }
    //color flash
    if (gocolorflash) {
        float r = (float)flashcolorRed/255;
        float g = (float)flashcolorGreen/255;
        float b = (float)flashcolorBlue/255;
            self.blackview.backgroundColor = [UIColor colorWithRed:r green:g blue:b alpha:1];

            self.blackview.alpha=1;
            [UIView beginAnimations:@"flashcolor" context:NULL];
            [UIView setAnimationDuration:0.35];
            self.blackview.alpha=0;
            [UIView commitAnimations];
        gocolorflash=NO;
        }      
    
    if (gomessage) {
        NSLog(message);
        [userViewController setMessage:message];
        gomessage=NO;
    }

	
}

//###########################################################



- (void) receivedOSCMessage: 		(OSCMessage *)  	m	{
	[self treatReceivedOSCMessage: m];
}

//treat oscmessage when received
- (void) treatReceivedOSCMessage: 	(OSCMessage *)  	m	{
	NSString * a = [m address];
    //just get sync
	if ([a isEqualToString: @"/synctest"]) {
		[self sendSync];
        return;
	}
    //get full sync info causing reload :
    //IP adress
    //movie file on list
	if ([a isEqualToString: @"/fullsynctest"]) {
		[self sendInfo];
        return;
	}
    
    //order play movie
	if ([a isEqualToString: @"/playmovie"]) {
		[self initGoMovieWithName : [[m value] stringValue]];
        return;
    }
    
    //order to skip in time in movie
	if ([a isEqualToString: @"/attime"]) {
        playbacktimeWanted = [[m value] intValue];
        if ((int)[moviePlayer duration]>playbacktimeWanted) {
            [moviePlayer setCurrentPlaybackTime:(double)playbacktimeWanted];
			[self sendSync];
        }else{	
			stopmovie = YES;
        }
        return;
    }
    
    //stop the movie
	if ([a isEqualToString: @"/stopmovie"]) {
		stopmovie = YES;
        return;
    }
    
    //mute
    if ([a isEqualToString: @"/mute"]) {
		gomute=YES;
        return;
    }
    //unmute
    if ([a isEqualToString: @"/unmute"]) {
		gounmute=YES;
        return;
    }
    //fade to black
    if ([a isEqualToString: @"/fadeblack"]) {
        gofadeblack=YES;
        return;
    }
    //fade to black
    if ([a isEqualToString: @"/fadewhite"]) {
		gofadewhite=YES;
        return;
    }
    //white flash
    if ([a isEqualToString: @"/flash"]) {
		goflash=YES;
        return;
    }
    //color flash
    if ([a isEqualToString: @"/colorflash"] && !gocolorflash) {
        flashcolorRed = [[m valueAtIndex:0] intValue];
        flashcolorGreen = [[m valueAtIndex:1] intValue];
        flashcolorBlue = [[m valueAtIndex:2] intValue];
        gocolorflash=YES;
        return;
    }
    if ([a isEqualToString: @"/message"]) {
        self.message= [[[m value ] stringValue]copy];
        gomessage=YES;
        return;
    }
    //no understanding message
    OSCMessage *newMsg = [OSCMessage createWithAddress:@"/problem"];
    [newMsg addString:@"bad request : "];
    [newMsg addString:a];
    [outPort sendThisMessage:newMsg];
	
}

//###########################################################

-(void) initGoMovieWithName:(NSString*)n {
    if ([n length]>=1){
        gomovie = YES;
        self.remotemoviename = n;
        self.remotemoviepath = [self.pathformovie stringByAppendingString:@"/"];
        self.remotemoviepath = [self.remotemoviepath stringByAppendingString:n];
        //set next button
        if ([tableViewController.moviesList lastObject]!=n) {
            [userViewController setNextTitle:[tableViewController.moviesList objectAtIndex:1 + [tableViewController.moviesList indexOfObject:n]]];
            userViewController.nextButton.hidden=NO;
        }else{
            userViewController.nextButton.hidden=YES;
        }
        //set back button
        if ([tableViewController.moviesList objectAtIndex:0]!=n) {
            [userViewController setBackTitle:[tableViewController.moviesList objectAtIndex: [tableViewController.moviesList indexOfObject:n]-1]];
            userViewController.backButton.hidden=NO;
        }else{
            userViewController.backButton.hidden=YES;
        }
    }
    
}


//###########################################################
//SCREEN MANAGER

//check screen
- (void) checkScreen{
	
	//no screen
	if (screenState == @"noscreen") {	
		//add extrenal tvout window
		if ([[UIScreen screens] count] > 1)
		{	
			// Associate the window with the second screen.
			// The main screen is always at index 0.
			UIScreen*    secondScreen = [[UIScreen screens] objectAtIndex:1];
			CGRect        screenBounds = secondScreen.bounds;
			
			_secondWindow = [[UIWindow alloc] initWithFrame:screenBounds];
			_secondWindow.screen = secondScreen;
			
			// Add a black background to the window		
			UIView*            whiteField = [[UIView alloc] initWithFrame:screenBounds];
			whiteField.backgroundColor = [UIColor blackColor];
			
			[_secondWindow addSubview:whiteField];
			[whiteField release];
			
			// Center a label in the view.
			NSString*    noContentString = [NSString stringWithFormat:@" "];
			CGSize        stringSize = [noContentString sizeWithFont:[UIFont systemFontOfSize:18]];
			CGRect        labelSize = CGRectMake((screenBounds.size.width - stringSize.width) / 2.0,
												 (screenBounds.size.height - stringSize.height) / 2.0,
												 stringSize.width, stringSize.height);
			UILabel*    noContentLabel = [[UILabel alloc] initWithFrame:labelSize];
			noContentLabel.text = noContentString;
			noContentLabel.font = [UIFont systemFontOfSize:18];
			[whiteField addSubview:noContentLabel];
            
            UIView * b = [[UIView alloc] initWithFrame:screenBounds];
            b.backgroundColor = [UIColor blackColor];
            blackview = b;
            blackview.alpha=0;
            [_secondWindow addSubview:blackview];
			
			// Go ahead and show the window.
			_secondWindow.hidden = NO;
            [viewController setInfoscreenText: [NSString stringWithFormat: @"second screen %.0f x %.0f",screenBounds.size.width,screenBounds.size.height]];
            [viewController setInfoText: @"Waiting"];
			screenState = [NSString stringWithFormat: @"%.0f x %.0f",screenBounds.size.width,screenBounds.size.height];
			playerState = @"waiting";
			[self sendSync];
		}
	}
	//screen connected check if still there
	else {
		//screen has been disconnected ?
		if (!([[UIScreen screens] count] > 1)) {
            [viewController setInfoscreenText: @"Warning screen disconnected !"];
            [viewController setInfoText: @"No Screen.."];
			playerState = @"noscreen";
			screenState = @"noscreen";
			[self sendSync];
		}
	}
    
}

//###########################################################
// UTILITIES

- (NSString *) getIPAddress{
    NSArray *addresses = [[NSHost currentHost] addresses];
    NSString * ip;
    for (NSString *anAddress in addresses) {
        if (![anAddress hasPrefix:@"127"] && [[anAddress componentsSeparatedByString:@"."] count] == 4) {
            ip = anAddress;
            break;
        } else {
            ip = @"Warning no IP address";
        }
    }
	return ip;
}

- (NSString *) platform{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine];
    free(machine);
    return platform;
}

- (void) debug : (NSString*) s{
	OSCMessage *newMsgdebug = [OSCMessage createWithAddress:@"/debug"];
	printf("debug: %s\n", [s cStringUsingEncoding:NSMacOSRomanStringEncoding]);
	[newMsgdebug addString:s];
	[outPort sendThisMessage:newMsgdebug];
}


//###########################################################
//notification for movie

-(void) installMovieNotificationObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(moviePlayBackDidFinish:) 
                                                 name:MPMoviePlayerPlaybackDidFinishNotification 
                                               object:moviePlayer];      
}

- (void) moviePlayBackDidFinish:(NSNotification*)notification {
    if(![userViewController isMute]){
        [userViewController muting:self];
        [userViewController setMuteButtonColor:[UIColor grayColor]];
        stopmovie=YES;
    }
    
}

-(void)removeMovieNotificationHandlers {    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:moviePlayer];
}



//###########################################################



- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
	[self debug:@"exit app"];
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    [userViewController release];
    [tableViewController release];
    [viewController release];
    [tabBarController release];
    [moviePlayer release];
    [_secondWindow release];
    [window release];
    [super dealloc];	
}


@end
