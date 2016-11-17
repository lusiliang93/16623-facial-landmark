//
//  ViewController.m
//  Smerk_Example
//
//  Created by Simon Lucey on 11/30/15.
//  Copyright © 2015 CMU_16432. All rights reserved.
//

#import "ViewController.h"
#import "SMKDetectionCamera.h"
#import <GPUImage/GPUImage.h>

@interface ViewController () {
    // Setup the view (this time using GPUImageView)
    GPUImageView *cameraView_;
    SMKDetectionCamera *detector_; // Detector that should be used
    UIView *faceFeatureTrackingView_; // View for showing bounding box around the face
    CGAffineTransform cameraOutputToPreviewFrameTransform_;
    CGAffineTransform portraitRotationTransform_;
    CGAffineTransform texelToPixelTransform_;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    // Setup GPUImageView (not we are not using UIImageView here).........
    cameraView_ = [[GPUImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
    
    // Set the face detector to be used
    detector_ = [[SMKDetectionCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionFront];
    [detector_ setOutputImageOrientation:UIInterfaceOrientationPortrait]; // Set to portrait
    cameraView_.fillMode = kGPUImageFillModePreserveAspectRatio;
    [detector_ addTarget:cameraView_];

    // Important: add as a subview
    [self.view addSubview:cameraView_];
    
    // Setup the face box view
    [self setupFaceTrackingViews];
    [self calculateTransformations];
    
    // Set the block for running face detector
    [detector_ beginDetecting:kFaceFeatures | kMachineAndFaceMetaData
                        codeTypes:@[AVMetadataObjectTypeQRCode]
               withDetectionBlock:^(SMKDetectionOptions detectionType, NSArray *detectedObjects, CGRect clapOrRectZero) {
                   // Check if the kFaceFeatures have been discovered
                   if (detectionType & kFaceFeatures) {
                       [self updateFaceFeatureTrackingViewWithObjects:detectedObjects];
                   }
               }];

    // Finally start the camera
    [detector_ startCameraCapture];
    
}

// Set up the view for facetracking
- (void)setupFaceTrackingViews
{
    faceFeatureTrackingView_ = [[UIView alloc] initWithFrame:CGRectZero];
    faceFeatureTrackingView_.layer.borderColor = [[UIColor redColor] CGColor];
    faceFeatureTrackingView_.layer.borderWidth = 3;
    faceFeatureTrackingView_.backgroundColor = [UIColor clearColor];
    faceFeatureTrackingView_.hidden = YES;
    faceFeatureTrackingView_.userInteractionEnabled = NO;
    [self.view addSubview:faceFeatureTrackingView_]; // Add as a sub-view
}

// Update the face feature tracking view
- (void)updateFaceFeatureTrackingViewWithObjects:(NSArray *)objects
{
    if (!objects.count) {
        faceFeatureTrackingView_.hidden = YES;
    }
    else {
        CIFaceFeature * feature = objects[0];
        CGRect face = feature.bounds;
        
        face = CGRectApplyAffineTransform(face, portraitRotationTransform_);
        face = CGRectApplyAffineTransform(face, cameraOutputToPreviewFrameTransform_);
        faceFeatureTrackingView_.frame = face;
        faceFeatureTrackingView_.hidden = NO;
        
        // Finally check if I smile (change the color)
        if(feature.hasSmile) {
            faceFeatureTrackingView_.layer.borderColor = [[UIColor blueColor] CGColor];
        }
        else {
            faceFeatureTrackingView_.layer.borderColor = [[UIColor redColor] CGColor];
        }
        
    }
}

// Calculate transformations for displaying output on the screen
- (void)calculateTransformations
{
    NSInteger outputHeight = [[detector_.captureSession.outputs[0] videoSettings][@"Height"] integerValue];
    NSInteger outputWidth = [[detector_.captureSession.outputs[0] videoSettings][@"Width"] integerValue];
    
    if (UIInterfaceOrientationIsPortrait(detector_.outputImageOrientation)) {
        // Portrait mode, swap width & height
        NSInteger temp = outputWidth;
        outputWidth = outputHeight;
        outputHeight = temp;
    }
    
    // Use self.view because self.cameraView is not resized at this point (if 3.5" device)
    CGFloat viewHeight = self.view.frame.size.height;
    CGFloat viewWidth = self.view.frame.size.width;
    
    // Calculate the scale and offset of the view vs the camera output
    // This depends on the fillmode of the GPUImageView
    CGFloat scale;
    CGAffineTransform frameTransform;
    switch (cameraView_.fillMode) {
        case kGPUImageFillModePreserveAspectRatio:
            scale = MIN(viewWidth / outputWidth, viewHeight / outputHeight);
            frameTransform = CGAffineTransformMakeScale(scale, scale);
            frameTransform = CGAffineTransformTranslate(frameTransform, -(outputWidth * scale - viewWidth)/2, -(outputHeight * scale - viewHeight)/2 );
            break;
        case kGPUImageFillModePreserveAspectRatioAndFill:
            scale = MAX(viewWidth / outputWidth, viewHeight / outputHeight);
            frameTransform = CGAffineTransformMakeScale(scale, scale);
            frameTransform = CGAffineTransformTranslate(frameTransform, -(outputWidth * scale - viewWidth)/2, -(outputHeight * scale - viewHeight)/2 );
            break;
        case kGPUImageFillModeStretch:
            frameTransform = CGAffineTransformMakeScale(viewWidth / outputWidth, viewHeight / outputHeight);
            break;
    }
    cameraOutputToPreviewFrameTransform_ = frameTransform;
    
    // In portrait mode, need to swap x & y coordinates of the returned boxes
    if (UIInterfaceOrientationIsPortrait(detector_.outputImageOrientation)) {
        // Interchange x & y
        portraitRotationTransform_ = CGAffineTransformMake(0, 1, 1, 0, 0, 0);
    }
    else {
        portraitRotationTransform_ = CGAffineTransformIdentity;
    }
    
    // AVMetaDataOutput works in texels (relative to the image size)
    // We need to transform this to pixels through simple scaling
    texelToPixelTransform_ = CGAffineTransformMakeScale(outputWidth, outputHeight);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
