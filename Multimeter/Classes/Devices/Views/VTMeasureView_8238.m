//
//  VTMeasureView_8238.m
//  Multimeter
//
//  Created by Vincent on 28/09/2016.
//  Copyright © 2016 vincent. All rights reserved.
//

#import "VTMeasureView_8238.h"
#import "PureLayout.h"
#import "VTDialView_8238.h"

@interface VTMeasureView_8238()

@property (strong, nonatomic) VTDialView *dialView;

@end

@implementation VTMeasureView_8238

@synthesize dialView = _dialView;

- (VTDialView *)dialView {
    if (!_dialView) {
        _dialView = [VTDialView_8238 new];
    }
    return _dialView;
}

@end
