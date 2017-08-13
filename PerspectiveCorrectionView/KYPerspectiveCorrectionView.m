//
//  KYPerspectiveCorrectionView.m
//  NewPerspectingTest
//
//  Created by mac on 2017/8/9.
//  Copyright © 2017年 ky1269. All rights reserved.
//

#import "KYPerspectiveCorrectionView.h"

@interface IndicatorVertex : UIView

@end

@implementation IndicatorVertex

- (void)drawRect:(CGRect)rect {
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(rect, 10, 10)];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextAddPath(context, path.CGPath);
    CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:1 alpha:0.8].CGColor);
    CGContextFillPath(context);
}

@end

@interface KYPerspectiveCorrectionView ()

@property (nonatomic, weak) UIImageView *imageView;

@property (nonatomic, strong) CAShapeLayer *indicatorLayer;
@property (nonatomic, strong) CAShapeLayer *removingMask;

@property (nonatomic, strong) NSMutableArray *vertexes;
@property (nonatomic, strong) CIRectangleFeature *rectangle;

@end

@implementation KYPerspectiveCorrectionView

- (instancetype)init {
    if (self = [super init]) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    UIImageView *imageView = [[UIImageView alloc] init];
    _imageView = imageView;
    [self addSubview:_imageView];
}

- (void)setImage:(UIImage *)image {
    if (image == nil) return;
    
    self.imageView.image = image;
    
    if (self.enableRectangleDetection) {
        [self detectRectangle];
    }
    
    [self setNeedsLayout];
}

- (UIImage *)perspectiveCorrection {
    CGPoint topLeft = [self vertextFromViewToImage:[self.vertexes[0] center]];
    CGPoint bottomLeft = [self vertextFromViewToImage:[self.vertexes[1] center]];
    CGPoint bottomRight = [self vertextFromViewToImage:[self.vertexes[2] center]];
    CGPoint topRight = [self vertextFromViewToImage:[self.vertexes[3] center]];
    
    CIImage *sourceImage = [[CIImage alloc] initWithCGImage:self.imageView.image.CGImage];
    CIImage *transformedImage = [sourceImage imageByApplyingTransform:CGAffineTransformMake(1, 0, 0, -1, 0, sourceImage.extent.size.height)];
    
    NSMutableDictionary *rectangleCoordinates = [NSMutableDictionary new];
    rectangleCoordinates[@"inputTopLeft"] = [CIVector vectorWithCGPoint:topLeft];
    rectangleCoordinates[@"inputTopRight"] = [CIVector vectorWithCGPoint:topRight];
    rectangleCoordinates[@"inputBottomLeft"] = [CIVector vectorWithCGPoint:bottomLeft];
    rectangleCoordinates[@"inputBottomRight"] = [CIVector vectorWithCGPoint:bottomRight];
    CIImage *enhancedImage = [transformedImage imageByApplyingFilter:@"CIPerspectiveCorrection" withInputParameters:rectangleCoordinates];
    
    if (!enhancedImage || CGRectIsEmpty(enhancedImage.extent)) return nil;
    
    CIContext *ctx = [CIContext context];
    CGImageRef intermediateImage = [ctx createCGImage:enhancedImage fromRect:enhancedImage.extent];
    
    UIImage *image = [UIImage imageWithCGImage:intermediateImage];
    
    CGImageRelease(intermediateImage);
    
    return image;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat imageRatio = self.imageView.image.size.height / self.imageView.image.size.width;
    
    CGRect frame = CGRectInset(self.bounds, 20, 20);
    
    CGFloat frameRatio = frame.size.height / frame.size.width;
    
    if (imageRatio > frameRatio) {
        frame.size.width = frame.size.height / imageRatio;
    } else {
        frame.size.height = frame.size.width * imageRatio;
    }
    
    self.imageView.frame = frame;
    self.imageView.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    
    if (self.rectangle) {
        [self.vertexes[0] setCenter:[self vertexFromRectangleToView:self.rectangle.bottomLeft]];
        [self.vertexes[1] setCenter:[self vertexFromRectangleToView:self.rectangle.topLeft]];
        [self.vertexes[2] setCenter:[self vertexFromRectangleToView:self.rectangle.topRight]];
        [self.vertexes[3] setCenter:[self vertexFromRectangleToView:self.rectangle.bottomRight]];
        self.rectangle = nil;
    } else {
        [self.vertexes[0] setCenter:self.imageView.frame.origin];
        [self.vertexes[1] setCenter:CGPointMake(self.imageView.frame.origin.x, CGRectGetMaxY(self.imageView.frame))];
        [self.vertexes[2] setCenter:CGPointMake(CGRectGetMaxX(self.imageView.frame), CGRectGetMaxY(self.imageView.frame))];
        [self.vertexes[3] setCenter:CGPointMake(CGRectGetMaxX(self.imageView.frame), self.imageView.frame.origin.y)];
    }
    [self drawIndicator];
}

#pragma mark - private

- (void)drawIndicator {
    UIBezierPath *path = [[UIBezierPath alloc] init];
    [path moveToPoint:[self.vertexes[0] center]];
    [path addLineToPoint:[self.vertexes[1] center]];
    [path addLineToPoint:[self.vertexes[2] center]];
    [path addLineToPoint:[self.vertexes[3] center]];
    [path closePath];
    self.indicatorLayer.path = path.CGPath;
    
    if (self.showRemovingMask) {
        CGMutablePathRef maskPath = CGPathCreateMutable();
        CGPathAddRect(maskPath, nil, self.bounds);
        CGPathAddPath(maskPath, nil, path.CGPath);
        self.removingMask.path = maskPath;
        CGPathRelease(maskPath);
    }
}

