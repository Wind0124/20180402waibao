//
//  VTBlePersistTool.m
//  Multimeter
//
//  Created by vincent on 16/4/14.
//  Copyright © 2016年 vincent. All rights reserved.
//

#import "VTBlePersistTool.h"
#import "FMDatabaseAdditions.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"
#import <PINCache.h>

static FMDatabaseQueue *gQueue = nil;

@implementation VTBlePersistTool

+ (BOOL)createDB {
    if (gQueue) {
        [gQueue close];
        gQueue = nil;
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir = paths[0];
    NSString *dbPath = [NSString stringWithFormat:@"%@/data.db", documentDir];
    gQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
    NSLog(@"path:%@", dbPath);
    
    NSDictionary *attributes = @{NSFileProtectionKey: NSFileProtectionNone};
    NSError *error;
    [[NSFileManager defaultManager] setAttributes:attributes
                                     ofItemAtPath:dbPath
                                            error:&error];
    __block BOOL success = NO;
    [gQueue inDatabase:^(FMDatabase *db) {
        //创建索引表
        NSString *createIndexTable = @"CREATE TABLE IF NOT EXISTS 'indexTable' ("
                                          "'id' integer NOT NULL PRIMARY KEY AUTOINCREMENT,"
                                          "'fileName' text,"
                                          "'startTime' real,"
                                          "'saveTime' real,"
                                          "'count' integer,"
                                          "'min' real,"
                                          "'max' real,"
                                          "'type' integer,"
                                          "'func' text,"
                                          "'unit' text"
                                          ")";
        success = [db executeUpdate:createIndexTable];
        // 创建包数据表
        NSString *createDataTable = @"CREATE TABLE IF NOT EXISTS 'bleDataTable' ("
                                         "'id' integer NOT NULL PRIMARY KEY AUTOINCREMENT,"
                                         "'pid' text,"
                                         "'index' integer,"
                                         "'recvTime' real,"
                                         "'data' blob"
                                         ")";
        success = [db executeUpdate:createDataTable];
        // 创建设备信息表
        NSString *createDeviceTable = @"CREATE TABLE IF NOT EXISTS 'bleDeviceTable' ("
                                    "'uuid' text PRIMARY KEY,"
                                    "'localname' text,"
                                    "'remark' text,"
                                    "'mac' text"
                                    ")";
        success = [db executeUpdate:createDeviceTable];
        
    }];
//    [self testData];
    
    return success;
}

+ (void)resetDB {
    [gQueue close];
}

+ (BOOL)removeDataWithIndexId:(NSInteger)indexId {
    __block BOOL success = FALSE;
    [gQueue inDatabase:^(FMDatabase *db) {
        NSString *indexSql = @"DELETE from 'indexTable' where id=?";
        success = [db executeUpdate:indexSql,@(indexId)];
        
        NSString *dataSql = @"DELETE from 'bleDataTable' where pid=?";
        success = [db executeUpdate:dataSql,@(indexId)];
    }];
    
    return success;
}

+ (BOOL)saveDatasToDB:(NSArray *)datas withIndexInfo:(VTBleFileModel *)model {
    __block BOOL success = FALSE;
    [gQueue inDatabase:^(FMDatabase *db) {
        NSString *indexSql = @"INSERT OR REPLACE INTO 'indexTable' ('fileName','startTime','saveTime','count','min','max','type','func','unit') VALUES (?,?,?,?,?,?,?,?,?)";
        success = [db executeUpdate:indexSql,model.fileName,model.startTime,model.saveTime,@(model.count),@(model.min),@(model.max),@(model.type),model.func,model.unit];
        int  dbID = [db intForQuery:@"select * from 'indexTable' where startTime=? and saveTime=?",
                     model.startTime,model.saveTime];
        for (int i=0; i<datas.count; i++) {
            NSDictionary *dict = datas[i];
            NSData *data = dict[@"data"];
            NSDate *date = dict[@"time"];
            NSString *sql = @"INSERT OR REPLACE INTO 'bleDataTable' ('pid','index','data','recvTime') VALUES (?,?,?,?)";
            success = [db executeUpdate:sql,@(dbID),@(i),data,date];
        }
    }];
    
    return success;
}

+ (NSArray *)fetchIndexInfos {
    __block NSMutableArray *array = [NSMutableArray array];
    [gQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"SELECT * FROM 'indexTable'";
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            VTBleFileModel *model = [VTBleFileModel new];
            model.id = [rs intForColumn:@"id"];
            model.fileName = [rs stringForColumn:@"fileName"];
            model.saveTime = [rs dateForColumn:@"saveTime"];
            model.startTime = [rs dateForColumn:@"startTime"];
            model.type = [rs intForColumn:@"type"];
            model.min = [rs doubleForColumn:@"min"];
            model.max = [rs doubleForColumn:@"max"];
            model.count = [rs intForColumn:@"count"];
            model.func = [rs stringForColumn:@"func"];
            model.unit = [rs stringForColumn:@"unit"];
            
            [array addObject:model];
        }
    }];
    return array;
}

