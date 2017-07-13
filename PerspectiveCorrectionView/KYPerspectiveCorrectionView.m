//
//  KYPerspectiveCorrectionView.m
//  Pods
//
//  Created by mac on 2017/7/10.
//
//

#import "KYPerspectiveCorrectionView.h"
#import "KYInterceptorIndicator.h"
#import "KYVertextAnalyzer.h"

#import "KYPerspectiveCorrectionHelper.h"

#define SnapshotWidth 100.0

@interface KYPerspectiveCorrectionView () <KYInterceptorIndicatorDelegate>

@property (nonatomic, weak) UIImageView *snapshot;
@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, weak) KYInterceptorIndicator *KYInterceptorIndicator;

@end

@implementation KYPerspectiveCorrectionView

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
    
    [self.KYInterceptorIndicator setInterceptBounds:self.imageView.frame];
    
    if (self.enableRectangleDetection) {
        CIRectangleFeature *rectangle = [KYVertextAnalyzer analyseRectangleInImage:self.imageView.image];
        if (rectangle) {
            CGFloat factor = self.imageView.frame.size.width / self.imageView.image.size.width;
            
            self.KYInterceptorIndicator.topLeft = [self scalePoint:rectangle.bottomLeft withFactor:factor];
            self.KYInterceptorIndicator.bottomLeft = [self scalePoint:rectangle.topLeft withFactor:factor];
            self.KYInterceptorIndicator.bottomRight = [self scalePoint:rectangle.topRight withFactor:factor];
            self.KYInterceptorIndicator.topRight = [self scalePoint:rectangle.bottomRight withFactor:factor];
        }
    }
}

- (void)setImage:(UIImage *)image {
    self.imageView.image = image;
    
    [self setNeedsLayout];
    
    [self.KYInterceptorIndicator setNeedsDisplay];
}

- (UIImage *)perspectiveCorrection {
    CGFloat factor = self.imageView.image.size.width / self.imageView.frame.size.width;
    
    CGPoint topLeft = [self scalePoint:self.KYInterceptorIndicator.topLeft withFactor:factor];
    CGPoint bottomLeft = [self scalePoint:self.KYInterceptorIndicator.bottomLeft withFactor:factor];
    CGPoint bottomRight = [self scalePoint:self.KYInterceptorIndicator.bottomRight withFactor:factor];
    CGPoint topRight = [self scalePoint:self.KYInterceptorIndicator.topRight withFactor:factor];
    
    UIImage *image = [KYPerspectiveCorrectionHelper perspectiveCorrectWithImage:self.imageView.image topLeft:topLeft bottomLeft:bottomLeft bottomRight:bottomRight topRight:topRight];
    
    return image;
}

#pragma mark - KYInterceptorIndicatorDelegate

- (void)KYInterceptorIndicator:(KYInterceptorIndicator *)KYInterceptorIndicator didMovedVertex:(CGPoint)vertex {
    if (self.snapshot.hidden) {
        self.snapshot.hidden = NO;
    }
    
    if (CGRectContainsPoint(CGRectMake(0, 0, SnapshotWidth + 40, SnapshotWidth + 40), vertex)) {
        self.snapshot.frame = CGRectMake(self.frame.size.width - SnapshotWidth, 0, SnapshotWidth, SnapshotWidth);
    } else {
        self.snapshot.frame = CGRectMake(0, 0, SnapshotWidth, SnapshotWidth);
    }
    
    CGFloat scaleFactor = 1.2;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(SnapshotWidth, SnapshotWidth), YES, 0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGAffineTransform transform = CGAffineTransformScale(CGAffineTransformIdentity, scaleFactor, scaleFactor);
    transform = CGAffineTransformTranslate(transform, -vertex.x + SnapshotWidth / 2 / scaleFactor, -vertex.y + SnapshotWidth / 2 / scaleFactor);
    
    CGContextConcatCTM(context, transform);
    [self.layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    self.snapshot.image = image;
}

- (void)KYInterceptorIndicatorStopedMovingVertex:(KYInterceptorIndicator *)KYInterceptorIndicator {
    self.snapshot.hidden = YES;
}

#pragma mark - private

- (CGPoint)scalePoint:(CGPoint)point withFactor:(CGFloat)factor {
    return CGPointMake(point.x * factor, point.y * factor);
}

#pragma mark -

- (UIImageView *)imageView {
    if (!_imageView) {
        UIImageView *imageView = [[UIImageView alloc] init];
        _imageView = imageView;
        _imageView.userInteractionEnabled = NO;
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        [self addSubview:_imageView];
    }
    return _imageView;
}

- (KYInterceptorIndicator *)KYInterceptorIndicator {
    if (!_KYInterceptorIndicator) {
        KYInterceptorIndicator *indicator = [[KYInterceptorIndicator alloc] initWithFrame:self.bounds];
        _KYInterceptorIndicator = indicator;
        _KYInterceptorIndicator.delegate = self;
        _KYInterceptorIndicator.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        [self insertSubview:_KYInterceptorIndicator aboveSubview:self.imageView];
    }
    return _KYInterceptorIndicator;
}

- (UIImageView *)snapshot {
    if (!_snapshot) {
        UIImageView *snapshot = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SnapshotWidth, SnapshotWidth)];
        _snapshot = snapshot;
        _snapshot.layer.cornerRadius = SnapshotWidth / 2;
        _snapshot.layer.masksToBounds = YES;
        _snapshot.layer.borderColor = [UIColor whiteColor].CGColor;
        _snapshot.layer.borderWidth = 1;
        _snapshot.hidden = YES;
        _snapshot.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:_snapshot];
    }
    return _snapshot;
}

@end
