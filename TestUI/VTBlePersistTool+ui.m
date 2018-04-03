//
//  VTBlePersistTool+ui.m
//  Multimeter
//
//  Created by Vincent on 18/12/2016.
//  Copyright © 2016 vincent. All rights reserved.
//

#import "VTBlePersistTool+ui.h"

@implementation VTBlePersistTool (ui)

#if TARGET_IPHONE_SIMULATOR
+ (NSUUID *)getLastConnect {
    NSString *uuidString = @"C2DE6989-FFF3-4DBD-90A3-40CF4E4A5719";
    if (!uuidString.length) {
        return nil;
    }
    return [[NSUUID alloc] initWithUUIDString:uuidString];
}
#endif

@end
