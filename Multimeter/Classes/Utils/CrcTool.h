//
//  CrcTool.h
//  Multimeter
//
//  Created by 俞伟山 on 2017/1/9.
//  Copyright © 2017年 vincent. All rights reserved.
//

#import <Foundation/Foundation.h>

unsigned char CRC8_Table(unsigned char *p, char counter);

@interface CrcTool : NSObject

@end
