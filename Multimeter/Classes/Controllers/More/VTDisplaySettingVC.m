//
//  VTDisplaySettingVC.m
//  Multimeter
//
//  Created by Vincent on 25/09/2016.
//  Copyright © 2016 vincent. All rights reserved.
//

#import "VTDisplaySettingVC.h"
#import "VTSwitchCell.h"
#import "VTSettingMgr.h"

@interface VTDisplaySettingVC () <UITableViewDataSource, UITableViewDelegate, VTSwitchCellDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) VTSwitchCell *chartCell;
@property (strong, nonatomic) VTSwitchCell *tableCell;

@end

@implementation VTDisplaySettingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = VTLOCALIZEDSTRING(@"显示");
    [self.view addSubview:self.tableView];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - VTSwitchCellDelegate
- (void)didSwitch:(VTSwitchCell *)cell on:(BOOL)onOrOff {
    if (cell == self.chartCell) {
        self.tableCell.isSwitchOn = !onOrOff;
    } else {
        self.chartCell.isSwitchOn = !onOrOff;
    }
    [VTSettingMgr sharedInstance].displayType = !self.chartCell.isSwitchOn;
}

#pragma mark - UITableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    VTSwitchCell *cell = nil;
    
    BOOL displayType = [VTSettingMgr sharedInstance].displayType;
    if (indexPath.row==0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"displaySettingCellChart" forIndexPath:indexPath];
        cell.tip = VTLOCALIZEDSTRING(@"曲线");
        cell.isSwitchOn = !displayType;
        cell.delegate = self;
        self.chartCell = cell;
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"displaySettingCellTbl" forIndexPath:indexPath];
        cell.tip = VTLOCALIZEDSTRING(@"表格");
        cell.isSwitchOn = displayType;
        cell.delegate = self;
        self.tableCell = cell;
    }
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}


#pragma mark - Properties

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.backgroundColor = UIColorFromRGBValue(0x303030);
        _tableView.separatorColor = UIColorFromRGBValueAlpha(0xffffff, 0.2);
        [_tableView registerClass:[VTSwitchCell class] forCellReuseIdentifier:@"displaySettingCellChart"];
        [_tableView registerClass:[VTSwitchCell class] forCellReuseIdentifier:@"displaySettingCellTbl"];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.allowsSelection = NO;
        _tableView.tableFooterView = [UIView new];
        _tableView.bounces = NO;
    }
    return _tableView;
}

@end
