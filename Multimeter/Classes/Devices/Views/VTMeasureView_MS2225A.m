//
//  VTMeasureView_MS2225A.m
//  Multimeter
//
//  Created by Wind on 2018/5/28.
//  Copyright © 2018年 vincent. All rights reserved.
//

#import "VTMeasureView_MS2225A.h"
#import "VTDialView_MS2225A.h"

@interface VTMeasureView_MS2225A()

@property (strong, nonatomic) VTDialView *dialView;

@end


@implementation VTMeasureView_MS2225A

@synthesize dialView = _dialView;

- (VTDialView *)dialView {
    if (!_dialView) {
        _dialView = [VTDialView_MS2225A new];
    }
    return _dialView;
}

@end
