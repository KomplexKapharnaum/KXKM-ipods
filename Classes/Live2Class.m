//
//  Live2Class.m
//  KXKM
//
//  Created by Snow Leopard User on 16/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#define PREQ_SIZE 3
#define LOADQ_SIZE 2

#import "Live2Class.h"
#import "ConfigConst.h"
#import "remoteplayv2AppDelegate.h"

@implementation Live2Class

//###########################################################
// INIT

- (id) init
{
    newsegment = nil;
    
    preQueue = [[NSMutableArray alloc] init];
    loadQueue = [[NSMutableArray alloc] init];
    
    use1 = YES;
    isLive = NO;
    itemPlaying = NO;
    
    return [super init];
}


//LOAD
-(void) load:(NSString*)file {
    if ([file length]>=1) newsegment = [file copy];
    //NSLog(@" segment recieved %@",file);
    [self start];
}

//###########################################################
// WORKER TIMER

// start Runner timer
-(void) start {
    if (!isLive) {
        remoteplayv2AppDelegate *appDelegate = (remoteplayv2AppDelegate*)[[UIApplication sharedApplication] delegate];
        isLive = YES;
        [appDelegate.disPlay live:YES];
    }
}

- (BOOL) isLive {
    return isLive;
}

// Runner command executed on each timer beat
- (void) beat {
    
    remoteplayv2AppDelegate *appDelegate = (remoteplayv2AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    //READY 1 :if loadQ{1} ready and preQ not empty = destroy loadQ{0}
    //if (([loadQueue count] > 1) && ([preQueue count] > 0)) {
        //AVPlayer* liveP1 = [loadQueue objectAtIndex:1];
        //if (liveP1.status == AVPlayerItemStatusReadyToPlay) [loadQueue removeObjectAtIndex:0];
    //}
    
    BOOL fin = NO;
    if (prorat > 0.95) fin = YES;
    
    //READY 0 : if loadQ{0} ready and (item finnished or loadQ{1} ready) = move loadQ{0} on display        
    if ([loadQueue count] > 0) {
                
        BOOL ready1 = NO;
        if ([loadQueue count] > 1) {
            AVPlayer* liveP1 = [loadQueue objectAtIndex:1];
            ready1 = (liveP1.status == AVPlayerItemStatusReadyToPlay);
        }
        
        AVPlayer* liveP0 = [loadQueue objectAtIndex:0];
        BOOL ready0 = (liveP0.status == AVPlayerItemStatusReadyToPlay);
        
        //if 2 segment are ready push away the current one
        BOOL push = NO;
        if (ready1 && ready0) push = YES;
        
        //if the next segment is ready
        if (ready0) {
            //push the next segment if : first start / two next segment ready / segment reach end
            if ((!itemPlaying) || (push) || (fin)) {
                
                //if (push) NSLog(@"pushed (%f %%)",(prorat*100));
                //if (!itemPlaying) NSLog(@"finnished");
                //if (fin) NSLog(@"finnished (%f %%)",(prorat*100));                
                
                if (playbackObserver != nil) [liveCurrent removeTimeObserver:playbackObserver];
                playbackObserver = nil;
                
                //handle as main player
                liveCurrent = [liveP0 retain];
                [loadQueue removeObjectAtIndex:0];
                liveCurrent.actionAtItemEnd = AVPlayerActionAtItemEndPause;
            
                itemPlaying = TRUE;
                
                //watch progression ratio
                CMTime interval = CMTimeMake(2, 100);  // 50ms
                playbackObserver = [liveCurrent addPeriodicTimeObserverForInterval:interval queue:dispatch_get_current_queue() usingBlock: ^(CMTime time) {
                        CMTime endTime = CMTimeConvertScale (liveCurrent.currentItem.asset.duration, liveCurrent.currentTime.timescale, kCMTimeRoundingMethod_RoundHalfAwayFromZero);
                        if (CMTimeCompare(endTime, kCMTimeZero) != 0) {
                            double normalizedTime = (double) liveCurrent.currentTime.value / (double) endTime.value;
                            prorat = normalizedTime;
                        }
                    }];
                        
                
                //attach to view
                AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:liveCurrent];
                layer.frame = appDelegate.disPlay.live1view.layer.bounds;
            
                UIView *view;
                if (use1) view = appDelegate.disPlay.live1view;
                else view = appDelegate.disPlay.live2view;
            
                if (view.layer.sublayers != nil) [[[view.layer.sublayers objectAtIndex:0] player] release];
                view.layer.sublayers = nil;
                [view.layer addSublayer:layer];
                
                [liveCurrent play];
                
                //animate fade in DISABLED
                //view.alpha = 0;
                [appDelegate.disPlay.liveview bringSubviewToFront:view];
                //[UIView beginAnimations:@"fadelive" context:NULL];
                //[UIView setAnimationDuration:0.2];
                //view.alpha = 1;
                //[UIView commitAnimations];
                
                
            
                use1 = !use1;
            
                [appDelegate.disPlay mute:[appDelegate.disPlay muted]];
                //TODO CHECK WITH JEX
                //[appDelegate.disPlay mir:[appDelegate.disPlay mired]];
                [appDelegate.disPlay mir:NO];
            }
        }        
    } //else if (fin) NSLog(@"finnished but not ready ! (%f %%)",(prorat*100));
    
    //REFILL loadQ by pulling preQ
    while (([loadQueue count] < LOADQ_SIZE) && ([preQueue count] > 0)) {
        
        //pull from preQ
        NSURL* segURL = [preQueue objectAtIndex:0]; //TODO Maybe direct pass to AVPlayer constructor
        [preQueue removeObjectAtIndex:0];
        
        //create player
        AVPlayer* livePlayer = [[[AVPlayer playerWithURL:segURL] retain] autorelease]; //TODO Maybe not retain
        
        //add to loadQueue
        [loadQueue addObject:livePlayer];
    }
    
    //NEW arrival push in preQ
    if (newsegment != nil) {
        
        //if preQ full = clear it !
        if ([preQueue count] == PREQ_SIZE) [preQueue removeAllObjects];
        
        //create URL
        NSURL *segment = [[NSURL URLWithString:newsegment] retain]; //TODO Maybe not RETAIN !!
        
        //add URL to preQueue
        [preQueue addObject:segment];  
        newsegment = nil;
    }
    
    //TODO re-set clock (disable auto repeat)
}

-(void) playerItemDidReachEnd:(NSNotification *)notification {
    itemPlaying = NO;
}

//STOP LIVE
-(void) stop{
    
    isLive = NO;
    
    [preQueue removeAllObjects];
    [loadQueue removeAllObjects];
    
    remoteplayv2AppDelegate *appDelegate = (remoteplayv2AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    if (playbackObserver != nil) [liveCurrent removeTimeObserver:playbackObserver];
    playbackObserver = nil;
    
    //clear views
    appDelegate.disPlay.live1view.layer.sublayers = nil;
    appDelegate.disPlay.live2view.layer.sublayers = nil;
    [appDelegate.disPlay live:NO];
}

@end
