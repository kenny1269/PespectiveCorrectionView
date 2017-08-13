//
//  ViewController.m
//  PespectiveCorrectionViewDemo
//
//  Created by mac on 2017/7/11.
//  Copyright © 2017年 ky1269. All rights reserved.
//

#import "ViewController.h"

#import "ResultViewController.h"

#import "KYPerspectiveCorrectionView.h"

#import "UIImage+Rotate.h"

@interface ViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, CALayerDelegate, KYPerspectiveCorrectionViewDelegate>
@property (weak, nonatomic) IBOutlet KYPerspectiveCorrectionView *KYPerspectiveCorrectionView;

@property (nonatomic, strong) CALayer *snapshot;

@property (nonatomic, assign) CGPoint touchLocation;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.KYPerspectiveCorrectionView.delegate = self;
    self.KYPerspectiveCorrectionView.showRemovingMask = YES;
    self.KYPerspectiveCorrectionView.enableRectangleDetection = YES;
    [self.KYPerspectiveCorrectionView setImage:[UIImage imageNamed:@"2.jpg"]];
    
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (IBAction)pickImage:(id)sender {
    UIImagePickerController *vc = [[UIImagePickerController alloc] init];
    vc.sourceType = UIImagePickerControllerSourceTypeCamera;
    vc.delegate = self;
    [self presentViewController:vc animated:YES completion:nil];
}
- (IBAction)correction:(id)sender {
    UIImage *image = [self.KYPerspectiveCorrectionView perspectiveCorrection];
    [self performSegueWithIdentifier:@"ShowResult" sender:image];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ResultViewController *vc = [(UINavigationController *)segue.destinationViewController viewControllers].firstObject;
    vc.image = sender;
}

#pragma mark - KYPerspectiveCorrectionViewDelegate

- (void)perspectiveCorrectionViewWillMoveVertex:(KYPerspectiveCorrectionView *)view {
    self.snapshot.hidden = NO;
}

- (void)perspectiveCorrectionViewDidEndMovingVertex:(KYPerspectiveCorrectionView *)view {
    self.snapshot.hidden = YES;
}

- (void)perspectiveCorrectionView:(KYPerspectiveCorrectionView *)view didMoveVertexToPointInPerspectiveCorrectionView:(CGPoint)point {
    self.touchLocation = point;
    [self.snapshot setNeedsDisplay];
}

#pragma mark - CALayerDelegate

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
    CGContextTranslateCTM(ctx, -self.touchLocation.x + 50, -self.touchLocation.y + 50);
    [self.KYPerspectiveCorrectionView.layer renderInContext:ctx];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    [self.KYPerspectiveCorrectionView setImage:[image fixOrientation]];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 

- (CALayer *)snapshot {
    if (!_snapshot) {
        _snapshot = [CALayer layer];
        _snapshot.frame = CGRectMake(0, 10, 100, 100);
        _snapshot.delegate = self;
        _snapshot.drawsAsynchronously = YES;
        _snapshot.contentsScale = [UIScreen mainScreen].scale;
        _snapshot.backgroundColor = [UIColor blackColor].CGColor;
        _snapshot.cornerRadius = 50;
        _snapshot.borderWidth = 2;
        _snapshot.borderColor = [UIColor whiteColor].CGColor;
        _snapshot.masksToBounds = YES;
        [self.view.layer addSublayer:_snapshot];
    }
    return _snapshot;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