+ (BOOL)updateIndexFile:(VTBleFileModel *)model {
    __block BOOL success = FALSE;
    [gQueue inDatabase:^(FMDatabase *db) {
//        for (VTBleFileModel *model in indexFiles) {
            NSString *indexSql = @"INSERT OR REPLACE INTO 'indexTable' ('id','fileName','startTime','saveTime','count','min','max','type','func','unit') VALUES (?,?,?,?,?,?,?,?,?,?)";
            success = [db executeUpdate:indexSql,@(model.id),model.fileName,model.startTime,model.saveTime,@(model.count),@(model.min),@(model.max),@(model.type),model.func,model.unit];
//        }
    }];
    
    return success;
}

+ (NSArray *)fetchBleDatasWithIndexId:(NSInteger)id {
    __block NSMutableArray *array = [NSMutableArray array];
    [gQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"SELECT * FROM 'bleDataTable' WHERE pid=? ORDER BY ID ASC";
        FMResultSet *rs = [db executeQuery:sql,@(id)];
        while ([rs next]) {
            VTBleDataModel *model = [VTBleDataModel new];
            model.id = [rs intForColumn:@"id"];
            model.index = [rs intForColumn:@"index"];
            model.pid = [rs intForColumn:@"pid"];
            model.data = [rs dataForColumn:@"data"];
            model.recvTime = [rs dateForColumn:@"recvTime"];
            [array addObject:model];
        }
    }];
    return array;
}

+ (NSArray *)fetchBleDatasWithFileName:(NSString *)fileName {
    __block NSMutableArray *array = [NSMutableArray array];
    [gQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"SELECT d.'data',d.'index',d.'recvTime',i.'filename' FROM 'bleDataTable' as d,'indexTable' as i WHERE d.'pid'=i.'id' and i.'filename'=? ORDER BY d.'id' ASC";
        FMResultSet *rs = [db executeQuery:sql,fileName];
        while ([rs next]) {
            VTBleDataModel *model = [VTBleDataModel new];
//            model.id = [rs intForColumn:@"id"];
            model.index = [rs intForColumn:@"index"];
//            model.pid = [rs intForColumn:@"pid"];
            model.data = [rs dataForColumn:@"data"];
            model.recvTime = [rs dateForColumn:@"recvTime"];
            [array addObject:model];
        }
    }];
    return array;
}

+ (BOOL)saveDeviceToDB:(CBPeripheral *)peripheral {
    __block BOOL success = FALSE;
    [gQueue inDatabase:^(FMDatabase *db) {
        NSString *indexSql = @"INSERT OR REPLACE INTO 'bleDeviceTable' ('uuid','remark','localname') VALUES (?,?,?)";
        VTLog(@"save uuid:%@, remark:%@", peripheral.identifier.UUIDString, peripheral.remarkName);
        success = [db executeUpdate:indexSql,peripheral.identifier.UUIDString, peripheral.remarkName, peripheral.localName];
    }];
    
    return success;
}

+ (NSString *)fetchRemarkFromDBWithUUID:(NSString *)uuid {
    __block NSString *remark = nil;
    [gQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"SELECT remark FROM 'bleDeviceTable' WHERE uuid=?";
        remark = [db stringForQuery:sql,uuid];
//        VTLog(@"get uuid:%@", uuid);
    }];
    return remark;
}

+ (void)saveLastConnectIdentifier:(NSUUID *)identifier {
    if (identifier) {
        [[PINCache sharedCache] setObject:identifier.UUIDString forKey:@"lastConnectIdentifier"];
    } else {
        [[PINCache sharedCache] removeObjectForKey:@"lastConnectIdentifier"];
    }
}

+ (NSUUID *)getLastConnect {
    NSString *uuidString = [[PINCache sharedCache] objectForKey:@"lastConnectIdentifier"];
    if (!uuidString.length) {
        return nil;
    }
    return [[NSUUID alloc] initWithUUIDString:uuidString];
}

#pragma mark - Test



@end
