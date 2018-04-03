//
//  VTDialView_8238.h
//  Multimeter
//
//  Created by Vincent on 28/09/2016.
//  Copyright © 2016 vincent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VTBleDataParser.h"
#import "VTDialView.h"

@interface VTDialView_8238 : VTDialView

- (void)updateByParser:(VTBleDataParser *)parser;
// 下线时更清表盘
- (void)resetWhenOffline;

@end
