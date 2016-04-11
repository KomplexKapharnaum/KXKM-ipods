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
    //NSLog(rcvCommand);
    if (rcvCommand == nil) return;
    
    remoteplayv2AppDelegate *appDelegate = (remoteplayv2AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSArray *pieces = [rcvCommand componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([pieces count] < 1) return;
    
    NSString *command = [pieces objectAtIndex:0];
    
    NSMutableArray *orders;
    orders = [NSMutableArray arrayWithArray: pieces];
    [orders removeObjectAtIndex:0]; //remove command
    
    //SYNC : mode, state, args (movie, time, ...)
	if ([command isEqualToString: @"/synctest"]) {
        [appDelegate.comPort sendSync];
        [appDelegate.checkMachine syncAct];
    }
    
    //INIT INFO : ipod ip
	else if ([command isEqualToString: @"/fullsynctest"]) [appDelegate.comPort sendInfo];
    
    //SET IP SERVER :
	else if ([command isEqualToString: @"/ipregie"]) {
        if ([orders count] >= 1) [appDelegate.comPort setIpServer:[orders objectAtIndex:0]];
    }
    
    //FORCE AUTO :
	else if ([command isEqualToString: @"/mastermode"]) {
        [appDelegate.interFace setMode:AUTO];
        gomaster = YES;
    }
    
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
        if ([orders count] >= 1)
        {
            message = [[orders componentsJoinedByString:@" "] copy];
            gomessage=YES;
        }
    }
    
    //TITLES
    //ADD TEXT
    else if ([command isEqualToString: @"/titles"]) {
        if ([orders count] >= 1)
        {
            [appDelegate.disPlay titlesText:[orders componentsJoinedByString:@" "]];
            //NSLog([orders componentsJoinedByString:@" "]);
            gotitles=YES;
        }
    }
    
    //ONLY IN AUTO MODE
    else if ([appDelegate.interFace mode] == AUTO) {
        
        //LOAD & PLAY MOVIE
        if (([command isEqualToString: @"/loadmovie"]) || ([command isEqualToString: @"/playmovie"]) || ([command isEqualToString: @"/playstream"])) {
            
            if ([orders count] >= 1) [appDelegate.moviePlayer load: [[orders componentsJoinedByString:@" "] copy]];
            else NSLog(@"dry playmovie");
            playmovie = ([command isEqualToString: @"/playmovie"] || [command isEqualToString: @"/playstream"]);
        }
        
        
        //PLAY LIVE
        else if ([command isEqualToString: @"/playlive"]) {
            if ([orders count] >= 1) [appDelegate.live2Player load : [[orders componentsJoinedByString:@" "] copy]];
            playlive = YES;
        }
        
        //SKIP AT TIME
        else if ([command isEqualToString: @"/attime"]) {
            if ([orders count] >= 1) [appDelegate.moviePlayer skip:[[orders objectAtIndex:0] intValue]];
        }
        
        //STOP MOVIE
        else if ([command isEqualToString: @"/stopmovie"])
        {
            stopmovie = YES;
            stoprecord = YES;
        }
        
        //STOP MOVIE
        else if ([command isEqualToString: @"/stoplive"]) stoplive = YES;
        
        //LOOP
        else if ([command isEqualToString: @"/loop"]) {
            [appDelegate.moviePlayer loopMedia:TRUE];
        }
        
        //UNPAUSE
        else if ([command isEqualToString: @"/unloop"]) {
            [appDelegate.moviePlayer loopMedia:FALSE];
        }
        
        //LOOP
        else if ([command isEqualToString: @"/flip"]) {
            [appDelegate.disPlay flip:TRUE];
        }
        
        //UNPAUSE
        else if ([command isEqualToString: @"/unflip"]) {
            [appDelegate.disPlay flip:FALSE];
        }
        
        //PAUSE
        else if ([command isEqualToString: @"/pause"]) {
            [appDelegate.moviePlayer pause];
        }
        
        //UNPAUSE
        else if ([command isEqualToString: @"/unpause"]) {
            [appDelegate.moviePlayer unpause];
        }
        
        //START RECORD
        else if ([command isEqualToString: @"/rec"]) {
            if ([orders count] >= 1)
            {
                [appDelegate.recOrder setFile: [[orders objectAtIndex:0] copy]];
                [appDelegate.recOrder setOrientation: [[orders objectAtIndex:1] copy]];
                startrecord = YES;
            }
        }
        
        //MUTE
        else if ([command isEqualToString: @"/mute"]) gomute = YES;
        
        //UNMUTE
        else if ([command isEqualToString: @"/unmute"]) gounmute = YES;
        
        //VOLUME
        else if ([command isEqualToString: @"/volume"])
        {
            if ([orders count] >= 1)
            {
                newvolume = [[orders objectAtIndex:0] intValue];
                govolume = YES;
            }
        }
        
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
        
        //STOP RECORD
        else if ([command isEqualToString: @"/recstop"]) stoprecord = YES;
        
        //UNFADE
        else if ([command isEqualToString: @"/unfade"]) gounfade = YES;
        
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
    
        //SCHEDULED ORDERS
    //play movie
    if (playmovie)
    {
        if ([appDelegate.recOrder isRecording]) [appDelegate.recOrder stop];
        if ([appDelegate.live2Player isLive]) [appDelegate.live2Player stop];
        [appDelegate.moviePlayer play];
    }
        
    //stop movie
    if (stopmovie) [appDelegate.moviePlayer stop];
    
    //play live
    if (playlive)
    {
        if ([appDelegate.recOrder isRecording]) [appDelegate.recOrder stop];
        if ([appDelegate.moviePlayer isPlaying]) [appDelegate.moviePlayer stop];
        [appDelegate.live2Player start];
    }
    if ([appDelegate.live2Player isLive]) [appDelegate.live2Player beat];
        
    //stop live
    if (stoplive) [appDelegate.live2Player stop];
        
    //volume
    if (gomute) [appDelegate.disPlay mute:YES];
    if (gounmute) [appDelegate.disPlay mute:NO];
    if (govolume) [appDelegate.moviePlayer setVolume:newvolume];
    
    //don't execute video related order if no screen
    if (![[appDelegate.disPlay resolution]  isEqual: @"noscreen"])
    {
        //fade / unfade to color
        if (gofade) [appDelegate.disPlay fade:YES];
        if (gounfade) [appDelegate.disPlay fade:NO];
        
        //white flash
        if (goflash) [appDelegate.disPlay flash];
        
        //titles : add text
        if (gotitles) [appDelegate.disPlay titles];
    }
    
    //start record
    if (startrecord)
    {
        if ([appDelegate.moviePlayer isPlaying]) [appDelegate.moviePlayer stop];
        if ([appDelegate.live2Player isLive]) [appDelegate.live2Player stop];
        [appDelegate.recOrder start];
    }
    //stop record
    if (stoprecord) [appDelegate.recOrder stop];
    
    //message
    if (gomessage) [appDelegate.interFace Bmessage:message];
    
    //CHANGE TABBAR WHEN RECEIVE MASTERMODE MESSAGE
    if (gomaster) [appDelegate.tabBarController setSelectedIndex:0];
    
    //IMPORTANT : if use of a new command BOOL, don't forget to register it in clear function !!!!
    [self clear];
}

//clear pennding actions
- (void) clear {
    
    playmovie = NO;
	stopmovie = NO;
    
    startrecord = NO;
	stoprecord = NO;
    
    playlive = NO;
    stoplive = NO;
    
    gomute = NO;
    gounmute = NO;
    govolume = NO;
    newvolume = 0;
    
    gofade = NO;
    gounfade = NO;
    
    goflash = NO;
    
    gotitles = NO;
    gomessage = NO;
    
    gomaster = NO;
}


@end
