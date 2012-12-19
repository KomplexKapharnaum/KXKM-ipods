//
//  remoteplayv2AppDelegate.h
//  remoteplayv2
//
//  Created by Pierre Hoezelle, Thomas Bohl, Jeremie Forge
//  Copyright 2011 KXKM. Creative Commons BY-NC-SA.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import "DisplayClass.h"
#import "ComClass.h"
#import "RunClass.h"
#import "CheckerClass.h"
#import "FilesClass.h"
#import "MovieClass.h"
#import "Live2Class.h"
#import "RecClass.h"
#import "InterfaceClass.h"


@interface remoteplayv2AppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate > {
    
    //INTERFACE
	UIWindow *window;
	UITabBarController *tabBarController;
    
    //OBJECTS
    DisplayClass *disPlay;      //Second Screen
    ComClass *comPort;          //Communication
    RunClass *runMachine;       //Running commands
    CheckerClass *checkMachine; //Check states
    FilesClass *filesManager;   //Files Manager
    MovieClass *moviePlayer;    //Movie Player 
    Live2Class *live2Player;      //Live Player
    RecClass *recOrder;      //Recorder
    InterfaceClass *interFace;  //User Interface
           
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;


@property (nonatomic, retain) DisplayClass *disPlay;
@property (nonatomic, retain) ComClass *comPort;
@property (nonatomic, retain) RunClass *runMachine;
@property (nonatomic, retain) CheckerClass *checkMachine;
@property (nonatomic, retain) FilesClass *filesManager;
@property (nonatomic, retain) MovieClass *moviePlayer;
@property (nonatomic, retain) Live2Class *live2Player;
@property (nonatomic, retain) RecClass *recOrder;
@property (nonatomic, retain) InterfaceClass *interFace;


//manage movie functions 
-(void) disableStreaming;

@end

