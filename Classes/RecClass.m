//
//  RecClass.m
//  KXKM
//  Created by Pierre Hoezelle, Thomas Bohl, Jeremie Forge
//  Copyright 2011 KXKM. Creative Commons BY-NC-SA.
//  12/12/12.
//
//

#import "RecClass.h"
#import "ConfigConst.h"
#import "remoteplayv2AppDelegate.h"

@implementation RecClass

@synthesize MovieFileName;

//###########################################################
// INIT

- (id) init
{
    [self setOrientation:@"paysage"];
    return [super init];
}

//###########################################################
// PREPARE THE RECORDING SESSION

-(void) setFile:(NSString *)file
{
    //FILENAME
    MovieFileName = file;
}

-(void) setOrientation:(NSString *)orientation
{
    //FILENAME
    CameraOrientation = orientation;
}

-(void) start
{            
    if ([CaptureSession isRunning]) [self rec];

    //INIT SESSION
    CaptureSession = [[AVCaptureSession alloc] init];
    
    //MICRO
    AVCaptureDeviceInput *audioInput = [self internalMic];
    if ((audioInput) && ([CaptureSession canAddInput:audioInput])) [CaptureSession addInput:audioInput];
    else {
        [self error:@"no_mic" :YES];
        return;
    }
    
    //CAMERA
    AVCaptureDeviceInput *videoInput = [self backCamera];
    if ((videoInput) && ([CaptureSession canAddInput:videoInput])) [CaptureSession addInput:videoInput];
    else {
        [self error:@"no_camera" :YES];
        return;
    }
    
    //OUTPUT
    MovieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    MovieFileOutput.minFreeDiskSpaceLimit = 1024 * 1024;
    
    if ([CaptureSession canAddOutput:MovieFileOutput]) [CaptureSession addOutput:MovieFileOutput];
    else {
        [self error:@"no_output_handler" :YES];
        return;
    }
    
    //SET THE CONNECTION PROPERTIES (output properties)
	[self CameraSetOutputProperties];
    
    //QUALITY
    [CaptureSession setSessionPreset:AVCaptureSessionPresetHigh];
    
    //START SESSION
    [CaptureSession startRunning];
    
    //START RECORD
    [self rec];
}

//###########################################################
// START RECORDING

-(void) rec
{    
    if ([MovieFileOutput isRecording]) return;
    
    //----- RECORDE TO APP DOCUMENTS -----
    remoteplayv2AppDelegate *appDelegate = (remoteplayv2AppDelegate*)[[UIApplication sharedApplication] delegate];
    if ([appDelegate.filesManager find:MovieFileName])
    {
        [self error:@"file_already_exist" :YES];
        return;
    }
    
    //Start recording
    [MovieFileOutput startRecordingToOutputFileURL:[appDelegate.filesManager urlnew:MovieFileName] recordingDelegate:self];
}


//###########################################################
// STOP RECORDING / CHECK FILE / CLOSE SESSION

-(void) stop
{
    if ([MovieFileOutput isRecording]) [MovieFileOutput stopRecording];
    if ([CaptureSession isRunning]) [CaptureSession stopRunning];
    
    
    //NSLog(@"stoprecord");
    
    //remoteplayv2AppDelegate *appDelegate = (remoteplayv2AppDelegate*)[[UIApplication sharedApplication] delegate];
    //[appDelegate.comPort sendRec:@"stop"];
}

//###########################################################
// IS RECORDING

-(BOOL) isRecording
{
    if (!MovieFileOutput) return NO;
    return [MovieFileOutput isRecording];
}

-(void) error:(NSString*)erro:(BOOL)stop
{
    NSString* msg = @"error ";
    msg = [msg stringByAppendingString:erro];
    
    remoteplayv2AppDelegate *appDelegate = (remoteplayv2AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate.comPort sendRec:msg];
    
    if (stop) [self stop];
}


//###########################################################
// did FINISH
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput
        didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL
        fromConnections:(NSArray *)connections
        error:(NSError *)error {
    
    BOOL RecordedSuccessfully = YES;
    if ([error code] != noErr)
	{
        // A problem occurred: Find out if the recording was successful.
        id value = [[error userInfo] objectForKey:AVErrorRecordingSuccessfullyFinishedKey];
        if (value) RecordedSuccessfully = [value boolValue];
    }
	if (RecordedSuccessfully)
	{
		//NSLog([outputFileURL absoluteString]);
        remoteplayv2AppDelegate *appDelegate = (remoteplayv2AppDelegate*)[[UIApplication sharedApplication] delegate];
        [appDelegate.interFace setMediaList: [appDelegate.filesManager mediaList]];
        [appDelegate.comPort sendRec:[@"addfile " stringByAppendingString:MovieFileName]];
	}
    else {
        //ERROR While recording!
        [self error:@"recording_error" :NO];
    }
    
    [self stop];
}

//###########################################################
// did START
- (void)             captureOutput:(AVCaptureFileOutput *)captureOutput
didStartRecordingToOutputFileAtURL:(NSURL *)fileURL
                   fromConnections:(NSArray *)connections
{
    NSLog(@"did start recording");
    
    //send info
    remoteplayv2AppDelegate *appDelegate = (remoteplayv2AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate.comPort sendSync];
}

//###########################################################
// INPUTS SELECT
- (AVCaptureDevice *) cameraWithPosition:(AVCaptureDevicePosition) position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}

- (AVCaptureDeviceInput *) backCamera
{
    return [AVCaptureDeviceInput deviceInputWithDevice:[self cameraWithPosition:AVCaptureDevicePositionBack] error:NULL];
}

- (AVCaptureDeviceInput *) frontCamera
{
    return [AVCaptureDeviceInput deviceInputWithDevice:[self cameraWithPosition:AVCaptureDevicePositionFront] error:NULL];
}

- (AVCaptureDeviceInput *) internalMic
{
    return [AVCaptureDeviceInput deviceInputWithDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio] error:NULL];
}

//********** CAMERA PROPERTIES **********
- (void) CameraSetOutputProperties
{
	//SET THE CONNECTION PROPERTIES (output properties)
	AVCaptureConnection *CaptureConnection = [MovieFileOutput connectionWithMediaType:AVMediaTypeVideo];
	
	//Set landscape (if required)
	if ([CaptureConnection isVideoOrientationSupported])
	{
        AVCaptureVideoOrientation orientation;
		if ([CameraOrientation isEqualToString:@"portrait"]) orientation = AVCaptureVideoOrientationPortrait;
        else orientation = AVCaptureVideoOrientationLandscapeRight;
        
        [CaptureConnection setVideoOrientation:orientation];
	}
	
	//Set frame rate (if requried)
	//CMTimeShow(CaptureConnection.videoMinFrameDuration);
	//CMTimeShow(CaptureConnection.videoMaxFrameDuration);
	
	if (CaptureConnection.supportsVideoMinFrameDuration)
		CaptureConnection.videoMinFrameDuration = CMTimeMake(1, CAPTURE_FRAMES_PER_SECOND);
	if (CaptureConnection.supportsVideoMaxFrameDuration)
		CaptureConnection.videoMaxFrameDuration = CMTimeMake(1, CAPTURE_FRAMES_PER_SECOND);
	
	//CMTimeShow(CaptureConnection.videoMinFrameDuration);
	//CMTimeShow(CaptureConnection.videoMaxFrameDuration);
}

//********** DEALLOC **********
- (void)dealloc
{
	[CaptureSession release];
	[MovieFileOutput release];
    
	[super dealloc];
}

@end
