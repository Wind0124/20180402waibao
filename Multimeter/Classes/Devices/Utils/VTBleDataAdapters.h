//
//  VTBleDataAdapters.h
//  Multimeter
//
//  Created by Vincent on 27/09/2016.
//  Copyright © 2016 vincent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VTBleDataParser.h"

@protocol VTBleDataAdapter <NSObject>

@property (weak, nonatomic) VTBleDataParser *parser;

- (NSString *)modelName;
- (CGFloat)angle;
// 第几档
- (NSInteger)pointPos;
- (NSDictionary *)getRange;

@optional
- (NSString *)segFunction;
// interceptor;

- (void)beforParse;
- (void)afterParse;

- (BOOL)isFuncClick;
- (BOOL)isHoldClick;
- (BOOL)isHZClick;
- (BOOL)isBrightClick;
- (BOOL)isRangeClick;
- (BOOL)isRELClick;

@end


@interface VTBleDataAdapter_450B : NSObject  <VTBleDataAdapter>
@end


@interface VTBleDataAdapter_453B : NSObject  <VTBleDataAdapter>
@end


@interface VTBleDataAdapter_C052 : NSObject  <VTBleDataAdapter>
@end


@interface VTBleDataAdapter_8238 : NSObject  <VTBleDataAdapter>
@end

@interface VTBleDataAdapter_2225A : NSObject <VTBleDataAdapter>
@end
