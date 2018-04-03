//
//  VTMeasureView_C052.m
//  Multimeter
//
//  Created by Vincent on 27/09/2016.
//  Copyright © 2016 vincent. All rights reserved.
//

#import "VTMeasureView_C052.h"
#import "VTDialView_C052.h"

@interface VTMeasureView_C052()

@property (strong, nonatomic) VTDialView *dialView;

@end

@implementation VTMeasureView_C052

@synthesize dialView = _dialView;

- (VTDialView *)dialView {
    if (!_dialView) {
        _dialView = [VTDialView_C052 new];
    }
    return _dialView;
}

@end
