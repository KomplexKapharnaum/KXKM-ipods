//
//  remoteplayv2AppDelegate.m
//  remoteplayv2
//
//  Created by Pierre Hoezelle, Thomas Bohl, Jeremie Forge
//  Copyright 2011 KXKM. Creative Commons BY-NC-SA.
//

#import "remoteplayv2AppDelegate.h"
#import "remoteplayv2ViewController.h"
#import "remoteplayv2TableViewController.h"
#import "remoteplayv2UserViewController.h"

@implementation remoteplayv2AppDelegate

@synthesize window;
@synthesize _secondWindow, layerAVF;
@synthesize playerview, player1view, player2view, muteview, fadeview, flashview, titlesview, mirview;
@synthesize tabBarController;
@synthesize moviePlayer,playerAVF;
@synthesize manager;
@synthesize outPort;
@synthesize timermouvement;
@synthesize remotemoviepath;
@synthesize pathformovie;
@synthesize remotemoviename,screenstate,playerstate,message,customTitles,movieLast;
@synthesize gomovie,gopause,gostop,gomute,gofade,goflash,gomessage,gotitles;
@synthesize muted,faded,paused,mired;
@synthesize streamingMode,createPlayer,useAVF,usePlayer1,releasePlayer;



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
        gostop = NO;
        createPlayer = YES;
        useAVF = YES;
        usePlayer1 = YES;
        releasePlayer = 0;
        
        //initiatisations états
        playerMode = @"auto"; 
        playerState = @"starting";
        screenState = @"noscreen";
        remotemoviename = @"";
        muted = NO;
        faded = NO;
        paused = NO;
        mired = YES;
        
        //display info
        [viewController setInfoscreenText: @"Warning no second screen"];
        [viewController setInfoipText: [@"IP : " stringByAppendingString: [self getIPAddress]]];
    
	
    //APP init       
        //list media
        tableViewController.moviesList = [[self listMedia] copy];
        [tableViewController.moviesTable reloadData];
    
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
    [outPort sendThisMessage:newMsg];
    
    NSArray * mediaList = [self listMedia];
    for (NSString *movies in mediaList) {
        newMsg = [self oscNewMsg:@"fileinfo"];
        [newMsg addString:movies];
        [outPort sendThisMessage:newMsg];
    }
    
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


//INFO (state box info)
-(void) infoState:(NSString*)msg{
    [(remoteplayv2ViewController*)[ self.tabBarController.viewControllers objectAtIndex:0] setInfoText:msg];
}

//INFO (state box info)
-(void) infoMovie:(NSString*)msg{
    [(remoteplayv2ViewController*)[ self.tabBarController.viewControllers objectAtIndex:0] setInfoMovieText:msg];
}


//###########################################################
// OSC RECEIVER

