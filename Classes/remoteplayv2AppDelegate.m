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
@synthesize checkMachine;
@synthesize filesManager;
@synthesize moviePlayer;
@synthesize livePlayer;
@synthesize interFace;


#pragma mark -
#pragma mark Application lifecycle

//###########################################################
//STARTUP

//APPLICATION START
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    //VUES : pointeur vers l'objet de chacune des vues pour un accès rapide depuis le delegate
        //TABS : Add the view controller's view to the window and display.
        [self.window addSubview:tabBarController.view];
        [self.window makeKeyAndVisible];
    
    //OBJECTS
        //DISPLAY 
        disPlay = [[DisplayClass alloc] init];
    
        //COMMUNICATION 
        comPort = [[ComClass alloc] init];
    
        //RUN MACHINE (Clock & Dispatch Orders) 
        runMachine = [[RunClass alloc] init];
    
        //RUN MACHINE (Clock & Check states) 
        checkMachine = [[CheckerClass alloc] init];
    
        //FILES MANAGER
        filesManager = [[FilesClass alloc] init];
    
        //MOVIE PLAYER
        moviePlayer = [[MovieClass alloc] init];
    
        //MOVIE PLAYER
        livePlayer = [[LiveClass alloc] init];
    
        //INTERFACE CTRL
        interFace = [[InterfaceClass alloc] initWithTabBar:tabBarController];
    
    //APP Info and States        
        //auto info
        [interFace infoIP: @"noIP"];
        [interFace infoScreen: @"noscreen"];
        [interFace infoState: @"starting"];
        [interFace infoMovie: @""];
        [interFace infoServer: [comPort serverState]];
        [interFace infoName: comPort.ipodName];
        
        //list media
        [interFace setMediaList: [filesManager list]];
	
    
    //APP START      
        [runMachine start];
        [checkMachine start];
    
	//end of startup
    return YES;
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
    
    //objects
    [disPlay release];
    [comPort release];
    [runMachine release];
    [checkMachine release];
    [filesManager release];
    [moviePlayer release];
    [livePlayer release];
    [interFace release];
    
    //interface
    [tabBarController release];
    [window release];
    
    [super dealloc];	
}


@end
