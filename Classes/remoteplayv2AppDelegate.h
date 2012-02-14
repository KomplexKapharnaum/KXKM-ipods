//
//  remoteplayv2AppDelegate.h
//  remoteplayv2
//
//  Created by Pierre Hoezelle, Thomas Bohl, Jeremie Forge
//  Copyright 2011 KXKM. Creative Commons BY-NC-SA.
//

#import <UIKit/UIKit.h>
#import "remoteplayv2ViewController.h"
#import "remoteplayv2TableViewController.h"
#import "remoteplayv2UserViewController.h"

#import "DisplayClass.h"
#import "ComClass.h"
#import "RunClass.h"
#import "FilesClass.h"
#import "MovieClass.h"
#import "LiveClass.h"
#import "InterfaceClass.h"

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

//#import "RTSPClient.hh"


@interface remoteplayv2AppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate > {
    
    //INTERFACE
	UIWindow *window;
	UITabBarController *tabBarController;
	
    //CONTROLLERS
    remoteplayv2ViewController *viewController;
    remoteplayv2UserViewController*userViewController;
    remoteplayv2TableViewController *tableViewController;
    
    //OBJECTS
    DisplayClass *disPlay;      //Second Screen
    ComClass *comPort;          //Communication
    RunClass *runMachine;       //Communication
    FilesClass *filesManager;   //Files Manager
    MovieClass *moviePlayer;    //Movie Player 
    LiveClass *livePlayer;      //Live Player 
    InterfaceClass *interFace;  //User Interface
    
    //ipod info
    NSString *playerMode;
    NSString *playerState;
    
    //boucle
    NSTimer *timerchecker;    
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@property (nonatomic, retain) DisplayClass *disPlay;
@property (nonatomic, retain) ComClass *comPort;
@property (nonatomic, retain) RunClass *runMachine;
@property (nonatomic, retain) FilesClass *filesManager;
@property (nonatomic, retain) MovieClass *moviePlayer;
@property (nonatomic, retain) LiveClass *livePlayer;
@property (nonatomic, retain) InterfaceClass *interFace;

@property (nonatomic,retain) NSTimer *timerchecker;

@property (nonatomic,retain) NSString *playerState;
@property (nonatomic,retain) NSString *playerMode;




//info display
-(void) infoScreen:(NSString*)msg;
-(void) infoState:(NSString*)msg;
-(void) infoMovie:(NSString*)msg;

- (void) topDepartChecker: (NSTimer*)timer;

//manage movie functions 
-(void) disableStreaming;

@end

