//
//  VTDialView_C052.m
//  Multimeter
//
//  Created by Vincent on 28/09/2016.
//  Copyright © 2016 vincent. All rights reserved.
//

#import "VTDialView_C052.h"
#import "PureLayout.h"

@interface VTDialView_C052()

@property (strong, nonatomic) UIButton *rangeBtn;
@property (strong, nonatomic) UIButton *relBtn;
@property (strong, nonatomic) UIButton *sunBtn;
@property (strong, nonatomic) UIButton *hzBtn;
@property (strong, nonatomic) UIButton *bleBtn;
@property (strong, nonatomic) UIButton *funcBtn;

@end


@implementation VTDialView_C052

- (void)setup {
    [self addSubview:self.rangeBtn];
    [self addSubview:self.relBtn];
    [self addSubview:self.sunBtn];
    [self addSubview:self.hzBtn];
    
    [self addSubview:self.funcBtn];
//    [self addSubview:self.bleBtn];
    
    [self addSubview:self.backgroundView];
    [self addSubview:self.detailLabel];
    [self addSubview:self.pointerView];
    
    [self setupContraints];
    
    [self.backgroundView setImage:[UIImage imageNamed:@"dial_c052"]];
}

- (void)setupContraints {
    /// 第一行
    [self.sunBtn autoSetDimensionsToSize:CGSizeMake(68, 34)];
    [self.sunBtn autoConstrainAttribute:ALAttributeLeft toAttribute:ALAttributeVertical ofView:self withOffset:11];
    [self.sunBtn autoPinEdgeToSuperviewEdge:ALEdgeTop];
    
    [self.relBtn autoSetDimensionsToSize:CGSizeMake(68, 34)];
    [self.relBtn autoConstrainAttribute:ALAttributeRight toAttribute:ALAttributeVertical ofView:self withOffset:-11];
    [self.relBtn autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.sunBtn];
    
    [self.rangeBtn autoSetDimensionsToSize:CGSizeMake(68, 34)];
    [self.rangeBtn autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:self.relBtn withOffset:-22];
    [self.rangeBtn autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.sunBtn];
    
    [self.hzBtn autoSetDimensionsToSize:CGSizeMake(68, 34)];
    [self.hzBtn autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.sunBtn withOffset:22];
    [self.hzBtn autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.sunBtn];

    /// ble,func
    [self.funcBtn autoSetDimensionsToSize:CGSizeMake(34, 34)];
    [self.funcBtn autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.rangeBtn withOffset:10];
    [self.funcBtn autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.sunBtn withOffset:15];
    
//    [self.bleBtn autoSetDimensionsToSize:CGSizeMake(34, 34)];
//    [self.bleBtn autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.hzBtn withOffset:-10];
//    [self.bleBtn autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.funcBtn];
    
    
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
    self.sunBtn.selected = parser.isHoldClick;
    self.hzBtn.selected = parser.isHZClick;
    self.bleBtn.selected = parser.isBlue;
    
    self.rangeBtn.selected = parser.isRangeClick;
    self.relBtn.selected = parser.isRELClick;
}

#pragma mark - Properties
- (UIButton *)funcBtn {
    if (!_funcBtn) {
        _funcBtn = [UIButton new];
        [_funcBtn setBackgroundImage:[UIImage imageNamed:@"btn_c052_func"] forState:UIControlStateNormal];
        [_funcBtn setBackgroundImage:[UIImage imageNamed:@"btn_c052_func_hl"] forState:UIControlStateSelected];
    }
    return _funcBtn;
}

- (UIButton *)bleBtn {
    if (!_bleBtn) {
        _bleBtn = [UIButton new];
        [_bleBtn setBackgroundImage:[UIImage imageNamed:@"btn_c052_ble"] forState:UIControlStateNormal];
        [_bleBtn setBackgroundImage:[UIImage imageNamed:@"btn_c052_ble_hl"] forState:UIControlStateSelected];
    }
    return _bleBtn;
}

- (UIButton *)rangeBtn {
    if (!_rangeBtn) {
        _rangeBtn = [UIButton new];
        [_rangeBtn setBackgroundImage:[UIImage imageNamed:@"btn_c052_range"] forState:UIControlStateNormal];
        [_rangeBtn setBackgroundImage:[UIImage imageNamed:@"btn_c052_range_hl"] forState:UIControlStateSelected];
    }
    return _rangeBtn;
}

- (UIButton *)relBtn {
    if (!_relBtn) {
        _relBtn = [UIButton new];
        [_relBtn setBackgroundImage:[UIImage imageNamed:@"btn_c052_rel"] forState:UIControlStateNormal];
        [_relBtn setBackgroundImage:[UIImage imageNamed:@"btn_c052_rel_hl"] forState:UIControlStateSelected];
    }
    return _relBtn;
}

- (UIButton *)sunBtn {
    if (!_sunBtn) {
        _sunBtn = [UIButton new];
        [_sunBtn setBackgroundImage:[UIImage imageNamed:@"btn_c052_sun"] forState:UIControlStateNormal];
        [_sunBtn setBackgroundImage:[UIImage imageNamed:@"btn_c052_sun_hl"] forState:UIControlStateSelected];
    }
    return _sunBtn;
}

- (UIButton *)hzBtn {
    if (!_hzBtn) {
        _hzBtn = [UIButton new];
        [_hzBtn setBackgroundImage:[UIImage imageNamed:@"btn_c052_hz"] forState:UIControlStateNormal];
        [_hzBtn setBackgroundImage:[UIImage imageNamed:@"btn_c052_hz_hl"] forState:UIControlStateSelected];
    }
    return _hzBtn;
}


@end