//treat oscmessage when received
- (void) receivedOSCMessage: 	(OSCMessage *)  	m	{
	NSString * a = [m address];
    
    //SYNC : mode, state, args (movie, time, ...)
	if ([a isEqualToString: @"/synctest"]) {
        [self sendSync];
        return;
	}
    
    //INIT INFO : ip, media list
	if ([a isEqualToString: @"/fullsynctest"]) {
		[self sendInfo];
        return;
	}
    
    //LOAD & PLAY MOVIE
	if (([a isEqualToString: @"/loadmovie"]) || ([a isEqualToString: @"/playmovie"])) {
        streamingMode = NO;
        useAVF = NO;
        [self initGoMovieWithName : [[m value] stringValue] : [a isEqualToString: @"/playmovie"]];
        return;
    }
    
    //LOAD & PLAY STREAM
	if (([a isEqualToString: @"/loadstream"]) || ([a isEqualToString: @"/playstream"])) {
		streamingMode = YES;
        useAVF = NO;
        [self initGoMovieWithName : [[m value] stringValue] : [a isEqualToString: @"/playstream"]];
        return;
    }
    
    //PLAY MOVIE AVF
	if ([a isEqualToString: @"/playmovieAVF"]) {
        streamingMode = NO;
        useAVF = YES;
        [self initGoMovieWithName : [[m value] stringValue] : YES];
        return;
    }
    
    //PLAY STREAM AVF
	if ([a isEqualToString: @"/playstreamAVF"]) {
		streamingMode = YES;
        useAVF = YES;
        [self initGoMovieWithName : [[m value] stringValue] : YES];
        return;
    }
    
    //SKIP AT TIME
	if ([a isEqualToString: @"/attime"]) {
        [self skipMovie:[[m value] intValue]];
        [self sendSync];
        return;
    }
    
    //STOP MOVIE
	if ([a isEqualToString: @"/stopmovie"]) {
		gostop = YES;
        return;
    }
    
    //PAUSE
    if ([a isEqualToString: @"/pause"]) {
        gopause = YES;
        paused = YES;
        return;
    }
    
    //UNPAUSE
    if ([a isEqualToString: @"/unpause"]) {
        gopause = YES;
        paused = NO;
        return;
    }
    
    //MUTE
    if ([a isEqualToString: @"/mute"]) {
		muted = YES;
        gomute = YES;
        return;
    }
    
    //UNMUTE
    if ([a isEqualToString: @"/unmute"]) {
		muted = NO;
        gomute = YES;
        return;
    }
    
    //FADE to color (RGBA 8bit)
    if ([a isEqualToString: @"/fade"]) {
        fadecolorRed = [[m valueAtIndex:0] intValue];
        fadecolorGreen = [[m valueAtIndex:1] intValue];
        fadecolorBlue = [[m valueAtIndex:2] intValue];
        fadecolorAlpha = 255;
        if ([m valueAtIndex:3] != NULL) 
            fadecolorAlpha = [[m valueAtIndex:3] intValue];
        
        faded = YES;
        gofade = YES;
        return;
    }
    
    //UNFADE
    if ([a isEqualToString: @"/unfade"]) {
        faded = NO;
        gofade = YES;
        return;
    }
    
    //FADE to color (RGBA 8bit)
    if ([a isEqualToString: @"/flash"]) {
        if ([m valueAtIndex:2] != NULL) 
        {    
            flashcolorRed = [[m valueAtIndex:0] intValue];
            flashcolorGreen = [[m valueAtIndex:1] intValue];
            flashcolorBlue = [[m valueAtIndex:2] intValue];
            flashcolorAlpha = 255;
            if ([m valueAtIndex:3] != NULL) 
                flashcolorAlpha = [[m valueAtIndex:3] intValue];
        }
        else {
            flashcolorRed = 255;
            flashcolorGreen = 255;
            flashcolorBlue = 255;
            flashcolorAlpha = 255;
        }
        
        goflash = YES;
        return;
    }
    
    //ADD TEXT
    if ([a isEqualToString: @"/titles"]) {
        self.customTitles = [[[m value ] stringValue]copy];
        gotitles=YES;
        return;
    }
    
    //CHANGE TEXT COLOR
    if ([a isEqualToString: @"/titlescolor"]) {
        if ([m valueAtIndex:2] != NULL) 
        {    
            titlescolorRed = [[m valueAtIndex:0] intValue];
            titlescolorGreen = [[m valueAtIndex:1] intValue];
            titlescolorBlue = [[m valueAtIndex:2] intValue];
            titlescolorAlpha = 255;
            if ([m valueAtIndex:3] != NULL) 
                titlescolorAlpha = [[m valueAtIndex:3] intValue];
        }
        else {
            titlescolorRed = 0;
            titlescolorGreen = 0;
            titlescolorBlue = 0;
            titlescolorAlpha = 1;
        }
        return;
    }
    
    //DISPLAY MESSAGE
    if ([a isEqualToString: @"/message"]) {
        self.message= [[[m value ] stringValue]copy];
        gomessage=YES;
        return;
    }
    
    //UNKNOW ORDER
    OSCMessage *newMsg = [OSCMessage createWithAddress:@"/problem"];
    [newMsg addString:@"bad request : "];
    [newMsg addString:a];
    [outPort sendThisMessage:newMsg];
}


