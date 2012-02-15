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
    
    //CHECK IF SCREEN CHANGED
    if ([appDelegate.disPlay checkScreen]) {
        if ([[appDelegate.disPlay resolution] isEqualToString: @"noscreen"]) [appDelegate.moviePlayer stop];
        [appDelegate.interFace infoScreen: [appDelegate.disPlay resolution]];
        [appDelegate.comPort sendSync];    
    }
    
    //UPDATE PLAYER STATE    
    if ([appDelegate.livePlayer isPlaying]) {
        [appDelegate.interFace infoState:@"live"];
        NSString* buffer = [@"Buffer " stringByAppendingFormat:@"%i",[appDelegate.livePlayer queueSize]];
        [appDelegate.interFace infoMovie:buffer];
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
        
    //UPDATE CLOCK DISPLAY
    //NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    //[dateFormatter setDateFormat:@"HH:mm:ss"];
    //[appDelegate.interFace infoTime: [dateFormatter stringFromDate:[NSDate date]]];
    //[dateFormatter release];
    
    //RE LAUNCH VIDEO IF PAUSED (debug streaming)
    //TODO, check player state to know if it is usefull..
    //TODO ADD Observer !
    //if (streamingMode) [self.moviePlayer play]; 
    //if (sourceMode == LIVE_MODE) [playerAVF play]; 
    
    
}

@end
