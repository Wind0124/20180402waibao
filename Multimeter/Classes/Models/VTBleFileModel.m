//
//  VTBleFileModel.m
//  Multimeter
//
//  Created by vincent on 16/4/16.
//  Copyright © 2016年 vincent. All rights reserved.
//

#import "VTBleFileModel.h"

@implementation VTBleFileModel

- (NSString *)genfileName {
    static NSDateFormatter *dateFormatter = nil;
    if (!dateFormatter) {
        dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"YYYY-MM-dd-HH.mm.ss"];
    }
    return  [dateFormatter stringFromDate:self.saveTime];
}

@end
