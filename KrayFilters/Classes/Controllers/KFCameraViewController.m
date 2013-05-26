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
    GPUImageFilter *sketchFilter;
}

@property (nonatomic) ALAssetsLibrary *assetsLibrary;


@end

@implementation KFCameraViewController

@synthesize assetsLibrary = _assetsLibrary;

NSUInteger UIViewAutoresizingMaskAll() {
    return UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin |UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (ALAssetsLibrary*) assetsLibrary {
    if (!_assetsLibrary)
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
    return _assetsLibrary;
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
    [SVProgressHUD showWithStatus:@"Saving..."];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        UIImage *image = [sketchFilter imageFromCurrentlyProcessedOutput];
        [self.assetsLibrary writeImageToSavedPhotosAlbum:image.CGImage orientation:(ALAssetOrientation)image.imageOrientation completionBlock:^(NSURL *assetURL, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error) {
                    [SVProgressHUD showErrorWithStatus:@"Error Saving!"];
                    return;
                }
                [SVProgressHUD showSuccessWithStatus:@"Photo Saved!"];
            });
        }];
    });
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration  {
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
        toInterfaceOrientation = toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ? UIInterfaceOrientationLandscapeRight : UIInterfaceOrientationLandscapeLeft;
    camera.outputImageOrientation = toInterfaceOrientation;
}

@end
