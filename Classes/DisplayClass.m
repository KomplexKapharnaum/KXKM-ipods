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
@synthesize liveview, live1view, live2view;
@synthesize movieview, movie1view, movie2view;
@synthesize muteview, fadeview, flashview, titlesview, mirview;

//###########################################################
// DISPLAY : screen / views

- (id) init
{
    screenResolution = @"noscreen";
    
    customTitles = @"";
    
    [self titlesColor:255:255:255:255];
    [self flashColor:255:255:255:255];
    [self fadeColor:255:255:255:255];
    
    return [super init];	
}

//###########################################################
//VIEWS MANAGER

//MUTE
-(void) mute:(BOOL)muteMe {
    
    if (muteMe) muteview.alpha = 1;
    else muteview.alpha = 0;
    
    remoteplayv2AppDelegate *appDelegate = (remoteplayv2AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate.interFace Bmute:muteMe];
}

-(BOOL) muted {
    return (muteview.alpha == 1);
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
-(void) titles {
    
    //suppress all titlesview subviews (sinon les titrages s'empilent)
    //TODO check if it is still working !
    NSArray* tv = [titlesview subviews];
    if ([tv count] > 0) for (UIView *v in tv) { [v removeFromSuperview]; }
    
    float r = (float)titlescolorRed/255;
    float g = (float)titlescolorGreen/255;
    float b = (float)titlescolorBlue/255;
    float a = (float)titlescolorAlpha/255;
    
    
    CGSize stringSize = [customTitles sizeWithFont:[UIFont systemFontOfSize:80]]; 
    CGRect labelSize = CGRectMake((titlesview.bounds.size.width - stringSize.width) / 2.0,
                                  (titlesview.bounds.size.height - stringSize.height),
                                  stringSize.width, stringSize.height);
    
    UILabel* soustitres = [[UILabel alloc] initWithFrame:labelSize];
    soustitres.textColor = [UIColor colorWithRed:r green:g blue:b alpha:a];
    soustitres.backgroundColor = [UIColor clearColor];
    soustitres.text = customTitles;
    soustitres.font = [UIFont systemFontOfSize:80];
    [titlesview addSubview:soustitres];
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

//check screen
- (BOOL) checkScreen{
	
    NSString* newRes = [screenResolution copy];
    
	//no screen
	if ([newRes isEqualToString: @"noscreen"]) {	
		//add extrenal tvout window
		if ([[UIScreen screens] count] > 1)
		{	
			// Associate the window with the second screen.
			// The main screen is always at index 0.
			
            //select external Screen
            UIScreen*    secondScreen = [[UIScreen screens] objectAtIndex:1];
			
            //create WINDOW (full sized for second screen)	
			_secondWindow = [[UIWindow alloc] initWithFrame:secondScreen.bounds];
			
            //attach WINDOW to external screen
            _secondWindow.screen = secondScreen;
			
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
            
                //Create PLAYER 1 view
                if (DEBUG_PLAYERS) {
                    movie1view = [[UIView alloc] initWithFrame:CGRectMake(10,10,350,350)];
                    movie1view.backgroundColor = [UIColor greenColor];
                }
                else 
                {
                    movie1view = [[UIView alloc] initWithFrame:secondScreen.bounds];
                    movie1view.backgroundColor = [UIColor clearColor];
                }
                movie1view.alpha=1;
                [movieview addSubview:movie1view];
            
                //Create PLAYER 2 view
                if (DEBUG_PLAYERS) {
                    movie2view = [[UIView alloc] initWithFrame:CGRectMake(200,100,350,350)];
                    movie2view.backgroundColor = [UIColor yellowColor];
                }
                else 
                {
                    movie2view = [[UIView alloc] initWithFrame:secondScreen.bounds];
                    movie2view.backgroundColor = [UIColor clearColor];
                }
                movie2view.alpha=1;
                [movieview addSubview:movie2view];
            
            //LIVE PLAYER
            //Create Masks (liveview)
            liveview = [[UIView alloc] initWithFrame:secondScreen.bounds];
            liveview.backgroundColor = [UIColor blackColor];
            liveview.alpha=0;
            [_secondWindow addSubview:liveview];
            
                //Create PLAYER 1 view
                if (DEBUG_PLAYERS) {
                    live1view = [[UIView alloc] initWithFrame:CGRectMake(10,10,350,350)];
                    live1view.backgroundColor = [UIColor blueColor];
                }
                else 
                {
                    live1view = [[UIView alloc] initWithFrame:secondScreen.bounds];
                    live1view.backgroundColor = [UIColor clearColor];
                }
                live1view.alpha=1;
                [liveview addSubview:live1view];
            
                //Create PLAYER 2 view
                if (DEBUG_PLAYERS) {
                    live2view = [[UIView alloc] initWithFrame:CGRectMake(200,100,350,350)];
                    live2view.backgroundColor = [UIColor redColor];
                }
                else 
                {
                    live2view = [[UIView alloc] initWithFrame:secondScreen.bounds];
                    live2view.backgroundColor = [UIColor clearColor];
                }
                live2view.alpha=1;
                [liveview addSubview:live2view];
            
            //Create Masks (fadeview)
            fadeview = [[UIView alloc] initWithFrame:secondScreen.bounds];
            fadeview.backgroundColor = [UIColor blackColor];
            fadeview.alpha=0;
            [_secondWindow addSubview:fadeview];
            
            //Create Masks (titlesview)
            titlesview = [[UIView alloc] initWithFrame:secondScreen.bounds];
            titlesview.backgroundColor = [UIColor clearColor];
            titlesview.alpha=1;
            [_secondWindow addSubview:titlesview];
            
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
			newRes =  [NSString stringWithFormat: @"%.0f x %.0f",secondScreen.bounds.size.width,secondScreen.bounds.size.height];
            
            //init View visibility
            [self mir: VIEW_MIR];
            [self fade: VIEW_FADE];
            [self mute: VIEW_MUTE];
            
		}
	}
	//screen connected check if still there
	else if ([[UIScreen screens] count] < 2) newRes = @"noscreen";
    
    //if resolution changed, send TRUE
    if (![newRes isEqualToString: screenResolution]) {
        screenResolution = [newRes copy];
        return TRUE;
    }
    
    return FALSE;
}



@end
