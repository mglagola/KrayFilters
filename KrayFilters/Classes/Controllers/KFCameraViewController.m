//
//  KFCameraViewController.m
//  KrayFilters
//
//  Created by Mark Glagola on 5/25/13.
//  Copyright (c) 2013 Mark Glagola. All rights reserved.
//

#import "KFCameraViewController.h"
#import "GPUImage.h"

@interface KFCameraViewController () {
    GPUImageVideoCamera *camera;
}

@end

@implementation KFCameraViewController

NSUInteger UIViewAutoresizingMaskAll() {
    return UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin |UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];

    camera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1920x1080 cameraPosition:AVCaptureDevicePositionBack];
    camera.outputImageOrientation = self.interfaceOrientation;
    GPUImageFilter *sketchFilter = [[GPUImageSketchFilter alloc] init];
    [camera addTarget:sketchFilter];

    GPUImageView *imageView = [[GPUImageView alloc] initWithFrame:self.view.frame];
    imageView.autoresizingMask = UIViewAutoresizingMaskAll();
    [self.view addSubview:imageView];
    [sketchFilter addTarget:imageView];
    
    [camera startCameraCapture];
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration  {
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
        toInterfaceOrientation = toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ? UIInterfaceOrientationLandscapeRight : UIInterfaceOrientationLandscapeLeft;
    camera.outputImageOrientation = toInterfaceOrientation;
}

@end
