//
//  DisplayClass.m
//  KXKM
//
//  Created by Snow Leopard User on 08/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DisplayClass.h"
#import "ConfigConst.h"
#import "remoteplayv2AppDelegate.h"

@implementation DisplayClass

@synthesize _secondWindow,screenResolution;
@synthesize liveview, movieview, srtview;
@synthesize muteview, fadeview, flashview, titlesview, mirview;

//###########################################################
// DISPLAY : screen / views

- (id) init
{
    screenResolution = @"noscreen";
    
    customTitles = @"";
    titlesCounter = 0;
    titlesMode = 1;
    titlesOr = 1;
    
    isFlipped = NO;
    isMuted = NO;
    
    subTitles = [[NSArray alloc] initWithObjects:
                 @"Maintenant",
                 @"Maintenant", 
                 @"Il y a 1 minute",
                 @"Il y a longtemps",
                 @"Il y a quelques secondes",
                 @"5 minutes ago",
                 @"Now",
                 @"Ici et Maintenant",
                 @"Depuis le reseau",
                 @"Imminent",
                 //@"",
                 nil];
    
    
    [self titlesColor:255:255:255:255];
    [self flashColor:255:255:255:255];
    [self fadeColor:255:255:255:255];
    
    return [super init];	
}

//###########################################################
//VIEWS MANAGER

//MUTE
-(void) mute:(BOOL)muteMe {
    
    isMuted = muteMe;
    
    if (muteview) {
        if (muteMe) muteview.alpha = 1;
        else muteview.alpha = 0;
    }
    
    remoteplayv2AppDelegate *appDelegate = (remoteplayv2AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate.moviePlayer muteSound:muteMe];
    [appDelegate.interFace Bmovie:[appDelegate.moviePlayer movie]:muteMe];
}

-(BOOL) muted {
    return isMuted;
}


//MIR
-(void) mir:(BOOL)mirDisp{
    
    if (mirDisp) mirview.alpha = 1;
    else mirview.alpha = 0;
    
    remoteplayv2AppDelegate *appDelegate = (remoteplayv2AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate.interFace Bmir:mirDisp];
}

-(BOOL) mired {
    return (mirview.alpha == 1);
}

//FLIP
-(void) flip:(BOOL)flipDisp{
    
    isFlipped = flipDisp;
    
    if (isFlipped) NSLog(@"flip");
    else NSLog(@"unflip");
    
    if (isFlipped) _secondWindow.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    else _secondWindow.transform = CGAffineTransformMakeScale(1.0, 1.0);
    
    remoteplayv2AppDelegate *appDelegate = (remoteplayv2AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate.interFace Bflip:isFlipped];
}

-(BOOL) flipped {
    return isFlipped;
}

//FADE
-(void) fade:(BOOL)fadeMe{
    
    if(fadeMe){
        float r = (float)fadecolorRed/255;
        float g = (float)fadecolorGreen/255;
        float b = (float)fadecolorBlue/255;
        float a = (float)fadecolorAlpha/255;        
        
        fadeview.backgroundColor=[UIColor colorWithRed:r green:g blue:b alpha:a];
        [UIView beginAnimations:@"fade" context:NULL];
        [UIView setAnimationDuration:1.5];
        fadeview.alpha=a;
        [UIView commitAnimations];
    }
    else {
        [UIView beginAnimations:@"unfade" context:NULL];
        [UIView setAnimationDuration:1.5];
        fadeview.alpha=0;
        [UIView commitAnimations];
    }
    
    remoteplayv2AppDelegate *appDelegate = (remoteplayv2AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate.interFace Bfade:fadeMe];
}

-(void) fadeColor:(int)Red:(int)Green:(int)Blue:(int)Alpha{
    
    fadecolorRed = Red;
    fadecolorGreen = Green;
    fadecolorBlue = Blue;
    if (Alpha > 0) fadecolorAlpha = Alpha;
    else fadecolorAlpha = 255;
}

-(BOOL) faded {
    return (fadeview.alpha > 0);
}

