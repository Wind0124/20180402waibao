//
//  VTDateFormater.m
//  Multimeter
//
//  Created by Vincent on 27/09/2016.
//  Copyright © 2016 vincent. All rights reserved.
//

#import "VTDateFormater.h"

@implementation VTDateFormater

+ (NSString *)stringFromDate:(NSDate *)date {
    static NSDateFormatter *dateFormatter = nil;
    if (!dateFormatter) {
        dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    }
    NSString *str = [dateFormatter stringFromDate:date];
    return str;
}

@end