//###########################################################
//WORKERS TIMER

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
    
    //UPDATE MOVIE SCROLLER
    if (!createPlayer) {
        if(!userViewController.timeSlider.touchInside){
            userViewController.timeSlider.maximumValue=(CGFloat)[moviePlayer duration];
            userViewController.timeSlider.value = (CGFloat)[moviePlayer currentPlaybackTime];
        }
        else [moviePlayer setCurrentPlaybackTime:(double)userViewController.timeSlider.value];
    }
	
	//STOP VIDEO IF NO SCREEN
	if (screenState == @"noscreen") [self stopMovie];
	
    //RE LAUNCH VIDEO IF PAUSED (debug streaming)
    //TODO, check player state to know if it is usefull..
    //TODO ADD Observer !
    //if (streamingMode) [self.moviePlayer play];  
    
    //SCHEDULED ORDERS
    //play movie
	if (gomovie) {
        if (useAVF) [self playMovieAVF];
        else [self playMovie];		
        [self sendSync];	
        gostop=NO;
		gomovie=NO;
	}
    
    //stop movie
	if (gostop) {
        [self stopMovie];
		[self sendSync];
        gostop=NO;
	}
    //pause
    if (gopause) {
        [self pauseMovie];
        [self sendSync];
        gopause=NO;
    }
    //mute
    if (gomute) {
		[self muteMovie:muted];
        [self sendSync];
        gomute=NO;
    }
    //fade / unfade to color
    if (gofade) {
		[self fadeMovie:faded];
        [self sendSync];
        gofade=NO;
    }
    //white flash
    if (goflash) {
        [self flashMovie];
        goflash=NO;
    }
    
    //titles : add text
    if (gotitles) {
        //suppress all titlesview subviews (sinon les titrages s'empilent)
        //for (UIView *titlesview in [self.titlesview subviews]) { [titlesview removeFromSuperview]; }
        for (UIView *tview in [self.titlesview subviews]) { [tview removeFromSuperview]; }
        
        float r = (float)titlescolorRed/255;
        float g = (float)titlescolorGreen/255;
        float b = (float)titlescolorBlue/255;
        float a = (float)titlescolorAlpha/255;
        
        
        CGSize stringSize = [customTitles sizeWithFont:[UIFont systemFontOfSize:80]]; 
        CGRect labelSize = CGRectMake((_secondWindow.screen.bounds.size.width - stringSize.width) / 2.0,
                                      (_secondWindow.screen.bounds.size.height - stringSize.height),
                                      stringSize.width, stringSize.height);
        
        UILabel* soustitres = [[UILabel alloc] initWithFrame:labelSize];
        //soustitres.textColor = [UIColor whiteColor];
        soustitres.textColor = [UIColor colorWithRed:r green:g blue:b alpha:a];
        soustitres.backgroundColor = [UIColor clearColor];
        soustitres.text = customTitles;
        soustitres.font = [UIFont systemFontOfSize:80];
        [self.titlesview addSubview:soustitres];
        gotitles=NO;
    }
    
    //message
    if (gomessage) {
        [userViewController setMessage:message];
        gomessage=NO;
    }
    
    //UPDATE PLAYER STATE
    
    if (paused) playerState = @"paused";
    else if (faded) playerState = @"faded";
    else if ([self isPlaying]) 
    {
        if (muted) playerState = @"muted";
        else if (mired) playerState = @"mired";
        else if(streamingMode) playerState = @"streaming";
        else playerState = @"playing";
    }
    else {
        playerState = @"waiting";
    }
    
    //UPDATE DISPLAY STATE
    [self infoState:playerState];
    [userViewController setMovieTitle:remotemoviename];
    
    //Player release counter
    if (releasePlayer > 0) {
        if (releasePlayer == 1) {
            if (usePlayer1) player1view.layer.sublayers = nil;
            else player2view.layer.sublayers = nil;
        }   
        releasePlayer--;
    }
}

//###########################################################
// MOVIE PLAYER CONTROLS

