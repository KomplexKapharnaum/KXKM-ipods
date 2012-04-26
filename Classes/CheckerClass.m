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
    lastSync = 1000;
    lastTab = 0;
    timeHere = 0;
    batteryRefresh = TIMER_CHECK_BATT;
    broadcastRefresh = TIMER_CHECK_BROAD;
    return [super init];	
}

//###########################################################
// CHECKER LOOP

// start Runner timer
-(void) start {
    
    //LAUNCH BEAT REPEAT
	timerChecker = [NSTimer scheduledTimerWithTimeInterval:TIMER_CHECK 
                                                   target:self 
                                                 selector:@selector(beat) 
                                                 userInfo:nil 
                                                  repeats:YES];
}

// Runner command executed on each timer beat
- (void) beat{
    
    remoteplayv2AppDelegate *appDelegate = (remoteplayv2AppDelegate*)[[UIApplication sharedApplication] delegate];

    //INITIAL INFO (DISABLE ONCE DONE) FIX 4.3 compatibility
    if (![[appDelegate.interFace getInfoName] isEqualToString:appDelegate.comPort.ipodName]) {
        [appDelegate.interFace infoName: appDelegate.comPort.ipodName];
        [appDelegate.interFace infoScreen: [appDelegate.disPlay resolution]];
    }
    
    //CHECK IF WIFI CONNECTED
    [appDelegate.interFace infoIP: [appDelegate.comPort getIPAddress]];
    
    //CHECK SERVER CONNECTION
    NSString *serverIPstate = [appDelegate.comPort serverState];
    [appDelegate.interFace infoServer: serverIPstate];
    
    //RE-ASK IP REGIE WHEN BROADCAST MODE
    if ([serverIPstate isEqualToString:@"broadcast"]) {
        if (TIMER_CHECK_BROAD > 0) broadcastRefresh++;
        if (broadcastRefresh > TIMER_CHECK_BROAD) {
            [appDelegate.comPort sendAskip];
            broadcastRefresh = 0;
        }
    }    
    
    //UPDATE LINK STATE
    if (lastSync > 4) [appDelegate.interFace infoLink: @"nolink"];
    else [appDelegate.interFace infoLink: @"OK"];
    if (lastSync < 1000) lastSync++; //security increaser
    
    //CHECK IF SCREEN CHANGED
    if ([appDelegate.disPlay checkScreen]) {
        if ([[appDelegate.disPlay resolution] isEqualToString: @"noscreen"]) [appDelegate.moviePlayer stop];
        [appDelegate.interFace infoScreen: [appDelegate.disPlay resolution]];
        [appDelegate.comPort sendSync];    
    }
    
    //UPDATE PLAYER STATE    
    if ([appDelegate.live2Player isLive]) {
        [appDelegate.interFace infoState:@"live"];
        [appDelegate.interFace infoMovie:@""];
    }
    else if ([appDelegate.moviePlayer isPlaying]) {
        if(appDelegate.interFace.mode==MANU)[appDelegate.interFace infoState:@"play manu"];
        if(appDelegate.interFace.mode==AUTO)[appDelegate.interFace infoState:@"play auto"];
        [appDelegate.interFace infoMovie:[appDelegate.moviePlayer movie]];
    }
    else {
        [appDelegate.interFace infoState:@"wait"];
        [appDelegate.interFace infoMovie:@""];
    }
    
    //UPDATE CTRL STATE
    if ([appDelegate.disPlay faded]) [appDelegate.interFace infoCtrl:@"faded"];
    else [appDelegate.interFace infoCtrl:@""];
    
    //UPDATE MOVIE SCROLLER
    if ([appDelegate.moviePlayer isPlaying])
        [appDelegate.interFace Bslide:[appDelegate.moviePlayer duration]:[appDelegate.moviePlayer currentTime]];
    
    
    //UPDATE BATTERY STATE
    if (TIMER_CHECK_BATT > 0) batteryRefresh++;
    if (batteryRefresh > TIMER_CHECK_BATT) {
        [appDelegate.comPort sendBat];
        batteryRefresh = 0;
    }    
    
    //CHECK ACTIVE TAB
    //tab change
    if (lastTab != [appDelegate.tabBarController selectedIndex]) {
        timeHere = 0;
        lastTab = [appDelegate.tabBarController selectedIndex];
    }
    
    //auto mode : go back home if needed
    if (TIMER_CHECK_HOME > 0) {
        //tab counter and auto back to home
        if ([appDelegate.interFace mode] == AUTO) {
            if ((lastTab == 1)||(lastTab == 2)) timeHere++;
            
            if ((lastTab == 1) && (timeHere > TIMER_CHECK_HOME)) 
                if ((![appDelegate.moviePlayer isPause]) && (![appDelegate.disPlay faded])) 
                        [appDelegate.tabBarController setSelectedIndex:0];
            
            if ((lastTab == 2) && (timeHere > (TIMER_CHECK_USER))) 
                if ((![appDelegate.moviePlayer isPause]) && (![appDelegate.disPlay faded]))
                    [appDelegate.tabBarController setSelectedIndex:0];
                else [appDelegate.tabBarController setSelectedIndex:1];
        }
    }
    
    //manu mode : go back user ctrl if needed
    if (TIMER_CHECK_USER > 0) {
        //tab counter and auto back to user∂∂
        if ([appDelegate.interFace mode] == MANU) {
            if (lastTab == 2) timeHere++;
            
            if ((lastTab == 2) && (timeHere > TIMER_CHECK_USER)) 
               [appDelegate.tabBarController setSelectedIndex:1];
        }
    }
    
}

- (void) userAct : (int) tim {
    //on manual action reset timeHere
    timeHere = tim;
}

- (void) syncAct {
    //on manual action reset timeHere
    lastSync = 0;
}

@end
