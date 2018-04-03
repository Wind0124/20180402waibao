//
//  VTSwitchCell.h
//  Multimeter
//
//  Created by Vincent on 26/09/2016.
//  Copyright © 2016 vincent. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VTSwitchCell;
@protocol VTSwitchCellDelegate <NSObject>

- (void)didSwitch:(VTSwitchCell *)cell on:(BOOL)onOrOff;

@end

@interface VTSwitchCell : UITableViewCell

@property (assign, nonatomic) BOOL isSwitchOn;
@property (strong, nonatomic) NSString *tip;
@property (weak, nonatomic) id<VTSwitchCellDelegate> delegate;

@end
