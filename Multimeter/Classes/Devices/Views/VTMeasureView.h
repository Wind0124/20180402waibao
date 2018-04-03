//
//  VTMeasureView.h
//  Multimeter
//
//  Created by Vincent on 28/11/2016.
//  Copyright © 2016 vincent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VTOperationButton.h"
#import "VTDialView.h"
#import "VTLcdView.h"

@interface VTMeasureView : UIView

@property (strong, nonatomic) VTLcdView *lcdView;
@property (strong, nonatomic) VTDialView *dialView;

@property (strong, nonatomic) VTOperationButton *recordBtn;
@property (strong, nonatomic) VTOperationButton *pauseBtn;
@property (strong, nonatomic) VTOperationButton *analyzeBtn;

@property (strong, nonatomic) UILabel *lowBatteryLabel;

@property (strong, nonatomic) UIView *chartContainer;

- (void)resetContraintsForContainer;

@end
