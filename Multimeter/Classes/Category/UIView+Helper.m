//
//  UIView+Helper.m
//
//  Created by vincent on 13/11/12.
//  Copyright (c) 2013 xxx. All rights reserved.
//

#import "UIView+Helper.h"
#import <QuartzCore/QuartzCore.h>

// 竖屏时的固定屏幕宽高
static CGFloat gScreenWidth = 0;
static CGFloat gScreenHeight = 0;

@implementation UIView (Helper)

- (BOOL)containsSubView:(UIView *)subView
{
    for (UIView *view in [self subviews]) {
        if ([view isEqual:subView]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)containsSubViewOfClassType:(Class)class {
    for (UIView *view in [self subviews]) {
        if ([view isMemberOfClass:class]) {
            return YES;
        }
    }
    return NO;
}

- (void)removeAllSubViews {
    for (UIView *view in [self subviews]) {
        [view removeFromSuperview];
    }
}

- (CGPoint)origin {
	return self.frame.origin;
}

- (void)setOrigin:(CGPoint)newOrigin {
	self.frame = CGRectMake(newOrigin.x, newOrigin.y, self.frame.size.width, self.frame.size.height);
}

- (CGSize)size {
	return self.frame.size;
}

- (void)setSize:(CGSize)newSize {
	self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y,
							newSize.width, newSize.height);
}

- (CGFloat)left {
	return self.frame.origin.x;
}

- (void)setLeft:(CGFloat)newLeft {
	self.frame = CGRectMake(newLeft, self.frame.origin.y,
							self.frame.size.width, self.frame.size.height);
}

- (CGFloat)top {
	return self.frame.origin.y;
}

- (void)setTop:(CGFloat)newTop {
	self.frame = CGRectMake(self.frame.origin.x, newTop,
							self.frame.size.width, self.frame.size.height);
}

- (CGFloat)right {
	return self.frame.origin.x + self.frame.size.width;
}

- (void)setRight:(CGFloat)newRight {
	self.frame = CGRectMake(newRight - self.frame.size.width, self.frame.origin.y,
							self.frame.size.width, self.frame.size.height);
}

- (CGFloat)bottom {
	return self.frame.origin.y + self.frame.size.height;
}

- (void)setBottom:(CGFloat)newBottom {
	self.frame = CGRectMake(self.frame.origin.x, newBottom - self.frame.size.height,
							self.frame.size.width, self.frame.size.height);
}

- (CGFloat)leftEx {
    return self.left;
}

- (void)setLeftEx:(CGFloat)newLeft {
    self.frame = CGRectMake(newLeft, self.frame.origin.y,
                            self.frame.size.width+self.frame.origin.x-newLeft, self.frame.size.height);
}

- (CGFloat)rightEx {
    return self.right;
}

- (void)setRightEx:(CGFloat)newRight {
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y,
                            newRight-self.frame.origin.x, self.frame.size.height);
}

- (CGFloat)topEx {
    return self.top;
}

- (void)setTopEx:(CGFloat)newTop {
    self.frame = CGRectMake(self.frame.origin.x, newTop,
                            self.frame.size.width, self.frame.size.height+self.frame.origin.y-newTop);
}

- (CGFloat)bottomEx {
    return self.bottom;
}

- (void)setBottomEx:(CGFloat)newBottom {
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y,
                            self.frame.size.width, newBottom-self.frame.origin.y);
}

- (CGFloat)width {
	return self.frame.size.width;
}

- (void)setWidth:(CGFloat)newWidth {
	self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y,
							newWidth, self.frame.size.height);
}

- (CGFloat)height {
	return self.frame.size.height;
}

- (void)setHeight:(CGFloat)newHeight {
	self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y,
							self.frame.size.width, newHeight);
}

- (CGFloat)centerX {
    return self.center.x;
}

- (void)setCenterX:(CGFloat)centerX {
    self.center = CGPointMake(centerX, self.center.y);
}


- (CGFloat)centerY {
    return self.center.y;
}

- (void)setCenterY:(CGFloat)centerY {
    self.center = CGPointMake(self.center.x, centerY);
}

// TODO:
+ (void)moveView:(UIView *)srcView toView:(UIView *)dstView withSameContraint:(BOOL)yesOrNO {
    for (NSLayoutConstraint *constraint in srcView.superview.constraints) {
        if (constraint.firstItem == srcView) {
            [srcView.superview addConstraint:[NSLayoutConstraint constraintWithItem:dstView attribute:constraint.firstAttribute relatedBy:constraint.relation toItem:constraint.secondItem attribute:constraint.secondAttribute multiplier:constraint.multiplier constant:constraint.constant]];
        }
        else if (constraint.secondItem == srcView) {
            [dstView.superview addConstraint:[NSLayoutConstraint constraintWithItem:constraint.firstItem attribute:constraint.firstAttribute relatedBy:constraint.relation toItem:dstView attribute:constraint.secondAttribute multiplier:constraint.multiplier constant:constraint.constant]];
        }
    }
}

+ (UIViewAutoresizing)fillAutoresizingMask {
    return UIViewAutoresizingFlexibleLeftMargin
                | UIViewAutoresizingFlexibleWidth
                | UIViewAutoresizingFlexibleRightMargin
                | UIViewAutoresizingFlexibleTopMargin
                | UIViewAutoresizingFlexibleHeight
                | UIViewAutoresizingFlexibleBottomMargin;
}

// 实际的屏幕宽高,适配横屏
+ (CGSize)screenSizeEx {
    CGSize size = [self screenSize];
    if ([self isLanscape]) {
        return CGSizeMake(size.height, size.width);
    } else {
        return CGSizeMake(size.width, size.height);
    }
//    return [UIApplication sharedApplication].keyWindow.bounds.size;
}

// 固定的屏幕宽高
+ (CGSize)screenSize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        CGFloat height = [UIScreen mainScreen].bounds.size.height;
        
        CGFloat min = MIN(width, height);
        CGFloat max = MAX(width, height);
        
        gScreenWidth = min;
        gScreenHeight = max;
    });
   
    return CGSizeMake(gScreenWidth, gScreenHeight);
}

+ (BOOL)isLanscape {
    UIInterfaceOrientation barOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsLandscape(barOrientation)) {
        return YES;
    }
    return NO;
}

// 清除子控件相关的约束
- (void)clearSubviewContraints {
    NSMutableArray *toDels = [NSMutableArray new];
    // 清除当前view中跟子控件相关的约束
    for (NSLayoutConstraint *contraint in self.constraints) {
        if (!contraint.firstItem || !contraint.secondItem ) continue;
        [toDels addObject:contraint];
    }
    [self removeConstraints:toDels];
    // 清除子控件中,跟子控件的子控件约束无关的约束(如子控件的宽度等约束)
    for (UIView *view in self.subviews) {
        toDels = [NSMutableArray new];
        for (NSLayoutConstraint *contraint in view.constraints) {
            if (!contraint.firstItem || !contraint.secondItem ) {
                [toDels addObject:contraint];
            }
        }
        [view removeConstraints:toDels];
    }
}

@end
