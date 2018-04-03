//
//  VTSettingMgr.h
//  Multimeter
//
//  Created by Vincent on 25/09/2016.
//  Copyright © 2016 vincent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VTSettingMgr : NSObject

+ (instancetype)sharedInstance;

// 语音播报开关
@property (assign, nonatomic) BOOL speechEnabled;
// 显示类型, 0:曲线 1:表格
@property (assign, nonatomic) NSInteger displayType;
// 采样速率
@property (assign, nonatomic) NSInteger sampleRate;

@end
