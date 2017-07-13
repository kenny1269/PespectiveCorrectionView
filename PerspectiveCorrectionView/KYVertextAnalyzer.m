//
//  KYVertextAnalyzer.m
//  DetectTest
//
//  Created by mac on 2017/6/30.
//  Copyright © 2017年 ky1269. All rights reserved.
//

#import "KYVertextAnalyzer.h"

#import "UIImage+Rotate.h"

@implementation KYVertextAnalyzer

+ (CIRectangleFeature *)analyseRectangleInImage:(UIImage *)image {
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeRectangle context:nil options:@{CIDetectorAccuracy : CIDetectorAccuracyHigh}];
    
    CIImage *sourceImage = [[CIImage alloc] initWithCGImage:[image fixOrientation].CGImage];
    
    CIFilter *transform = [CIFilter filterWithName:@"CIAffineTransform"];
    [transform setValue:sourceImage forKey:kCIInputImageKey];
    NSValue *rotation = [NSValue valueWithCGAffineTransform:CGAffineTransformMake(1, 0, 0, -1, 0, sourceImage.extent.size.height)];
    [transform setValue:rotation forKey:@"inputTransform"];
    sourceImage = [transform outputImage];
    
    NSArray *rectangles = [detector featuresInImage:sourceImage];
    
    if (![rectangles count]) return nil;
    
    float halfPerimiterValue = 0;
    
    CIRectangleFeature *biggestRectangle = [rectangles firstObject];
    
    for (CIRectangleFeature *rect in rectangles)
    {
        CGPoint p1 = rect.topLeft;
        CGPoint p2 = rect.topRight;
        CGFloat width = hypotf(p1.x - p2.x, p1.y - p2.y);
        
        CGPoint p3 = rect.topLeft;
        CGPoint p4 = rect.bottomLeft;
        CGFloat height = hypotf(p3.x - p4.x, p3.y - p4.y);
        
        CGFloat currentHalfPerimiterValue = height + width;
        
        if (halfPerimiterValue < currentHalfPerimiterValue)
        {
            halfPerimiterValue = currentHalfPerimiterValue;
            biggestRectangle = rect;
        }
    }
    
    return biggestRectangle;
}

@end
