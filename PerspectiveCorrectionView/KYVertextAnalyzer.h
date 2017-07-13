//
//  KYVertextAnalyzer.h
//  DetectTest
//
//  Created by mac on 2017/6/30.
//  Copyright © 2017年 ky1269. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

@interface KYVertextAnalyzer : NSObject

+ (CIRectangleFeature *)analyseRectangleInImage:(UIImage *)image;

@end
