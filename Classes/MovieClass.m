//
//  MovieClass.m
//  KXKM
//
//  Created by Snow Leopard User on 09/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MovieClass.h"
#import "remoteplayv2AppDelegate.h"

@implementation MovieClass


//###########################################################
// INIT

- (id) init
{
    use1 = YES;
    
    movieLoad = nil;
    movieCurrent = nil;
    
    return [super init];	
}


//###########################################################
// MOVIE PLAYER CONTROLS

//LOAD
-(void) load:(NSString*)file {
    if ([file length]>=1) movieLoad = file;
}

//PLAY 
-(void) play{
    
    remoteplayv2AppDelegate *appDelegate = (remoteplayv2AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    if (movieLoad == nil) return;    
    
    if ([movieLoad isEqualToString:@"*"] && (movieCurrent != nil)) {
        movieLoad = [movieCurrent copy];
        return;
    }
    
    if ([movieLoad isEqualToString:@"stop"]) {
        [self stop];
        return;
    }
    
    //if same movie just rewind
    if ([movieCurrent isEqualToString:movieLoad]) [self restart];

    //else create new player
    else {  
        
        //Player
        player = [AVPlayer playerWithURL:[appDelegate.filesManager url:movieLoad]];
        player.actionAtItemEnd = AVPlayerActionAtItemEndPause;
        
        //Layer
        AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:player];
        layer.frame = appDelegate.disPlay.movie1view.layer.bounds;
        
        UIView *view;
        if (use1) view = appDelegate.disPlay.movie1view;
        else view = appDelegate.disPlay.movie2view;
        
        view.layer.sublayers = nil;
        [view.layer addSublayer:layer];
        [appDelegate.disPlay.movieview bringSubviewToFront:view];
        //TODO ADD OBSERVER ON LAYER TO RELEASE THE OTHER ONE
        
        [self start];
        
        use1 = !use1;
        
        [appDelegate.disPlay mute:[appDelegate.disPlay muted]];
        //TODO CHECK WITH JEX
        //[appDelegate.disPlay mir:[appDelegate.disPlay mired]];
        [appDelegate.disPlay mir:NO];
        
        movieCurrent = [movieLoad copy];
        
        //SET CURRENT - NEXT - PREVIOUS 
        [appDelegate.interFace Bmovie:movieCurrent:[appDelegate.disPlay muted]];
        [appDelegate.interFace Bnext:[appDelegate.filesManager after:movieCurrent]];
        [appDelegate.interFace Bprev:[appDelegate.filesManager before:movieCurrent]];
    }    
}

//START
-(void) start {
    [player play];
    paused = NO;
    
    remoteplayv2AppDelegate *appDelegate = (remoteplayv2AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate.interFace Bpause:NO];
}

//RESTART (from beginning)
-(void) restart {
    [self skip:0];
    [self start];
}

//STOP
-(void) stop{
    
    remoteplayv2AppDelegate *appDelegate = (remoteplayv2AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    appDelegate.disPlay.movie1view.layer.sublayers = nil;
    appDelegate.disPlay.movie2view.layer.sublayers = nil;
    
    paused = NO;
    
    if ([movieLoad isEqualToString:@"*"] && (movieCurrent != nil)) movieLoad = [movieCurrent copy];
    movieCurrent = nil;
    
    [appDelegate.interFace Bmovie:nil:[appDelegate.disPlay muted]];
}

//PAUSE
-(void) pause{
    [player pause];
    paused = YES;
    
    remoteplayv2AppDelegate *appDelegate = (remoteplayv2AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate.interFace Bpause:YES];
}

//UNPAUSE
-(void) unpause{
    [self start];
}

//SWITCH PAUSE
-(void) switchpause{
    if (paused) [self unpause];
    else [self pause];
}

//SKIP
-(void) skip:(int) playbacktimeWanted{
    
    if (![self isPlaying]) return;
    
    if ( CMTimeGetSeconds(player.currentItem.duration) > (playbacktimeWanted/1000)) {
        //TODO Optimize seekToTime, and seekToTime 0 (rewind)
        [player seekToTime:CMTimeMake(playbacktimeWanted, 1000) toleranceBefore: kCMTimeZero toleranceAfter: kCMTimeZero];
        [self start];
    }
    else {
        remoteplayv2AppDelegate *appDelegate = (remoteplayv2AppDelegate*)[[UIApplication sharedApplication] delegate];
        [appDelegate.runMachine dispatch:@"/stopmovie"];
        //TODO REPLACE with [self stop]; but carefully   - direct call from dispatcher : stop is not allowed !
    }
}

//CURRENT MOVIE
-(NSString*) movie{
    return movieCurrent;
}

//IS PLAYING
-(BOOL) isPlaying{
    return (movieCurrent != nil);
}


-(CMTime) duration{
    if ([self isPlaying]) return [[player currentItem] duration];
    else return CMTimeMakeWithSeconds(0, 1);
}

-(CMTime) currentTime{
    if ([self isPlaying]) return [player currentTime];
    else return CMTimeMakeWithSeconds(0, 1);
}

@end