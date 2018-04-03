//
//  CBPeripheral+Extra.h
//  Multimeter
//
//  Created by vincent on 16/4/10.
//  Copyright © 2016年 vincent. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

@interface CBPeripheral (Extra)

// 扫描到的rssi,不是连接后的rssi
@property (strong, nonatomic) NSNumber *scanRSSI;
// 设备的localName
@property (strong, nonatomic) NSString *localName;
// 设备备注名
@property (strong, nonatomic) NSString *remarkName;

// 有备注显示备注、无备注显示localName, 无localName显示name
@property (readonly, strong, nonatomic) NSString *availableName;

// 上次扫描到的时间,超时则清除
@property (strong, nonatomic) NSDate *lastUpdateTime;


@end
