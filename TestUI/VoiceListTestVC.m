//
//  VoiceListTestVC.m
//  Multimeter
//
//  Created by Vincent on 9/3/16.
//  Copyright © 2016 vincent. All rights reserved.
//

#import "VoiceListTestVC.h"
#import <AVFoundation/AVFoundation.h>
#import "VTSpeechMgr.h"

@interface VoiceListTestVC()

@property (strong, nonatomic) NSArray *dataSource;
@property (strong, nonatomic) AVSpeechSynthesizer *synthesize;

@end

@implementation VoiceListTestVC

- (void)viewDidLoad {
    self.title = @"测试voice";
    self.dataSource = [AVSpeechSynthesisVoice speechVoices];
    
}


#pragma mark - UITableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    AVSpeechSynthesisVoice *voice = self.dataSource[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@", voice.language];
    
    return cell;
}

#pragma mark - UITableView Delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AVSpeechSynthesisVoice *voice = self.dataSource[indexPath.row];
    AVSpeechUtterance *utt = [[AVSpeechUtterance alloc]initWithString:@"-211.01Hz 17Ω"];
    utt.voice = voice;
    NSLog(@"%lf, %lf, %lf", AVSpeechUtteranceMinimumSpeechRate, AVSpeechUtteranceDefaultSpeechRate,AVSpeechUtteranceMaximumSpeechRate);
    utt.rate = 0.3;
    [self.synthesize speakUtterance:utt];
}


- (AVSpeechSynthesizer *)synthesize {
    if (!_synthesize) {
        _synthesize = [AVSpeechSynthesizer new];
    }
    return _synthesize;
}

@end
