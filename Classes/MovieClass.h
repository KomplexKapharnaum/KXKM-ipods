//
//  MovieClass.h
//  KXKM
//
//  Created by Snow Leopard User on 09/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface MovieClass : NSObject {
    
    AVPlayer* player;
    
    BOOL use1;
    BOOL paused;
    
    NSString *movieLoad;
    NSString *movieCurrent;
    
}

-(void) load:(NSString*)file;
-(void) play;
-(void) stop;
-(void) start;
-(void) restart;
-(void) pause;
-(void) unpause;
-(void) switchpause;
-(void) skip:(int) playbacktimeWanted;
-(NSString*) movie;
-(BOOL) isPlaying;
-(CMTime) duration;
-(CMTime) currentTime;

@end
