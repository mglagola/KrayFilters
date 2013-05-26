//
//  KFCameraViewController.m
//  KrayFilters
//
//  Created by Mark Glagola on 5/25/13.
//  Copyright (c) 2013 Mark Glagola. All rights reserved.
//

#import "KFCameraViewController.h"
#import "GPUImage.h"
#import "MGInstagram.h"

@interface KFCameraViewController () {
    GPUImageVideoCamera *camera;
    GPUImageFilter *sketchFilter;
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
    sketchFilter = [[GPUImageSketchFilter alloc] init];
    [camera addTarget:sketchFilter];

    GPUImageView *imageView = [[GPUImageView alloc] initWithFrame:self.view.frame];
    imageView.autoresizingMask = UIViewAutoresizingMaskAll();
    [self.view addSubview:imageView];
    [sketchFilter addTarget:imageView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *bImage = [UIImage imageNamed:@"camera-button"];
    CGSize bSize = CGSizeMake(60, 46);
    button.frame = CGRectMake(self.view.width*.5f-bSize.width*.5f, self.view.height-bSize.height*1.1f, bSize.width, bSize.height);
    [button setImage:bImage forState:UIControlStateNormal];
    [button addTarget:self action:@selector(captureButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    [camera startCameraCapture];
    
}

- (void) captureButtonPressed {
    UIImage *image = [sketchFilter imageFromCurrentlyProcessedOutput];
    UIImageWriteToSavedPhotosAlbum(image, NULL, NULL, NULL);
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration  {
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
        toInterfaceOrientation = toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ? UIInterfaceOrientationLandscapeRight : UIInterfaceOrientationLandscapeLeft;
    camera.outputImageOrientation = toInterfaceOrientation;
}

@end
