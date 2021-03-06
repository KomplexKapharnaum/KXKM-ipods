//
//  InterfaceClass.h
//  KXKM
//
//  Created by Snow Leopard User on 09/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "remoteplayv2ViewController.h"
#import "remoteplayv2TableViewController.h"
#import "remoteplayv2UserViewController.h"

@interface InterfaceClass : NSObject {
    
    int mode;
    UIColor* activeBtnColor;
    UIColor* notactiveBtnColor;

    //INTERFACES CONTROLLERS
    remoteplayv2ViewController      *autoView;
    remoteplayv2UserViewController  *manuView;
    remoteplayv2TableViewController *mediaView;
}

//INIT
- (id) initWithTabBar: (UITabBarController*) tabBar;

//MODE INFO
-(void) setMode:(int) md;
-(int) mode;
-(NSString*) modeName;

//AUTO INFO
-(void) infoIP:(NSString*)msg;
-(void) infoScreen:(NSString*)msg;
-(void) infoState:(NSString*)msg;
-(void) infoCtrl:(NSString*)msg;
-(void) infoMovie:(NSString*)msg;
-(void) infoServer:(NSString*)msg;
-(void) infoName:(NSString*)msg;
-(void) infoLink:(NSString*)msg;
-(void) infoRec:(BOOL)recording;
-(NSString*) getInfoName;

//MANU INFO
-(void) Bslide:(CMTime)maxi:(CMTime)current;
-(void) Bvolume:(int)vol;
-(void) Bfade:(BOOL)m;
-(void) Bflash;
-(void) Bmir:(BOOL)m;
-(void) Bpause:(BOOL)m;
-(void) Bloop:(BOOL)m;
-(void) Bflip:(BOOL)m;
-(void) Bmovie:(NSString*)m:(BOOL)muted;
-(void) Bnext:(NSString*)m;
-(void) Bprev:(NSString*)m;
-(void) Bmessage:(NSString*)m;

//MEDIA LIST
-(void) setMediaList:(NSArray*)list;


@end
