//
//  KYPerspectiveCorrectionView.h
//  Pods
//
//  Created by mac on 2017/7/10.
//
//

#import <UIKit/UIKit.h>

@interface KYPerspectiveCorrectionView : UIView

@property (nonatomic, assign) BOOL enableRectangleDetection;

- (void)setImage:(UIImage *)image;

- (UIImage *)perspectiveCorrection;

@end
