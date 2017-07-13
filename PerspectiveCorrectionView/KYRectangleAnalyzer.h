//
//  KYRectangleAnalyzer.h
//  PerspectiveCorrectionViewDemo
//
//  Created by mac on 2017/7/13.
//  Copyright © 2017年 ky1269. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

@interface KYRectangleAnalyzer : NSObject

+ (CIRectangleFeature *)analyseRectangleInImage:(UIImage *)image;

@end
