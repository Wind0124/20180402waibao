//
//  CommonDefs.h
//  Multimeter
//
//  Created by vincent on 16/4/10.
//  Copyright © 2016年 vincent. All rights reserved.
//

#ifndef CommonDefs_h
#define CommonDefs_h

#import "UIView+Helper.h"

// 工具
#define STORYBOARD_INSTANT(id)  [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:id];

#define MS_STORYBOARD_INSTANT(id)  [[UIStoryboard storyboardWithName:@"Measure" bundle:nil] instantiateViewControllerWithIdentifier:id];

#define WEAKSELF typeof(self) __weak weakSelf = self;
#define STRONGSELF typeof(weakSelf) __strong strongSelf = weakSelf;

#define VTLOCALIZEDSTRING(string)  NSLocalizedString(string, @"")

#define UIColorFromRGBValue(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define UIColorFromRGBValueAlpha(rgbValue,a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]

#define VALID_STRING(str) (str==nil?@"":str)
#define VALID_VALUE(value) (value==nil?[NSNull null]:value)

//#define SCREENHEIGHT      ([UIScreen mainScreen].bounds.size.height)
//#define SCREENWIDTH       ([UIScreen mainScreen].bounds.size.width)

#define HPROPER           (SCREENWIDTH/375.0)
#define VPROPER           ((SCREENHEIGHT-64)/603.0)

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#ifdef DEBUG
#define VTLog(...) NSLog(__VA_ARGS__)
#else
#define VTLog(...)
#endif


// 业务相关
#define kDeviceIdentifier                           @"bde spp dev"
#define kDeviceNotifyServiceUUID                    @"FFB0"
#define kDeviceInfoServiceUUID                      @"180A"

#define kCharacteristicUUID                         @"FFB2"

// 超时时间,目前没有严格的定义
#define TIMEOUT_CONNECT_PROCEDURE                   (5)
#define TIMEOUT_SERVICE_DISCOVER_PROCEDURE          (20.0)
#define TIMEOUT_BLE_DISCOVER_PROCEDURE              (5.0)
#define TIMEOUT_BLE_REPEATE_INTERVAL                (2.0)   // 间隔2s扫描一次
#define TIMEOUT_BLE_LIVE                            (2.0)   // 3s没有刷新的设备认为掉线了

// 测试的宏
//#define TEST_FAKE_DATA
//#define TEST_BLE_DISCOVER


#endif /* CommonDefs_h */
