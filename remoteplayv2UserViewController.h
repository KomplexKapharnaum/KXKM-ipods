//
//  remoteplayv2UserViewController.h
//  remoteplayv2
//
//  Created by Pierre Hoezelle, Thomas Bohl, Jeremie Forge
//  Copyright 2011 KXKM. Creative Commons BY-NC-SA.
//

#import <UIKit/UIKit.h>


@interface remoteplayv2UserViewController : UIViewController{

    IBOutlet UIButton *muteButton;
    IBOutlet UIButton *nextButton;
    IBOutlet UIButton *backButton;
    
    IBOutlet UISlider *timeSlider;
    
    IBOutlet UIButton *fadeBlackButton;
    IBOutlet UIButton *fadeWhiteButton;
    
    IBOutlet UILabel *messageRegie;
    
    //etat de la vidéo
    BOOL mute;
    //appdelegate
    
}



@property (nonatomic,retain) IBOutlet UIButton *muteButton;
@property (nonatomic,retain) IBOutlet UIButton *nextButton;
@property (nonatomic,retain) IBOutlet UIButton *backButton;

@property (nonatomic,retain) IBOutlet UISlider *timeSlider;

@property (nonatomic,retain) IBOutlet UIButton *fadeBlackButton;

@property (nonatomic,retain) IBOutlet UILabel *messageRegie;

//fonction action
- (IBAction)muting:(id)sender;
- (IBAction)mutingAndPause:(id)sender;
- (IBAction)goNext:(id)sender;
- (IBAction)goBack:(id)sender;
- (IBAction)slide:(id)sender;
- (IBAction)fadeBlack:(id)sender;
- (IBAction)fadeWhite:(id)sender;
- (IBAction)flash:(id)sender;
-(IBAction)sos:(id)sender;


//fonction modification vue
-(void) setMessage:(NSString*)m;

-(void) setMovieTitle:(NSString*)t;
-(void) setMuteButtonColor:(UIColor*)c;
-(void) setNextTitle:(NSString*)t;
-(void) setBackTitle:(NSString*)t;

-(BOOL) isMute;

@end
