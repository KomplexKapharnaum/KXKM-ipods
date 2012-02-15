//
//  InterfaceClass.m
//  KXKM
//
//  Created by Snow Leopard User on 09/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InterfaceClass.h"
#import "ConfigConst.h"
#import "remoteplayv2AppDelegate.h"

@implementation InterfaceClass

//###########################################################
// INIT

- (id) init
{
    mode = AUTO;
    return [super init];	
}

- (id) initWithTabBar: (UITabBarController*) tabBar
{
    //VUE 1 : controle auto (remote)
    autoView = (remoteplayv2ViewController*)[ tabBar.viewControllers objectAtIndex:0];
    
    //VUE 2 : controle manuel
    manuView = (remoteplayv2UserViewController*) [tabBar.viewControllers objectAtIndex:1];
    [manuView loadView];
    
    //VUE 3 : media liste
    mediaView = (remoteplayv2TableViewController*) [tabBar.viewControllers objectAtIndex:2];
    
    return [self init];	
}

//###########################################################
// MODE CTRL

-(void) setMode:(int) md {
    mode = md;
}

-(int) mode {
    return mode;
}

-(NSString*) modeName {
    if (mode == AUTO) return @"auto";
    else if (mode == MANU) return @"manu";
    else return @"unknown";
}

//###########################################################
// AUTO VIEW : INFO

//INFO (IP box info)
-(void) infoIP:(NSString*)msg{
    
    if ([msg isEqualToString:@"noIP"]) {
        autoView.infoip.text = @"NO";
        autoView.infoip.textColor = [UIColor redColor];
    }
    else {
        autoView.infoip.text = msg;
        autoView.infoip.textColor = [UIColor greenColor];
    }    
}

//INFO (screen box info)
-(void) infoScreen:(NSString*)msg{
    
    if ([msg isEqualToString:@"noscreen"]) {
        autoView.infoscreen.text = @"NO";
        autoView.infoscreen.textColor = [UIColor redColor];
    }
    else {
        autoView.infoscreen.text = msg;
        autoView.infoscreen.textColor = [UIColor greenColor];
    }
}

//INFO (state box info)
-(void) infoState:(NSString*)msg{
    autoView.infostate.text = msg;
}

//INFO (movie box info)
-(void) infoMovie:(NSString*)msg{
    autoView.infomovie.text = msg;
}

//INFO (server box info)
-(void) infoServer:(NSString*)msg{ 
    if ([msg isEqualToString:@"noserver"]) {
        autoView.infoserver.text = @"NO";
        autoView.infoserver.textColor = [UIColor redColor];
    }
    else if ([msg isEqualToString:@"broadcast"]) {
        autoView.infoserver.text = @"Broadcast";
        autoView.infoserver.textColor = [UIColor orangeColor];
    }
    else {
        autoView.infoserver.text = @"Ok";
        autoView.infoserver.textColor = [UIColor greenColor];
    }
}

//INFO (server box info)
-(void) infoName:(NSString*)msg{
    autoView.infoname.text = msg;
}


//###########################################################
// MANU BUTTON INFO

-(void) Bmute:(BOOL)m {
    
    if (m) manuView.movieButton.backgroundColor = [UIColor orangeColor];
    else manuView.movieButton.backgroundColor = [UIColor whiteColor];
    //TODO KEEP GREEN ON UNMUTE IF PLAYING
}

-(void) Bslide:(CMTime)max:(CMTime)current{
    
    if (!manuView.timeSlider.touchInside) {
        manuView.timeSlider.maximumValue = (CGFloat)CMTimeGetSeconds(max);
        manuView.timeSlider.value = (CGFloat)CMTimeGetSeconds(current);
    }
}

-(void) Bfade:(BOOL)m{
    
    if (m) {
        manuView.fadeBlackButton.backgroundColor = [UIColor orangeColor];
        manuView.fadeWhiteButton.backgroundColor = [UIColor orangeColor];
    }
    else {
        manuView.fadeBlackButton.backgroundColor = [UIColor whiteColor];
        manuView.fadeWhiteButton.backgroundColor = [UIColor whiteColor];
    }
}

-(void) Bflash {
    
    manuView.flashButton.backgroundColor = [UIColor orangeColor];
    [UIView beginAnimations:@"Bflash" context:NULL];
    [UIView setAnimationDuration:FLASH_LENGHT];
    manuView.flashButton.backgroundColor = [UIColor whiteColor];
    [UIView commitAnimations];
    
}

-(void) Bmir:(BOOL)m{
    
    if (m) manuView.mirButton.backgroundColor = [UIColor orangeColor];
    else manuView.mirButton.backgroundColor = [UIColor whiteColor];
}

-(void) Bpause:(BOOL)m{
    
    if (m) manuView.pauseButton.backgroundColor = [UIColor orangeColor];
    else manuView.pauseButton.backgroundColor = [UIColor whiteColor];
}

-(void) Bmovie:(NSString*)m:(BOOL)muted {
    
    if (m != nil) {
        [manuView.movieButton setTitle:m forState:UIControlStateNormal];
        manuView.movieButton.backgroundColor = [UIColor greenColor]; 
    }
    else {
        [manuView.movieButton setTitle:@"" forState:UIControlStateNormal];
        manuView.movieButton.backgroundColor = [UIColor whiteColor];    
    }
    if (muted) [self Bmute:YES];
}

-(void) Bnext:(NSString*)m {
    
    if (m != nil) {
        [manuView.nextButton setTitle:m forState:UIControlStateNormal];
        manuView.nextButton.hidden=NO;
    }
    else {
        [manuView.nextButton setTitle:@"" forState:UIControlStateNormal];
        manuView.nextButton.hidden=YES;    
    }
        
}

-(void) Bprev:(NSString*)m {
    
    if (m != nil) {
        [manuView.backButton setTitle:m forState:UIControlStateNormal];
        manuView.backButton.hidden=NO;
    }
    else {
        [manuView.backButton setTitle:@"" forState:UIControlStateNormal];
        manuView.backButton.hidden=YES;    
    }
    
}

-(void) Bmessage:(NSString *)m {
    
    if (m != nil) manuView.messageRegie.text = m;
    else manuView.messageRegie.text = @"";
    
}


//###########################################################
// MEDIA LIST VIEW

-(void) setMediaList:(NSArray*)list{
    
    mediaView.movies = [list copy];
    mediaView.sections = [[NSMutableArray arrayWithObjects: nil] retain];
    BOOL found;
    
    for (NSString *movie in list)
    {
        NSString *c = [[movie componentsSeparatedByString:@"_"] objectAtIndex:0];
        found = NO;
        
        for (NSString *str in mediaView.sections)
            if ([str isEqualToString:c]) found = YES;
        
        if (!found) [mediaView.sections addObject:c];
    }    
    
    [mediaView.moviesTable reloadData];
}
@end
