//
//  VTSettingMgr.m
//  Multimeter
//
//  Created by Vincent on 25/09/2016.
//  Copyright © 2016 vincent. All rights reserved.
//

#import "VTSettingMgr.h"
#import <PINCache.h>

@implementation VTSettingMgr

@dynamic speechEnabled;
@dynamic displayType;
@dynamic sampleRate;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static VTSettingMgr *sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        sharedInstance = [VTSettingMgr new];
    });
    return sharedInstance;
}

#pragma mark - Properties

- (BOOL)speechEnabled {
    NSNumber *speechEnabled = [[PINCache sharedCache] objectForKey:@"speechEnabled"];
    return [speechEnabled boolValue];
}

- (void)setSpeechEnabled:(BOOL)speechEnabled {
    [[PINCache sharedCache] setObject:@(speechEnabled) forKey:@"speechEnabled"];
}

- (NSInteger)displayType {
    NSNumber *type = [[PINCache sharedCache] objectForKey:@"displayType"];
    return [type integerValue];
}

- (void)setDisplayType:(NSInteger)displayType {
    [[PINCache sharedCache] setObject:@(displayType) forKey:@"displayType"];
}

- (NSInteger)sampleRate {
    NSNumber *rate = [[PINCache sharedCache] objectForKey:@"sampleRate"];
    NSInteger intValue = [rate integerValue];
    if (intValue <= 0) return 60;   // 默认值
    
    return intValue;
}

- (void)setSampleRate:(NSInteger)sampleRate {
    [[PINCache sharedCache] setObject:@(sampleRate) forKey:@"sampleRate"];
}

@end
