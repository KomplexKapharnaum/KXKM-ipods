//
//  MovieClass.h
//  KXKM
//
//  Created by Snow Leopard User on 09/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <Accelerate/Accelerate.h>
#import <MediaToolbox/MediaToolbox.h>
#import "ASBPlayerSubtitling.h"

@interface MovieClass : NSObject {
    
    AVPlayer* player;
    ASBPlayerSubtitling* subtitles;
    AVAudioPlayer* dubPlayer;
    
    UIView *movie1view;
    UIView *movie2view;
    
    UILabel *srtLabel;
    
    AVPlayerLayer *layer1;
    AVPlayerLayer *layer2;
    
    BOOL use1;
    BOOL paused;
    BOOL autoloop;
    int volume;
    BOOL mute;
    
    NSString *movieLoad;
    NSString *movieCurrent;
    int playerType;
    
    NSTimer *Releaser;
}

@property (nonatomic,retain) UIView *movie1view;
@property (nonatomic,retain) UIView *movie2view;
@property (nonatomic,retain) UIView *srtLabel;

-(void) load:(NSString*)file;
-(void) play;
-(void) stop;
-(void) start;
-(void) restart;
-(void) movieDidEnd:(NSNotification *)notification;
-(void) loopMedia:(BOOL)loop;
-(void) switchLoop;
-(BOOL) isLoop;
-(void) pause;
-(void) muteSound:(BOOL)muteMe;
-(void) setVolume:(int)vol;
-(int)  getVolume;
-(void) applyVolume;
-(void) unpause;
-(BOOL) isPause;
-(void) switchpause;
-(void) skip:(int) playbacktimeWanted;
-(NSString*) movie;
-(int) type;
-(BOOL) isPlaying;
-(CMTime) duration;
-(CMTime) currentTime;
- (void) releaseMovie;

- (AVPlayerItem *) itemWithEQ:(AVAsset *)asset;



@end
