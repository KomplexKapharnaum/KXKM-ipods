//
//  Live2Class.h
//  KXKM
//
//  Created by Snow Leopard User on 16/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface Live2Class : NSObject {
    
    NSString* newsegment;
    
    NSMutableArray* preQueue;
    NSMutableArray* loadQueue;
    
    AVPlayer* liveCurrent;
    
    BOOL use1;
    BOOL live;
    BOOL itemPlaying;
    
    double prorat;
    
    id playbackObserver;
}


-(void) load:(NSString*)file;
-(void) start;
-(void) beat;
-(void) stop;
-(BOOL) isLive;
-(void) playerItemDidReachEnd:(NSNotification *)notification;

@end
