//
//  VTMeasurePresenterProtocol.h
//  Multimeter
//
//  Created by Vincent on 27/09/2016.
//  Copyright © 2016 vincent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VTBleDataParser.h"
#import "EverChart.h"
#import "VTOperationButton.h"

@protocol VTMeasurePresenterProtocol <NSObject>

@property (assign, nonatomic) NSInteger model;
@property (assign, nonatomic) UIViewController *targetVC;
@property (strong, nonatomic, readonly) VTOperationButton *recordBtn;

- (void)updateUIWithParser:(VTBleDataParser *)parser;
- (void)remove;
- (void)addToView:(UIView *)view;

// 设备下线时,要回到off状态
- (void)updateWhenDeviceDisconnected;
- (void)updateBleButton:(BOOL)yesOrNo;

// 曲线
- (UIView *)chartContainer;
// 图表
- (UIView *)tableContainer;
// 切换表盘和分析
- (void)switchAnalyzeOrDial:(BOOL)yesOrNO;

- (void)resetContraintsForContainer;

@end
