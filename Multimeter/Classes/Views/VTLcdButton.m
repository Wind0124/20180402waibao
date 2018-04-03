//
//  VTLcdButton.m
//  Multimeter
//
//  Created by vincent on 16/4/24.
//  Copyright © 2016年 vincent. All rights reserved.
//

#import "VTLcdButton.h"

@implementation VTLcdButton

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (selected) {
        self.backgroundColor = UIColorFromRGBValue(0x484848);
        self.hidden = NO;
    } else {
        self.backgroundColor = [UIColor clearColor];        
        self.hidden = YES;
    }
}


@end
