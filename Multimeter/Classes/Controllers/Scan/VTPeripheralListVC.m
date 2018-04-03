//
//  VTPeripheralListVC.m
//  Multimeter
//
//  Created by vincent on 16/4/13.
//  Copyright © 2016年 vincent. All rights reserved.
//

#import "VTPeripheralListVC.h"
#import "VTBleManager.h"
#import "VTDeviceCell.h"
#import "VTMeasureVC.h"

#import <RESideMenu/RESideMenu.h>
#import "MJRefresh.h"
#import "VTNormalButton.h"

#import "UIAlertView+Blocks.h"
#import "UIView+Helper.h"

@interface VTPeripheralListVC ()<VTBleManagerDelegate>

@property (strong, nonatomic) UIView *footerView;

@end

@implementation VTPeripheralListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [VTBleManager sharedInstance].delegate = self;
    
//    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = UIColorFromRGBValue(0x303030);
    self.tableView.separatorColor = UIColorFromRGBValue(0x6a6a6a);
    self.tableView.tableFooterView = self.footerView;
    WEAKSELF
    self.tableView.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf refreshData];
    }];
    [self refreshData];
    self.view.backgroundColor = UIColorFromRGBValue(0x303030);
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.manager.centralManager stopScan];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)refreshData {
    self.manager.delegate = self;
    [self.manager rescanRepeatWithInterval:TIMEOUT_BLE_REPEATE_INTERVAL];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.manager.peripherals.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CBPeripheral *peripheral = self.manager.peripherals[indexPath.row];
    
    VTDeviceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"deviceCellIdentifier" forIndexPath:indexPath];
    [cell configureWithModel:peripheral];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CBPeripheral *peripheral = self.manager.peripherals[indexPath.row];
    [self connectPeripheral:peripheral];
}

#pragma mark - VTBleManagerDelegate
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI {
    [self.tableView reloadData];
    [self.tableView.mj_header endRefreshing];
}

- (void)didFailToDiscoverPeripheralAtBleManager:(VTBleManager *)manager {
    [self.manager.centralManager stopScan];
    [self.tableView.mj_header endRefreshing];
}

- (void)didPeripheralOfflineAtBleManager:(VTBleManager *)manager {
    [self.tableView reloadData];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    VTLog(@"连接设备成功");
    VTMeasureVC *vc = STORYBOARD_INSTANT(@"VTMeasureVC");
    vc.peripheral = peripheral;
    self.manager.delegate = vc;
    [self.manager.centralManager stopScan];
    self.sideMenuViewController.contentViewController = [[UINavigationController alloc] initWithRootViewController:vc];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    [UIAlertView showWithTitle:nil message:VTLOCALIZEDSTRING(@"设备连接失败") cancelButtonTitle:VTLOCALIZEDSTRING(@"知道了") otherButtonTitles:nil tapBlock:nil];
}

#pragma mark - Private methods
- (void)connectPeripheral:(CBPeripheral *)peripheral {
    [self.manager connectPeripheral:peripheral withTimeOut:TIMEOUT_CONNECT_PROCEDURE];
//    [self.manager.centralManager connectPeripheral:peripheral options:nil];
  //@{CBConnectPeripheralOptionNotifyOnDisconnectionKey:@(YES)}];
}

#pragma mark - Properties
- (VTBleManager *)manager {
    return [VTBleManager sharedInstance];
}

- (UIView *)footerView {
    if (!_footerView) {
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 80)];
        VTNormalButton *button = [VTNormalButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 30, SCREENWIDTH-60, 50);
        button.center = _footerView.center;
        [button setTitle:VTLOCALIZEDSTRING(@"刷新列表") forState:UIControlStateNormal];
        [button addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventTouchUpInside];
        [_footerView addSubview:button];
    }
    return _footerView;
}

@end
