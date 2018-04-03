//
//  VTMeasureView_453B.m
//  Multimeter
//
//  Created by Vincent on 27/09/2016.
//  Copyright © 2016 vincent. All rights reserved.
//

#import "VTMeasureView_453B.h"
#import "VTDialView_453B.h"

@interface VTMeasureView_453B()

@property (strong, nonatomic) VTDialView *dialView;

@end

@implementation VTMeasureView_453B

@synthesize dialView = _dialView;

- (VTDialView *)dialView {
    if (!_dialView) {
        _dialView = [VTDialView_453B new];
    }
    return _dialView;
}

@end
