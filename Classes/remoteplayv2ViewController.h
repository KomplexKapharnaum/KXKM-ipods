//
//  remoteplayv2ViewController.h
//  remoteplayv2
//
//  Created by Pierre Hoezelle, Thomas Bohl, Jeremie Forge
//  Copyright 2011 KXKM. Creative Commons BY-NC-SA.
//

#import <UIKit/UIKit.h>

@interface remoteplayv2ViewController : UIViewController {
	NSString *MyNotificationName;
  
	UITextField *info;
	UITextField *infoscreen;
	UITextField *infoip;
	UITextField *infomovie;
}

@property (nonatomic, retain) IBOutlet UITextField *info;
@property (nonatomic, retain) IBOutlet UITextField *infoscreen;
@property (nonatomic, retain) IBOutlet UITextField *infoip;
@property (nonatomic, retain) IBOutlet UITextField *infomovie;

- (void)setInfoText:(NSString*)text;
- (void)setInfoscreenText:(NSString*)text;
- (void)setInfoipText:(NSString*)text;
- (void)setInfoMovieText:(NSString*)text;

- (void)myMethod;


@end

