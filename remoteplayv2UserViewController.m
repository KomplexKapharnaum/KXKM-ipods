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

@synthesize muteButton,nextButton,backButton,timeSlider,fadeBlackButton,fadeWhiteButton,mirButton,messageRegie;

//mute ou unmute la sortie vidéo (vue avec un cache noir devant la vidéo)
-(IBAction)muting:(id)sender{
    remoteplayv2AppDelegate *appDelegate = (remoteplayv2AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    if (appDelegate.muted) {
        [appDelegate muteMovie:NO];
        [self setMuteButtonColor:[UIColor greenColor]];
        [fadeBlackButton setTitle:@">B" forState:UIControlStateNormal];
    }else{
        [appDelegate muteMovie:YES];
        [self setMuteButtonColor:[UIColor orangeColor]];
    }
    [appDelegate sendSync];
}

-(BOOL) isMute{
    return mute;
}

//double click = mute and pause
- (IBAction)mutingAndPause:(id)sender{
    remoteplayv2AppDelegate *appDelegate = (remoteplayv2AppDelegate*)[[UIApplication sharedApplication] delegate];
    appDelegate.muteview.backgroundColor=[UIColor blackColor];
    appDelegate.muteview.alpha=1;
    [self setMuteButtonColor:[UIColor redColor]];
    mute=YES;
    [appDelegate.moviePlayer pause];
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
    [appDelegate.moviePlayer setCurrentPlaybackTime:(double)timeSlider.value];
    [appDelegate sendSync];
}

//fondu au noir
- (IBAction)fadeBlack:(id)sender{
    remoteplayv2AppDelegate *appDelegate = (remoteplayv2AppDelegate*)[[UIApplication sharedApplication] delegate];
    if(!mute){
        appDelegate.muteview.backgroundColor=[UIColor blackColor];
        [UIView beginAnimations:@"fadetoblack" context:NULL];
        [UIView setAnimationDuration:1.5];
        appDelegate.muteview.alpha=1;
        [UIView commitAnimations];
        mute=YES;
        [self setMuteButtonColor:[UIColor orangeColor]];
        [fadeBlackButton setTitle:@"B>" forState:UIControlStateNormal];
    }else{
        [UIView beginAnimations:@"unfadetoblack" context:NULL];
        [UIView setAnimationDuration:1.5];
        appDelegate.muteview.alpha=0;
        [UIView commitAnimations];
        [self setMuteButtonColor:[UIColor greenColor]];
        mute=NO;
        [fadeBlackButton setTitle:@">B" forState:UIControlStateNormal];
    }
    [appDelegate sendSync];
}

//fondu au blanc
- (IBAction)fadeWhite:(id)sender{
    remoteplayv2AppDelegate *appDelegate = (remoteplayv2AppDelegate*)[[UIApplication sharedApplication] delegate];
    if(!mute){
        appDelegate.muteview.backgroundColor=[UIColor whiteColor];
        [UIView beginAnimations:@"fadetowhite" context:NULL];
        [UIView setAnimationDuration:1.5];
        appDelegate.muteview.alpha=1;
        [UIView commitAnimations];
        mute=YES;
        [self setMuteButtonColor:[UIColor yellowColor]];
        [fadeWhiteButton setTitle:@"W>" forState:UIControlStateNormal];
    }else{
        [UIView beginAnimations:@"unfadetowhite" context:NULL];
        [UIView setAnimationDuration:1.5];
        appDelegate.muteview.alpha=0;
        [UIView commitAnimations];
        [self setMuteButtonColor:[UIColor greenColor]];
        mute=NO;
        [fadeWhiteButton setTitle:@">W" forState:UIControlStateNormal];
    }
    [appDelegate sendSync];
}

//switch mir
- (IBAction)mirSwitch:(id)sender{
    remoteplayv2AppDelegate *appDelegate = (remoteplayv2AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    [appDelegate mirMovie:!appDelegate.mired];
}

//flash
- (IBAction)flash:(id)sender{
        remoteplayv2AppDelegate *appDelegate = (remoteplayv2AppDelegate*)[[UIApplication sharedApplication] delegate];
    appDelegate.muteview.backgroundColor=[UIColor whiteColor];
    appDelegate.muteview.alpha=1;
    [UIView beginAnimations:@"flash" context:NULL];
    [UIView setAnimationDuration:0.35];
    appDelegate.muteview.alpha=0;
    [UIView commitAnimations];
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
