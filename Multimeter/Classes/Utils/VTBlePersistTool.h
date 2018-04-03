//
//  VTBlePersistTool.h
//  Multimeter
//
//  Created by vincent on 16/4/14.
//  Copyright © 2016年 vincent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CBPeripheral+Extra.h"

#import "VTBleFileModel.h"
#import "VTBleDataModel.h"

@interface VTBlePersistTool : NSObject

+ (BOOL)createDB;
+ (void)resetDB;

// 修改文件名
+ (BOOL)updateIndexFile:(VTBleFileModel *)model;
// 保存数据
+ (BOOL)saveDatasToDB:(NSArray *)datas withIndexInfo:(VTBleFileModel *)file;
// 获取保存的索引
+ (NSArray *)fetchIndexInfos;
// 从索引中取出所有数据段
+ (NSArray *)fetchBleDatasWithIndexId:(NSInteger)id;
// 根据文件名读取所有数据
+ (NSArray *)fetchBleDatasWithFileName:(NSString *)fileName;
// 从数据库清除文件
+ (BOOL)removeDataWithIndexId:(NSInteger)indexId;

// 保存设备信息
+ (BOOL)saveDeviceToDB:(CBPeripheral *)peripheral;
// 获取备注信息
+ (NSString *)fetchRemarkFromDBWithUUID:(NSString *)uuid;

// 保存上次连接
+ (void)saveLastConnectIdentifier:(NSUUID *)identifier;
// 获取上次连接
+ (NSUUID *)getLastConnect;
    
@end
