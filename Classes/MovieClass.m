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
@synthesize movie1view, movie2view, srtLabel;

//###########################################################
// INIT

- (id) init
{
    use1 = YES;
    
    movieLoad = nil;
    movieCurrent = nil;
    
    playerType = PLAYER_LOCAL;
    
    //Create PLAYER 1 view
    movie1view = [[UIView alloc] initWithFrame:CGRectMake(0,0,100,100)];
    movie1view.backgroundColor = [UIColor clearColor];
    movie1view.alpha=1;
    
    //Create PLAYER 2 view
    movie2view = [[UIView alloc] initWithFrame:CGRectMake(0,0,100,100)];
    movie2view.backgroundColor = [UIColor clearColor];
    movie2view.alpha=1;
    
    //Create SRT label
    srtLabel = [[UILabel alloc] init];
    [srtLabel setBackgroundColor:[UIColor clearColor]];
    [srtLabel setTextAlignment:NSTextAlignmentCenter];
    srtLabel.textColor = [UIColor yellowColor];
    srtLabel.text = @"";
    srtLabel.lineBreakMode = NSLineBreakByWordWrapping;
    srtLabel.numberOfLines = 0;
    
    subtitles = [ASBPlayerSubtitling new];
    subtitles.label = srtLabel;
    
    dubPlayer = nil;
    
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
    
    //if ([[appDelegate.disPlay resolution]  isEqual: @"noscreen"]) return;
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
        
        // Create the AVAsset
        AVAsset *asset = [AVAsset assetWithURL:[appDelegate.filesManager url:movieLoad]];
        AVPlayerItem *playerItem = nil;
        
        //ATTACH EQ
        if (FALSE) playerItem = [self itemWithEQ:asset];
        
        //Make item
        if (playerItem == nil) playerItem = [AVPlayerItem playerItemWithAsset:asset];
        
        //Player
        player = nil;
        player = [AVPlayer playerWithPlayerItem:playerItem];
        player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
        
        // Subtitles
        if (ENABLE_SRT) {
            NSURL* srtfile = [appDelegate.filesManager srtfor:movieLoad];
            [subtitles apply:srtfile to:player];
        }
        
        // Audio DUB
        if (ENABLE_DUB) {
            if (dubPlayer != nil) [dubPlayer pause];
            dubPlayer = nil;
            NSURL* audiodub = [appDelegate.filesManager dubfor:movieLoad];
            if (audiodub) dubPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audiodub error:nil];
        }
        
        //auto-loop
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(movieDidEnd:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                     object:[player currentItem]];
        
        //Layer
        AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:player];
        
        //select View
        UIView *view;
        if (use1) view = movie1view;
        else view = movie2view;
        
        
        //Attach Layer
        layer.frame = movie1view.layer.bounds;
        view.layer.sublayers = nil;
        [view.layer addSublayer:layer];
        
        //bring to front
        if (appDelegate.disPlay.movieview)
            [appDelegate.disPlay.movieview bringSubviewToFront:view];
        
        movieCurrent = [movieLoad copy];
        
        //let's play
        [self start];
        use1 = !use1;
        
        //Releaser of previous player
        if (Releaser != nil) [Releaser invalidate];
        Releaser = [NSTimer scheduledTimerWithTimeInterval:TIMER_RELMOVIE 
                                                    target:self selector:@selector(releaseMovie) userInfo:nil repeats:NO];
        
        
        [appDelegate.disPlay mute:[appDelegate.disPlay muted]];
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
    NSLog(@"movie did end");
    if (autoloop)
    {
        AVPlayerItem *p = [notification object];
        [p seekToTime:kCMTimeZero];
        if (dubPlayer  != nil) [dubPlayer setCurrentTime:0];
    }
    else [self stop];
}

//START
-(void) start {
    
    if (![self isPlaying]) return;
    
    [player play];
    if (dubPlayer != nil) [dubPlayer play];
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
    
    movie1view.layer.sublayers = nil;
    movie2view.layer.sublayers = nil;
    
    [subtitles stop];
    if (dubPlayer != nil) [dubPlayer pause];
    
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
    [appDelegate.comPort sendVolume:volume];
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
    
    if (dubPlayer != nil)
    {
        [self mainPlayerVolume:0.0];
        [dubPlayer setVolume:vol];
    }
    else [self mainPlayerVolume:vol];
    
}

