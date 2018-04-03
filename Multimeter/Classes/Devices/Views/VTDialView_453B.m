//
//  VTDialView_453B.m
//  Multimeter
//
//  Created by Vincent on 28/11/2016.
//  Copyright © 2016 vincent. All rights reserved.
//

#import "VTDialView_453B.h"
#import "PureLayout.h"

@interface VTDialView_453B()

@property (strong, nonatomic) UIButton *funcButton;
@property (strong, nonatomic) UIButton *hbButton;
@property (strong, nonatomic) UIButton *hzButton;

@end


@implementation VTDialView_453B

- (void)setup {
    [self addSubview:self.hbButton];
    [self addSubview:self.funcButton];
    [self addSubview:self.hzButton];
    
    [self addSubview:self.backgroundView];
    [self addSubview:self.detailLabel];
    [self addSubview:self.pointerView];
    
    [self setupContraints];
    
    [self.backgroundView setImage:[UIImage imageNamed:@"dial_453b"]];
}

- (void)setupContraints {
    [self.hbButton autoSetDimensionsToSize:CGSizeMake(68, 34)];
    [self.hbButton autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [self.hbButton autoPinEdgeToSuperviewEdge:ALEdgeTop];
    
    [self.funcButton autoSetDimensionsToSize:CGSizeMake(68, 34)];
    [self.funcButton autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.hbButton];
    [self.funcButton autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:self.hbButton withOffset:-10];
    
    [self.hzButton autoSetDimensionsToSize:CGSizeMake(68, 34)];
    [self.hzButton autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.hbButton];
    [self.hzButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.hbButton withOffset:10];
    
    /// public
    [self.backgroundView autoSetDimensionsToSize:CGSizeMake(325, 175)];
    [self.backgroundView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.hbButton withOffset:34];
    [self.backgroundView autoAlignAxisToSuperviewAxis:ALAxisVertical];
    
    [self.detailLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.backgroundView withOffset:65];
    [self.detailLabel autoSetDimension:ALDimensionHeight toSize:19];
    [self.detailLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft];
    [self.detailLabel autoPinEdgeToSuperviewEdge:ALEdgeRight];
    
    [self.pointerView autoSetDimensionsToSize:CGSizeMake(161, 38)];
    [self.pointerView autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [self.pointerView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.detailLabel withOffset:60];
}

- (void)updateByParser:(VTBleDataParser *)parser {
    [super updateByParser:parser];
    
    self.funcButton.selected = parser.isFuncClick;
    self.hbButton.selected = parser.isHoldClick;
    self.hzButton.selected = parser.isHZClick;
}

#pragma mark - Properties

- (UIButton *)funcButton {
    if (!_funcButton) {
        _funcButton = [UIButton new];
        [_funcButton setBackgroundImage:[UIImage imageNamed:@"btn_func_nor"] forState:UIControlStateNormal];
        [_funcButton setBackgroundImage:[UIImage imageNamed:@"btn_func_sel"] forState:UIControlStateSelected];
    }
    return _funcButton;
}

- (UIButton *)hbButton {
    if (!_hbButton) {
        _hbButton = [UIButton new];
        [_hbButton setBackgroundImage:[UIImage imageNamed:@"btn_bright_hold_nor"] forState:UIControlStateNormal];
        [_hbButton setBackgroundImage:[UIImage imageNamed:@"btn_bright_hold_sel"] forState:UIControlStateSelected];
    }
    return _hbButton;
}

- (UIButton *)hzButton {
    if (!_hzButton) {
        _hzButton = [UIButton new];
        [_hzButton setBackgroundImage:[UIImage imageNamed:@"btn_hz_nor"] forState:UIControlStateNormal];
        [_hzButton setBackgroundImage:[UIImage imageNamed:@"btn_hz_sel"] forState:UIControlStateSelected];
    }
    return _hzButton;
}

@end
