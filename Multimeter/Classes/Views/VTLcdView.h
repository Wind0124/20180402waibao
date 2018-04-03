//
//  VTLcdView.h
//  Multimeter
//
//  Created by vincent on 16/4/24.
//  Copyright © 2016年 vincent. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VTBleDataParser.h"

@interface VTLcdView : UIView

- (void)updateByParser:(VTBleDataParser *)parser;

// XXX
- (void)updateBleButton:(BOOL)yesOrNo;

@end
