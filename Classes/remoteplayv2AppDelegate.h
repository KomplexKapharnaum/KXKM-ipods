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
#import <VVOSC/VVOSC.h>
#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>


@interface remoteplayv2AppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate > {
    //ipod window
	UIWindow *window;
	UITabBarController *tabBarController;
	//ext window
	UIWindow *_secondWindow;
    UIView *blackview;
    UIView *fadeview;
    UIView *flashview;
    UIView *titlesview;
    //controllers
    remoteplayv2ViewController *viewController;
    remoteplayv2UserViewController*userViewController;
    remoteplayv2TableViewController *tableViewController;
    //ipod info
    NSString *myName;
    NSString *myIp;
    NSString *playerMode;
    NSString *playerState;
    NSString *screenState;
    //osc
    OSCManager	*manager;
	OSCOutPort *outPort;
	NSString* inPort;
    //boucle
    NSTimer *timermouvement;
	//movie
	MPMoviePlayerController *moviePlayer;
    MPMoviePlayerController *futurePlayer;
	NSURL *movieURL;
    int fadeColor;
    BOOL muted;
    BOOL faded;
    BOOL streamingMode;
    //instruction reçue par OSC
//    BOOL goload;
	BOOL gomovie;
	BOOL stopmovie;
	BOOL movieIsPlaying;
    BOOL gomute;
    BOOL gofade;
    BOOL goflash;
    BOOL gocolorflash;
    BOOL gomessage;
    BOOL gotitles;
    //détails instructions
    NSArray *mediaList;
	NSString *pathformovie;
	NSString *remotemoviepath;
	NSString *remotemoviename;
    NSString *customTitles;
	int playbacktimeWanted;
    int flashcolorRed;
    int flashcolorGreen;
    int flashcolorBlue;
    int flashcolorAlpha;
    int fadecolorRed;
    int fadecolorGreen;
    int fadecolorBlue;
    int fadecolorAlpha;
    NSString *message;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;


@property (nonatomic, retain) IBOutlet UIWindow *_secondWindow;
@property (nonatomic,retain) UIView *blackview;
@property (nonatomic,retain) UIView *fadeview;
@property (nonatomic,retain) UIView *flashview;
@property (nonatomic,retain) UIView *titlesview;

@property (readwrite, retain) OSCManager *manager;
@property (readwrite, retain) OSCOutPort *outPort;

@property (readwrite, retain) MPMoviePlayerController *moviePlayer;
@property (nonatomic, retain) NSURL *movieURL;
@property (nonatomic, retain) NSArray *mediaList;
@property (nonatomic,retain) NSTimer *timermouvement;

@property (nonatomic,retain) NSString *pathformovie;
@property (nonatomic,retain) NSString *remotemoviepath;
@property (nonatomic,retain) NSString *remotemoviename;
@property (nonatomic,retain) NSString *playerstate;
@property (nonatomic,retain) NSString *screenstate;

@property (nonatomic,retain) NSString *message;
@property (nonatomic,retain) NSString *customTitles;


//@property (nonatomic) BOOL goload;
@property (nonatomic) BOOL gomovie;
@property (nonatomic) BOOL stopmovie;
@property (nonatomic) BOOL movieIsPlaying;
@property (nonatomic) BOOL gomute;
@property (nonatomic) BOOL gofade;
@property (nonatomic) BOOL goflash;
@property (nonatomic) BOOL gomessage;
@property (nonatomic) BOOL streamingMode;
@property (nonatomic) BOOL gotitles;

//routines
- (void) sendInfo;
- (void) sendSync;
- (void) sendSOS;

//utilities
- (void) checkScreen;
- (void) listMedia;

//fonction boucle et son initialisation
- (void) topHorloge;
- (void) topDepartMouvement: (NSTimer*)timer;

//PLAYER CONTROLS
//-(void) loadMovie;
-(void) playMovie;
-(void) stopMovie;
-(void) skipMovie:(OSCMessage *)attime;
-(void) fadeMovie:(BOOL)fadeMe;
-(void) flashMovie;
-(void) muteMovie:(BOOL)muteMe;

//OSC functions
- (OSCMessage*) oscNewMsg: (NSString*)state;
- (void) receivedOSCMessage: 		(OSCMessage *)  	m;
- (void) treatReceivedOSCMessage: 	(OSCMessage *)  	m;

//debug
- (void) debug : (NSString*) s;

//define if we are on simulator and IP of the device
- (NSString *) getIPAddress;
- (NSString *) platform;

//manage movie functions 
-(void) disableStreaming;
-(void) initGoMovieWithName:(NSString*)n ;
-(void) installMovieNotificationObservers;
-(void) removeMovieNotificationHandlers;

@end