//FLASH
-(void) flash{
    
    float r = (float)flashcolorRed/255;
    float g = (float)flashcolorGreen/255;
    float b = (float)flashcolorBlue/255;
    float a = (float)flashcolorAlpha/255;
    flashview.backgroundColor = [UIColor colorWithRed:r green:g blue:b alpha:1];
    
    flashview.alpha=a;
    [UIView beginAnimations:@"flash" context:NULL];
    [UIView setAnimationDuration:FLASH_LENGHT];
    flashview.alpha=0;
    [UIView commitAnimations];
    
    remoteplayv2AppDelegate *appDelegate = (remoteplayv2AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate.interFace Bflash];
}

-(void) flashColor:(int)Red:(int)Green:(int)Blue:(int)Alpha{
    
    flashcolorRed = Red;
    flashcolorGreen = Green;
    flashcolorBlue = Blue;
    if (Alpha > 0) flashcolorAlpha = Alpha;
    else flashcolorAlpha = 255;
}


//TITLES
-(void) cleartitles {
    NSArray* tv = [titlesview subviews];
    if ([tv count] > 0) for (UIView *v in tv) { [v removeFromSuperview]; }
    NSArray* tv2 = [titlesview2 subviews];
    if ([tv2 count] > 0) for (UIView *v in tv2) { [v removeFromSuperview]; }
    titlesCounter = 0;
}

