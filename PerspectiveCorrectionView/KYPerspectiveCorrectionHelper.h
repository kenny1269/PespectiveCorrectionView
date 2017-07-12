//
//  KYPerspectiveCorrectionHelper.h
//  WorldTrip
//
//  Created by mac on 2017/7/5.
//  Copyright © 2017年 kfvnx. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

@interface KYPerspectiveCorrectionHelper : NSObject

+ (UIImage *)perspectiveCorrectWithImage:(UIImage *)image topLeft:(CGPoint)topLeft bottomLeft:(CGPoint)bottomLeft bottomRight:(CGPoint)bottomRight topRight:(CGPoint)topRight;

@end
