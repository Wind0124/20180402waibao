//
//  VTDialView_8238.m
//  Multimeter
//
//  Created by Vincent on 28/09/2016.
//  Copyright © 2016 vincent. All rights reserved.
//

#import "VTDialView_8238.h"
#import "PureLayout.h"


@interface VTDialView_8238()

@property (strong, nonatomic) UIButton *rangeBtn;
@property (strong, nonatomic) UIButton *holdBtn;
@property (strong, nonatomic) UIButton *bleBtn;
@property (strong, nonatomic) UIButton *funcBtn;

@end

@implementation VTDialView_8238

- (void)setup {
    [self addSubview:self.rangeBtn];
    [self addSubview:self.funcBtn];
    [self addSubview:self.holdBtn];
//    [self addSubview:self.bleBtn];
    
    [self addSubview:self.backgroundView];
    [self addSubview:self.detailLabel];
    [self addSubview:self.pointerView];
    
    [self setupContraints];
    
    [self.backgroundView setImage:[UIImage imageNamed:@"dial_8238"]];
}

- (void)setupContraints {
    [self.holdBtn autoSetDimensionsToSize:CGSizeMake(68, 34)];
    [self.holdBtn autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [self.holdBtn autoPinEdgeToSuperviewEdge:ALEdgeTop];
    
    [self.funcBtn autoSetDimensionsToSize:CGSizeMake(68, 34)];
    [self.funcBtn autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.holdBtn];
    [self.funcBtn autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:self.holdBtn withOffset:-22];
    
    [self.rangeBtn autoSetDimensionsToSize:CGSizeMake(68, 34)];
    [self.rangeBtn autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.holdBtn];
    [self.rangeBtn autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.holdBtn withOffset:22];
    
    /// public
    [self.backgroundView autoSetDimensionsToSize:CGSizeMake(325, 175)];
    [self.backgroundView autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self withOffset:64];
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
    
    self.funcBtn.selected = parser.isFuncClick;
    self.holdBtn.selected = parser.isHoldClick;
    self.bleBtn.selected = parser.isBlue;
    
    self.rangeBtn.selected = parser.isRangeClick;
}

#pragma mark - Properties
- (UIButton *)funcBtn {
    if (!_funcBtn) {
        _funcBtn = [UIButton new];
        [_funcBtn setBackgroundImage:[UIImage imageNamed:@"btn_8238_func"] forState:UIControlStateNormal];
        [_funcBtn setBackgroundImage:[UIImage imageNamed:@"btn_8238_func_hl"] forState:UIControlStateSelected];
    }
    return _funcBtn;
}

- (UIButton *)holdBtn {
    if (!_holdBtn) {
        _holdBtn = [UIButton new];
        [_holdBtn setBackgroundImage:[UIImage imageNamed:@"btn_8238_hold"] forState:UIControlStateNormal];
        [_holdBtn setBackgroundImage:[UIImage imageNamed:@"btn_8238_hold_hl"] forState:UIControlStateSelected];
    }
    return _holdBtn;
}

- (UIButton *)rangeBtn {
    if (!_rangeBtn) {
        _rangeBtn = [UIButton new];
        [_rangeBtn setBackgroundImage:[UIImage imageNamed:@"btn_8238_ran"] forState:UIControlStateNormal];
        [_rangeBtn setBackgroundImage:[UIImage imageNamed:@"btn_8238_ran_hl"] forState:UIControlStateSelected];
    }
    return _rangeBtn;
}

- (UIButton *)bleBtn {
    if (!_bleBtn) {
        _bleBtn = [UIButton new];
        [_bleBtn setBackgroundImage:[UIImage imageNamed:@"btn_8238_ble"] forState:UIControlStateNormal];
        [_bleBtn setBackgroundImage:[UIImage imageNamed:@"btn_8238_ble_hl"] forState:UIControlStateSelected];
    }
    return _bleBtn;
}

@end
