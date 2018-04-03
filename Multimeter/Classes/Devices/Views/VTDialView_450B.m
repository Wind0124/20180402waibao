//
//  VTDialView_450B.m
//  Multimeter
//
//  Created by Vincent on 28/11/2016.
//  Copyright © 2016 vincent. All rights reserved.
//

#import "VTDialView_450B.h"
#import "PureLayout.h"

@interface VTDialView_450B()

@property (strong, nonatomic) UIButton *funcButton;
@property (strong, nonatomic) UIButton *holdButton;
@property (strong, nonatomic) UIButton *brightButton;

@end


@implementation VTDialView_450B

- (void)setup {
    [self addSubview:self.funcButton];
    [self addSubview:self.holdButton];
    [self addSubview:self.brightButton];
    
    [self addSubview:self.backgroundView];
    [self addSubview:self.detailLabel];
    [self addSubview:self.pointerView];
    
    [self setupContraints];
    
    [self.backgroundView setImage:[UIImage imageNamed:@"dial_450b"]];
}

- (void)setupContraints {
    [self.holdButton autoSetDimensionsToSize:CGSizeMake(68, 34)];
    [self.holdButton autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [self.holdButton autoPinEdgeToSuperviewEdge:ALEdgeTop];
    
    [self.funcButton autoSetDimensionsToSize:CGSizeMake(68, 34)];
    [self.funcButton autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.holdButton];
    [self.funcButton autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:self.holdButton withOffset:-10];
    
    [self.brightButton autoSetDimensionsToSize:CGSizeMake(68, 34)];
    [self.brightButton autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.holdButton];
    [self.brightButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.holdButton withOffset:10];

    /// public
    [self.backgroundView autoSetDimensionsToSize:CGSizeMake(325, 175)];
    [self.backgroundView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.holdButton withOffset:34];
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
    self.holdButton.selected = parser.isHoldClick;
    self.brightButton.selected = parser.isBrightClick;
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

- (UIButton *)holdButton {
    if (!_holdButton) {
        _holdButton = [UIButton new];
        [_holdButton setBackgroundImage:[UIImage imageNamed:@"btn_hold_nor"] forState:UIControlStateNormal];
        [_holdButton setBackgroundImage:[UIImage imageNamed:@"btn_hold_sel"] forState:UIControlStateSelected];
    }
    return _holdButton;
}

- (UIButton *)brightButton {
    if (!_brightButton) {
        _brightButton = [UIButton new];
        [_brightButton setBackgroundImage:[UIImage imageNamed:@"btn_bright_nor"] forState:UIControlStateNormal];
        [_brightButton setBackgroundImage:[UIImage imageNamed:@"btn_bright_sel"] forState:UIControlStateSelected];
    }
    return _brightButton;
}


@end
