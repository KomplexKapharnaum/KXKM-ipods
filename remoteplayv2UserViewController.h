//
//  remoteplayv2UserViewController.h
//  remoteplayv2
//
//  Created by Pierre Hoezelle, Thomas Bohl, Jeremie Forge
//  Copyright 2011 KXKM. Creative Commons BY-NC-SA.
//

#import <UIKit/UIKit.h>


@interface remoteplayv2UserViewController : UIViewController


@property (nonatomic,retain) IBOutlet UIButton *nextButton;
@property (nonatomic,retain) IBOutlet UIButton *backButton;

@property (nonatomic,retain) IBOutlet UIButton *movieButton;

@property (nonatomic,retain) IBOutlet UISlider *timeSlider;

@property (nonatomic,retain) IBOutlet UIButton *fadeBlackButton;
@property (nonatomic,retain) IBOutlet UIButton *fadeWhiteButton;
@property (nonatomic,retain) IBOutlet UIButton *flashButton;
@property (nonatomic,retain) IBOutlet UIButton *mirButton;
@property (nonatomic,retain) IBOutlet UIButton *pauseButton;

@property (nonatomic,retain) IBOutlet UIButton *sosButton;
@property (nonatomic,retain) IBOutlet UILabel *messageRegie;

//fonction action
- (IBAction)goNext:(id)sender;
- (IBAction)goBack:(id)sender;

- (IBAction)mute:(id)sender;

- (IBAction)slide:(id)sender;

- (IBAction)fadeBlack:(id)sender;
- (IBAction)fadeWhite:(id)sender;
- (IBAction)mir:(id)sender;
- (IBAction)pause:(id)sender;

- (IBAction)flash:(id)sender;
- (IBAction)sos:(id)sender;


@end
