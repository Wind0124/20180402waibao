//
//  VTDeviceCell.h
//  Multimeter
//
//  Created by vincent on 16/4/10.
//  Copyright © 2016年 vincent. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CBPeripheral;

@interface VTDeviceCell : UITableViewCell

- (void)configureWithModel:(CBPeripheral *)model;

@end