-(void) titles {
    
    
    //RE-INIT ALL
    if ([customTitles isEqualToString:@"megainit"]) {
        [self cleartitles];  //CLEAR
        titlesOr = 1;        //VERTICAL
        titlesMode = 1;      //MODE 1
        return;
    }
    
    //SET MODE1
    if ([customTitles isEqualToString:@"megamode1"]) {
        titlesMode = 1;
        return;
    }
    
    //SET MODE2
    if ([customTitles isEqualToString:@"megamode2"]) {
        titlesMode = 2;
        return;
    }
    
    //SET VERTICAL (1)
    if ([customTitles isEqualToString:@"vertimode"]) {
        if (titlesOr != 1) [self cleartitles];
        titlesOr = 1;
        return;
    }
    
    //SET HORIZONTAL (2)
    if ([customTitles isEqualToString:@"horizonmode"]) {
        if (titlesOr != 2) [self cleartitles];
        titlesOr = 2;
        return;
    }
    
    //INSTANT CLEAR AND SWITCH BACK TO MODE 1
    if ([customTitles isEqualToString:@"megaclear"]) {
        [self cleartitles];
        titlesMode = 1;    
        return;
    }
    
    //POP OUT RANDOM CLEAR
    if ([customTitles isEqualToString:@"starterase"]) {
        NSArray* tv;
        if (titlesOr == 1) tv = [titlesview subviews];
        if (titlesOr == 2) tv = [titlesview2 subviews];
        
        if ([tv count] > 0) 
            for (UIView *Tview in tv) { 
                
                [UIView animateWithDuration:0.5
                                      delay:((ERASE_TIME*(arc4random() % 1000)+ERASE_TIME_OFFSET)/1000)
                                    options: UIViewAnimationCurveEaseIn
                                 animations:^{
                                     
                                     Tview.alpha = 0;
                                     
                                 } 
                                 completion:^(BOOL finished){
                                    
                                     [Tview removeFromSuperview];        
                                     titlesCounter = [[titlesview subviews] count] + [[titlesview2 subviews] count];
                                 }];
            }        

        titlesMode = 1;
        return;
    }
    
    UIView* titleV;
    if (titlesOr == 1) titleV = titlesview;
    else titleV = titlesview2;
    
    if ([[titleV subviews] count] >= 2) {
        
        UIView* prev1 = [[titleV subviews] objectAtIndex:([[titleV subviews] count] - 2)];
        UIView* prev2 = [[titleV subviews] objectAtIndex:([[titleV subviews] count] - 1)];
    
        soustitres.textColor = [UIColor whiteColor];
        prev1.alpha = 0; 
        
        //MODE 1
        if (titlesMode == 1) {
            
            [prev2 removeFromSuperview];
        
            //ANIMATE PREVIOUS MESSAGE
            [UIView animateWithDuration:0
                              delay:0.3
                            options: UIViewAnimationCurveLinear
                         animations:^{
                             
                             //First animation : go to bottom
                             CGRect framz = [prev1 frame];	
                             framz.origin.y = (titleV.bounds.size.height-240);
                             prev1.frame = framz;      
                             prev1.alpha = 0.9;
                         } 
                         completion:^(BOOL finished){
                             
                             //
                    
                         }];
            
            //MOVE DOWN ALL OTHER MESSAGES
            for (int i_sub = 2; i_sub <= [[titleV subviews] count]; i_sub++) {
                
                UIView* prev3 = [[titleV subviews] objectAtIndex:([[titleV subviews] count] - i_sub)];
                [UIView animateWithDuration:0.5
                                      delay:(0.07*i_sub)
                                    options: UIViewAnimationCurveEaseIn
                                 animations:^{
                                     CGRect framz = [prev3 frame];
                                     int dec = MAX(10,90-(11*i_sub));
                                     framz.origin.y = (framz.origin.y+dec);
                                     prev3.frame = framz;
                                     
                                     prev3.alpha = MAX(0.3,(prev3.alpha-0.2));
                                     
                                     if (framz.origin.y > titleV.bounds.size.height+10) {
                                         [prev3 removeFromSuperview];
                                         titlesCounter--;
                                     }
                                 } 
                                 completion:^(BOOL finished){
                                     
                            
                                 }];
                
            }
            
        
        }
        
        
        //MODE 2
        else if (titlesMode == 2) {
        
            prev2.alpha = 0;
            
            //ANIMATE PREVIOUS MESSAGE
            [UIView animateWithDuration:0
                          delay:0.3
                        options: UIViewAnimationCurveLinear
                     animations:^{
                         
                         //First animation : go to bottom with alpha 40%
                         
                         //Message
                         CGRect framz = [prev1 frame];	
                         framz.origin.y = (titleV.bounds.size.height-70-8*titlesCounter);
                         prev1.frame = framz;
            
                         //Sub Message (Time)
                         CGRect framz2 = [prev2 frame];	
                         framz2.origin.y = (titleV.bounds.size.height-8*titlesCounter);
                         prev2.frame = framz2;
                         
                         prev1.alpha = 0.4; 
                         prev2.alpha = 0.4;
                     } 
                     completion:^(BOOL finished){
                         
                          //Second animation : go down with alpha 100%
                         
                         [UIView animateWithDuration:15
                                               delay:0
                                             options: UIViewAnimationCurveEaseOut
                                          animations:^{
                                              CGRect framz = [prev1 frame];	
                                              framz.origin.y = framz.origin.y+30;
                                              prev1.frame = framz;
                                              prev1.alpha = 1; 
                                          } 
                                          completion:^(BOOL finished){
                                              
                                          }];
                     }];
            }
    }
    
    float r = (float)titlescolorRed/255;
    float g = (float)titlescolorGreen/255;
    float b = (float)titlescolorBlue/255;
    float a = (float)titlescolorAlpha/255;
    
    
    //ADD MAIN MESSAGE TEXT (change font size and add second line if necessary)
    int fontsize = 80;
    
    CGSize stringSize = [customTitles sizeWithFont:[UIFont fontWithName:@"Thonburi" size:fontsize]];
    
    if (stringSize.width > titleV.bounds.size.width) {
        fontsize = 50;
        stringSize = [customTitles sizeWithFont:[UIFont fontWithName:@"Thonburi" size:fontsize]];
        
        if (stringSize.width > titleV.bounds.size.width) {
            stringSize.width = titleV.bounds.size.width;
            stringSize.height = stringSize.height*2;
        }
        
    }
    
    int positionX = ((titleV.bounds.size.width - stringSize.width) * (arc4random() % 100) / 100 );
    CGRect labelSize = CGRectMake(positionX,0,stringSize.width, stringSize.height);
    
    soustitres = [[UILabel alloc] initWithFrame:labelSize];
    soustitres.textColor = [UIColor colorWithRed:r green:g blue:b alpha:a];
    soustitres.backgroundColor = [UIColor clearColor];
    soustitres.numberOfLines = 2;
    soustitres.text = customTitles;
    soustitres.font = [UIFont fontWithName:@"Thonburi" size:fontsize];
    soustitres.alpha = 1;
    [titleV addSubview:soustitres];
    
    //ADD RANDOM PIC
    //UIImageView* imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    //imgView.image = [UIImage imageNamed:@"image.png"];
    
    //ADD RANDOM TIME subtitle
    NSString* subtit = [subTitles objectAtIndex:(arc4random() % [subTitles count])];    
    CGSize stringSize2 = [subtit sizeWithFont:[UIFont fontWithName:@"Thonburi" size:20]]; 
    CGRect labelSize2 = CGRectMake(positionX,(stringSize.height-5),stringSize2.width, stringSize2.height);
    
    soustitres2 = [[UILabel alloc] initWithFrame:labelSize2];
    soustitres2.textColor = [UIColor whiteColor];
    soustitres2.backgroundColor = [UIColor clearColor];
    soustitres2.text = subtit;
    soustitres2.font = [UIFont fontWithName:@"Thonburi" size:20];
    soustitres2.alpha = 1;
    [titleV addSubview:soustitres2];

    
    //ANIMATED SHOW 
    /*[UIView animateWithDuration:0
                          delay:0.1
                        options: UIViewAnimationCurveLinear
                     animations:^{
                         soustitres.alpha=1;
                         soustitres2.alpha=1;
                     } 
                     completion:^(BOOL finished){
                     }];
    
    [UIView beginAnimations:@"movetxt" context:NULL];
    [UIView setAnimationDuration:MAX((3.6-0.06*titlesCounter),0.1)];
    //[UIView setAnimationDelay:1.0];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    CGRect framz = [soustitres frame];	
    framz.origin.y = (titlesview.bounds.size.height-20-6*titlesCounter);
    soustitres.frame = framz;
    [UIView commitAnimations];
    */
    
    titlesCounter++;
}