//PLAY
-(void) playMovie{
    NSURL *mymovieURL;
    
    if(streamingMode) mymovieURL = [NSURL URLWithString:self.remotemoviename];
    else mymovieURL = [NSURL fileURLWithPath:self.remotemoviepath];
    
    //if player already exist
    if (!createPlayer) {
        //if same movie just fast reward
        if (([movieLast isEqualToString:self.remotemoviepath]) && ([self isPlaying])) [self skipMovie:0];
        //else change movie url
        else {
            self.moviePlayer.contentURL = mymovieURL;
            [self.moviePlayer play];
        }
    }
    
    //first movie : create player
    else {     
        MPMoviePlayerController *mp = [[MPMoviePlayerController alloc] initWithContentURL:mymovieURL];
        mp.movieSourceType = MPMovieSourceTypeFile;
        playerState = @"loading movie";
        if (mp) {
            //init player
            [mp prepareToPlay];
            mp.controlStyle = MPMovieControlStyleNone;
            mp.repeatMode = MPMovieRepeatModeOne;
        
            //set player on second screen
            [[mp view] setFrame: [_secondWindow bounds]];
            [_secondWindow insertSubview:[mp view] belowSubview:player1view];
        
            // Play the movie!
            [self stopMovie];  //stop previous
            self.moviePlayer = mp; //attach new player
            [self.moviePlayer play]; //play
        
            //add observers
            [self installMovieNotificationObservers];
            createPlayer = NO;
        
            //keep mute state
            [self muteMovie:muted];
            
            //hide mire
            [self mirMovie:NO];
        
            //init slider
            userViewController.timeSlider.continuous=NO;
            userViewController.timeSlider.minimumValue=0.0;
        }
    }
    
    [movieLast release];
    movieLast = [remotemoviepath mutableCopy];
    
    [self infoMovie:remotemoviename];
    paused = NO;
}

//PLAY with AVFoundation Player
-(void) playMovieAVF{
    NSURL *movieURL;
    
    //URL
    if(streamingMode) movieURL = [NSURL URLWithString:self.remotemoviename];
    else movieURL = [NSURL fileURLWithPath:self.remotemoviepath];
    
    //if same movie just rewind
    if (([movieLast isEqualToString:self.remotemoviepath]) && ([self isPlaying])) [self skipMovie:0];
    else {        
        //create players
        self.playerAVF = [AVPlayer playerWithURL:movieURL];
        [playerAVF addObserver:self forKeyPath:@"status" options:0 context:nil];
        
        createPlayer = NO;
        [self muteMovie:muted];
        [self mirMovie:NO];
        
        userViewController.timeSlider.continuous=NO;
        userViewController.timeSlider.minimumValue=0.0;
    }
    
    [movieLast release];
    movieLast = [remotemoviepath mutableCopy];
    
    [self infoMovie:remotemoviename];
    paused = NO;
}

//IS PLAYING
-(BOOL) isPlaying{
    if (useAVF) {
        if (usePlayer1) return (player2view.layer.sublayers != nil);
        else return (player1view.layer.sublayers != nil);
    }
    else return (self.moviePlayer.playbackState == MPMoviePlaybackStatePlaying);
}


//STOP
-(void) stopMovie{
    if (useAVF) {
        player1view.layer.sublayers = nil;
        player2view.layer.sublayers = nil;
    }
    else {
        if(!createPlayer)
        {
            [self.moviePlayer stop];
            [self removeMovieNotificationHandlers];
            [self.moviePlayer release];
            createPlayer = YES;
        }
    }
    
    //show mire
    [self mirMovie:YES];
    paused = NO;
    [self infoMovie:@""];
}

//PAUSE
-(void) pauseMovie{
    if (useAVF) {
        if ([self isPlaying] && paused) [self.playerAVF pause];
        else if (!paused) [self.playerAVF play];
    }
    else {
        if ([self isPlaying] && paused) [self.moviePlayer pause];
        else if (!paused) [self.moviePlayer play];
    }
}

//SKIP
-(void) skipMovie:(int) playbacktimeWanted{
    if (useAVF) {
        //TODO : tolerance 0 pour le seekToTime
        if ( CMTimeGetSeconds(playerAVF.currentItem.duration) > playbacktimeWanted) 
                [playerAVF seekToTime:CMTimeMake(playbacktimeWanted, 1)];
        else gostop=YES; 
    }
    else {
        if ((int)[moviePlayer duration]>playbacktimeWanted) 
            [moviePlayer setCurrentPlaybackTime:(double)playbacktimeWanted];
        else gostop=YES;
    }
}

