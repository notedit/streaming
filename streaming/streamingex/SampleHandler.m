//
//  SampleHandler.m
//  streamingex
//
//  Created by xiang on 12/09/2017.
//  Copyright © 2017 dotEngine. All rights reserved.
//


#import "SampleHandler.h"

#import <DotEngine.h>
#import <DotStream.h>
#import <DotVideoCapturer.h>


static  NSString*  APP_KEY = @"45";
static  NSString*  APP_SECRET = @"dc5cabddba054ffe894ba79c2910866c";
static  NSString*  ROOM = @"dotcc";



//  To handle samples with a subclass of RPBroadcastSampleHandler set the following in the extension's Info.plist file:
//  - RPBroadcastProcessMode should be set to RPBroadcastProcessModeSampleBuffer
//  - NSExtensionPrincipalClass should be set to this class

@interface SampleHandler ()<DotEngineDelegate,DotStreamDelegate>
{
    
    DotEngine* dotEngine;
    DotStream* localStream;
    DotVideoCapturer* videoCapturer;
}
@end


@implementation SampleHandler

- (void)broadcastStartedWithSetupInfo:(NSDictionary<NSString *,NSObject *> *)setupInfo {
    // User has requested to start the broadcast. Setup info from the UI extension will be supplied.
    NSLog(@"broadcastStartedWithSetupInfo %@", setupInfo);
    
    if (dotEngine == nil) {
        dotEngine = [DotEngine sharedInstanceWithDelegate:self];
    }
    
    
    localStream = [[DotStream alloc] initWithAudio:YES
                                             video:YES
                                      videoProfile:DotEngine_VideoProfile_480P
                                          delegate:self];
    
    videoCapturer = [[DotVideoCapturer alloc] init];
    
    localStream.videoCaptuer = videoCapturer;
    
    [localStream setupLocalMedia];
}

- (void)broadcastPaused {
    // User has requested to pause the broadcast. Samples will stop being delivered.
    NSLog(@"broadcastPaused");
}

- (void)broadcastResumed {
    // User has requested to resume the broadcast. Samples delivery will resume.
    NSLog(@"broadcastResumed");
}

- (void)broadcastFinished {
    // User has requested to finish the broadcast.
    NSLog(@"broadcastFinished");
}

- (void)processSampleBuffer:(CMSampleBufferRef)sampleBuffer withType:(RPSampleBufferType)sampleBufferType {
    
    switch (sampleBufferType) {
        case RPSampleBufferTypeVideo:
            // Handle audio sample buffer
            break;
        case RPSampleBufferTypeAudioApp:
            // Handle audio sample buffer for app audio
            break;
        case RPSampleBufferTypeAudioMic:
            // Handle audio sample buffer for mic audio
            break;
            
        default:
            break;
    }
    
    if (sampleBufferType == RPSampleBufferTypeVideo) {
        
        CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        CVPixelBufferLockBaseAddress(imageBuffer, 0);
        
        // Get the pixel buffer width and height
        size_t width = CVPixelBufferGetWidth(imageBuffer);
        size_t height = CVPixelBufferGetHeight(imageBuffer);
        size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
        size_t planeCount =  CVPixelBufferGetPlaneCount(imageBuffer);
        
        NSLog(@"get CMSampleBufferRef width: %zu  height: %zu   bytesPerRow :%zu  planeCount: %zu", width, height, bytesPerRow,planeCount);
        
        CMTime currentTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
        
        OSType pixelFormatType = CVPixelBufferGetPixelFormatType(imageBuffer);
        
        if(pixelFormatType == kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange ||
           pixelFormatType == kCVPixelFormatType_420YpCbCr8BiPlanarFullRange){
            // only nv12 support
            NSLog(@"kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange ");
            
            if (videoCapturer != nil) {
                [videoCapturer sendCVPixelBuffer:imageBuffer
                                        rotation:VideoRoation_0];
            }
        }
        CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    }
}



#pragma DotEngine Delegate


-(void)dotEngine:(DotEngine* _Nonnull) engine didJoined:(NSString* _Nonnull)peerId
{
    NSLog(@"didJoined ");
}

-(void)dotEngine:(DotEngine* _Nonnull) engine didLeave:(NSString* _Nonnull)peerId
{
    NSLog(@"didLeave");
}

-(void)dotEngine:(DotEngine* _Nonnull) engine  stateChange:(DotStatus)state
{
    if (state == DotStatusConnected) {
        [dotEngine addStream:localStream];
    }
}

-(void)dotEngine:(DotEngine* _Nonnull) engine didAddLocalStream:(DotStream* _Nonnull)stream
{
    NSLog(@"didAddLocalStream");
}

-(void)dotEngine:(DotEngine* _Nonnull) engine didRemoveLocalStream:(DotStream* _Nonnull)stream
{

}

-(void)dotEngine:(DotEngine* _Nonnull) engine didAddRemoteStream:(DotStream* _Nonnull)stream
{

}

-(void)dotEngine:(DotEngine* _Nonnull) engine didRemoveRemoteStream:(DotStream* _Nonnull) stream
{

}

-(void)dotEngine:(DotEngine* _Nonnull) engine didOccurError:(DotEngineErrorCode)errorCode
{
    
    NSLog(@"didOccurError  %ld", (long)errorCode);
}


#pragma DotStream delegate


-(void)stream:(DotStream* _Nullable)stream  didMutedVideo:(BOOL)muted
{

}

-(void)stream:(DotStream* _Nullable)stream  didMutedAudio:(BOOL)muted
{

}

-(void)stream:(DotStream* _Nullable)stream  didGotAudioLevel:(int)audioLevel
{
    

}

@end
