//
//  VTDeviceCell.m
//  Multimeter
//
//  Created by vincent on 16/4/10.
//  Copyright © 2016年 vincent. All rights reserved.
//

#import "VTDeviceCell.h"
#import "CBPeripheral+Extra.h"

@interface VTDeviceCell()

@property (weak, nonatomic) IBOutlet UILabel *rssiLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *uuidLabel;

@end

@implementation VTDeviceCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse {
//    self.rssiLabel.text = @"";
//    self.nameLabel.text = @"";
//    self.uuidLabel.text = @"";
}

- (void)configureWithModel:(CBPeripheral *)model {
    self.rssiLabel.text = [NSString stringWithFormat:@"%@dBm", [model.scanRSSI stringValue]];
    self.nameLabel.text = model.availableName;
    self.uuidLabel.text = [model.identifier UUIDString];
}

@end