- (void)pan:(UIPanGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        sender.view.alpha = 0;
        
        if ([self.delegate respondsToSelector:@selector(perspectiveCorrectionViewWillMoveVertex:)]) {
            [self.delegate perspectiveCorrectionViewWillMoveVertex:self];
        }
        
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        sender.view.alpha = 1;
        
        if ([self.delegate respondsToSelector:@selector(perspectiveCorrectionViewDidEndMovingVertex:)]) {
            [self.delegate perspectiveCorrectionViewDidEndMovingVertex:self];
        }
    } else if (sender.state == UIGestureRecognizerStateChanged) {
        CGPoint lastLocation = sender.view.center;
        CGPoint location = [sender locationInView:self];
        if (!CGRectContainsPoint(self.imageView.frame, location)) {
            if (location.x < CGRectGetMinX(self.imageView.frame)) {
                location.x = CGRectGetMinX(self.imageView.frame);
            }
            if (location.x > CGRectGetMaxX(self.imageView.frame)) {
                location.x = CGRectGetMaxX(self.imageView.frame);
            }
            if (location.y > CGRectGetMaxY(self.imageView.frame)) {
                location.y = CGRectGetMaxY(self.imageView.frame);
            }
            if (location.y < CGRectGetMinY(self.imageView.frame)) {
                location.y = CGRectGetMinY(self.imageView.frame);
            }
        };
        sender.view.center = location;
        
        BOOL validate = [self validateQuadrilateralWithOppositeVertex1:[self.vertexes[0] center] vertex2:[self.vertexes[2] center] theOtherOppositeVertex3:[self.vertexes[1] center] vertex4:[self.vertexes[3] center]];
        if (validate) {
            [self drawIndicator];
        } else {
            sender.view.center = lastLocation;
        }
        
        if ([self.delegate respondsToSelector:@selector(perspectiveCorrectionView:didMoveVertexToPointInPerspectiveCorrectionView:)]) {
            [self.delegate perspectiveCorrectionView:self didMoveVertexToPointInPerspectiveCorrectionView:sender.view.center];
        }
    }
}

- (BOOL)validateQuadrilateralWithOppositeVertex1:(CGPoint)vertex1 vertex2:(CGPoint)vertex2 theOtherOppositeVertex3:(CGPoint)vertex3 vertex4:(CGPoint)vertex4 {
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

- (CGPoint)vertextFromViewToImage:(CGPoint)vertex {
    CGPoint locationInImageView = CGPointMake(vertex.x - self.imageView.frame.origin.x, vertex.y - self.imageView.frame.origin.y);
    CGFloat factor = self.imageView.image.size.width / self.imageView.frame.size.width;
    return CGPointMake(locationInImageView.x * factor, locationInImageView.y * factor);
}

- (void)detectRectangle {
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeRectangle context:nil options:@{CIDetectorAccuracy : CIDetectorAccuracyHigh}];
    CIImage *sourceImage = [[CIImage alloc] initWithCGImage:self.imageView.image.CGImage];
    CIImage *transformedImage = [sourceImage imageByApplyingTransform:CGAffineTransformMake(1, 0, 0, -1, 0, sourceImage.extent.size.height)];
    
    NSArray *rectangles = [detector featuresInImage:transformedImage];
    if (![rectangles count]) return;
    
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
    
    self.rectangle = biggestRectangle;
}

- (CGPoint)vertexFromRectangleToView:(CGPoint)vertex {
    CGFloat factor = self.imageView.frame.size.width / self.imageView.image.size.width;
    return CGPointMake(vertex.x * factor + self.imageView.frame.origin.x, vertex.y * factor + self.imageView.frame.origin.y);
}

#pragma mark -

- (NSMutableArray *)vertexes {
    if (!_vertexes) {
        _vertexes = [NSMutableArray array];
        for (NSUInteger i = 0; i < 4; i++) {
            IndicatorVertex *vertex = [[IndicatorVertex alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
            vertex.backgroundColor = [UIColor clearColor];
            [vertex addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)]];
            [_vertexes addObject:vertex];
            [self addSubview:vertex];
        }
    }
    return _vertexes;
}

- (CAShapeLayer *)indicatorLayer {
    if (!_indicatorLayer) {
        _indicatorLayer = [CAShapeLayer layer];
        _indicatorLayer.frame = self.bounds;
        _indicatorLayer.lineWidth = 2;
        _indicatorLayer.strokeColor = [UIColor whiteColor].CGColor;
        _indicatorLayer.fillColor = [UIColor clearColor].CGColor;
        [self.layer insertSublayer:_indicatorLayer above:self.imageView.layer];
    }
    return _indicatorLayer;
}

- (CAShapeLayer *)removingMask {
    if (!_removingMask) {
        _removingMask = [CAShapeLayer layer];
        _removingMask.frame = self.bounds;
        _removingMask.fillColor = [UIColor colorWithWhite:0 alpha:0.5].CGColor;
        _removingMask.fillRule = kCAFillRuleEvenOdd;
        [self.layer insertSublayer:_removingMask below:self.indicatorLayer];
    }
    return _removingMask;
}

- (void)setShowRemovingMask:(BOOL)showRemovingMask {
    _showRemovingMask = showRemovingMask;
    self.removingMask.hidden = !_showRemovingMask;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