-(void) titlesColor:(int)Red:(int)Green:(int)Blue:(int)Alpha{
    
    titlescolorRed = Red;
    titlescolorGreen = Green;
    titlescolorBlue = Blue;
    if (Alpha > 0) titlescolorAlpha = Alpha;
    else titlescolorAlpha = 255;
}

-(void) titlesText:(NSString*) txt {
    customTitles = [txt copy];
}

- (void) live:(BOOL)go {
    if (go) liveview.alpha = 1;
    else liveview.alpha = 0;
}

//###########################################################
//SCREEN MANAGER

//get resolution
- (NSString*) resolution {
    return screenResolution;
}

//Create EXTERNAL window on SCREEN 1
-(void) createWindow {
    
    if ([[UIScreen screens] count] < 2) return;
    
    remoteplayv2AppDelegate *appDelegate = (remoteplayv2AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    //select Screen
    UIScreen*   secondScreen = [[UIScreen screens] objectAtIndex: 1];
    
    //create WINDOW (full sized for second screen)
    _secondWindow = [[UIWindow alloc] initWithFrame:secondScreen.bounds];
    
    //ATTACH TO CURRENT ACTIVE SCREEN
    _secondWindow.screen = secondScreen;
    CGRect frame = _secondWindow.frame;
    
    // Add a black background to the window
    UIView* backField = [[UIView alloc] initWithFrame:secondScreen.bounds];
    backField.backgroundColor = [UIColor blackColor];
    [_secondWindow addSubview:backField];
    [backField release];
    
    //MOVIE PLAYER
    //Create Masks (movieview)
    movieview = [[UIView alloc] initWithFrame:secondScreen.bounds];
    movieview.backgroundColor = [UIColor clearColor];
    movieview.alpha=1;
    [_secondWindow addSubview:movieview];
    
        //Attach PLAYER subviews
        [movieview addSubview: appDelegate.moviePlayer.movie1view];
        [movieview addSubview: appDelegate.moviePlayer.movie2view];
        appDelegate.moviePlayer.movie1view.frame = frame;
        appDelegate.moviePlayer.movie2view.frame = frame;
    
    //SRT PLAYER
    //Create Masks (movieview)
    srtview = [[UIView alloc] initWithFrame:secondScreen.bounds];
    srtview.backgroundColor = [UIColor clearColor];
    srtview.alpha=1;
    [_secondWindow addSubview:srtview];
    
        //Attach SRT subviews
        [srtview addSubview: appDelegate.moviePlayer.srtLabel];
        appDelegate.moviePlayer.srtLabel.frame = CGRectMake(0,(7*frame.size.height/8),frame.size.width,(frame.size.height/8));
    
    //LIVE PLAYER
    //Create Masks (liveview)
    liveview = [[UIView alloc] initWithFrame:secondScreen.bounds];
    liveview.backgroundColor = [UIColor blackColor];
    liveview.alpha=0;
    [_secondWindow addSubview:liveview];
    
        //Attach PLAYER subviews
        [liveview addSubview: appDelegate.live2Player.live1view];
        [liveview addSubview: appDelegate.live2Player.live2view];
        appDelegate.live2Player.live1view.frame = frame;
        appDelegate.live2Player.live2view.frame = frame;
    
    
    //Create Masks (fadeview)
    fadeview = [[UIView alloc] initWithFrame:secondScreen.bounds];
    fadeview.backgroundColor = [UIColor blackColor];
    fadeview.alpha=0;
    [_secondWindow addSubview:fadeview];
    
    //Create Masks (titlesview)
    CGRect titleframe = CGRectMake(
                                   (secondScreen.bounds.size.width-secondScreen.bounds.size.height)/2,
                                   (secondScreen.bounds.size.height-secondScreen.bounds.size.width)/2
                                   ,secondScreen.bounds.size.height, secondScreen.bounds.size.width);
    
    
    //VERTICAL TITLES VIEW
    titlesview = [[UIView alloc] initWithFrame:titleframe];
    titlesview.backgroundColor = [UIColor clearColor];
    titlesview.alpha=1;
    [_secondWindow addSubview:titlesview];
    [titlesview.layer setTransform: CATransform3DMakeRotation((M_PI/2), 0, 0.0, 1.0)];
    
    //HORIZONTAL TITLES VIEW
    titlesview2 = [[UIView alloc] initWithFrame:secondScreen.bounds];
    titlesview2.backgroundColor = [UIColor clearColor];
    titlesview2.alpha=1;
    [_secondWindow addSubview:titlesview2];
    
    
    //Create Masks (muteview)
    muteview = [[UIView alloc] initWithFrame:secondScreen.bounds];
    muteview.backgroundColor = [UIColor blackColor];
    muteview.alpha=0;
    [_secondWindow addSubview:muteview];
    
    //Create Masks (mirview)
    mirview = [[UIView alloc] initWithFrame:secondScreen.bounds];
    mirview.backgroundColor = [UIColor blackColor];
    mirview.alpha=0;
    [_secondWindow addSubview:mirview];
    
    // Center a label in the view.
    NSString*    noContentString = [NSString stringWithFormat:@" "];
    CGSize        stringSize = [noContentString sizeWithFont:[UIFont systemFontOfSize:18]];
    CGRect        labelSize = CGRectMake((secondScreen.bounds.size.width - stringSize.width) / 2.0,
                                         (secondScreen.bounds.size.height - stringSize.height) / 2.0,
                                         stringSize.width, stringSize.height);
    UILabel*    noContentLabel = [[UILabel alloc] initWithFrame:labelSize];
    noContentLabel.text = noContentString;
    noContentLabel.font = [UIFont systemFontOfSize:18];
    [mirview addSubview:noContentLabel];
    
    //Create Masks (flashview)
    flashview = [[UIView alloc] initWithFrame:secondScreen.bounds];
    flashview.backgroundColor = [UIColor blackColor];
    flashview.alpha=0;
    [_secondWindow addSubview:flashview];
    
    
    // Go ahead and show the window.
    _secondWindow.hidden = NO;
    
    //init View visibility
    [self mir: VIEW_MIR];
    [self fade: VIEW_FADE];
    [self mute: VIEW_MUTE];
}

//check screen
- (BOOL) checkScreen{
    
    //last known resolution
    NSString* newRes = [screenResolution copy];
    
    
    //external screen plugged
    if ([[UIScreen screens] count] > 1)
    {
        //new external screen
        if ([newRes isEqualToString: @"noscreen"])
        {
            //initialize window
            if (!_secondWindow) [self createWindow];
            
            //get resolution
            newRes =  [NSString stringWithFormat: @"%.0f x %.0f",_secondWindow.bounds.size.width,_secondWindow.bounds.size.height];
        }
    }
    //external screen removed
    else if (![newRes isEqualToString: @"noscreen"]) newRes = @"noscreen";

    //if resolution changed, send TRUE
    if (![newRes isEqualToString: screenResolution]) {
        screenResolution = [newRes copy];
        return TRUE;
    }
    
    return FALSE;
}



@end
