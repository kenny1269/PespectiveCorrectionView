//
//  KYVertextAnalyzer.m
//  DetectTest
//
//  Created by mac on 2017/6/30.
//  Copyright © 2017年 ky1269. All rights reserved.
//

#import "KYVertextAnalyzer.h"

@implementation KYVertextAnalyzer

+ (BOOL)validateVertexesOfQuadrilateralWithOppositeVertex1:(CGPoint)vertex1 vertex2:(CGPoint)vertex2 theOtherOppositeVertex3:(CGPoint)vertex3 vertex4:(CGPoint)vertex4 {
    float slope1 = (vertex1.y - vertex2.y) / (vertex1.x - vertex2.x);
    float slope2 = (vertex3.y - vertex4.y) / (vertex3.x - vertex4.x);
    
    float k1 = (vertex2.y * vertex1.x - vertex1.y * vertex2.x) / (vertex1.x - vertex2.x);
    float k2 = (vertex4.y * vertex3.x - vertex3.y * vertex4.x) / (vertex3.x - vertex4.x);
    
    float intersectX = (k2 - k1) / (slope1 - slope2);
    float intersectY = (slope1 * k2 - slope2 * k1) / (slope1 - slope2);
    
    float atan1 = atan(vertex1.y / vertex1.x);
    float atan2 = atan(vertex2.y / vertex2.x);
    float atan3 = atan(vertex3.y / vertex3.x);
    float atan4 = atan(vertex4.y / vertex4.x);
    float atanIntersect = atan(intersectY / intersectX);
    
    BOOL validate1 = NO;
    BOOL validate2 = NO;
    
    if ((atan1 < atanIntersect && atanIntersect < atan2) || (atan2 < atanIntersect && atanIntersect < atan1)) {
        validate1 = YES;
    }
    
    if ((atan3 < atanIntersect && atanIntersect < atan4) || (atan4 < atanIntersect && atanIntersect < atan3)) {
        validate2 = YES;
    }
    
    return validate1 && validate2;
}

@end
