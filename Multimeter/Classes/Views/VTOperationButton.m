//
//  VTOperationButton.m
//  Multimeter
//
//  Created by vincent on 16/4/23.
//  Copyright © 2016年 vincent. All rights reserved.
//

#import "VTOperationButton.h"
#import "LKBadgeView.h"
#import "UIView+Helper.h"

#ifdef AUTO_PX
#undef AUTO_PX
#endif

#define AUTO_PX(x) (_scale?((x)*k2PROPOR):(x))

@interface VTOperationButton()

@property (strong, nonatomic) LKBadgeView *badgeView;

@end


@implementation VTOperationButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) return nil;
    
    [self setup];
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (!self) return nil;
    
    [self setup];
    return self;
}
        
- (void)setup {
    self.titleLabel.font = [UIFont systemFontOfSize:AUTO_PX(15)];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    // selected
    [self setImage:[self imageForState:UIControlStateHighlighted] forState:UIControlStateSelected];
    [self addSubview:self.badgeView];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected: selected];
    
    [self setNeedsLayout];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    [self setNeedsLayout];
}

- (void)setBadgeText:(NSString *)text {
    if (!text.length) {
        _badgeView.hidden = YES;
    } else {
        _badgeView.hidden = NO;
        [_badgeView setText:text];
    }
}

//
- (void)layoutSubviews {
    
    [super layoutSubviews];
//    CGFloat scale = [UIScreen mainScreen].scale;
    
    // 图片居中
    CGRect frame;
    CGRect bounds = self.bounds;
    
    // 调整label位置
    UILabel *label = self.titleLabel;
    frame.size.width = CGRectGetWidth(bounds);
    frame.size.height = AUTO_PX(18);
    frame.origin.x = 0;
    frame.origin.y = CGRectGetMaxY(bounds) - AUTO_PX(10) - CGRectGetHeight(frame);
    label.frame = frame;
    
    // 调整imageView位置
    UIImageView *imgView = self.imageView;
    CGFloat centerY = CGRectGetMinY(label.frame)-AUTO_PX(35);
    if (_scale) {
        CGFloat min = MIN(imgView.width, imgView.height);
        imgView.size = CGSizeMake(min, min);
    }
    imgView.center = CGPointMake(CGRectGetMidX(bounds), centerY);

//    imgView.frame = frame;
#if 1
#endif
}

#pragma mark - Properties
- (LKBadgeView *)badgeView {
    if (!_badgeView) {
        _badgeView = [[LKBadgeView alloc] initWithFrame:CGRectMake(AUTO_PX(55), 0, AUTO_PX(140), AUTO_PX(20))];
        _badgeView.badgeColor = [UIColor redColor];
        _badgeView.horizontalAlignment = LKBadgeViewHorizontalAlignmentLeft;
    }
    return _badgeView;
}

@end
