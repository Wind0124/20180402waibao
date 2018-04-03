//
//  VTSwitchCell.m
//  Multimeter
//
//  Created by Vincent on 26/09/2016.
//  Copyright © 2016 vincent. All rights reserved.
//

#import "VTSwitchCell.h"

@interface VTSwitchCell()

@property (strong, nonatomic) UISwitch *switcher;

@end

@implementation VTSwitchCell

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
    self.accessoryView = self.switcher;
    
    self.backgroundColor = UIColorFromRGBValue(0x454545);
    self.textLabel.font = [UIFont systemFontOfSize:18];
    self.textLabel.textColor = [UIColor whiteColor];
}

//- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
//    [super setSelected:selected animated:animated];
//}

- (void)onSwitch:(UISwitch *)sender {
    _isSwitchOn = sender.isOn;
    if ([self.delegate respondsToSelector:@selector(didSwitch:on:)]) {
        [self.delegate didSwitch:self on:_isSwitchOn];
    }
}

#pragma mark - Properties

- (void)setTip:(NSString *)tip {
    _tip =  tip;
    self.textLabel.text = tip;
}

- (UISwitch *)switcher {
    if (!_switcher) {
        _switcher = [UISwitch new];
        _switcher.onTintColor = UIColorFromRGBValue(0xc31a20);
        [_switcher addTarget:self action:@selector(onSwitch:) forControlEvents:UIControlEventValueChanged];
    }
    return _switcher;
}

- (void)setIsSwitchOn:(BOOL)isSwitchOn {
    _isSwitchOn = isSwitchOn;
    [self.switcher setOn:isSwitchOn];
}


@end
