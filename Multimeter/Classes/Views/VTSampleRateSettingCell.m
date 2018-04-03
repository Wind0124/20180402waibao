//
//  VTSampleRateSettingCell.m
//  Multimeter
//
//  Created by Vincent on 25/09/2016.
//  Copyright © 2016 vincent. All rights reserved.
//

#import "VTSampleRateSettingCell.h"
#import <PureLayout.h>

#define MAX_SAMPLE_RATE  (120)
#define MIN_SAMPLE_RATE  (1)

@interface VTSampleRateSettingCell()

@property (strong, nonatomic) UISlider *slider;
@property (strong, nonatomic) NSString *headerText;

@end

@implementation VTSampleRateSettingCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setup];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) return nil;
    
    [self setup];
    
    return self;
}

- (void)setup {
    self.backgroundColor = UIColorFromRGBValue(0x454545);
    self.userInteractionEnabled = YES;
    
    [self addSubview:self.slider];
    [self.slider autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:60];
    [self.slider autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:60];
    [self.slider autoSetDimension:ALDimensionHeight toSize:80];
    [self.slider autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
}

// 不即时生效,界面消失后生效
- (void)onSliderChanged:(UISlider *)sender {
    NSInteger value = (NSInteger)sender.value;
    _rate = value;
    if ([self.delegate respondsToSelector:@selector(didRateChanged:)]) {
        [self.delegate didRateChanged:value];
    }
}

- (void)setRate:(NSInteger)rate {
    _rate = rate;
    [self.slider setValue:rate];
}

- (UISlider *)slider {
    if (!_slider) {
        _slider = [UISlider new];
        [_slider setMaximumValue:MAX_SAMPLE_RATE];
        [_slider setMinimumValue:MIN_SAMPLE_RATE];
        [_slider addTarget:self action:@selector(onSliderChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _slider;
}



@end
