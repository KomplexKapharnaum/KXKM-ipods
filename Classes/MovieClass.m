//
//  MovieClass.m
//  KXKM
//
//  Created by Snow Leopard User on 09/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MovieClass.h"
#import "remoteplayv2AppDelegate.h"
#import "ConfigConst.h"

@implementation MovieClass


//###########################################################
// INIT

- (id) init
{
    use1 = YES;
    
    movieLoad = nil;
    movieCurrent = nil;
    
    playerType = PLAYER_LOCAL;
    
    [self loopMedia:FALSE];
    [self setVolume:100];
    [self muteSound:FALSE];
    
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
    
    if ([[appDelegate.disPlay resolution]  isEqual: @"noscreen"]) return;
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
        
        //Player Type
        if ([appDelegate.filesManager find:movieLoad]) playerType = PLAYER_LOCAL;
        else {
            if (STREAM_UNKNOWN_MOVIE) playerType = PLAYER_STREAM;
            else {
                [self stop];
                return;
            }
        }
        
        //Player
        player = [AVPlayer playerWithURL:[appDelegate.filesManager url:movieLoad]];
        player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
        
        //auto-loop
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(movieDidEnd:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                     object:[player currentItem]];
        
        //Layer
        AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:player];
        layer.frame = appDelegate.disPlay.movie1view.layer.bounds;
        
        UIView *view;
        if (use1) view = appDelegate.disPlay.movie1view;
        else view = appDelegate.disPlay.movie2view;
        
        view.layer.sublayers = nil;
        [view.layer addSublayer:layer];
        [appDelegate.disPlay.movieview bringSubviewToFront:view];
        
        movieCurrent = [movieLoad copy];
        
        [self start];
        use1 = !use1;
        
        //Releaser
        if (Releaser != nil) [Releaser invalidate];
        Releaser = [NSTimer scheduledTimerWithTimeInterval:TIMER_RELMOVIE 
                                                    target:self selector:@selector(releaseMovie) userInfo:nil repeats:NO];
        
        
        [appDelegate.disPlay mute:[appDelegate.disPlay muted]];
        //TODO CHECK WITH JEX
        //[appDelegate.disPlay mir:[appDelegate.disPlay mired]];
        [appDelegate.disPlay mir:NO];
        
        
        //SET CURRENT - NEXT - PREVIOUS 
        [appDelegate.interFace Bmovie:movieCurrent:[appDelegate.disPlay muted]];
        [appDelegate.interFace Bnext:[appDelegate.filesManager after:movieCurrent]];
        [appDelegate.interFace Bprev:[appDelegate.filesManager before:movieCurrent]];
    }    
}

//MOVIE END OBSEREVER (auto loop)
- (void)movieDidEnd:(NSNotification *)notification {
    if (autoloop)
    {
        AVPlayerItem *p = [notification object];
        [p seekToTime:kCMTimeZero];
    }
    else [self stop];
}

//START
-(void) start {
    
    if (![self isPlaying]) return;
    
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
    
    playerType = PLAYER_LOCAL;
}

//LOOP
-(void) loopMedia:(BOOL)loop{
    autoloop = loop;
    
    remoteplayv2AppDelegate *appDelegate = (remoteplayv2AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate.interFace Bloop:autoloop];
}

//LOOP
-(BOOL) isLoop{
    return autoloop;
}

//SWITCH LOOP
-(void) switchLoop{
    [self loopMedia:!autoloop];
}

//MUTE
-(void) muteSound:(BOOL)muteMe {
    mute = muteMe;
    [self applyVolume];
}

//VOLUME
-(void) setVolume:(int)vol{
    volume = vol;
    [self applyVolume];
    remoteplayv2AppDelegate *appDelegate = (remoteplayv2AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate.interFace Bvolume:volume];
}

//VOLUME
-(int) getVolume{
    return volume;
}

//VOLUME
-(void) applyVolume{
    
    if (![self isPlaying]) return;
    
    float vol;
    if (mute) vol = 0.0;
    else vol = volume/100.0;
    
    if ([player respondsToSelector:@selector(setVolume:)]) {
        player.volume = vol;
    }else {
        NSArray *audioTracks = player.currentItem.asset.tracks;
        
        // Mute all the audio tracks
        NSMutableArray *allAudioParams = [NSMutableArray array];
        for (AVAssetTrack *track in audioTracks) {
            AVMutableAudioMixInputParameters *audioInputParams =[AVMutableAudioMixInputParameters audioMixInputParameters];
            [audioInputParams setVolume:vol atTime:kCMTimeZero];
            [audioInputParams setTrackID:[track trackID]];
            [allAudioParams addObject:audioInputParams];
        }
        AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
        [audioMix setInputParameters:allAudioParams];
        
        [player.currentItem setAudioMix:audioMix];
    }
}

//PAUSE
-(void) pause{
    
    if (![self isPlaying]) return;
    
    [player pause];
    paused = YES;
    
    remoteplayv2AppDelegate *appDelegate = (remoteplayv2AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate.interFace Bpause:YES];
}

//UNPAUSE
-(void) unpause{
    [self start];
}

-(BOOL) isPause{
    return paused;
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
    if ([self isPlaying]) return movieCurrent;
    else return nil;
}

//CURRENT MOVIE TYPE
-(int) type{
    return playerType;
}

//IS PLAYING
-(BOOL) isPlaying{
    return (movieCurrent != nil);
}

//DURATION
-(CMTime) duration{
    if ([self isPlaying]) return [[player currentItem] duration];
    else return CMTimeMakeWithSeconds(0, 1);
}

//CURRENT TIME
-(CMTime) currentTime{
    if ([self isPlaying]) return [player currentTime];
    else return CMTimeMakeWithSeconds(0, 1);
}

//RELEASE PLAYER
- (void) releaseMovie {
    
    remoteplayv2AppDelegate *appDelegate = (remoteplayv2AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (use1) appDelegate.disPlay.movie1view.layer.sublayers = nil;
    else appDelegate.disPlay.movie2view.layer.sublayers = nil;

    Releaser = nil;
}

@end