//MUTE
-(void) muteMovie:(BOOL)muteMe{
    
    if (muteMe) muteview.alpha = 1;
    else muteview.alpha = 0;
    
    muted = muteMe;
}

//MIR
-(void) mirMovie:(BOOL)mirDisp{
    
    if (mirDisp) mirview.alpha = 1;
    else mirview.alpha = 0;
    
    mired = mirDisp;
}

//FADE
-(void) fadeMovie:(BOOL)fadeMe{
    
    if(fadeMe){
        float r = (float)fadecolorRed/255;
        float g = (float)fadecolorGreen/255;
        float b = (float)fadecolorBlue/255;
        float a = (float)fadecolorAlpha/255;        
        
        self.fadeview.backgroundColor=[UIColor colorWithRed:r green:g blue:b alpha:a];
        [UIView beginAnimations:@"fade" context:NULL];
        [UIView setAnimationDuration:1.5];
        self.fadeview.alpha=a;
        [UIView commitAnimations];
        faded=YES;
    }else{
        [UIView beginAnimations:@"unfade" context:NULL];
        [UIView setAnimationDuration:1.5];
        self.fadeview.alpha=0;
        [UIView commitAnimations];
        faded=NO;
    }
}

//FLASH
-(void) flashMovie{
    float r = (float)flashcolorRed/255;
    float g = (float)flashcolorGreen/255;
    float b = (float)flashcolorBlue/255;
    float a = (float)flashcolorAlpha/255;
    self.flashview.backgroundColor = [UIColor colorWithRed:r green:g blue:b alpha:1];
    
    self.flashview.alpha=a;
    [UIView beginAnimations:@"flash" context:NULL];
    [UIView setAnimationDuration:0.35];
    self.flashview.alpha=0;
    [UIView commitAnimations];
}

//###########################################################
// PLAYER UTILITIES

-(void) initGoMovieWithName:(NSString*)n:(BOOL)go {
    if ([n length]>=1){
        
        self.remotemoviename = n;
        
        //Streaming URL
        if (streamingMode) self.remotemoviepath = self.remotemoviename;
        //Local File     
        else {
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
            }else userViewController.backButton.hidden=YES;
        }
    }
    
    gomovie = go;
}
	
-(void) disableStreaming{
    streamingMode = NO;
}

-(void) enableGoMovie{
    gomovie = YES;
}

//###########################################################
//FILES MANAGER

