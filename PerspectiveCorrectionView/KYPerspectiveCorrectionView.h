//
//  KYPerspectiveCorrectionView.h
//  NewPerspectingTest
//
//  Created by mac on 2017/8/9.
//  Copyright © 2017年 ky1269. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KYPerspectiveCorrectionView;

@protocol KYPerspectiveCorrectionViewDelegate <NSObject>

- (void)perspectiveCorrectionViewWillMoveVertex:(KYPerspectiveCorrectionView *)view;

- (void)perspectiveCorrectionViewDidEndMovingVertex:(KYPerspectiveCorrectionView *)view;

- (void)perspectiveCorrectionView:(KYPerspectiveCorrectionView *)view didMoveVertexToPointInPerspectiveCorrectionView:(CGPoint)point;

@end

@interface KYPerspectiveCorrectionView : UIView
@property (nonatomic, assign) id<KYPerspectiveCorrectionViewDelegate> delegate;
@property (nonatomic, assign) BOOL enableRectangleDetection;
@property (nonatomic, assign) BOOL showRemovingMask;

- (void)setImage:(UIImage *)image;

- (UIImage *)perspectiveCorrection;

@end
