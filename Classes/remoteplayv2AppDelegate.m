//
//  remoteplayv2AppDelegate.m
//  remoteplayv2
//
//  Created by Pierre Hoezelle, Thomas Bohl, Jeremie Forge
//  Copyright 2011 KXKM. Creative Commons BY-NC-SA.
//

//TCP
#define WELCOME_MSG  0
#define ECHO_MSG     1
#define WARNING_MSG  2

#define READ_TIMEOUT 5.0

//PLAYERS
#define LOCAL_MODE      0
#define STREAM_MODE     1
#define LIVE_MODE       2

#define RELEASE_TIME    2


#define FORMAT(format, ...) [NSString stringWithFormat:(format), ##__VA_ARGS__]

#import "remoteplayv2AppDelegate.h"
#import "remoteplayv2ViewController.h"
#import "remoteplayv2TableViewController.h"
#import "remoteplayv2UserViewController.h"

@implementation remoteplayv2AppDelegate

@synthesize window;
@synthesize _secondWindow, layerAVF;
@synthesize playerview, player1view, player2view, player3view, muteview, fadeview, flashview, titlesview, mirview;
@synthesize tabBarController;
@synthesize moviePlayer,playerAVF,playerAVF1,playerAVF2,playerAVF3;
@synthesize manager,outPort;
@synthesize timermouvement,timerchecker;
@synthesize remotemoviepath,pathformovie;
@synthesize remotemoviename,screenstate,playerstate,message,customTitles,movieLast;
@synthesize rcvCommand,gomovie,gopause,gostop,gomute,gofade,goflash,gomessage,gotitles;
@synthesize muted,faded,paused,mired;
@synthesize sourceMode,createPlayer,firstStart,useAVF,useTCP,usePlayer,releasePlayer1,releasePlayer2,releasePlayer3;
@synthesize fadecolorRed,fadecolorGreen,fadecolorBlue;


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
        NSString *portServerValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"osc_port_server_key"];
        outPort = [manager createNewOutputToAddress:ipServerValue atPort:[portServerValue intValue]];
    
    //TCP Communication
        //TCP open Server & Listen Port (UDP fallback if failed)
        useTCP = [self openTCP:1333];
    
    //APP Info and States
        //initiatisations ordres
        gomovie = NO;
        gostop = NO;
        createPlayer = YES;
        useAVF = YES;
        usePlayer = 1;
        releasePlayer1 = 0;
        releasePlayer2 = 0;
        releasePlayer3 = 0;
        firstStart = YES;
        
        //initiatisations états
        playerMode = @"auto"; 
        playerState = @"starting";
        screenState = @"noscreen";
        remotemoviename = @"";
        muted = NO;
        faded = NO;
        paused = NO;
        mired = YES;
    
        [self titlesColor:255:255:255:255];
        [self flashColor:255:255:255:255];
        [self fadeColor:255:255:255:255];
        
        //display info
        [viewController setInfoscreenText: @"Warning no second screen"];
        [viewController setInfoipText: [@"IP : " stringByAppendingString: [self getIPAddress]]];
    
	
    //APP init       
        //list media
        tableViewController.moviesList = [[self listMedia] copy];
        [tableViewController.moviesTable reloadData];
    
        //set up the timer
        [self topDepartMouvement: timermouvement];
        [self topDepartChecker: timerchecker];
    
	//end of startup
    return YES;
}