// INTERNAL PLAYER VOLUME
-(void) mainPlayerVolume:(float) vol {
    
    if ([player respondsToSelector:@selector(setVolume:)]) {
        player.volume = vol;
        
    }else {
        NSArray *audioTracks = player.currentItem.asset.tracks;
        
        // Set all the audio tracks
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
    if (dubPlayer != nil) [dubPlayer pause];
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
        
        // Seek DUB player
        if (dubPlayer != nil) {
            if ((playbacktimeWanted/1000) > dubPlayer.duration) [dubPlayer setCurrentTime:dubPlayer.duration];
            else [dubPlayer setCurrentTime:(playbacktimeWanted/1000)];
        }
        
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
    
    //if (use1) NSLog(@"releasing m1");
    //else NSLog(@"releasing m2");
    
    if (use1) movie1view.layer.sublayers = nil;
    else movie2view.layer.sublayers = nil;
    
    Releaser = nil;
}

////EQ SECTION

void eq_init(MTAudioProcessingTapRef tap, void *clientInfo, void **tapStorageOut)
{
    NSLog(@"Initialising the Audio Tap Processor");
    *tapStorageOut = clientInfo;
}

void eq_finalize(MTAudioProcessingTapRef tap)
{
    NSLog(@"Finalizing the Audio Tap Processor");
}

void eq_prepare(MTAudioProcessingTapRef tap, CMItemCount maxFrames, const AudioStreamBasicDescription *processingFormat)
{
    NSLog(@"Preparing the Audio Tap Processor");
}

void eq_unprepare(MTAudioProcessingTapRef tap)
{
    NSLog(@"Unpreparing the Audio Tap Processor");
}

void eq_process(MTAudioProcessingTapRef tap, CMItemCount numberFrames,
             MTAudioProcessingTapFlags flags, AudioBufferList *bufferListInOut,
             CMItemCount *numberFramesOut, MTAudioProcessingTapFlags *flagsOut)
{
    NSLog(@"Processing the Audio Tap");
    OSStatus err = MTAudioProcessingTapGetSourceAudio(tap, numberFrames, bufferListInOut,
                                                      flagsOut, NULL, numberFramesOut);
    if (err) NSLog(@"Error from GetSourceAudio: %ld", err);
    
    //LAKEViewController *self = (__bridge LAKEViewController *) MTAudioProcessingTapGetStorage(tap);
    
    //float scalar = self.slider.value;
    float scalar = 2.0;
    
    vDSP_vsmul(bufferListInOut->mBuffers[1].mData, 1, &scalar, bufferListInOut->mBuffers[1].mData, 1, bufferListInOut->mBuffers[1].mDataByteSize / sizeof(float));
    vDSP_vsmul(bufferListInOut->mBuffers[0].mData, 1, &scalar, bufferListInOut->mBuffers[0].mData, 1, bufferListInOut->mBuffers[0].mDataByteSize / sizeof(float));
}

//attachEQ using MT-TAP
- (AVPlayerItem *) itemWithEQ:(AVAsset *)asset {
    
    //get audio track
    //AVAssetTrack *audioTrack = [[asset tracks] objectAtIndex:0];
    AVAssetTrack *audioTrack = [asset tracksWithMediaType:AVMediaTypeAudio][0];
    
    //get audio input params
    AVMutableAudioMixInputParameters *inputParams = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:audioTrack];
    
    // Create a processing tap for the input parameters
    MTAudioProcessingTapCallbacks callbacks;
    callbacks.version = kMTAudioProcessingTapCallbacksVersion_0;
    callbacks.clientInfo = (__bridge void *)(self);
    callbacks.init = eq_init;
    callbacks.prepare = eq_prepare;
    callbacks.process = eq_process;
    callbacks.unprepare = eq_unprepare;
    callbacks.finalize = eq_finalize;
    
    MTAudioProcessingTapRef tap;
    // The create function makes a copy of our callbacks struct
    OSStatus err = MTAudioProcessingTapCreate(kCFAllocatorDefault, &callbacks,
                                              kMTAudioProcessingTapCreationFlag_PostEffects, &tap);
    if (err || !tap) {
        NSLog(@"Unable to create the Audio Processing Tap");
        return nil;
    }
    assert(tap);
    
    // Assign the tap to the input parameters
    inputParams.audioTapProcessor = tap;
    
    // Create a new AVAudioMix and assign it to our AVPlayerItem
    AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
    audioMix.inputParameters = @[inputParams];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
    playerItem.audioMix = audioMix;
    return playerItem;
}


@end
