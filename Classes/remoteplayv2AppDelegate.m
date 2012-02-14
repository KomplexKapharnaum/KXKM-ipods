//
//  remoteplayv2AppDelegate.m
//  remoteplayv2
//
//  Created by Pierre Hoezelle, Thomas Bohl, Jeremie Forge
//  Copyright 2011 KXKM. Creative Commons BY-NC-SA.
//


#define TIME_CHECKER    0.2 //clock for cheker in seconds
//#define RELEASE_PLAYER  6   // multiply x TIME_CHECKER
//#define RELEASE_LIVE    20  // multiply x TIME_CHECKER //MUST BE HIGHER THAN SEGMENT PLAYED!

#define FORMAT(format, ...) [NSString stringWithFormat:(format), ##__VA_ARGS__]

#import "ConfigConst.h"
#import "remoteplayv2AppDelegate.h"
#import "remoteplayv2ViewController.h"
#import "remoteplayv2TableViewController.h"
#import "remoteplayv2UserViewController.h"
#include <sys/types.h>

@implementation remoteplayv2AppDelegate

@synthesize window,tabBarController;
@synthesize disPlay;
@synthesize comPort;
@synthesize runMachine;
@synthesize filesManager;
@synthesize moviePlayer;
@synthesize livePlayer;
@synthesize interFace;

@synthesize timerchecker;
@synthesize playerState,playerMode;


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
    
    //OBJECTS
        //DISPLAY 
        disPlay = [[DisplayClass alloc] init];
    
        //COMMUNICATION 
        comPort = [[ComClass alloc] init];
    
        //RUN MACHINE (Clock & Dispatch Orders) 
        runMachine = [[RunClass alloc] init];
    
        //FILES MANAGER
        filesManager = [[FilesClass alloc] init];
    
        //MOVIE PLAYER
        moviePlayer = [[MovieClass alloc] init];
    
        //MOVIE PLAYER
        livePlayer = [[LiveClass alloc] init];
    
        //INTERFACE CTRL
        interFace = [[InterfaceClass alloc] init];
    
    //APP Info and States
        
        //initiatisations états
        playerMode = @"auto"; 
        playerState = @"starting";
        
        //display info
        [viewController setInfoscreenText: @"No Screen"];
        [viewController setInfoipText: [@"IP : " stringByAppendingString: [comPort getIPAddress]]];
    
	
    //APP init       
        //list media
        tableViewController.moviesList = [[filesManager list] copy];
        [tableViewController.moviesTable reloadData];
    
        //set up the timer
        [runMachine start];
        [self topDepartChecker: timerchecker];
    
	//end of startup
    return YES;
}


//INFO (screen box info)
-(void) infoScreen:(NSString*)msg{
    [(remoteplayv2ViewController*)[ self.tabBarController.viewControllers objectAtIndex:0] setInfoscreenText:msg];
}

//INFO (state box info)
-(void) infoState:(NSString*)msg{
    [(remoteplayv2ViewController*)[ self.tabBarController.viewControllers objectAtIndex:0] setInfoText:msg];
}

//INFO (state box info)
-(void) infoMovie:(NSString*)msg{
    [(remoteplayv2ViewController*)[ self.tabBarController.viewControllers objectAtIndex:0] setInfoMovieText:msg];
}







//lancer le timer de Check (screen, players, connection TCP)
-(void)topDepartChecker: (NSTimer*)timer{
	timer = [NSTimer scheduledTimerWithTimeInterval:TIME_CHECKER
											 target:self 
										   selector:@selector(topChecker) 
										   userInfo:nil 
											repeats:YES];
	timerchecker = timer;
}

-(void)topChecker{
	
    //CHECK IF SCREEN CHANGED
    if ([disPlay checkScreen]) {
               
        if ([[disPlay resolution] isEqualToString: @"noscreen"]) {
            [moviePlayer stop];
            [self infoScreen: @"No Screen !"];
        }
        else [self infoScreen: [NSString stringWithFormat: @"Screen %@",[disPlay resolution]]];
        
        [comPort sendSync];    
    }
    
    //UPDATE CLOCK DISPLAY
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    [viewController setTimeText: [dateFormatter stringFromDate:[NSDate date]]];
    [dateFormatter release];
    
    //UPDATE MOVIE SCROLLER
    /* TODO UPDATE TIME
    if ([self isPlaying]) {
        if(!userViewController.timeSlider.touchInside){
            userViewController.timeSlider.maximumValue=(CGFloat)CMTimeGetSeconds([[playerMOVIE currentItem] duration]);
            userViewController.timeSlider.value = (CGFloat)CMTimeGetSeconds([playerMOVIE currentTime]);
        }
        else [self skipMovie:(int)userViewController.timeSlider.value*1000];
    }
    */
     
    //RE LAUNCH VIDEO IF PAUSED (debug streaming)
    //TODO, check player state to know if it is usefull..
    //TODO ADD Observer !
    //if (streamingMode) [self.moviePlayer play]; 
    //if (sourceMode == LIVE_MODE) [playerAVF play]; 
     
    //UPDATE PLAYER STATE
    /* TODO PLAYER STATE GENERATED BY MOVIE CLASS
    if (paused) playerState = @"paused";
    else if ([disPlay faded]) playerState = @"faded";
    else if ([self isPlaying]) 
    {
        if ([disPlay muted]) playerState = @"muted";
        else if ([disPlay mired]) playerState = @"mired";
        else if(sourceMode == STREAM_MODE) playerState = @"streaming";
        else if(sourceMode == LIVE_MODE) playerState = @"live";
        else {
            playerState = @"playing";
        }
    }
    else {
        playerState = @"waiting";
    }
    */
    
    //UPDATE DISPLAY STATE
    [self infoState:playerState];
    //[userViewController setMovieTitle:remotemoviename];

    
    //LIVE RELEASE COUNTER
    /*if (releasePlayer1 > 0) {
        if (releasePlayer1 == 1) {
            disPlay.player1view.layer.sublayers = nil;
            [self.playerAVF1 pause];
            [self player1End:nil];
        }
        releasePlayer1--;
    }
    if (releasePlayer2 > 0) {
        if (releasePlayer2 == 1) {
            disPlay.player2view.layer.sublayers = nil;
            [self.playerAVF2 pause];
            [self player2End:nil];
        }
        releasePlayer2--;
    }
    if (releasePlayer3 > 0) {
        if (releasePlayer3 == 1) {
            disPlay.player3view.layer.sublayers = nil;
            [self.playerAVF3 pause];
            [self player3End:nil];
        } 
        releasePlayer3--;
    }
    */
}




//###########################################################
// PLAYER UTILITIES


	
-(void) disableStreaming{
    [runMachine dispatch:@"/stoplive"];
}

-(void) enableGoMovie{
    [runMachine dispatch:@"/playmovie"];
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
	[comPort sendDebug:@"exit app"];
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    
    //controllers
    [userViewController release];
    [tableViewController release];
    [viewController release];
    
    //objects
    [disPlay release];
    [comPort release];
    [runMachine release];
    [filesManager release];
    [moviePlayer release];
    [livePlayer release];
    [interFace release];
    
    [tabBarController release];
    [window release];
    [super dealloc];	
}


@end
