//
//  KYInterceptorIndicator.m
//  WorldTrip
//
//  Created by mac on 2017/7/6.
//  Copyright © 2017年 kfvnx. All rights reserved.
//

#import "KYInterceptorIndicator.h"

#import <objc/runtime.h>

@interface KYInterceptorIndicator () <UIGestureRecognizerDelegate>

@property (nonatomic, weak) UIView *activeButton;

@property (nonatomic, strong) UIPanGestureRecognizer *pan;

@property (nonatomic, assign) CGRect interceptBounds;

@property (nonatomic, strong) NSMutableArray *realButtons;

@end

@implementation KYInterceptorIndicator

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.interceptBounds = self.bounds;
        self.backgroundColor = [UIColor clearColor];
        [self addGestureRecognizer:self.pan];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextBeginPath(context);
    
    CGPoint addLines[5] = {[self.realButtons[0] center], [self.realButtons[1] center], [self.realButtons[2] center], [self.realButtons[3] center], [self.realButtons[0] center]};
    
    CGContextAddLines(context, addLines, 5);
    CGContextClosePath(context);
    
    CGContextSetLineWidth(context, 2);
    CGColorRef color = [UIColor whiteColor].CGColor;
    
    CGContextSetStrokeColorWithColor(context, color);
    
    CGContextStrokePath(context);
}

- (void)setInterceptBounds:(CGRect)bounds {
    _interceptBounds = bounds;
    
    {
        UIButton *button = self.realButtons[0];
        button.center = bounds.origin;
    }
    
    {
        UIButton *button = self.realButtons[1];
        button.center = CGPointMake(bounds.origin.x, CGRectGetMaxY(bounds));
    }
    
    {
        UIButton *button = self.realButtons[2];
        button.center = CGPointMake(CGRectGetMaxX(bounds), CGRectGetMaxY(bounds));
    }
    
    {
        UIButton *button = self.realButtons[3];
        button.center = CGPointMake(CGRectGetMaxX(bounds), bounds.origin.y);
    }
}

#pragma mark - private

- (void)pan:(UIPanGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        self.activeButton = nil;
        
        if ([self.delegate respondsToSelector:@selector(KYInterceptorIndicatorStopedMovingVertex:)]) {
            [self.delegate KYInterceptorIndicatorStopedMovingVertex:self];
        }
    } else {
        if (self.activeButton) {
            CGPoint location = [sender locationInView:self];
            
            if (!CGRectContainsPoint(self.interceptBounds, location)) {
                if (location.x < CGRectGetMinX(self.interceptBounds)) {
                    location.x = CGRectGetMinX(self.interceptBounds);
                }
                
                if (location.x > CGRectGetMaxX(self.interceptBounds)) {
                    location.x = CGRectGetMaxX(self.interceptBounds);
                }
                
                if (location.y > CGRectGetMaxY(self.interceptBounds)) {
                    location.y = CGRectGetMaxY(self.interceptBounds);
                }
                
                if (location.y < CGRectGetMinY(self.interceptBounds)) {
                    location.y = CGRectGetMinY(self.interceptBounds);
                }
            };
            
            CGPoint lastCenter = self.activeButton.center;
            self.activeButton.center = location;
            
            BOOL validate = [self.class validateQuadrilateralWithOppositeVertex1:[self.realButtons[0] center] vertex2:[self.realButtons[2] center] theOtherOppositeVertex3:[self.realButtons[1] center] vertex4:[self.realButtons[3] center]];
            
            if (validate) {
                [self setNeedsDisplay];
                
                if ([self.delegate respondsToSelector:@selector(KYInterceptorIndicator:didMovedVertex:)]) {
                    [self.delegate KYInterceptorIndicator:self didMovedVertex:location];
                }
            } else {
                self.activeButton.center = lastCenter;
            }
        }
    }
}

- (CGPoint)scalePoint:(CGPoint)point withFactor:(CGFloat)factor {
    return CGPointMake(point.x * factor + self.interceptBounds.origin.x, point.y * factor + self.interceptBounds.origin.y);
}

+ (BOOL)validateQuadrilateralWithOppositeVertex1:(CGPoint)vertex1 vertex2:(CGPoint)vertex2 theOtherOppositeVertex3:(CGPoint)vertex3 vertex4:(CGPoint)vertex4 {
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

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint location = [gestureRecognizer locationInView:self];
    for (UIView *button in self.realButtons) {
        if (CGRectContainsPoint(CGRectInset(button.frame, -20, -20), location)) {
            self.activeButton = button;
            return YES;
        }
    }
    return NO;
}

#pragma mark -

- (UIPanGestureRecognizer *)pan {
    if (!_pan) {
        _pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        _pan.delegate = self;
        _pan.maximumNumberOfTouches = 1;
    }
    return _pan;
}

- (NSMutableArray *)realButtons  {
    if (!_realButtons) {
        _realButtons = [NSMutableArray array];
        for (NSInteger i = 0; i < 4; i++) {
            UIView *button = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
            button.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8];
            button.layer.cornerRadius = 10;
            button.layer.masksToBounds = YES;
            [_realButtons addObject:button];
            [self addSubview:button];
        }
    }
    return _realButtons;
}

- (CGPoint)topLeft {
    return CGPointMake([self.realButtons[0] center].x - self.interceptBounds.origin.x, [self.realButtons[0] center].y - self.interceptBounds.origin.y);
}

- (CGPoint)bottomLeft {
    return CGPointMake([self.realButtons[1] center].x - self.interceptBounds.origin.x, [self.realButtons[1] center].y - self.interceptBounds.origin.y);
}

- (CGPoint)bottomRight {
    return CGPointMake([self.realButtons[2] center].x - self.interceptBounds.origin.x, [self.realButtons[2] center].y - self.interceptBounds.origin.y);
}

- (CGPoint)topRight {
    return CGPointMake([self.realButtons[3] center].x - self.interceptBounds.origin.x, [self.realButtons[3] center].y - self.interceptBounds.origin.y);
}

- (void)setTopLeft:(CGPoint)topLeft {
    [self.realButtons[0] setCenter:CGPointMake(topLeft.x + self.interceptBounds.origin.x, topLeft.y + self.interceptBounds.origin.y)];
}

- (void)setBottomLeft:(CGPoint)bottomLeft {
    [self.realButtons[1] setCenter:CGPointMake(bottomLeft.x + self.interceptBounds.origin.x, bottomLeft.y + self.interceptBounds.origin.y)];
}

- (void)setBottomRight:(CGPoint)bottomRight {
    [self.realButtons[2] setCenter:CGPointMake(bottomRight.x + self.interceptBounds.origin.x, bottomRight.y + self.interceptBounds.origin.y)];
}

- (void)setTopRight:(CGPoint)topRight {
    [self.realButtons[3] setCenter:CGPointMake(topRight.x + self.interceptBounds.origin.x, topRight.y + self.interceptBounds.origin.y)];
}

@end
