//
//  VTBleFileModel.h
//  Multimeter
//
//  Created by vincent on 16/4/16.
//  Copyright © 2016年 vincent. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  用于保存到数据中的文件结构
 */
@interface VTBleFileModel : NSObject

// 数据库id
@property (assign, nonatomic) NSInteger id;
// 文件名
@property (strong, nonatomic) NSString *fileName;
// 开始录制时间
@property (strong, nonatomic) NSDate *startTime;
// 保存时间
@property (strong, nonatomic) NSDate *saveTime;
// 有多少报文
@property (assign, nonatomic) NSInteger count;
// 量程最小值
@property (assign, nonatomic) CGFloat min;
// 量程最大值
@property (assign, nonatomic) CGFloat max;
// 拔盘类型
@property (assign, nonatomic) NSInteger type;
// 功能类型
@property (strong, nonatomic) NSString *func;
// 单位
@property (strong, nonatomic) NSString *unit;

// 产生文件名
- (NSString *)genfileName;

@end