//###########################################################
// COMMUNICATION
//OSC tools OSC FROM STRING
-(OSCMessage*)oscWithString:(NSString*)msg{
    NSArray *words = [msg componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    OSCMessage *oscmsg = [OSCMessage createWithAddress:[@"/" stringByAppendingString: myName]];
    for (int y = 0; y < [words count]; y++) [oscmsg addString:[words objectAtIndex:y]];
    return oscmsg;
}

//Say ALLO
-(void) sayAllo{
    NSString* msg = @"allo";
    [outPort sendThisMessage:[self oscWithString:msg]];
}

//Info message : IP, media list
-(void)sendInfo{
    
    NSString *msg = @"initinfo ";
    msg = [msg stringByAppendingString:[self getIPAddress]];
    
    if (useTCP) [self sendTCP:msg];
    else [outPort sendThisMessage:[self oscWithString:msg]];
    
    NSArray * mediaList = [self listMedia];
    
    if (useTCP) {
        NSString *filesmsg = @"fileinfo";
        for (NSString *movies in mediaList) {
            filesmsg = [filesmsg stringByAppendingString:@" "];
            filesmsg = [filesmsg stringByAppendingString:movies];
        }
        [self sendTCP:filesmsg];
    }
    else 
        for (NSString *movies in mediaList) 
                [self sendTCP:[@"fileinfo " stringByAppendingString:movies]];
    
}

	
//Sync message : send player state message
-(void)sendSync{
    
    //Player Mode : Auto, Manu, Streaming, ... 
    NSString* msg = playerMode;
    
    //Player State : waiting, playing,
    msg = [msg stringByAppendingString:@" "];
    msg = [msg stringByAppendingString:playerState];
    
    //TODO construct detailed state message 
    //TODO construct detailed state message
    //TODO construct detailed state message
    
    //msg = [msg stringByAppendingString:[NSString stringWithFormat:@" %i",[moviePlayer currentPlaybackTime]]];
    //msg = [msg stringByAppendingString:[NSString stringWithFormat:@" %i",[userViewController isMute]]];
    
    if (useTCP) [self sendTCP:msg];
    else [outPort sendThisMessage:[self oscWithString:msg]];
}

//send SOS
-(void) sendSOS {    
    NSString* msg = @"SOS";
    
    if (useTCP) [self sendTCP:msg];
    else [outPort sendThisMessage:[self oscWithString:msg]];
}

//send ERROR
-(void) sendError:(NSString*)m {    
    NSString* msg = [@"error " stringByAppendingString:m];
    
    if (useTCP) [self sendTCP:msg];
    else [outPort sendThisMessage:[self oscWithString:msg]];
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
// TCP COMM

// TCP Sock : Create Server and open Socket
- (BOOL) openTCP:(int)TCPListenPort {
    
    //TCP SERVER (wait for call and answer it)
    socketQueue = dispatch_queue_create("socketQueue", NULL);
    listenSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:socketQueue];
    
    // Setup an array to store all accepted client connections
    connectedSockets = [[NSMutableArray alloc] initWithCapacity:1];
     
    NSError *error = nil;
    if([listenSocket acceptOnPort:TCPListenPort error:&error]) return YES;
    else return NO;
}

// TCP Sock : Connection asked by new client
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
	@synchronized(connectedSockets)
	{
		[connectedSockets addObject:newSocket];
	}
	
	NSString *welcomeMsg = [@"KXKM TCP Server on " stringByAppendingString:myName];
	NSData *welcomeData = [welcomeMsg dataUsingEncoding:NSUTF8StringEncoding];
	
	[newSocket writeData:welcomeData withTimeout:-1 tag:WELCOME_MSG];
	[newSocket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:READ_TIMEOUT tag:0];
    
    if (firstStart) [self sendInfo];
    firstStart = NO;
}

// TCP Sock : CLIENT connection TERMINATED
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
	if (sock != listenSocket)
	{		
		@synchronized(connectedSockets)
		{
			[connectedSockets removeObject:sock];
		}
	}
}

//TCP Sock : write a message on all available client socket
- (void) sendTCP: (NSString *) m {
    
    NSString *msg = [@"/" stringByAppendingString: myName];
    msg = [msg stringByAppendingString:@" "];
    msg = [msg stringByAppendingString:m];
    msg = [msg stringByAppendingString:@"\r\n"];
    NSData *data = [msg dataUsingEncoding:NSUTF8StringEncoding];
    
    if ([connectedSockets count] > 0)
        for (GCDAsyncSocket *sock in connectedSockets) 
                [sock writeData:data withTimeout:-1 tag:1];
}


