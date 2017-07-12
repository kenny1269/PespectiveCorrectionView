//
//  KYVertextAnalyzer.h
//  DetectTest
//
//  Created by mac on 2017/6/30.
//  Copyright © 2017年 ky1269. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, PointPositionType) {
    PointPositionTypeTopLeft,
    PointPositionTypeBottomLeft,
    PointPositionTypeTopRight,
    PointPositionTypeBottomRight
};

@interface KYVertextAnalyzer : NSObject

+ (BOOL)validateVertexesOfQuadrilateralWithOppositeVertex1:(CGPoint)vertex1 vertex2:(CGPoint)vertex2 theOtherOppositeVertex3:(CGPoint)vertex3 vertex4:(CGPoint)vertex4;

@end
