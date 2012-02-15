//
//  RunClass.m
//  KXKM
//
//  Created by Snow Leopard User on 09/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RunClass.h"
#import "ConfigConst.h"
#import "remoteplayv2AppDelegate.h"

@implementation RunClass

//###########################################################
// INIT

- (id) init
{
    [self clear];
    return [super init];	
}

//###########################################################
// DISPATCH RECIEVED COMMANDS

// Dispatch recieved orders : some actions can be performed directly
// but some actions must be performed by the BEAT clocked function
- (void) dispatch:(NSString*) rcvCommand {
    
    remoteplayv2AppDelegate *appDelegate = (remoteplayv2AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSArray *pieces = [rcvCommand componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *command = [pieces objectAtIndex:0];
    
    NSMutableArray *orders = [NSMutableArray arrayWithArray: pieces];
    [orders removeObjectAtIndex:0];
    
    //SYNC : mode, state, args (movie, time, ...)
	if ([command isEqualToString: @"/synctest"]) [appDelegate.comPort sendSync];
    
    //INIT INFO : ipod ip
	else if ([command isEqualToString: @"/fullsynctest"]) [appDelegate.comPort sendInfo];
    
    //SET IP SERVER :
	else if ([command isEqualToString: @"/ipregie"]) [appDelegate.comPort setIpServer:[orders objectAtIndex:0]];
    
    //FORCE AUTO :
	else if ([command isEqualToString: @"/mastermode"]) [appDelegate.interFace setMode:AUTO];
    
    //FLASH (RGBA 8bit)
    else if ([command isEqualToString: @"/flash"]) {
        //set color
        if ([orders count] >= 4)  
            [appDelegate.disPlay flashColor:[[orders objectAtIndex:0] intValue] :[[orders objectAtIndex:1] intValue] :[[orders objectAtIndex:2] intValue] :[[orders objectAtIndex:3] intValue]];
        
        else if ([orders count] >= 3)  
            [appDelegate.disPlay flashColor:[[orders objectAtIndex:0] intValue] :[[orders objectAtIndex:1] intValue] :[[orders objectAtIndex:2] intValue] : 255];
        
        else [appDelegate.disPlay flashColor:255:255:255:255];
        
        goflash = YES;
    }
    
    //DISPLAY MESSAGE
    else if ([command isEqualToString: @"/message"]) {
        message = [[orders componentsJoinedByString:@" "] copy];
        gomessage=YES;
    }
    
    //ONLY IN AUTO MODE
    else if ([appDelegate.interFace mode] == AUTO) {
        
        //LOAD & PLAY MOVIE
        if (([command isEqualToString: @"/loadmovie"]) || ([command isEqualToString: @"/playmovie"])) {
            [appDelegate.moviePlayer load: [[orders componentsJoinedByString:@" "] copy]];
            playmovie = [command isEqualToString: @"/playmovie"];
        }
        
        //PLAY LIVE
        else if ([command isEqualToString: @"/playlive"]) {
            appDelegate.disPlay.playerview.alpha=1;
            [appDelegate.livePlayer load : [[orders componentsJoinedByString:@" "] copy]];
            playlive = YES;
            return;
        }
        
        //SKIP AT TIME
        else if ([command isEqualToString: @"/attime"]) {
            if ([orders count] >= 1) [appDelegate.moviePlayer skip:[[orders objectAtIndex:0] intValue]];
        }
        
        //STOP MOVIE
        else if ([command isEqualToString: @"/stopmovie"]) stopmovie = YES;
        
        //STOP MOVIE
        else if ([command isEqualToString: @"/stoplive"]) stoplive = YES;
        
        //PAUSE
        else if ([command isEqualToString: @"/pause"]) {
            [appDelegate.moviePlayer pause];
        }
        
        //UNPAUSE
        else if ([command isEqualToString: @"/unpause"]) {
            [appDelegate.moviePlayer unpause];
        }
        
        //MUTE
        else if ([command isEqualToString: @"/mute"]) gomute = YES;
        
        //UNMUTE
        else if ([command isEqualToString: @"/unmute"]) gounmute = YES;
        
        //FADE to color (RGBA 8bit)
        else if ([command isEqualToString: @"/fade"]) {
            
            //set color
            if ([orders count] >= 4)  
                [appDelegate.disPlay fadeColor:[[orders objectAtIndex:0] intValue] :[[orders objectAtIndex:1] intValue] :[[orders objectAtIndex:2] intValue] :[[orders objectAtIndex:3] intValue]];
            
            else if ([orders count] >= 3)  
                [appDelegate.disPlay fadeColor:[[orders objectAtIndex:0] intValue] :[[orders objectAtIndex:1] intValue] :[[orders objectAtIndex:2] intValue] :255];
            
            else [appDelegate.disPlay fadeColor:255:255:255:255];
            
            gofade = YES;
        }
        
        //UNFADE
        else if ([command isEqualToString: @"/unfade"]) gounfade = YES;
        
        //ADD TEXT
        else if ([command isEqualToString: @"/titles"]) {
            [appDelegate.disPlay titlesText:[orders componentsJoinedByString:@" "]];
            gotitles=YES;
        }
        
        //CHANGE TEXT COLOR
        else if ([command isEqualToString: @"/titlescolor"]) {
            
            //set color
            if ([orders count] >= 4)  
                [appDelegate.disPlay titlesColor:[[orders objectAtIndex:0] intValue] :[[orders objectAtIndex:1] intValue] :[[orders objectAtIndex:2] intValue] :[[orders objectAtIndex:3] intValue]];
            
            else if ([orders count] >= 3)  
                [appDelegate.disPlay titlesColor:[[orders objectAtIndex:0] intValue] :[[orders objectAtIndex:1] intValue] :[[orders objectAtIndex:2] intValue] : 255];
            
            else [appDelegate.disPlay titlesColor:255:255:255:255];
        }
        
        //UNKNOW ORDER
        else [appDelegate.comPort sendError:command];   
    }
    
    else {
        
        //WE ARE NOT IN AUTO MODE, NOTIFY (Manu or Unknown mode)
        [appDelegate.comPort sendSync];
    }
    
}


//###########################################################
// WORKER TIMER

// start Runner timer
-(void) start {
	timerRunner = [NSTimer scheduledTimerWithTimeInterval:TIMER_RUN
											 target:self 
										   selector:@selector(beat) 
										   userInfo:nil 
											repeats:YES];
}

// Runner command executed on each timer beat
- (void) beat{
    
    remoteplayv2AppDelegate *appDelegate = (remoteplayv2AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    //don't execute video related order if no screen 
    if ([appDelegate.disPlay resolution] != @"noscreen") {
        
        //SCHEDULED ORDERS
        //play movie
        if (playmovie) [appDelegate.moviePlayer play];
        
        //stop movie
        if (stopmovie) [appDelegate.moviePlayer stop];
        
        //play live
        if (playlive) [appDelegate.livePlayer play];
        
        //stop live
        if (stoplive) [appDelegate.livePlayer stop];
        
        //mute
        if (gomute) [appDelegate.disPlay mute:YES];
        if (gounmute) [appDelegate.disPlay mute:NO];

        //fade / unfade to color
        if (gofade) [appDelegate.disPlay fade:YES];
        if (gounfade) [appDelegate.disPlay fade:NO];
        
        //white flash
        if (goflash) [appDelegate.disPlay flash];
        
        //titles : add text
        if (gotitles) [appDelegate.disPlay titles];
    }
    
    //message TODO
    if (gomessage) [appDelegate.interFace Bmessage:message];
    
    //IMPORTANT : if use of a new command BOOL, don't forget to register it in clear function !!!!
    [self clear];
}

//clear pennding actions
- (void) clear {
    
    playmovie = NO;
	stopmovie = NO;
    
    playlive = NO;
    stoplive = NO;
    
    gomute = NO;
    gounmute = NO;
    
    gofade = NO;
    gounfade = NO;
    
    goflash = NO;
    
    gotitles = NO;
    gomessage = NO;
}


@end