// TCP Sock :  A message has been recieved from the client
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
	dispatch_async(dispatch_get_main_queue(), ^{
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        
        //get data and remove \r\n
		NSData *strData = [data subdataWithRange:NSMakeRange(0, [data length] - 2)];
		//convert data into NSString
        NSString *msg = [[[NSString alloc] initWithData:strData encoding:NSUTF8StringEncoding] autorelease];
		if (msg) 
		{
            //pass the Message to the runner
            rcvCommand = msg;
            [self runMessage];
        }
		[pool release];
	});
	    
    //restart reader
    [sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:READ_TIMEOUT tag:0];
}


//###########################################################
// OSC RECEIVER

- (void) receivedOSCMessage: (OSCMessage *) m {
    rcvCommand = [m address];
    
    for (int y = 0; y < 10 ; y++) 
            if ([m valueAtIndex:y] != NULL) 
                rcvCommand = [rcvCommand stringByAppendingString:[[m valueAtIndex:y] stringValue]];
    
    [self runMessage];
}

//treat Message when received
- (void) runMessage {
    //NSLog(rcvCommand);
    NSArray *pieces = [rcvCommand componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *command = [pieces objectAtIndex:0];
    
    NSMutableArray *orders = [NSMutableArray arrayWithArray: pieces];
    [orders removeObjectAtIndex:0];
    
    //SWITCH COMMUNICATION METHOD
	if ([command isEqualToString: @"/usetcp"]) {
        useTCP = YES;
        return;
	}
    
    //SWITCH COMMUNICATION METHOD
	if ([command isEqualToString: @"/useudp"]) {
        useTCP = NO;
        return;
	}
    
    //SYNC : mode, state, args (movie, time, ...)
	if ([command isEqualToString: @"/synctest"]) {
        [self sendSync];
        return;
	}
    
    //INIT INFO : ip, media list
	if ([command isEqualToString: @"/fullsynctest"]) {
		[self sendInfo];
        return;
	}
    
    //LOAD & PLAY MOVIE
	if (([command isEqualToString: @"/loadmovie"]) || ([command isEqualToString: @"/playmovie"])) {
        sourceMode = LOCAL_MODE;
        useAVF = NO;
        [self initGoMovieWithName : [[orders componentsJoinedByString:@" "] copy] : [command isEqualToString: @"/playmovie"]];
        return;
    }
    
    //LOAD & PLAY STREAM
	if (([command isEqualToString: @"/loadstream"]) || ([command isEqualToString: @"/playstream"])) {
		sourceMode = STREAM_MODE;
        useAVF = NO;
        [self initGoMovieWithName : [[orders componentsJoinedByString:@" "] copy] : [command isEqualToString: @"/playstream"]];
        return;
    }
    
    //PLAY MOVIE AVF
	if ([command isEqualToString: @"/playmovieAVF"]) {
        sourceMode = LOCAL_MODE;
        useAVF = YES;
        [self initGoMovieWithName : [[orders componentsJoinedByString:@" "] copy] : YES];
        return;
    }
    
    //PLAY STREAM AVF
	if ([command isEqualToString: @"/playstreamAVF"]) {
		sourceMode = STREAM_MODE;
        useAVF = YES;
        [self initGoMovieWithName : [[orders componentsJoinedByString:@" "] copy] : YES];
        return;
    }
    
    //PLAY LIVE AVF
	if ([command isEqualToString: @"/playlive"]) {
		useAVF = YES;
        if (sourceMode != LIVE_MODE) {
            sourceMode = LIVE_MODE;
            [self stopMovie];
        }
        [self initGoMovieWithName : [[orders componentsJoinedByString:@" "] copy] : YES];
        return;
    }
    
    //SKIP AT TIME
	if ([command isEqualToString: @"/attime"]) {
        if ([orders count] >= 1) {
            [self skipMovie:[[orders objectAtIndex:0] intValue]];
            [self sendSync];
        }
        return;
    }
    
    //STOP MOVIE
	if ([command isEqualToString: @"/stopmovie"]) {
		gostop = YES;
        return;
    }
    
    //PAUSE
    if ([command isEqualToString: @"/pause"]) {
        paused = YES;
        gopause = YES;
        return;
    }
    
    //UNPAUSE
    if ([command isEqualToString: @"/unpause"]) {
        paused = NO;
        gopause = YES;
        return;
    }
    
    //MUTE
    if ([command isEqualToString: @"/mute"]) {
		muted = YES;
        gomute = YES;
        return;
    }
    
    //UNMUTE
    if ([command isEqualToString: @"/unmute"]) {
		muted = NO;
        gomute = YES;
        return;
    }
    
    //FADE to color (RGBA 8bit)
    if ([command isEqualToString: @"/fade"]) {
        
        //set color
        if ([orders count] >= 4)  
            [self fadeColor:[[orders objectAtIndex:0] intValue] :[[orders objectAtIndex:1] intValue] :[[orders objectAtIndex:2] intValue] :[[orders objectAtIndex:3] intValue]];
        
        else if ([orders count] >= 3)  
            [self fadeColor:[[orders objectAtIndex:0] intValue] :[[orders objectAtIndex:1] intValue] :[[orders objectAtIndex:2] intValue] :255];
        
        else [self fadeColor:255:255:255:255];
        
        faded = YES;
        gofade = YES;
        return;
    }
    
    //UNFADE
    if ([command isEqualToString: @"/unfade"]) {
        faded = NO;
        gofade = YES;
        return;
    }
    
    //FADE to color (RGBA 8bit)
    if ([command isEqualToString: @"/flash"]) {
        //set color
        if ([orders count] >= 4)  
            [self flashColor:[[orders objectAtIndex:0] intValue] :[[orders objectAtIndex:1] intValue] :[[orders objectAtIndex:2] intValue] :[[orders objectAtIndex:3] intValue]];
        
        else if ([orders count] >= 3)  
            [self flashColor:[[orders objectAtIndex:0] intValue] :[[orders objectAtIndex:1] intValue] :[[orders objectAtIndex:2] intValue] : 255];
        
        else [self flashColor:255:255:255:255];
        
        goflash = YES;
        return;
    }
    
    //ADD TEXT
    if ([command isEqualToString: @"/titles"]) {
        customTitles = [[orders componentsJoinedByString:@" "] copy];
        gotitles=YES;
        return;
    }
    
    //CHANGE TEXT COLOR
    if ([command isEqualToString: @"/titlescolor"]) {
        
        //set color
        if ([orders count] >= 4)  
            [self titlesColor:[[orders objectAtIndex:0] intValue] :[[orders objectAtIndex:1] intValue] :[[orders objectAtIndex:2] intValue] :[[orders objectAtIndex:3] intValue]];
        
        else if ([orders count] >= 3)  
            [self titlesColor:[[orders objectAtIndex:0] intValue] :[[orders objectAtIndex:1] intValue] :[[orders objectAtIndex:2] intValue] : 255];
        
        else [self titlesColor:255:255:255:255];
        
        return;
    }
    
    //DISPLAY MESSAGE
    if ([command isEqualToString: @"/message"]) {
        self.message= [[orders componentsJoinedByString:@" "] copy];
        gomessage=YES;
        return;
    }
    
    //UNKNOW ORDER
    [self sendError:command];
}


//###########################################################
//WORKERS TIMER

//lancer le timer de commande
-(void)topDepartMouvement: (NSTimer*)timer{
	timer = [NSTimer scheduledTimerWithTimeInterval:0.01 //10ms
											 target:self 
										   selector:@selector(topHorloge) 
										   userInfo:nil 
											repeats:YES];
	timermouvement = timer;
}


- (void)topHorloge{
    
    //don't execute video related order if no screen 
    if (screenState != @"noscreen") {
        
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
            //TODO check if it is still working !
            for (UIView *titlesview in [self.titlesview subviews]) { [titlesview removeFromSuperview]; }
            //for (UIView *tview in [self.titlesview subviews]) { [tview removeFromSuperview]; }
        
            float r = (float)titlescolorRed/255;
            float g = (float)titlescolorGreen/255;
            float b = (float)titlescolorBlue/255;
            float a = (float)titlescolorAlpha/255;
        
        
            CGSize stringSize = [customTitles sizeWithFont:[UIFont systemFontOfSize:80]]; 
            CGRect labelSize = CGRectMake((_secondWindow.screen.bounds.size.width - stringSize.width) / 2.0,
                                      (_secondWindow.screen.bounds.size.height - stringSize.height),
                                      stringSize.width, stringSize.height);
        
            UILabel* soustitres = [[UILabel alloc] initWithFrame:labelSize];
            soustitres.textColor = [UIColor colorWithRed:r green:g blue:b alpha:a];
            soustitres.backgroundColor = [UIColor clearColor];
            soustitres.text = customTitles;
            soustitres.font = [UIFont systemFontOfSize:80];
            [self.titlesview addSubview:soustitres];
            gotitles=NO;
        }
    }
    
    //message
    if (gomessage) {
        [userViewController setMessage:message];
        gomessage=NO;
    }
}

