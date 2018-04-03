//
//  VTNormalButton.m
//  Multimeter
//
//  Created by vincent on 16/4/24.
//  Copyright © 2016年 vincent. All rights reserved.
//

#import "VTNormalButton.h"

@implementation VTNormalButton

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
    self.titleLabel.font = [UIFont systemFontOfSize:20];
//    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.layer.cornerRadius = 5;
    self.layer.borderWidth = 1;
    self.layer.borderColor = [UIColor whiteColor].CGColor;
    self.backgroundColor = [UIColor clearColor];//UIColorFromRGBValue(0xc62b2e);
}

- (void)setHighlighted:(BOOL)highlighted {
    
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (!selected) {
        self.layer.borderColor = [UIColor whiteColor].CGColor;
    } else {
        self.layer.borderColor = [UIColor clearColor].CGColor;
    }
}

@end
