//
//  VTDialView.h
//  Multimeter
//
//  Created by vincent on 16/4/24.
//  Copyright © 2016年 vincent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VTBleDataParser.h"

@interface VTDialView : UIView

@property (strong, nonatomic) UIImageView *backgroundView;
@property (strong, nonatomic) UIImageView *pointerView;
@property (strong, nonatomic) UILabel *detailLabel;

- (void)updateByParser:(VTBleDataParser *)parser;
// 下线时更清表盘
- (void)resetWhenOffline;

@end
