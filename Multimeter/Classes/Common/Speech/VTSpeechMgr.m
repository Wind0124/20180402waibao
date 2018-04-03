//
//  VTSpeechMgr.m
//  Multimeter
//
//  Created by Vincent on 9/3/16.
//  Copyright © 2016 vincent. All rights reserved.
//

#import "VTSpeechMgr.h"
#import <AVFoundation/AVFoundation.h>

@interface VTSpeechMgr() <AVSpeechSynthesizerDelegate>

@property (assign, nonatomic) NSInteger gender;
@property (assign, nonatomic) CGFloat volume;

@property (strong, nonatomic) AVSpeechSynthesizer *synthesize;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
// 是否正在读
@property (assign, nonatomic) BOOL isSaying;
// 正在警告中
@property (assign, nonatomic) BOOL isWarning;

@end

@implementation VTSpeechMgr

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static VTSpeechMgr *mgr = nil;
    dispatch_once(&onceToken, ^{
        mgr = [VTSpeechMgr new];
    });
    return mgr;
}

- (instancetype)init {
    self = [super init];
    if (!self) return nil;
    
    self.gender = 0;
    self.volume = 1.0;
    
    return self;
}

- (void)configure:(NSInteger)gender volume:(CGFloat)volume {
    self.gender = gender;
    self.volume = volume;
}

- (void)say:(NSString *)sth {
    // TODO: 频繁的情况处理
    if (_isSaying || _isMute || _isWarning) {
        return;
    }
    _isSaying = YES;
    AVSpeechUtterance *utt = [[AVSpeechUtterance alloc] initWithString:sth];
    utt.volume = self.volume;
//    utt.voice = self.voice;
    utt.rate = self.rate;
    utt.pitchMultiplier = self.pitchMultiplier;
    
    [self.synthesize speakUtterance:utt];
}

- (void)playWarn {
    _isWarning = YES;
    if (!_audioPlayer) {
        AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"warn" ofType:@"mp3"]] error:nil];
        player.volume = 1;//0.0-1.0之间
        player.numberOfLoops = 1;//-1;
        _audioPlayer = player;
    }
    [_audioPlayer play];
    [self performSelector:@selector(stopWarn) withObject:nil afterDelay:1];
}

- (void)stopWarn {
    [_audioPlayer stop];
    _audioPlayer = nil;
    _isWarning = NO;
}

// 使用不同的voice说话
+ (void)testVoiceSay:(NSString *)sth {
    
}

+ (void)listSupportVoices {
    NSArray *voices = [AVSpeechSynthesisVoice speechVoices];
    for (AVSpeechSynthesisVoice *voice in voices) {
        NSLog(@"language: %@", voice.language);
    }
    NSLog(@"currentLanguage: %@", [AVSpeechSynthesisVoice currentLanguageCode]);
}

#pragma mark - AVSpeechSynthesizerDelegate
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance {
    _isSaying = NO;
}

#pragma mark - Properties

- (AVSpeechSynthesisVoice *)voice {
    // 定个男声音
    NSString *voiceType = nil;
    if (self.gender) {
        voiceType = @"en-GB";
    } else {
        voiceType = @"en-AU";
    }
    
    return [AVSpeechSynthesisVoice voiceWithLanguage:voiceType];
}

- (CGFloat)rate {
    return AVSpeechUtteranceDefaultSpeechRate;
}

- (CGFloat)pitchMultiplier {
    return 1.0;
}

- (AVSpeechSynthesizer *)synthesize {
    if (!_synthesize) {
        _synthesize = [AVSpeechSynthesizer new];
        _synthesize.delegate = self;
    }
    return _synthesize;
}

@end
