//
//  VTBleDataModel.h
//  Multimeter
//
//  Created by vincent on 16/4/16.
//  Copyright © 2016年 vincent. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  用于保存到数据为的文件详情中的每条记录
 */
@interface VTBleDataModel : NSObject

@property (assign, nonatomic) NSInteger id;
@property (assign, nonatomic) NSInteger index;
@property (assign, nonatomic) NSInteger pid;
@property (strong, nonatomic) NSDate *recvTime;
@property (strong, nonatomic) NSData *data;

@end
