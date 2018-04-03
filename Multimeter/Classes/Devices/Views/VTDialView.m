//
//  VTDialView.m
//  Multimeter
//
//  Created by vincent on 16/4/24.
//  Copyright © 2016年 vincent. All rights reserved.
//

#import "VTDialView.h"

@interface VTDialView()

// 机器型号
@property (assign, nonatomic) NSInteger modelType;
@property (assign, nonatomic) CGFloat angle;

@end


@implementation VTDialView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame: frame];
    if (!self) return self;
    
    [self setup];
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder: aDecoder];
    if (!self) return self;
    
    [self setup];
    
    return self;
}

- (void)setup {
    
}

- (void)setupContraints {
    
}

- (void)updateByParser:(VTBleDataParser *)parser {
    self.detailLabel.text = parser.funcString;
    self.angle = parser.angle;
}

- (void)setAngle:(CGFloat)angle {
    if (_angle == angle) return;
    
    // XXX: angle＝0,一般是出错了
    if (angle == 0) {
        _angle = 0;
        return;
    }
    
    [UIView animateWithDuration:0.25 delay:0 usingSpringWithDamping:0.3 initialSpringVelocity:0 options:0 animations:^{
        self.pointerView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, angle);
    } completion:^(BOOL finished) {
        _angle = angle;
    }];
}

- (void)resetWhenOffline {
//    _angle = 0;
    [UIView animateWithDuration:0.25 delay:0 usingSpringWithDamping:0.3 initialSpringVelocity:0 options:0 animations:^{
        self.pointerView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        _angle = 0;
    }];
}

- (UIImageView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [UIImageView new];
    }
    return _backgroundView;
}

- (UILabel *)detailLabel {
    if (!_detailLabel) {
        _detailLabel = [UILabel new];
        _detailLabel.textAlignment = NSTextAlignmentCenter;
        _detailLabel.textColor = [UIColor colorWithWhite:1. alpha:0.4];
        _detailLabel.numberOfLines = 1;
        _detailLabel.font = [UIFont systemFontOfSize:15];
        
    }
    return _detailLabel;
}

- (UIImageView *)pointerView {
    if (!_pointerView) {
        _pointerView = [UIImageView new];
        _pointerView.image = [UIImage imageNamed:@"pointer"];
    }
    return _pointerView;
}

@end
