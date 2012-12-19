//
//  RecClass.h
//  KXKM
//
//  Created by Pierre Hoezelle, Thomas Bohl, Jeremie Forge
//  Copyright 2011 KXKM. Creative Commons BY-NC-SA.
//  12/12/12.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface RecClass : NSObject <AVCaptureFileOutputRecordingDelegate>
{	
	AVCaptureSession *CaptureSession;
	AVCaptureMovieFileOutput *MovieFileOutput;
    NSString *MovieFileName;
    NSString *CameraOrientation;
}

@property (readwrite, retain) NSString* MovieFileName;

- (void) CameraSetOutputProperties;
- (void) setFile:(NSString*)file;
- (void) setOrientation:(NSString*)orientation;
- (void) start;
- (void) rec;
- (void) stop;
- (BOOL) isRecording;

@end