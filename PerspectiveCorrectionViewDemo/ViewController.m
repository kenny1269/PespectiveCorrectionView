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

@interface ViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet KYPerspectiveCorrectionView *KYPerspectiveCorrectionView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.KYPerspectiveCorrectionView.enableRectangleDetection = YES;
    [self.KYPerspectiveCorrectionView setImage:[UIImage imageNamed:@"1.jpg"]];
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

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    [self.KYPerspectiveCorrectionView setImage:image];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
