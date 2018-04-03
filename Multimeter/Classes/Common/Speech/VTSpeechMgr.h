//
//  VTSpeechMgr.h
//  Multimeter
//
//  Created by Vincent on 9/3/16.
//  Copyright © 2016 vincent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VTSpeechMgr : NSObject

+ (instancetype)sharedInstance;

// 进入语音设置等界面要可以临时静音
@property (assign, nonatomic) BOOL isMute;

// 简单设置,male/woman, 音量
- (void)configure:(NSInteger)gender volume:(CGFloat)volume;
- (void)say:(NSString *)sth;

// 弹/关警告音
- (void)playWarn;
- (void)stopWarn;

// for test
+ (void)testVoiceSay:(NSString *)sth;
+ (void)listSupportVoices;
    
@end
