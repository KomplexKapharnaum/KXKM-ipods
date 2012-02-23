//
//  CheckerClass.m
//  KXKM
//
//  Created by Snow Leopard User on 14/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CheckerClass.h"
#import "ConfigConst.h"
#import "remoteplayv2AppDelegate.h"

@implementation CheckerClass

//###########################################################
// INIT

- (id) init
{
    return [super init];	
}

//###########################################################
// CHECKER LOOP

// start Runner timer
-(void) start {
	timerChecker = [NSTimer scheduledTimerWithTimeInterval:TIMER_CHECK 
                                                   target:self 
                                                 selector:@selector(beat) 
                                                 userInfo:nil 
                                                  repeats:YES];
}

// Runner command executed on each timer beat
- (void) beat{
    
    remoteplayv2AppDelegate *appDelegate = (remoteplayv2AppDelegate*)[[UIApplication sharedApplication] delegate];

    //CHECK IF WIFI CONNECTED
    [appDelegate.interFace infoIP: [appDelegate.comPort getIPAddress]];
    
    //CHECK SERVER CONNECTION
    [appDelegate.interFace infoServer: [appDelegate.comPort serverState]];
    
    //CHECK IF SCREEN CHANGED
    if ([appDelegate.disPlay checkScreen]) {
        if ([[appDelegate.disPlay resolution] isEqualToString: @"noscreen"]) [appDelegate.moviePlayer stop];
        [appDelegate.interFace infoScreen: [appDelegate.disPlay resolution]];
        [appDelegate.comPort sendSync];    
    }
    
    //UPDATE PLAYER STATE    
    if ([appDelegate.live2Player isLive]) {
        [appDelegate.interFace infoState:@"live"];
        //TODO info buffer
        //NSString* buffer = [@"Buffer " stringByAppendingFormat:@"%i",[appDelegate.live2Player ]];
        //[appDelegate.interFace infoMovie:buffer];
    }
    else if ([appDelegate.moviePlayer isPlaying]) {
        [appDelegate.interFace infoState:@"play"];
        [appDelegate.interFace infoMovie:[appDelegate.moviePlayer movie]];
    }
    else {
        [appDelegate.interFace infoState:@"wait"];
        [appDelegate.interFace infoMovie:@""];
    }
    
    //UPDATE MOVIE SCROLLER
    if ([appDelegate.moviePlayer isPlaying])
        [appDelegate.interFace Bslide:[appDelegate.moviePlayer duration]:[appDelegate.moviePlayer currentTime]];
            
}

@end
