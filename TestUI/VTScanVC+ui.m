//
//  VTScanVC+ui.m
//  Multimeter
//
//  Created by Vincent on 9/13/16.
//  Copyright © 2016 vincent. All rights reserved.
//

#import "VTScanVC+ui.h"
#import "NSObject+Swizzling.h"

@implementation VTScanVC (ui)

+ (void)load {
    [self vt_swizzleMethod:@selector(viewDidAppear:) withMethod:@selector(ui_viewDidAppear:)];
}

- (void)ui_viewDidAppear:(BOOL)animated {
    [self ui_viewDidAppear:animated];
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self performSelector:@selector(didFailToDiscoverPeripheralAtBleManager:) withObject:nil];
//    });
}

@end
