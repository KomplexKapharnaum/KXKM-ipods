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
    
    if (mode == AUTO){
        //manuView.backButton.enabled=NO;
        //manuView.backButton.hidden=YES;
        //manuView.nextButton.enabled=NO;
        //manuView.nextButton.hidden=YES;
        //manuView.fadeBlackButton.enabled=NO;
        //manuView.fadeBlackButton.hidden=YES;
        //manuView.fadeWhiteButton.enabled=NO;
        //manuView.fadeWhiteButton.hidden=YES;
        //manuView.pauseButton.enabled=NO;
        //manuView.pauseButton.hidden=YES;
    }
    else if (mode == MANU){
        //manuView.backButton.enabled=YES;
        //manuView.backButton.hidden=NO;
        //manuView.nextButton.enabled=YES;
        //manuView.nextButton.hidden=NO;
        //manuView.fadeBlackButton.enabled=YES;
        //manuView.fadeBlackButton.hidden=NO;
        //manuView.fadeWhiteButton.enabled=YES;
        //manuView.fadeWhiteButton.hidden=NO;
        //manuView.pauseButton.enabled=YES;
        //manuView.pauseButton.hidden=NO;
    }

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

//LINK
-(void) infoLink:(NSString*)msg{
    
    if ([msg isEqualToString:@"nolink"]) {
        autoView.infolink.text = @"NO";
        autoView.infolink.textColor = [UIColor redColor];
    }
    else {
        autoView.infolink.text = msg;
        autoView.infolink.textColor = [UIColor greenColor];
    }
}

//INFO (state box info)
-(void) infoState:(NSString*)msg{
    autoView.infostate.text = msg;
}

//INFO (ctrl box info)
-(void) infoCtrl:(NSString*)msg{
    autoView.infoctrl.text = msg;
}

//INFO (movie box info)
-(void) infoMovie:(NSString*)msg{
    autoView.infomovie.text = msg;
}

//INFO (record info)
-(void) infoRec:(BOOL)recording{
    if (recording) autoView.inforec.backgroundColor = [UIColor redColor];
    else autoView.inforec.backgroundColor = [UIColor blackColor];
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
        autoView.infoserver.text = msg;
        autoView.infoserver.textColor = [UIColor greenColor];
    }
}

//INFO (server box info)
-(void) infoName:(NSString*)msg{
    autoView.infoname.text = msg;
}

-(NSString*) getInfoName{
    return autoView.infoname.text;
}


//###########################################################
// MANU BUTTON INFO

-(void) Bslide:(CMTime)maxi:(CMTime)current{
    
    if (!manuView.timeSlider.touchInside) {
        manuView.timeSlider.maximumValue = (CGFloat)CMTimeGetSeconds(maxi);
        manuView.timeSlider.value = (CGFloat)CMTimeGetSeconds(current);
    }
    
    NSUInteger dTotalSeconds = CMTimeGetSeconds(current);
    NSUInteger dHours = floor(dTotalSeconds / 3600);
    NSUInteger dMinutes = floor(dTotalSeconds % 3600 / 60);
    NSUInteger dSeconds = floor(dTotalSeconds % 3600 % 60);
    
    NSUInteger tTotalSeconds = CMTimeGetSeconds(maxi);
    NSUInteger tHours = floor(tTotalSeconds / 3600);
    NSUInteger tMinutes = floor(tTotalSeconds % 3600 / 60);
    NSUInteger tSeconds = floor(tTotalSeconds % 3600 % 60);
    
    NSString *videoDurationText = [NSString stringWithFormat:@"%i:%02i:%02i / %i:%02i:%02i",dHours, dMinutes, dSeconds,tHours, tMinutes, tSeconds];
    manuView.timeLabel.text = videoDurationText;
    
}

-(void) Bvolume:(int)vol{
    
    if (!manuView.volumeSlider.touchInside)
        manuView.volumeSlider.value = vol;
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
    
    if (m) autoView.mirButtonauto.backgroundColor = [UIColor orangeColor];
    else autoView.mirButtonauto.backgroundColor = [UIColor colorWithWhite:1 alpha:0.09]; 
}

-(void) Bpause:(BOOL)m{
    
    if (m) manuView.pauseButton.backgroundColor = [UIColor orangeColor];
    else manuView.pauseButton.backgroundColor = [UIColor whiteColor];
}

-(void) Bloop:(BOOL)m{
    
    if (m) manuView.loopButton.backgroundColor = [UIColor orangeColor];
    else manuView.loopButton.backgroundColor = [UIColor whiteColor];
}

-(void) Bmovie:(NSString*)m:(BOOL)muted {
    
    if (m != nil)
    {
        [manuView.movieButton setTitle:m forState:UIControlStateNormal];
        if (muted) manuView.movieButton.backgroundColor = [UIColor orangeColor];
        else manuView.movieButton.backgroundColor =[UIColor colorWithRed:0/255.0f green:110/255.0f blue:0/255.0f alpha:1.0f];;
    }
    else
    {
        [manuView.movieButton setTitle:@"" forState:UIControlStateNormal];
        if (muted) manuView.movieButton.backgroundColor = [UIColor orangeColor];
        else manuView.movieButton.backgroundColor = [UIColor darkGrayColor];
    }
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
