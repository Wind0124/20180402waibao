//
//  VTChangeDeviceRemarkVC.m
//  Multimeter
//
//  Created by vincent on 16/4/16.
//  Copyright © 2016年 vincent. All rights reserved.
//

#import "VTChangeDeviceRemarkVC.h"
#import "VTBlePersistTool.h"

@interface VTChangeDeviceRemarkVC ()

@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation VTChangeDeviceRemarkVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = VTLOCALIZEDSTRING(@"重命名");
    self.textField.text = self.peripheral.remarkName;
}

//- (void)awakeFromNib {
//    
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onDoneClick:(id)sender {
    self.peripheral.remarkName = self.textField.text;
    [VTBlePersistTool saveDeviceToDB:self.peripheral];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
