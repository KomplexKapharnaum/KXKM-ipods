//
//  remoteplayv2UserViewController.m
//  remoteplayv2
//
//  Created by Pierre Hoezelle, Thomas Bohl, Jeremie Forge
//  Copyright 2011 KXKM. Creative Commons BY-NC-SA.
//

#import "remoteplayv2UserViewController.h"
#import "remoteplayv2AppDelegate.h"

@implementation remoteplayv2UserViewController

@synthesize movieButton,pauseButton,nextButton,backButton,timeSlider,volumeSlider,fadeBlackButton,fadeWhiteButton,mirButton,messageRegie,timeLabel, sosButton, flashButton,loopButton;

//mute ou unmute la sortie vidéo (vue avec un cache noir devant la vidéo)
-(IBAction)mute:(id)sender{
    remoteplayv2AppDelegate *appDelegate = (remoteplayv2AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    [appDelegate.disPlay mute:![appDelegate.disPlay muted]];
    [appDelegate.checkMachine userAct:0];
}

//vidéo suivante
- (IBAction)goNext:(id)sender{
    remoteplayv2AppDelegate *appDelegate = (remoteplayv2AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *m = [nextButton titleForState:UIControlStateNormal];
    [appDelegate.moviePlayer load:m];
    [appDelegate.moviePlayer play];
    [appDelegate.checkMachine userAct:0];
}

//vidéo précedente
- (IBAction)goBack:(id)sender{
    remoteplayv2AppDelegate *appDelegate = (remoteplayv2AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *m = [backButton titleForState:UIControlStateNormal];
    [appDelegate.moviePlayer load:m];
    [appDelegate.moviePlayer play];
    [appDelegate.checkMachine userAct:0];
}

//défilement
-(IBAction)slide:(id)sender{
    remoteplayv2AppDelegate *appDelegate = (remoteplayv2AppDelegate*)[[UIApplication sharedApplication] delegate];
    int seekTime = timeSlider.value*1000;
    [appDelegate.moviePlayer skip:seekTime];
    [appDelegate.checkMachine userAct:0];
}

//volume
-(IBAction)volume:(id)sender{
    remoteplayv2AppDelegate *appDelegate = (remoteplayv2AppDelegate*)[[UIApplication sharedApplication] delegate];
    int volume = volumeSlider.value;
    [appDelegate.moviePlayer setVolume:volume];
    [appDelegate.checkMachine userAct:0];
}

//fondu au noir
- (IBAction)fadeBlack:(id)sender{
    remoteplayv2AppDelegate *appDelegate = (remoteplayv2AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    if (![appDelegate.disPlay faded]) [appDelegate.disPlay fadeColor:0:0:0:255];
    [appDelegate.disPlay fade:(![appDelegate.disPlay faded])];
    [appDelegate.checkMachine userAct:0];
}

//fondu au blanc
- (IBAction)fadeWhite:(id)sender{
    remoteplayv2AppDelegate *appDelegate = (remoteplayv2AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    if (![appDelegate.disPlay faded]) [appDelegate.disPlay fadeColor:255:255:255:255];
    [appDelegate.disPlay fade:(![appDelegate.disPlay faded])];
    [appDelegate.comPort sendSync];
    [appDelegate.checkMachine userAct:0];
}

//mir switch 
- (IBAction)mir:(id)sender{
    remoteplayv2AppDelegate *appDelegate = (remoteplayv2AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    [appDelegate.disPlay mir:(![appDelegate.disPlay mired])];
    [appDelegate.checkMachine userAct:0];
}

//mir switch
- (IBAction)loop:(id)sender{
    remoteplayv2AppDelegate *appDelegate = (remoteplayv2AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    [appDelegate.moviePlayer switchLoop];
    [appDelegate.checkMachine userAct:0];
}

//pause switch 
- (IBAction)pause:(id)sender{
    remoteplayv2AppDelegate *appDelegate = (remoteplayv2AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    [appDelegate.moviePlayer switchpause];
    [appDelegate.checkMachine userAct:0];
}

//flash
- (IBAction)flash:(id)sender{
        remoteplayv2AppDelegate *appDelegate = (remoteplayv2AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    [appDelegate.disPlay flashColor:255:255:255:255];
    [appDelegate.disPlay flash];
    [appDelegate.checkMachine userAct:0];
}

//envoi message sos à la régie
-(IBAction)flip:(id)sender{
    remoteplayv2AppDelegate *appDelegate = (remoteplayv2AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    [appDelegate.disPlay flip:(![appDelegate.disPlay flipped])];
    [appDelegate.checkMachine userAct:0];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
