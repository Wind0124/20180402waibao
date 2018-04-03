//
//  VTLcdView.m
//  Multimeter
//
//  Created by vincent on 16/4/24.
//  Copyright © 2016年 vincent. All rights reserved.
//

#import "VTLcdView.h"

@interface VTLcdView()

@property (weak, nonatomic) IBOutlet UILabel *lcdLabel;
@property (weak, nonatomic) IBOutlet UILabel *unitLabel;

@property (weak, nonatomic) IBOutlet UIButton *maxButton;
@property (weak, nonatomic) IBOutlet UIButton *minButton;
@property (weak, nonatomic) IBOutlet UIButton *holdButton;
@property (weak, nonatomic) IBOutlet UIButton *bleButton;

@end


@implementation VTLcdView

- (void)updateByParser:(VTBleDataParser *)parser {
    self.lcdLabel.text = parser.lcdString;
    self.unitLabel.text = parser.unitString;
    
    self.maxButton.selected = parser.isMax;
    self.minButton.selected = parser.isMin;
    self.holdButton.selected = parser.isH;
//    self.bleButton.selected = parser.isBlue;
}

- (void)awakeFromNib {
    if(SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        UIFont *font = [UIFont fontWithName:@"Digiface" size:120];
        self.lcdLabel.font = font;
    }
    self.maxButton.hidden = YES;
    self.minButton.hidden = YES;
    self.holdButton.hidden = YES;
    self.bleButton.hidden = YES;
}

- (void)updateBleButton:(BOOL)yesOrNo {
//    self.bleButton.selected = yesOrNo;
}

@end
