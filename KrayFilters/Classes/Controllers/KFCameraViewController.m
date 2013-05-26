//
//  KFCameraViewController.m
//  KrayFilters
//
//  Created by Mark Glagola on 5/25/13.
//  Copyright (c) 2013 Mark Glagola. All rights reserved.
//

#import "KFCameraViewController.h"
#import "GPUImage.h"
#import "KFCaptureButton.h"
#import "KFImageHeatFilter.h"
 
@interface KFCameraViewController () {
    GPUImageVideoCamera *camera;
    GPUImageFilter *filter;
    
    IBOutlet KFCaptureButton *captureButton;
    IBOutlet GPUImageView *gpuImageView;

//    CGPoint panStartPoint;
    NSInteger currentFilter;
}

@property (nonatomic) ALAssetsLibrary *assetsLibrary;

@end

@implementation KFCameraViewController

@synthesize assetsLibrary = _assetsLibrary;

NSUInteger UIViewAutoresizingMaskAll() {
    return UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin |UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (NSArray*) filterClasses {
    return @[[GPUImageSketchFilter class],
             [GPUImageSmoothToonFilter class],
             [GPUImagePrewittEdgeDetectionFilter class],
             [GPUImageErosionFilter class],
             [KFImageHeatFilter class],
             ];
}

- (ALAssetsLibrary*) assetsLibrary {
    if (!_assetsLibrary)
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
    return _assetsLibrary;
}

- (void) changeFilter:(GPUImageFilter*)toFilter {
    //remove old filter
    if (filter) {
        [camera removeTarget:filter];
        [filter removeTarget:gpuImageView];
    }
    
    //add new filter
    filter = toFilter;
    [camera addTarget:filter];
    [filter addTarget:gpuImageView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    captureButton.layer.cornerRadius = captureButton.width*.25f;
    
    currentFilter = 0;

    camera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1920x1080 cameraPosition:AVCaptureDevicePositionBack];
    camera.outputImageOrientation = self.interfaceOrientation;
    gpuImageView.autoresizingMask = UIViewAutoresizingMaskAll();
    [self changeFilter:[[GPUImageSketchFilter alloc] init]];

    
    [camera startCameraCapture];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    doubleTap.cancelsTouchesInView = NO;
    doubleTap.numberOfTapsRequired = 2;
    [gpuImageView addGestureRecognizer:doubleTap];
        
//    UIPanGestureRecognizer *panGest = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureDetected:)];
//    panGest.cancelsTouchesInView = NO;
//    panGest.delaysTouchesEnded = NO;
//    [gpuImageView addGestureRecognizer:panGest];
}

//- (void) panGestureDetected:(UIPanGestureRecognizer*)gesture {
//    CGPoint currentLoc = [gesture translationInView:gpuImageView];
//    if (gesture.state == UIGestureRecognizerStateBegan) {
//        panStartPoint = currentLoc;
//    }
//    
//    CGFloat offset = currentLoc.y - panStartPoint.y;
//    NSLog(@"%f", offset);
//}

- (void) tapGesture:(UITapGestureRecognizer*)gesture {
    currentFilter++;
    if (currentFilter > self.filterClasses.count-1)
        currentFilter = 0;
    
    Class newFilterClass = [[self filterClasses] objectAtIndex:currentFilter];
    [self changeFilter:[[newFilterClass alloc] init]];
}

- (IBAction)captureButtonPressed:(id)sender {
    if (!filter) return;
    
    [SVProgressHUD showWithStatus:@"Saving..."];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        UIImage *image = [filter imageFromCurrentlyProcessedOutput];
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

#pragma mark - Interface Orientation Change
- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration  {
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
        toInterfaceOrientation = toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ? UIInterfaceOrientationLandscapeRight : UIInterfaceOrientationLandscapeLeft;
    camera.outputImageOrientation = toInterfaceOrientation;
}

@end
