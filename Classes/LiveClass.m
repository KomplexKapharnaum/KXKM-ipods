//
//  LiveClass.m
//  KXKM
//
//  Created by Snow Leopard User on 09/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LiveClass.h"
#import "ConfigConst.h"
#import "remoteplayv2AppDelegate.h"

@implementation LiveClass

//###########################################################
// INIT

- (id) init
{
    nextsegment = nil;
    
    use1 = YES;
    
    queue = [[NSMutableArray alloc] init];
    
    liveCurrent = nil;
    
    return [super init];	
}

//LOAD
-(void) load:(NSString*)file {
    if ([file length]>=1) nextsegment = file;
}

//PLAY LIVE : add media in queue to prepare
-(void) play{
    
    //URL 
    if (nextsegment == nil) return;
    NSURL *movieURL = [NSURL URLWithString:nextsegment];
    nextsegment = nil;

    //NEW PLAYER
    AVPlayer* livePlayer = [[AVPlayer playerWithURL:movieURL] retain];
    livePlayer.actionAtItemEnd = AVPlayerActionAtItemEndPause;    
    [livePlayer addObserver:self forKeyPath:@"status" options:0 context:nil];
    
    //ADD TO QUEUE
    [queue addObject:livePlayer];
}

//ON READY
- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context
{    
    if ([keyPath isEqualToString:@"status"] )
    {
        //flush unplayed previous segment if the queue is too big (max "LIVE_BUFFER" ready segment in the queue) 
        /*int index = [queue indexOfObject:object];
        for (int i = 0; i < (index-LIVE_BUFFER); i++) {
            [[queue objectAtIndex:0] removeObserver:self forKeyPath:@"status" context:nil];
            [queue removeObjectAtIndex:0];
        }*/
        
        //playPause to preload ?
        //[object play];
        //[object pause];
        
        //if current player is empty, and  start this segment
        if ((liveCurrent == nil) && ([queue count] > LIVE_BUFFER)) [self popAndStart];
    }    
}

//POP AND START
-(void) popAndStart {
    
    if ([queue count] == 0) {
        liveCurrent = nil;
        return;
    }
    
    //TODO add Ready test else liveCurrent = nil;
    //if ([queue count] <= LIVE_BUFFER) {
    //    liveCurrent = nil;
    //}
    
    //handle current segments
    liveCurrent = [[[queue objectAtIndex:0] retain] autorelease];
    
    //remove from the queue
    [queue removeObjectAtIndex:0];
    
    //add Notifications END
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(currentDidFinish:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[liveCurrent currentItem]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(currentDidFinish:)
                                                 name:AVPlayerItemFailedToPlayToEndTimeNotification
                                               object:[liveCurrent currentItem]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(currentDidFinish:)
                                                 name:AVPlayerItemFailedToPlayToEndTimeErrorKey
                                               object:[liveCurrent currentItem]];
    
    
    remoteplayv2AppDelegate *appDelegate = (remoteplayv2AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    //attach to view
    AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:liveCurrent];
    layer.frame = appDelegate.disPlay.player1view.layer.bounds;
    
    UIView *view;
    if (use1) view = appDelegate.disPlay.player1view;
    else view = appDelegate.disPlay.player2view;
    
    view.layer.sublayers = nil;
    [view.layer addSublayer:layer];
    [appDelegate.disPlay.playerview bringSubviewToFront:view];
    
    [liveCurrent play];
    
    use1 = !use1;

    [appDelegate.disPlay mute:[appDelegate.disPlay muted]];
    //TODO CHECK WITH JEX
    //[appDelegate.disPlay mir:[appDelegate.disPlay mired]];
    [appDelegate.disPlay mir:NO];
}


//SEGMENT DID END
-(void)currentDidFinish:(NSNotification *)notification {

    if (liveCurrent != nil) {
        [liveCurrent removeObserver:self forKeyPath:@"status" context:nil];
    
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:[liveCurrent currentItem]];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemFailedToPlayToEndTimeNotification object:[liveCurrent currentItem]];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemFailedToPlayToEndTimeErrorKey object:[liveCurrent currentItem]];
    
        [self popAndStart];
    }
}


//STOP LIVE
-(void) stop{
    
    remoteplayv2AppDelegate *appDelegate = (remoteplayv2AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    //release the current segment
    [self currentDidFinish:nil];
    
    //purge queue
    for (int i = 0; i < [queue count]; i++) {
        [[queue objectAtIndex:0] removeObserver:self forKeyPath:@"status" context:nil];
        [queue removeObjectAtIndex:0];
    }
    
    //clear views
    appDelegate.disPlay.player1view.layer.sublayers = nil;
    appDelegate.disPlay.player2view.layer.sublayers = nil;
    appDelegate.disPlay.playerview.alpha=0;
}

//IS PLAYING
-(BOOL) isPlaying{
    remoteplayv2AppDelegate *appDelegate = (remoteplayv2AppDelegate*)[[UIApplication sharedApplication] delegate];
    return (appDelegate.disPlay.playerview.alpha != 0);
}

//BUFFER SIZE
-(int) queueSize{
    return [queue count];
}


- (void) dealloc
{
    [queue release];
    [super dealloc];	
}

@end
