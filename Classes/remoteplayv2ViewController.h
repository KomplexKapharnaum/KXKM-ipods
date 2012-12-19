//
//  remoteplayv2ViewController.h
//  remoteplayv2
//
//  Created by Pierre Hoezelle, Thomas Bohl, Jeremie Forge
//  Copyright 2011 KXKM. Creative Commons BY-NC-SA.
//

#import <UIKit/UIKit.h>

@interface remoteplayv2ViewController : UIViewController

@property (nonatomic, retain) IBOutlet UITextField *infoip;
@property (nonatomic, retain) IBOutlet UITextField *infoscreen;
@property (nonatomic, retain) IBOutlet UITextField *infostate;
@property (nonatomic, retain) IBOutlet UITextField *infoctrl;
@property (nonatomic, retain) IBOutlet UITextField *infomovie;
@property (nonatomic, retain) IBOutlet UITextField *infoserver;
@property (nonatomic, retain) IBOutlet UITextField *infoname;
@property (nonatomic, retain) IBOutlet UITextField *infolink;
@property (retain, nonatomic) IBOutlet UILabel *inforec;

@property (nonatomic,retain) IBOutlet UIButton *mirButtonauto;

@property (nonatomic,retain) IBOutlet UISwitch *recSwitch;

- (IBAction)mir:(id)sender;
- (IBAction)sos:(id)sender;

@end

