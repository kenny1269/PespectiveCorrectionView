//
//  PerspectiveCorrectionHelper.m
//  WorldTrip
//
//  Created by mac on 2017/7/5.
//  Copyright © 2017年 kfvnx. All rights reserved.
//

#import "KYPerspectiveCorrectionHelper.h"

#import "UIImage+Rotate.h"

@implementation KYPerspectiveCorrectionHelper

+ (UIImage *)perspectiveCorrectWithImage:(UIImage *)image topLeft:(CGPoint)topLeft bottomLeft:(CGPoint)bottomLeft bottomRight:(CGPoint)bottomRight topRight:(CGPoint)topRight {
    CIImage *sourceImage = [[CIImage alloc] initWithCGImage:[image fixOrientation].CGImage];
    
    CIFilter *transform = [CIFilter filterWithName:@"CIAffineTransform"];
    [transform setValue:sourceImage forKey:kCIInputImageKey];
    NSValue *rotation = [NSValue valueWithCGAffineTransform:CGAffineTransformMake(1, 0, 0, -1, 0, sourceImage.extent.size.height)];
    [transform setValue:rotation forKey:@"inputTransform"];
    sourceImage = [transform outputImage];
    
    NSMutableDictionary *rectangleCoordinates = [NSMutableDictionary new];
    rectangleCoordinates[@"inputTopLeft"] = [CIVector vectorWithCGPoint:topLeft];
    rectangleCoordinates[@"inputTopRight"] = [CIVector vectorWithCGPoint:topRight];
    rectangleCoordinates[@"inputBottomLeft"] = [CIVector vectorWithCGPoint:bottomLeft];
    rectangleCoordinates[@"inputBottomRight"] = [CIVector vectorWithCGPoint:bottomRight];
    CIImage *enhancedImage = [sourceImage imageByApplyingFilter:@"CIPerspectiveCorrection" withInputParameters:rectangleCoordinates];
    
    if (!enhancedImage || CGRectIsEmpty(enhancedImage.extent)) return nil;
    
    CIContext *ctx = nil;
    if (!ctx)
    {
        ctx = [CIContext contextWithOptions:@{kCIContextWorkingColorSpace:[NSNull null]}];
    }
    
    CGSize bounds = enhancedImage.extent.size;
    bounds = CGSizeMake(floorf(bounds.width / 4) * 4,floorf(bounds.height / 4) * 4);
    CGRect extent = CGRectMake(enhancedImage.extent.origin.x, enhancedImage.extent.origin.y, bounds.width, bounds.height);
    
    static int bytesPerPixel = 8;
    uint rowBytes = bytesPerPixel * bounds.width;
    uint totalBytes = rowBytes * bounds.height;
    uint8_t *byteBuffer = malloc(totalBytes);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    [ctx render:enhancedImage toBitmap:byteBuffer rowBytes:rowBytes bounds:extent format:kCIFormatRGBA8 colorSpace:colorSpace];
    
    CGContextRef bitmapContext = CGBitmapContextCreate(byteBuffer,bounds.width,bounds.height,bytesPerPixel,rowBytes,colorSpace,kCGImageAlphaNoneSkipLast);
    CGImageRef imgRef = CGBitmapContextCreateImage(bitmapContext);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(bitmapContext);
    free(byteBuffer);
    
    return [UIImage imageWithCGImage:imgRef];;
}

@end
