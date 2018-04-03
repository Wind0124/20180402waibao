//
//  VTSampleRateSettingCell.h
//  Multimeter
//
//  Created by Vincent on 25/09/2016.
//  Copyright © 2016 vincent. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol VTSampleRateSettingCellDelegate <NSObject>

- (void)didRateChanged:(NSInteger)value;

@end

@interface VTSampleRateSettingCell : UITableViewCell

@property (weak, nonatomic) id<VTSampleRateSettingCellDelegate> delegate;
@property (assign, nonatomic) NSInteger rate;

@end
