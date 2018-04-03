//
//  VTMeasureVC.h
//  Multimeter
//
//  Created by vincent on 16/4/10.
//  Copyright © 2016年 vincent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VTBleManager.h"
#import "VTMeasurePresenterProtocol.h"

@class CBPeripheral;

@interface VTMeasureVC : UIViewController<VTBleManagerDelegate>

@property (strong, nonatomic) CBPeripheral *peripheral;
// 上次记录了连接,打开app直接进入测量
@property (assign, nonatomic) BOOL jumpFromLastConnect;
// 展现,不同表不同的展现方式
@property (strong, nonatomic) NSObject<VTMeasurePresenterProtocol> *presenter;

- (void)updateUIWithData:(NSData *)data;

@end
