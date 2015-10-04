//
//  ViewController.m
//  PinguPay
//
//  Created by Pratham Mehta on 02/10/15.
//  Copyright (c) 2015 PinguPay Inc. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <AVCaptureMetadataOutputObjectsDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic) BOOL qrfound;

@end

@implementation ViewController

- (void)viewDidLoad
{
    self.creditCardCollectionView.delegate = self;
    self.creditCardCollectionView.dataSource = self;
    [self.creditCardCollectionView reloadData];
    
    self.storeNameLabel.alpha = 0;
    self.locationLabel.alpha = 0;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 4;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"creditCardCell" forIndexPath:indexPath];
    UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:5];
    imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%ld",(long)indexPath.row+1]];
    return cell;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice
                                                                        error:nil];
    self.captureSession = [[AVCaptureSession alloc] init];
    [self.captureSession addInput:input];
    
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [self.captureSession addOutput:captureMetadataOutput];
    
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("myQueue", NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
    
    self.videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    [self.videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [self.videoPreviewLayer setFrame:self.cameraPreview.layer.bounds];
    [self.cameraPreview.layer addSublayer:_videoPreviewLayer];
    
    [self.captureSession startRunning];
    
    

}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects
       fromConnection:(AVCaptureConnection *)connection
{
    
    if(!self.qrfound)
    {
        self.qrfound = YES;
        AVMetadataMachineReadableCodeObject *metadataObject = metadataObjects.lastObject;
        NSLog(@"Object: %@",metadataObject.stringValue);
        [self performSelectorOnMainThread:@selector(performAnimations) withObject:nil waitUntilDone:NO];
    }
}

- (void) performAnimations
{
    [UIView animateWithDuration:1.0
                     animations:^{
                         self.cameraPreview.alpha = 0;
                         self.creditCardCollectionView.center = CGPointMake(self.view.center.x,
                                                                            self.creditCardCollectionView.center.y - 100);
                         self.storeNameLabel.alpha = 1.0;
                         self.locationLabel.alpha = 1.0;
                     }
                     completion:nil];

}

@end
