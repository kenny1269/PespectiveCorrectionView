//
//  KYInterceptorIndicator.m
//  WorldTrip
//
//  Created by mac on 2017/7/6.
//  Copyright © 2017年 kfvnx. All rights reserved.
//

#import "KYInterceptorIndicator.h"

#import "KYVertextAnalyzer.h"

#import <objc/runtime.h>

static char PointPositionKey;

@interface UIView (PointPosition)

@property (nonatomic, assign) PointPositionType position;

@end

@implementation UIView (PointPosition)

- (PointPositionType)position {
    return [objc_getAssociatedObject(self, &PointPositionKey) integerValue];
}

- (void)setPosition:(PointPositionType)position {
    objc_setAssociatedObject(self, &PointPositionKey, @(position), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@interface KYInterceptorIndicator () <UIGestureRecognizerDelegate>

@property (nonatomic, weak) UIView *activeButton;

@property (nonatomic, strong) UIPanGestureRecognizer *pan;

@property (nonatomic, assign) CGRect interceptBounds;

@property (nonatomic, strong) NSMutableArray *buttons;

@end

@implementation KYInterceptorIndicator

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self addGestureRecognizer:self.pan];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextBeginPath(context);
    
    CGPoint addLines[5] = {_topLeft, _bottomLeft, _bottomRight, _topRight, _topLeft};
    
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
        UIButton *button = self.buttons[0];
        button.center = bounds.origin;
        button.position = PointPositionTypeTopLeft;
        self.topLeft = button.center;
    }
    
    {
        UIButton *button = self.buttons[1];
        button.center = CGPointMake(bounds.origin.x, CGRectGetMaxY(bounds));
        button.position = PointPositionTypeBottomLeft;
        self.bottomLeft = button.center;
    }
    
    {
        UIButton *button = self.buttons[2];
        button.center = CGPointMake(CGRectGetMaxX(bounds), bounds.origin.y);
        button.position = PointPositionTypeTopRight;
        self.topRight = button.center;
    }
    
    {
        UIButton *button = self.buttons[3];
        button.center = CGPointMake(CGRectGetMaxX(bounds), CGRectGetMaxY(bounds));
        button.position = PointPositionTypeBottomRight;
        self.bottomRight = button.center;
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
        
        if (self.activeButton) {
            if (self.activeButton.position == PointPositionTypeTopLeft) {
                self.topLeft = location;
            } else if (self.activeButton.position == PointPositionTypeTopRight) {
                self.topRight = location;
            } else if (self.activeButton.position == PointPositionTypeBottomLeft) {
                self.bottomLeft = location;
            } else if (self.activeButton.position == PointPositionTypeBottomRight) {
                self.bottomRight = location;
            }
            
            BOOL validate = [KYVertextAnalyzer validateVertexesOfQuadrilateralWithOppositeVertex1:self.topLeft vertex2:self.bottomRight theOtherOppositeVertex3:self.topRight vertex4:self.bottomLeft];
            
            if (validate) {
                self.activeButton.center = location;
                [self setNeedsDisplay];
                
                if ([self.delegate respondsToSelector:@selector(KYInterceptorIndicator:didMovedVertex:)]) {
                    [self.delegate KYInterceptorIndicator:self didMovedVertex:location];
                }
            } else {
                if (self.activeButton.position == PointPositionTypeTopLeft) {
                    self.topLeft = self.activeButton.center;
                } else if (self.activeButton.position == PointPositionTypeTopRight) {
                    self.topRight = self.activeButton.center;
                } else if (self.activeButton.position == PointPositionTypeBottomLeft) {
                    self.bottomLeft = self.activeButton.center;
                } else if (self.activeButton.position == PointPositionTypeBottomRight) {
                    self.bottomRight = self.activeButton.center;
                }
            }
        }
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint location = [gestureRecognizer locationInView:self];
    for (UIView *button in self.buttons) {
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

- (NSMutableArray *)buttons  {
    if (!_buttons) {
        _buttons = [NSMutableArray array];
        for (NSInteger i = 0; i < 4; i++) {
            UIView *button = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
            button.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8];
            button.layer.cornerRadius = 10;
            button.layer.masksToBounds = YES;
            [_buttons addObject:button];
            [self addSubview:button];
        }
    }
    return _buttons;
}

@end
