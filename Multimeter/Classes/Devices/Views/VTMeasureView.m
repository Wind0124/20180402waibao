//
//  VTMeasureView.m
//  Multimeter
//
//  Created by Vincent on 28/11/2016.
//  Copyright © 2016 vincent. All rights reserved.
//

#import "VTMeasureView.h"
#import "PureLayout.h"

@interface VTMeasureView()

@property (strong, nonatomic) UIView *opertaionView;

@end


@implementation VTMeasureView

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
    [self addSubview:self.lcdView];
    [self addSubview:self.dialView];
    [self addSubview:self.opertaionView];
    
    [self.opertaionView addSubview:self.recordBtn];
    [self.opertaionView addSubview:self.pauseBtn];
    [self.opertaionView addSubview:self.analyzeBtn];
    
    [self addSubview:self.lowBatteryLabel];
    [self addSubview:self.chartContainer];

    [self setupContraints];
    
    [self.recordBtn setTitle:VTLOCALIZEDSTRING(@"保存") forState:UIControlStateNormal];
    [self.pauseBtn setTitle:VTLOCALIZEDSTRING(@"暂停") forState:UIControlStateNormal];
    [self.analyzeBtn setTitle:VTLOCALIZEDSTRING(@"分析") forState:UIControlStateNormal];
}

- (void)setupContraints {
    [self.lcdView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(15, 15, 0, 15) excludingEdge:ALEdgeBottom];
    [self.lcdView autoSetDimension:ALDimensionHeight toSize:155];
    
    [self.dialView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.lcdView withOffset:20];
    [self.dialView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
    [self.dialView autoPinEdgeToSuperviewEdge:ALEdgeRight];

    [self.opertaionView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.dialView];
    [self.opertaionView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0) excludingEdge:ALEdgeTop];
    [self.opertaionView autoSetDimension:ALDimensionHeight toSize:100];
    
    [self.recordBtn autoSetDimensionsToSize:CGSizeMake(80, 100)];
    [self.recordBtn autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [self.recordBtn autoAlignAxisToSuperviewAxis:ALAxisHorizontal];

    [self.pauseBtn autoSetDimensionsToSize:CGSizeMake(80, 100)];
    [self.pauseBtn autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [self.pauseBtn autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:self.recordBtn withOffset:-20];
    
    [self.analyzeBtn autoSetDimensionsToSize:CGSizeMake(80, 100)];
    [self.analyzeBtn autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [self.analyzeBtn autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.recordBtn withOffset:20];
    
    [self.lowBatteryLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft];
    [self.lowBatteryLabel autoPinEdgeToSuperviewEdge:ALEdgeRight];
    [self.lowBatteryLabel autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:self.opertaionView withOffset:-20];
}

#pragma mark - Properties
- (VTLcdView *)lcdView {
    if (!_lcdView) {
        _lcdView = [[[NSBundle mainBundle]loadNibNamed:@"VTLcdView" owner:self options:nil] lastObject];
    }
    return _lcdView;
}

- (VTDialView *)dialView {
    if (!_dialView) {
        _dialView = [VTDialView new];
    }
    return _dialView;
}

- (UIView *)opertaionView {
    if (!_opertaionView) {
        _opertaionView = [UIView new];
        _opertaionView.backgroundColor = [UIColor clearColor];
    }
    return _opertaionView;
}

- (VTOperationButton *)recordBtn {
    if (!_recordBtn) {
        _recordBtn = [VTOperationButton new];
        [_recordBtn setImage:[UIImage imageNamed:@"btn_record_nor"] forState:UIControlStateNormal];
        [_recordBtn setImage:[UIImage imageNamed:@"btn_record_sel"] forState:UIControlStateHighlighted];
        [_recordBtn setImage:[UIImage imageNamed:@"btn_record_sel"] forState:UIControlStateSelected];
    }
    return _recordBtn;
}

- (VTOperationButton *)pauseBtn {
    if (!_pauseBtn) {
        _pauseBtn = [VTOperationButton new];
        [_pauseBtn setImage:[UIImage imageNamed:@"btn_pause_nor"] forState:UIControlStateNormal];
        [_pauseBtn setImage:[UIImage imageNamed:@"btn_pause_sel"] forState:UIControlStateHighlighted];
        [_pauseBtn setImage:[UIImage imageNamed:@"btn_pause_sel"] forState:UIControlStateSelected];
    }
    return _pauseBtn;
}

- (VTOperationButton *)analyzeBtn {
    if (!_analyzeBtn) {
        _analyzeBtn = [VTOperationButton new];
        [_analyzeBtn setImage:[UIImage imageNamed:@"btn_analyze_nor"] forState:UIControlStateNormal];
        [_analyzeBtn setImage:[UIImage imageNamed:@"btn_analyze_sel"] forState:UIControlStateHighlighted];
        [_analyzeBtn setImage:[UIImage imageNamed:@"btn_analyze_sel"] forState:UIControlStateSelected];
    }
    return _analyzeBtn;
}

- (UILabel *)lowBatteryLabel {
    if (!_lowBatteryLabel) {
        _lowBatteryLabel = [UILabel new];
        _lowBatteryLabel.font = [UIFont systemFontOfSize:17];
        _lowBatteryLabel.textColor = [UIColor redColor];
        _lowBatteryLabel.numberOfLines = 1;
        _lowBatteryLabel.text = @"电量低！";
        _lowBatteryLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _lowBatteryLabel;
}

- (void)resetContraintsForContainer {
    if (self.chartContainer.superview != self) {
        [self addSubview:self.chartContainer];
    }
    self.chartContainer.frame = CGRectMake(0, 190, 375, 313);
//    [self.chartContainer autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
//    [self.chartContainer autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
//    [self.chartContainer autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:190];
//    [self.chartContainer autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:100];
}

- (UIView *)chartContainer {
    if (!_chartContainer) {
        _chartContainer = [UIView new];
        _chartContainer.frame = CGRectMake(0, 190, 375, 313);
    }
    return _chartContainer;
}

@end