//MEDIA list
- (NSArray *)listMedia{
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
    NSArray *mediaList = [dirContents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"pathExtension IN %@", extensions]];
    
    return mediaList;
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
			
            //select external Screen
            UIScreen*    secondScreen = [[UIScreen screens] objectAtIndex:1];
			
            //create WINDOW (full sized for second screen)	
			_secondWindow = [[UIWindow alloc] initWithFrame:secondScreen.bounds];
			
            //attach WINDOW to external screen
                _secondWindow.screen = secondScreen;
			
                // Add a black background to the window		
                UIView* backField = [[UIView alloc] initWithFrame:secondScreen.bounds];
                backField.backgroundColor = [UIColor blackColor];			
                [_secondWindow addSubview:backField];
                [backField release];
            
            //Create Masks (playerview)
                playerview = [[UIView alloc] initWithFrame:secondScreen.bounds];
                playerview.backgroundColor = [UIColor clearColor];
                playerview.alpha=1;
                [_secondWindow addSubview:playerview];
            
                //Create PLAYER 1 view
                    player1view = [[UIView alloc] initWithFrame:secondScreen.bounds];
                    player1view.backgroundColor = [UIColor clearColor];
                    player1view.alpha=1;
                    [playerview addSubview:player1view];
            
                //Create PLAYER 2 view
                    player2view = [[UIView alloc] initWithFrame:secondScreen.bounds];
                    player2view.backgroundColor = [UIColor clearColor];
                    player2view.alpha=1;
                    [playerview addSubview:player2view];
            
            
            //Create Masks (fadeview)
                fadeview = [[UIView alloc] initWithFrame:secondScreen.bounds];
                fadeview.backgroundColor = [UIColor blackColor];
                fadeview.alpha=0;
                [_secondWindow addSubview:fadeview];
            
            //Create Masks (titlesview)
                titlesview = [[UIView alloc] initWithFrame:secondScreen.bounds];
                titlesview.backgroundColor = [UIColor clearColor];
                titlesview.alpha=1;
                [_secondWindow addSubview:titlesview];
            
            //Create Masks (muteview)
                muteview = [[UIView alloc] initWithFrame:secondScreen.bounds];
                muteview.backgroundColor = [UIColor blackColor];
                muteview.alpha=0;
                [_secondWindow addSubview:muteview];
            
            //Create Masks (mirview)
                mirview = [[UIView alloc] initWithFrame:secondScreen.bounds];
                mirview.backgroundColor = [UIColor blackColor];
                mirview.alpha=1;
                [_secondWindow addSubview:mirview];
            
                // Center a label in the view.
                NSString*    noContentString = [NSString stringWithFormat:@" "];
                CGSize        stringSize = [noContentString sizeWithFont:[UIFont systemFontOfSize:18]];
                CGRect        labelSize = CGRectMake((secondScreen.bounds.size.width - stringSize.width) / 2.0,
												 (secondScreen.bounds.size.height - stringSize.height) / 2.0,
												 stringSize.width, stringSize.height);
                UILabel*    noContentLabel = [[UILabel alloc] initWithFrame:labelSize];
                noContentLabel.text = noContentString;
                noContentLabel.font = [UIFont systemFontOfSize:18];
                [mirview addSubview:noContentLabel];
            
            //Create Masks (flashview)
                flashview = [[UIView alloc] initWithFrame:secondScreen.bounds];
                flashview.backgroundColor = [UIColor blackColor];
                flashview.alpha=0;
                [_secondWindow addSubview:flashview];
			
			// Go ahead and show the window.
			_secondWindow.hidden = NO;
            [viewController setInfoscreenText: [NSString stringWithFormat: @"second screen %.0f x %.0f",secondScreen.bounds.size.width,secondScreen.bounds.size.height]];
			screenState = [NSString stringWithFormat: @"%.0f x %.0f",secondScreen.bounds.size.width,secondScreen.bounds.size.height];
			playerState = @"ready";
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
    //if(![userViewController isMute]){
        //[userViewController muting:self];
        //[userViewController setMuteButtonColor:[UIColor grayColor]];
    //    stopmovie=YES;
    //}
    [userViewController setMuteButtonColor:[UIColor grayColor]];
}

-(void)removeMovieNotificationHandlers {    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:moviePlayer];
}


//observer manager (AVPlayer,...)
- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context
{
    //AVF Player Statuts OBSERVER
    if (object == playerAVF && [keyPath isEqualToString:@"status"]) {
        if (playerAVF.status == AVPlayerStatusReadyToPlay) {
            
            layerAVF = [AVPlayerLayer playerLayerWithPlayer:playerAVF];
            layerAVF.frame = player1view.layer.bounds;
            
            if (usePlayer1) {
                //push view 1 on back
                [playerview sendSubviewToBack:player1view];
                
                //clear view 1
                player1view.layer.sublayers = nil;
                
                //attach PLAYER to view 1
                [player1view.layer addSublayer:layerAVF];
                
                //next will be player 2
                usePlayer1 = NO;
            }
            else {
                //push view 2 on back
                [playerview sendSubviewToBack:player2view];
                
                //clear view 2
                player2view.layer.sublayers = nil;
                
                //attach PLAYER to view 2
                [player2view.layer addSublayer:layerAVF];
                
                //next will be player 2
                usePlayer1 = YES;
            }
            
            //start Player
            [playerAVF play];
            
            //send last initialized view to front
            if (usePlayer1) {
                [playerview sendSubviewToBack:player1view];
            }
            else {
                [playerview sendSubviewToBack:player2view];
            }
            
            releasePlayer = 10;
        }
    }
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
