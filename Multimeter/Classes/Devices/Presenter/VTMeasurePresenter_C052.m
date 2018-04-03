//
//  VTMeasurePresenter_C052.m
//  Multimeter
//
//  Created by Vincent on 28/09/2016.
//  Copyright © 2016 vincent. All rights reserved.
//

#import "VTMeasurePresenter_C052.h"
#import "VTMeasureView_C052.h"
#import "PureLayout.h"
#import "VTSlotAlertView.h"
#import "VTSpeechMgr.h"


@interface VTMeasurePresenter_C052()

@property (weak, nonatomic) UIView *contentView;
@property (strong, nonatomic) VTMeasureView_C052 *view;
@property (strong, nonatomic) VTSlotAlertView *alertView;
@property (assign, nonatomic) NSInteger lastPointPos;


@end

@implementation VTMeasurePresenter_C052

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
    return 0xc052;
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
            imageName = @"c052_1.gif";
        else if (type==2)
            imageName = @"c052_2.gif";
        else
            imageName = @"c052_3.gif";
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
    if (pos==0 || pos==3) {
        return 0;
    }
    if (pos==9) return 3;
    if (pos>=6 && pos<=8) return 2;
    
    return 1;
}

- (void)didTapOnCloseBtn:(id)sender {
    self.alertView.hidden = YES;
    [VTSpeechMgr sharedInstance].isMute = NO;
}

#pragma mark - Properties

- (UIView *)view {
    if (!_view) {
//        _view =  [[[NSBundle mainBundle] loadNibNamed:@"VTMeasureView_C052" owner:self options:nil]lastObject];
        _view = [VTMeasureView_C052 new];
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
    } else {
        self.view.chartContainer.hidden = YES;
        self.view.dialView.hidden = NO;
    }
}

- (void)resetContraintsForContainer {
    if ([self.view respondsToSelector:_cmd]) {
        [self.view resetContraintsForContainer];
    }
}

@end