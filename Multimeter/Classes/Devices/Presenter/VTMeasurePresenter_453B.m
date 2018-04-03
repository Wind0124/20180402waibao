//
//  VTMeasurePresenter_453B.m
//  Multimeter
//
//  Created by Vincent on 27/09/2016.
//  Copyright © 2016 vincent. All rights reserved.
//

#import "VTMeasurePresenter_453B.h"
#import "VTMeasureView_453B.h"
#import "PureLayout.h"
#import "VTSlotAlertView.h"
#import "VTSpeechMgr.h"

@interface VTMeasurePresenter_453B()<VTSlotAlertViewDelegate>

@property (weak, nonatomic) UIView *contentView;
@property (strong, nonatomic) VTMeasureView_453B *view;
@property (strong, nonatomic) VTSlotAlertView *alertView;
@property (assign, nonatomic) NSInteger lastPointPos;

@end

@implementation VTMeasurePresenter_453B

@synthesize targetVC = _targetVC;

- (void)setup {
    
}

- (instancetype)init {
    self = [super init];
    [self setup];
    
    return self;
}

- (void)addToView:(UIView *)view {
    _contentView = view;
    [_contentView addSubview:self.view];
    
    [self.view autoPinEdgesToSuperviewEdges];
    self.view.backgroundColor = [UIColor clearColor];
    
    if (_targetVC) {
        [self.view.pauseBtn addTarget:_targetVC action:@selector(onPauseBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view.analyzeBtn addTarget:_targetVC action:@selector(onAnalyzeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view.recordBtn addTarget:_targetVC action:@selector(onRecordBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    self.view.chartContainer.hidden = YES;
}

- (void)remove {
    [self.view removeFromSuperview];
}

- (NSInteger)model {
    return 0x453b;
}

- (VTOperationButton *)recordBtn {
    return self.view.recordBtn;
}

- (void)updateWhenDeviceDisconnected {
    _lastPointPos = 0;
    [self.view.dialView resetWhenOffline];
}

- (void)updateBleButton:(BOOL)yesOrNo {
    [self.view.lcdView updateBleButton:yesOrNo];
}

- (void)updateUIWithParser:(VTBleDataParser *)parser {
    // 电池低电量标志提示
    if ([parser isLowBattery]) {
        self.view.lowBatteryLabel.text = VTLOCALIZEDSTRING(@"电池电量低");
        self.view.lowBatteryLabel.hidden = NO;
    } else {
        self.view.lowBatteryLabel.hidden = YES;
    }
    
    // 更新lcd
    [self.view.lcdView updateByParser:parser];
    
    // 更新拔盘数据
    [self.view.dialView updateByParser:parser];
    
    [self popAlertIfNeed:parser.pointPos];
}

- (void)popAlertIfNeed:(NSInteger)pos {
    if (_lastPointPos == pos) return;
    
    //    [self.alertView showAnimation];
    NSInteger type = [self gitType:pos];
    if (type==0) {
        self.alertView.hidden = YES;
        _lastPointPos = pos;
        [[VTSpeechMgr sharedInstance] stopWarn];
        return;
    }
    NSInteger lastType = [self gitType:_lastPointPos];
    if (lastType != type) {
        NSString *imageName = nil;
        if (type==1)
           imageName = @"453_1.gif";
        else
           imageName = @"453_2.gif";
        // 正在显示表格,则不弹窗
        if (self.view.chartContainer.hidden) {
            [self showAlertView];
            [self.alertView setGIFImageName:imageName];
            [[VTSpeechMgr sharedInstance] playWarn];
        }
    }
    _lastPointPos = pos;
}

- (void)showAlertView {
    if (!self.alertView.superview) {
        [self.view addSubview:self.alertView];
        [self.alertView autoPinEdgesToSuperviewEdges];
    } else {
        [self.view bringSubviewToFront:self.alertView];
    }
    self.alertView.hidden = NO;
    [VTSpeechMgr sharedInstance].isMute = YES;
}

- (NSInteger)gitType:(NSInteger)pos {
    if (pos==0 || pos==2) {
        return 0;
    }
    if (pos==9) return 2;
    return 1;
}

- (void)didTapOnCloseBtn:(id)sender {
    self.alertView.hidden = YES;
    [VTSpeechMgr sharedInstance].isMute = NO;
}

#pragma mark - Properties

- (UIView *)view {
    if (!_view) {
//        _view =  [[[NSBundle mainBundle] loadNibNamed:@"VTMeasureView_453B" owner:self options:nil]lastObject];
        _view = [VTMeasureView_453B new];
    }
    return _view;
}

- (UIView *)chartContainer {
    return self.view.chartContainer;
}

- (VTSlotAlertView *)alertView {
    if (!_alertView) {
        _alertView = [[[NSBundle mainBundle]loadNibNamed:@"VTSlotAlertView" owner:self options:nil] lastObject];
        _alertView.hidden = YES;
        _alertView.delegate = self;
    }
    return _alertView;
}

// 切换表盘和分析
- (void)switchAnalyzeOrDial:(BOOL)yesOrNO {
    if (yesOrNO) {
        self.chartContainer.hidden = NO;
        self.view.dialView.hidden = YES;
        //        [self.chartContainer.superview bringSubviewToFront:self.chartContainer];
    } else {
        self.view.chartContainer.hidden = YES;
        self.view.dialView.hidden = NO;
        //        [self.dialView.superview bringSubviewToFront:self.dialView];
    }
    
}

- (void)resetContraintsForContainer {
    if ([self.view respondsToSelector:_cmd]) {
        [self.view resetContraintsForContainer];
    }
}


@end
