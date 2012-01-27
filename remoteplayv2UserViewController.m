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

@synthesize muteButton,pauseButton,nextButton,backButton,timeSlider,fadeBlackButton,fadeWhiteButton,mirButton,messageRegie;

//mute ou unmute la sortie vidéo (vue avec un cache noir devant la vidéo)
-(IBAction)muting:(id)sender{
    remoteplayv2AppDelegate *appDelegate = (remoteplayv2AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    appDelegate.paused = NO;
    [appDelegate pauseMovie];
    
    if (appDelegate.muted) {
        [appDelegate muteMovie:NO];
        [self setMuteButtonColor:[UIColor greenColor]];
        //[fadeBlackButton setTitle:@">B" forState:UIControlStateNormal];
    }else{
        [appDelegate muteMovie:YES];
        [self setMuteButtonColor:[UIColor orangeColor]];
    }
    [appDelegate sendSync];
}

//double click = mute and pause
- (IBAction)mutingAndPause:(id)sender{
    remoteplayv2AppDelegate *appDelegate = (remoteplayv2AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    [appDelegate muteMovie:YES];
    appDelegate.paused = YES;
    [appDelegate pauseMovie];
    
    [self setMuteButtonColor:[UIColor redColor]];
}

//vidéo suivante
- (IBAction)goNext:(id)sender{
    remoteplayv2AppDelegate *appDelegate = (remoteplayv2AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *m = [nextButton titleForState:UIControlStateNormal];
    [appDelegate disableStreaming];
    [appDelegate initGoMovieWithName:m:YES];
}

//vidéo précedente
- (IBAction)goBack:(id)sender{
    remoteplayv2AppDelegate *appDelegate = (remoteplayv2AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *m = [backButton titleForState:UIControlStateNormal];
    [appDelegate disableStreaming];
    [appDelegate initGoMovieWithName:m:YES];
}

//défilement
-(IBAction)slide:(id)sender{
    remoteplayv2AppDelegate *appDelegate = (remoteplayv2AppDelegate*)[[UIApplication sharedApplication] delegate];
    int seekTime = timeSlider.value*1000;
    [appDelegate skipMovie:seekTime];
    [appDelegate sendSync];
}

//fondu au noir
- (IBAction)fadeBlack:(id)sender{
    remoteplayv2AppDelegate *appDelegate = (remoteplayv2AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    if (!appDelegate.faded) [appDelegate fadeColor:0:0:0:255];
    [appDelegate fadeMovie:(!appDelegate.faded)];
    [appDelegate sendSync];
}

//fondu au blanc
- (IBAction)fadeWhite:(id)sender{
    remoteplayv2AppDelegate *appDelegate = (remoteplayv2AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    if (!appDelegate.faded) [appDelegate fadeColor:255:255:255:255];
    [appDelegate fadeMovie:(!appDelegate.faded)];
    [appDelegate sendSync];
}

//mir switch 
- (IBAction)mirSwitch:(id)sender{
    remoteplayv2AppDelegate *appDelegate = (remoteplayv2AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    [appDelegate mirMovie:!appDelegate.mired];
}

//pause switch 
- (IBAction)pauseSwitch:(id)sender{
    remoteplayv2AppDelegate *appDelegate = (remoteplayv2AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    appDelegate.paused = !appDelegate.paused;
    [appDelegate pauseMovie];
}

//flash
- (IBAction)flash:(id)sender{
        remoteplayv2AppDelegate *appDelegate = (remoteplayv2AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    [appDelegate flashColor:255:255:255:255];
    [appDelegate flashMovie];
}

//envoi message sos à la régie
-(IBAction)sos:(id)sender{
    remoteplayv2AppDelegate *appDelegate = (remoteplayv2AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    [appDelegate sendSOS];
}

//fonction pour changer les attribut de la vue
-(void)setMuteButtonColor:(UIColor*)c{
    muteButton.backgroundColor =c;
}

-(void) setMovieTitle:(NSString*)t {
    [muteButton setTitle:t forState:UIControlStateNormal];
}

-(void) setNextTitle:(NSString*)t {
    [nextButton setTitle:t forState:UIControlStateNormal];
}
-(void) setBackTitle:(NSString*)t {
    [backButton setTitle:t forState:UIControlStateNormal];
}

-(void)setMessage:(NSString*)m{
    [messageRegie setText:m];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {    }
    return self;
    mute = NO;
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
