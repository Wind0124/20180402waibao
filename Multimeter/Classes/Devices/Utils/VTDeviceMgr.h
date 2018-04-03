//
//  VTDeviceMgr.h
//  Multimeter
//
//  Created by Vincent on 27/09/2016.
//  Copyright © 2016 vincent. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VTBleDataAdapter;
@protocol VTMeasurePresenterProtocol;

// 注册设备,每次添加一个新设备,往这边注册
@interface VTDeviceMgr : NSObject

+ (NSObject<VTBleDataAdapter> *)adapterForModel:(NSInteger)model;
+ (NSObject<VTMeasurePresenterProtocol> *)presenterForModel:(NSInteger)model;
    
@end
