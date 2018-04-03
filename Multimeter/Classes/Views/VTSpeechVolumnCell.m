//
//  VTSpeechVolumnCell.m
//  Multimeter
//
//  Created by Vincent on 25/09/2016.
//  Copyright © 2016 vincent. All rights reserved.
//

#import "VTSpeechVolumnCell.h"

@interface VTSpeechVolumnCell()

@property (strong, nonatomic) UISlider *volumnSlider;

@end


@implementation VTSpeechVolumnCell

- (void)setVolumn:(CGFloat)volumn {
    self.volumnSlider.value = volumn;
}

@end

