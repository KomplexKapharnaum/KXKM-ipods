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
#import "GCDAsyncSocket.h"


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
	OSCOutPort *outPort;
	NSString* inPort;
    
    //boucle
    NSTimer *timermouvement;
    NSTimer *timerchecker;
	
    //movie
	MPMoviePlayerController *moviePlayer;
    
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
    BOOL gomute;
    BOOL gofade;
    BOOL goflash;
    BOOL gocolorflash;
    BOOL gomessage;
    BOOL gotitles;
    BOOL createPlayer;
    BOOL firstStart;
    BOOL useAVF;
    BOOL useTCP;
    int usePlayer;
    int releasePlayer1;
    int releasePlayer2;
    int releasePlayer3;
    //détails instructions
//    NSArray *mediaList;
	NSString *pathformovie;
	NSString *remotemoviepath;
	NSString *remotemoviename;
    NSString *customTitles;
    NSString *nextQueue;
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
    
    //TCP Communication
    dispatch_queue_t socketQueue;	
	GCDAsyncSocket *listenSocket;
	NSMutableArray *connectedSockets;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;


@property (nonatomic, retain) IBOutlet UIWindow *_secondWindow;
@property (nonatomic,retain) AVPlayerLayer *layerAVF;

@property (nonatomic,retain) UIView *playerview;
@property (nonatomic,retain) UIView *player1view;
@property (nonatomic,retain) UIView *player2view;
@property (nonatomic,retain) UIView *player3view;

@property (nonatomic,retain) UIView *muteview;
@property (nonatomic,retain) UIView *mirview;
@property (nonatomic,retain) UIView *fadeview;
@property (nonatomic,retain) UIView *flashview;
@property (nonatomic,retain) UIView *titlesview;

@property (readwrite, retain) OSCManager *manager;
@property (readwrite, retain) OSCOutPort *outPort;

@property (readwrite, retain) MPMoviePlayerController *moviePlayer;

@property (readwrite, retain) AVPlayer* playerAVF;
@property (readwrite, retain) AVPlayer* playerAVF1;
@property (readwrite, retain) AVPlayer* playerAVF2;
@property (readwrite, retain) AVPlayer* playerAVF3;

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
@property (nonatomic) BOOL gomute;
@property (nonatomic) BOOL gofade;
@property (nonatomic) BOOL goflash;
@property (nonatomic) BOOL gomessage;
@property (nonatomic) BOOL gotitles;
@property (nonatomic) BOOL createPlayer;
@property (nonatomic) BOOL firstStart;
@property (nonatomic) BOOL useAVF;
@property (nonatomic) BOOL useTCP;
@property (nonatomic) int usePlayer;
@property (nonatomic) int releasePlayer1;
@property (nonatomic) int releasePlayer2;
@property (nonatomic) int releasePlayer3;
@property (nonatomic) int sourceMode;

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
-(void) stopMovie;
-(void) pauseMovie;
-(BOOL) isPlaying;
-(void) playMovieAVF;
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

//TCP Communication
- (BOOL) openTCP: (int) TCPListenPort;
- (void) sendTCP: (NSString *) m;

//debug
- (void) debug : (NSString*) s;

//define if we are on simulator and IP of the device
- (NSString *) getIPAddress;
- (NSString *) platform;

//manage movie functions 
-(void) disableStreaming;
-(void) initGoMovieWithName:(NSString*)n:(BOOL)go ;
-(void) installMovieNotificationObservers;
-(void) removeMovieNotificationHandlers;

@end