//lancer le timer de Check (screen, players, connection TCP)
-(void)topDepartChecker: (NSTimer*)timer{
	timer = [NSTimer scheduledTimerWithTimeInterval:0.2 //200ms
											 target:self 
										   selector:@selector(topChecker) 
										   userInfo:nil 
											repeats:YES];
	timerchecker = timer;
}

-(void)topChecker{
	
    //CHECK SCREEN
    [self checkScreen];
    if (screenState == @"noscreen") [self stopMovie];
    
    //CHECK REGIE TCP CONNECTION
    if (([connectedSockets count] == 0) && (useTCP)) [self sayAllo]; 
    
    //UPDATE MOVIE SCROLLER
    if ((useAVF) && ([self isPlaying])) {
        if(!userViewController.timeSlider.touchInside){
            userViewController.timeSlider.maximumValue=(CGFloat)CMTimeGetSeconds([[playerAVF currentItem] duration]);
            userViewController.timeSlider.value = (CGFloat)CMTimeGetSeconds([playerAVF currentTime]);
        }
        else [self skipMovie:(int)userViewController.timeSlider.value*1000];
    }
    else if (!createPlayer)  {
        if(!userViewController.timeSlider.touchInside){
                userViewController.timeSlider.maximumValue=(CGFloat)[moviePlayer duration];
                userViewController.timeSlider.value = (CGFloat)[moviePlayer currentPlaybackTime];
            }
        else [moviePlayer setCurrentPlaybackTime:(double)userViewController.timeSlider.value];
    }
     
    //RE LAUNCH VIDEO IF PAUSED (debug streaming)
    //TODO, check player state to know if it is usefull..
    //TODO ADD Observer !
    //if (streamingMode) [self.moviePlayer play]; 
    //if (sourceMode == LIVE_MODE) [playerAVF play]; 
     
    //UPDATE PLAYER STATE
    if (([connectedSockets count] == 0) && (useTCP)) playerState = @"no connection";
    else if (paused) playerState = @"paused";
    else if (faded) playerState = @"faded";
    else if ([self isPlaying]) 
    {
        if (muted) playerState = @"muted";
        else if (mired) playerState = @"mired";
        else if(sourceMode == STREAM_MODE) playerState = @"streaming";
        else if(sourceMode == LIVE_MODE) playerState = @"live";
        else playerState = @"playing";
    }
    else {
        playerState = @"waiting";
    }
    
    //UPDATE DISPLAY STATE
    [self infoState:playerState];
    [userViewController setMovieTitle:remotemoviename];
    
    //PLAYER RELEASE COUNTER
    if (releasePlayer1 > 0) {
        if (releasePlayer1 == 1) {
            player1view.layer.sublayers = nil;
            [self.playerAVF1 pause];
        }
        releasePlayer1--;
    }
    if (releasePlayer2 > 0) {
        if (releasePlayer2 == 1) {
            player2view.layer.sublayers = nil;
            [self.playerAVF2 pause];
        }
        releasePlayer2--;
    }
    if (releasePlayer3 > 0) {
        if (releasePlayer3 == 1) {
            player3view.layer.sublayers = nil;
            [self.playerAVF3 pause];
        } 
        releasePlayer3--;
    }

}

