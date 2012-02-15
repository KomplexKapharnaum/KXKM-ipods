//
//  RunClass.h
//  KXKM
//
//  Created by Snow Leopard User on 09/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RunClass : NSObject {
    
    NSTimer *timerRunner;
    
    BOOL playmovie;
	BOOL stopmovie;
    
    BOOL playlive;
    BOOL stoplive;
    
    BOOL gomute;
    BOOL gounmute;
    
    BOOL gofade;
    BOOL gounfade;
    
    BOOL goflash;
    
    BOOL gomessage;
    
    BOOL gotitles; 
    
    NSString* message;
}

- (void) dispatch:(NSString*) rcvCommand;

- (void) start;
- (void) beat;
- (void) clear;

@end
