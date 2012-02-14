//
//  LiveClass.h
//  KXKM
//
//  Created by Snow Leopard User on 09/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface LiveClass : NSObject {
    
    NSString* nextsegment; 
    
    BOOL use1;
    
    NSMutableArray* queue;
    
    AVPlayer* playerAVF;
    AVPlayer* playerAVF1;
    AVPlayer* playerAVF2;
    AVPlayer* playerAVF3;
    
    AVPlayer* liveCurrent;
    AVPlayer* liveNext;
    
    BOOL lock1;
    BOOL lock2;
    BOOL lock3;
    
    int releasePlayer1;
    int releasePlayer2;
    int releasePlayer3;
    
}

-(void) load:(NSString*)file;
-(void) play;
-(void) popAndStart;
-(void) currentDidFinish:(NSNotification *)notification;
-(void) stop;



@end
