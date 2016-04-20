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
    
    BOOL startrecord;
    BOOL stoprecord;
    
    BOOL flipmovie;
    BOOL unflipmovie;
    BOOL pausemovie;
    BOOL unpausemovie;
    BOOL loopmovie;
    BOOL unloopmovie;
    
    BOOL gomute;
    BOOL gounmute;
    BOOL govolume;
    int  newvolume;
    
    BOOL gofade;
    BOOL gounfade;
    
    BOOL goflash;
    
    BOOL gomessage;
    
    BOOL gotitles;
    
    BOOL gomaster;
    
    NSString* message;
}

- (void) dispatch:(NSString*) rcvCommand;

- (void) start;
- (void) beat;
- (void) clear;

@end
