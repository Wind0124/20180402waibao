//
//  VTDeviceMgr.m
//  Multimeter
//
//  Created by Vincent on 27/09/2016.
//  Copyright © 2016 vincent. All rights reserved.
//

#import "VTDeviceMgr.h"
#import "VTBleDataAdapters.h"
#import "VTMeasurePresenterProtocol.h"

static NSMutableDictionary *gRegisterDict = nil;

@implementation VTDeviceMgr

// 注册型号和对应的xxx
+ (void)load {
    if (!gRegisterDict){
        gRegisterDict = [NSMutableDictionary new];
    }
    NSDictionary *dict1 = @{
                            @"presenter": @"VTMeasurePresenter_450B",
                            @"adapter": @"VTBleDataAdapter_450B",
                            };
    [gRegisterDict setValue:dict1 forKey:[@(0x450b) stringValue]];
    
    NSDictionary *dict2 = @{
                            @"presenter": @"VTMeasurePresenter_453B",
                            @"adapter": @"VTBleDataAdapter_453B",
                            };
    [gRegisterDict setValue:dict2 forKey:[@(0x453b) stringValue]];
    
    NSDictionary *dict3 = @{
                            @"presenter": @"VTMeasurePresenter_C052",
                            @"adapter": @"VTBleDataAdapter_C052",
                            };
    [gRegisterDict setValue:dict3 forKey:[@(0xc052) stringValue]];
    
    NSDictionary *dict4 = @{
                            @"presenter": @"VTMeasurePresenter_8238",
                            @"adapter": @"VTBleDataAdapter_8238",
                            };
    [gRegisterDict setValue:dict4 forKey:[@(0x8238) stringValue]];
    
    // 2.0版本新增
    NSDictionary *dict5 = @{
                            @"presenter": @"VTMeasurePresenter_MS2225A",
                            @"adapter": @"VTBleDataAdapter_MS2225A",
                            };
    [gRegisterDict setValue:dict5 forKey:[@(0x2225) stringValue]];
    
    NSDictionary *dict6 = @{
                            @"presenter": @"VTMeasurePresenter_MS6252D",
                            @"adapter": @"VTBleDataAdapter_MS6252D",
                            };
    [gRegisterDict setValue:dict6 forKey:[@(0x6252) stringValue]];
    
    NSDictionary *dict7 = @{
                            @"presenter": @"VTMeasurePresenter_MS6612D",
                            @"adapter": @"VTBleDataAdapter_MS6612D",
                            };
    [gRegisterDict setValue:dict7 forKey:[@(0x6612) stringValue]];
}

// 通过 数字型号 选择加载数据控制器
+ (NSObject<VTBleDataAdapter> *)adapterForModel:(NSInteger)model {
    NSDictionary *dict = gRegisterDict[[@(model) stringValue]];
    NSString *adapterStr = dict[@"adapter"];
    if (!adapterStr.length) return nil;
    
    Class cls = NSClassFromString(adapterStr);
    if (![cls conformsToProtocol:@protocol(VTBleDataAdapter)]) return nil;

    return [cls new];
}

// 通过 数字型号 选择加载页面控制器
+ (NSObject<VTMeasurePresenterProtocol> *)presenterForModel:(NSInteger)model {
    NSDictionary *dict = gRegisterDict[[@(model) stringValue]];
    NSString *presenter = dict[@"presenter"];
    if (!presenter.length) return nil;
    
    Class cls = NSClassFromString(presenter);
    if (![cls conformsToProtocol:@protocol(VTMeasurePresenterProtocol)]) return nil;
    
    return [cls new];
}


@end
