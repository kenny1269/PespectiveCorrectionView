//
//  KYInterceptorIndicator.h
//  WorldTrip
//
//  Created by mac on 2017/7/6.
//  Copyright © 2017年 kfvnx. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KYInterceptorIndicator;

@protocol KYInterceptorIndicatorDelegate <NSObject>

- (void)KYInterceptorIndicator:(KYInterceptorIndicator *)KYInterceptorIndicator didMovedVertex:(CGPoint)vertex;

- (void)KYInterceptorIndicatorStopedMovingVertex:(KYInterceptorIndicator *)KYInterceptorIndicator;

@end

@interface KYInterceptorIndicator : UIView

@property (nonatomic, weak) id <KYInterceptorIndicatorDelegate> delegate;

@property (nonatomic, copy) NSArray *vertexes; //vertexes ordered in topleft, bottomleft, bottomright, topright

- (void)setInterceptBounds:(CGRect)bounds;

@end
