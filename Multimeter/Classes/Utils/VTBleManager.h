//
//  VTBleManager.h
//  Multimeter
//
//  Created by vincent on 16/4/12.
//  Copyright © 2016年 vincent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "CBPeripheral+Extra.h"

@class VTBleManager;

@protocol VTBleManagerDelegate <NSObject, CBCentralManagerDelegate>

// 超时或其他原因导致无法搜索到设备
- (void)didFailToDiscoverPeripheralAtBleManager:(VTBleManager *)manager;
// 部分设备掉线(过了存活时间)
- (void)didPeripheralOfflineAtBleManager:(VTBleManager *)manager;

@end

/**
 *   简单的蓝牙管理类,对代理事件进行默认处理,如果有代理,则把蓝牙事件进行转发
 */
@interface VTBleManager : NSObject

@property (weak, nonatomic) NSObject<VTBleManagerDelegate> *delegate;
@property (strong, nonatomic) CBCentralManager *centralManager;
@property (strong, nonatomic, readonly) NSMutableArray *peripherals;
@property (strong, nonatomic) CBPeripheral *connectedPeripheral;

+ (instancetype)sharedInstance;
// 增量更新
- (void)scanWithTimeOut:(NSTimeInterval)timeout;
// 清空设备表
- (void)rescanWithTimeOut:(NSTimeInterval)timeout;
// 不停地扫描
- (void)scanRepeatWithInterval:(NSTimeInterval)timeInterval;
// 重新不停地扫描
- (void)rescanRepeatWithInterval:(NSTimeInterval)timeInterval;

// 连接
- (void)connectPeripheral:(CBPeripheral *)peripheral withTimeOut:(NSTimeInterval)timeout;

@end