//###########################################################
// MOVIE PLAYER CONTROLS

//PLAY
-(void) playMovie{
    NSURL *mymovieURL;
    
    if(sourceMode == LOCAL_MODE) mymovieURL = [NSURL fileURLWithPath:self.remotemoviepath];
    else mymovieURL = [NSURL URLWithString:self.remotemoviename];
    
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
            [_secondWindow insertSubview:[mp view] belowSubview:playerview];
        
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
    if(sourceMode == LOCAL_MODE) movieURL = [NSURL fileURLWithPath:self.remotemoviepath];
    else movieURL = [NSURL URLWithString:self.remotemoviename];
    
    //if same movie just rewind
    if ((sourceMode != LIVE_MODE) && ([movieLast isEqualToString:self.remotemoviepath]) && ([self isPlaying])) [self skipMovie:0];
    else {        
        //create players
        if (usePlayer == 1) {
            self.playerAVF1 = [AVPlayer playerWithURL:movieURL];
            [playerAVF1 addObserver:self forKeyPath:@"status" options:0 context:nil];
            
            if (sourceMode == LIVE_MODE) {
                playerAVF = playerAVF3;
                [playerview bringSubviewToFront:player3view];
                [playerAVF play];
            }
        }
        else if (usePlayer == 2)  {
            self.playerAVF2 = [AVPlayer playerWithURL:movieURL];
            [playerAVF2 addObserver:self forKeyPath:@"status" options:0 context:nil];
            
            if (sourceMode == LIVE_MODE) {
                playerAVF = playerAVF1;
                [playerview bringSubviewToFront:player1view];
                [playerAVF play];
            }
        }
        else {
            self.playerAVF3 = [AVPlayer playerWithURL:movieURL];
            [playerAVF3 addObserver:self forKeyPath:@"status" options:0 context:nil];
            
            if (sourceMode == LIVE_MODE) {
                playerAVF = playerAVF2;
                [playerview bringSubviewToFront:player2view];
                [playerAVF play];
            }
        }
        
        //createPlayer = NO;
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
        if (usePlayer == 3) {
            if (sourceMode == LIVE_MODE) return (player1view.layer.sublayers != nil);
            else return (player2view.layer.sublayers != nil);
        }
        else if (usePlayer == 2) {
            if (sourceMode == LIVE_MODE) return (player3view.layer.sublayers != nil);
            else return (player1view.layer.sublayers != nil);
        }
        else {
            if (sourceMode == LIVE_MODE) return (player2view.layer.sublayers != nil);
            else return (player3view.layer.sublayers != nil);
        }
    }
    else return (self.moviePlayer.playbackState == MPMoviePlaybackStatePlaying);
}


