//
//  VTMeasureView_450B.m
//  Multimeter
//
//  Created by Vincent on 27/09/2016.
//  Copyright © 2016 vincent. All rights reserved.
//

#import "VTMeasureView_450B.h"
#import "PureLayout.h"
#import "VTDialView_450B.h"

@interface VTMeasureView_450B()

@property (strong, nonatomic) VTDialView *dialView;

@end


@implementation VTMeasureView_450B

@synthesize dialView = _dialView;

- (VTDialView *)dialView {
    if (!_dialView) {
        _dialView = [VTDialView_450B new];
    }
    return _dialView;
}

@end
