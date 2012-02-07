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
#import <AVFoundation/AVFoundation.h>
#import "GCDAsyncUdpSocket.h"
//#import "RTSPClient.hh"


@interface remoteplayv2AppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate > {
    //ipod window
	UIWindow *window;
	UITabBarController *tabBarController;
	//ext window
	UIWindow *_secondWindow;
    AVPlayerLayer *layerAVF;
    
    UIView *playerview;
    UIView *player1view;
    UIView *player2view;
    UIView *player3view;
    
    UIView *movieview;
    UIView *movie1view;
    UIView *movie2view;

    
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
    NSString *movieLast;
    
    //osc
    OSCManager	*manager;
    NSString* udpServerIP;
    OSCOutPort* vvoscOUT;
    
    //UPD
    int outPort;
	int inPort;
    
    //boucle
    NSTimer *timermouvement;
    NSTimer *timerchecker;
	
    //movie
	AVPlayer* playerMOVIE;
    
    AVPlayer* playerAVF;
    AVPlayer* playerAVF1;
    AVPlayer* playerAVF2;
    AVPlayer* playerAVF3;
    
    int sourceMode;
    
    int fadeColor;
    BOOL muted;
    BOOL faded;
    BOOL paused;
    BOOL mired;
    
    //instruction reçue par OSC
    NSString *rcvCommand;
	BOOL gomovie;
    BOOL gopause;
	BOOL gostop;
    BOOL gostoplive;
    BOOL gomute;
    BOOL gofade;
    BOOL goflash;
    BOOL gocolorflash;
    BOOL gomessage;
    BOOL gotitles;
    
    BOOL lock1;
    BOOL lock2;
    BOOL lock3;
    
    int usePlayer;
    int releasePlayer1;
    int releasePlayer2;
    int releasePlayer3;
    int releaseMOVIE;
    
    //détails instructions
	NSString *pathformovie;
	NSString *remotemoviepath;
	NSString *remotemoviename;
    NSString *customTitles;
    NSString *nextQueue;
    
    //Colors
    int flashcolorRed;
    int flashcolorGreen;
    int flashcolorBlue;
    int flashcolorAlpha;
    int fadecolorRed;
    int fadecolorGreen;
    int fadecolorBlue;
    int fadecolorAlpha;
    int titlescolorRed;
    int titlescolorGreen;
    int titlescolorBlue;
    int titlescolorAlpha;
    
    NSString *message;
    
    
    //UDP Communication
    GCDAsyncUdpSocket *udpSocketIN;
    GCDAsyncUdpSocket *udpSocketOUT;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;


@property (nonatomic, retain) IBOutlet UIWindow *_secondWindow;
@property (nonatomic,retain) AVPlayerLayer *layerAVF;

@property (nonatomic,retain) UIView *playerview;
@property (nonatomic,retain) UIView *player1view;
@property (nonatomic,retain) UIView *player2view;
@property (nonatomic,retain) UIView *player3view;

@property (nonatomic,retain) UIView *movieview;
@property (nonatomic,retain) UIView *movie1view;
@property (nonatomic,retain) UIView *movie2view;

@property (nonatomic,retain) UIView *muteview;
@property (nonatomic,retain) UIView *mirview;
@property (nonatomic,retain) UIView *fadeview;
@property (nonatomic,retain) UIView *flashview;
@property (nonatomic,retain) UIView *titlesview;

@property (readwrite, retain) OSCManager *manager;
@property (readwrite, retain) OSCOutPort *vvoscOUT;
@property (readwrite, retain) NSString* udpServerIP;

@property (readwrite, retain) MPMoviePlayerController *moviePlayer;

@property (readwrite, retain) AVPlayer* playerMOVIE;
@property (readwrite, retain) AVPlayer* playerAVF;
@property (retain) AVPlayer* playerAVF1;
@property (retain) AVPlayer* playerAVF2;
@property (retain) AVPlayer* playerAVF3;

@property (nonatomic,retain) NSTimer *timermouvement;
@property (nonatomic,retain) NSTimer *timerchecker;

@property (nonatomic,retain) NSString *pathformovie;
@property (nonatomic,retain) NSString *remotemoviepath;
@property (nonatomic,retain) NSString *remotemoviename;
@property (nonatomic,retain) NSString *playerstate;
@property (nonatomic,retain) NSString *screenstate;
@property (nonatomic,retain) NSString *movieLast;

@property (nonatomic,retain) NSString *message;
@property (nonatomic,retain) NSString *customTitles;

@property (nonatomic,retain) NSString *rcvCommand;

@property (nonatomic) int fadecolorRed;
@property (nonatomic) int fadecolorGreen;
@property (nonatomic) int fadecolorBlue;

@property (nonatomic) BOOL gomovie;
@property (nonatomic) BOOL gopause;
@property (nonatomic) BOOL gostop;
@property (nonatomic) BOOL gostoplive;
@property (nonatomic) BOOL gomute;
@property (nonatomic) BOOL gofade;
@property (nonatomic) BOOL goflash;
@property (nonatomic) BOOL gomessage;
@property (nonatomic) BOOL gotitles;

@property (nonatomic) BOOL lock1;
@property (nonatomic) BOOL lock2;
@property (nonatomic) BOOL lock3;

@property (nonatomic) int usePlayer;
@property (nonatomic) int releasePlayer1;
@property (nonatomic) int releasePlayer2;
@property (nonatomic) int releasePlayer3;
@property (nonatomic) int sourceMode;
@property (nonatomic) int releaseMOVIE;

@property (nonatomic) BOOL muted;
@property (nonatomic) BOOL faded;
@property (nonatomic) BOOL paused;
@property (nonatomic) BOOL mired;

//routines
- (void) sayAllo;
- (void) sendInfo;
- (void) sendSync;
- (void) sendSOS;
- (void) sendError: (NSString *) m;

//utilities
- (void) checkScreen;
- (NSArray *) listMedia;

//fonction boucle et son initialisation
- (void) topHorloge;
- (void) topDepartMouvement: (NSTimer*)timer;
- (void) topChecker;
- (void) topDepartChecker: (NSTimer*)timer;

//PLAYER CONTROLS
//-(void) loadMovie;
-(void) playMovie;
-(void) playLive;
-(void) stopMovie;
-(void) stopLive;
-(void) pauseMovie;
-(BOOL) isPlaying;
-(void) skipMovie:(int)playbacktimeWanted;
-(void) fadeMovie:(BOOL)fadeMe;
-(void) flashMovie;
-(void) muteMovie:(BOOL)muteMe;
-(void) mirMovie:(BOOL)mirDisp;

-(void) fadeColor:(int)Red:(int)Green:(int)Blue:(int)Alpha;
-(void) flashColor:(int)Red:(int)Green:(int)Blue:(int)Alpha;
-(void) titlesColor:(int)Red:(int)Green:(int)Blue:(int)Alpha;

//OSC functions
//- (OSCMessage*) oscNewMsg: (NSString*)state;
- (void) receivedOSCMessage: (OSCMessage *)m;
- (void) runMessage;

- (void) player1End : (NSNotification*) notification;
- (void) player2End : (NSNotification*) notification;
- (void) player3End : (NSNotification*) notification;

-(void) releaseUnusedMovie:(BOOL)clear;

//UDP Communication
- (void) sendUDP: (NSString *) m;

//debug
- (void) debug : (NSString*) s;

//define if we are on simulator and IP of the device
- (NSString *) getIPAddress;
- (NSString *) platform;

//manage movie functions 
-(void) disableStreaming;
-(void) initGoMovieWithName:(NSString*)n:(BOOL)go ;

@end