//STOP
-(void) stopMovie{
    if (useAVF) {
        player1view.layer.sublayers = nil;
        player2view.layer.sublayers = nil;
        player3view.layer.sublayers = nil;
        [self.playerAVF1 pause];
        [self.playerAVF2 pause];
        [self.playerAVF3 pause];
        usePlayer = 1;
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
        if ( CMTimeGetSeconds(playerAVF.currentItem.duration) > (playbacktimeWanted/1000)) {
                [playerAVF seekToTime:CMTimeMake(playbacktimeWanted, 1000) toleranceBefore: kCMTimeZero toleranceAfter: kCMTimeZero];
                [playerAVF play];
        }
        else gostop=YES; 
    }
    else {
        double seekTime = playbacktimeWanted/1000;
        if ((int)[moviePlayer duration]>seekTime) {
            [moviePlayer setCurrentPlaybackTime:seekTime];
            [moviePlayer play];
        }
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

//FADE SET COLOR
-(void) fadeColor:(int)Red:(int)Green:(int)Blue:(int)Alpha{
    
    fadecolorRed = Red;
    fadecolorGreen = Green;
    fadecolorBlue = Blue;
    if (Alpha > 0) fadecolorAlpha = Alpha;
    else fadecolorAlpha = 255;
}

//FLASH SET COLOR
-(void) flashColor:(int)Red:(int)Green:(int)Blue:(int)Alpha{
    
    flashcolorRed = Red;
    flashcolorGreen = Green;
    flashcolorBlue = Blue;
    if (Alpha > 0) flashcolorAlpha = Alpha;
    else flashcolorAlpha = 255;
}

//TITLES SET COLOR
-(void) titlesColor:(int)Red:(int)Green:(int)Blue:(int)Alpha{
    
    titlescolorRed = Red;
    titlescolorGreen = Green;
    titlescolorBlue = Blue;
    if (Alpha > 0) titlescolorAlpha = Alpha;
    else titlescolorAlpha = 255;
}

//###########################################################
// PLAYER UTILITIES

-(void) initGoMovieWithName:(NSString*)n:(BOOL)go {
    if ([n length]>=1){
        
        self.remotemoviename = n;
        
        //Streaming URL
        if (sourceMode != LOCAL_MODE) self.remotemoviepath = self.remotemoviename;
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
    sourceMode = LOCAL_MODE;
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
            
                //Create PLAYER 3 view
                    player3view = [[UIView alloc] initWithFrame:secondScreen.bounds];
                    player3view.backgroundColor = [UIColor clearColor];
                    player3view.alpha=1;
                    [playerview addSubview:player3view];
            
            
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
	
    s = [@"debug " stringByAppendingString:s];
    
	if (useTCP) [self sendTCP:s];
    else [outPort sendThisMessage:[self oscWithString:s]];
}


//###########################################################
//notification for movie (MPMovie)

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
    if ([keyPath isEqualToString:@"status"] )
    {    
        if ((object == playerAVF1 && playerAVF1.status == AVPlayerStatusReadyToPlay) 
            || (object == playerAVF2 && playerAVF1.status == AVPlayerStatusReadyToPlay)
            || (object == playerAVF3 && playerAVF3.status == AVPlayerStatusReadyToPlay))
        {           
            layerAVF = [AVPlayerLayer playerLayerWithPlayer:object];
            layerAVF.frame = player1view.layer.bounds;
            
            if (object == playerAVF1)
            {
                [playerview sendSubviewToBack:player1view];
                player1view.layer.sublayers = nil;
                [player1view.layer addSublayer:layerAVF];
                
                if ((sourceMode == LOCAL_MODE) || (sourceMode == STREAM_MODE)) {
                    releasePlayer3 = RELEASE_TIME;
                    playerAVF = object;
                    //TODO ANIMATE ??
                    [playerview bringSubviewToFront:player1view];
                    [playerAVF play];
                }
            }
            
            else if (object == playerAVF2)
            {
                [playerview sendSubviewToBack:player2view];
                player2view.layer.sublayers = nil;
                [player2view.layer addSublayer:layerAVF];
                
                if ((sourceMode == LOCAL_MODE) || (sourceMode == STREAM_MODE)) {
                    releasePlayer1 = RELEASE_TIME;
                    playerAVF = object;
                    //TODO ANIMATE ??
                    [playerview bringSubviewToFront:player2view];
                    [playerAVF play];
                }
            }
            
            else if (object == playerAVF3)
            {
                [playerview sendSubviewToBack:player3view];
                player3view.layer.sublayers = nil;
                [player3view.layer addSublayer:layerAVF];
                
                if ((sourceMode == LOCAL_MODE) || (sourceMode == STREAM_MODE)) {
                    releasePlayer2 = RELEASE_TIME;
                    playerAVF = object;
                    //TODO ANIMATE ??
                    [playerview bringSubviewToFront:player3view];
                    [playerAVF play];
                }
            }
            
            
            //[playerAVF seekToTime:kCMTimeZero];
                
            //change next player
            usePlayer++;
            if (usePlayer > 3) usePlayer = 1;
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
