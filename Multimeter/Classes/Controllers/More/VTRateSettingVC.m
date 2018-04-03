//
//  VTRateSettingVC.m
//  Multimeter
//
//  Created by Vincent on 25/09/2016.
//  Copyright © 2016 vincent. All rights reserved.
//

#import "VTRateSettingVC.h"
#import "VTSampleRateSettingCell.h"
#import "VTSettingMgr.h"

@interface VTRateSettingVC () <UITableViewDataSource, UITableViewDelegate, VTSampleRateSettingCellDelegate>

@property (strong, nonatomic) NSString *headerText;
@property (strong, nonatomic) UILabel *headerLabel;
@property (strong, nonatomic) UITableView *tableView;

@end

@implementation VTRateSettingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = VTLOCALIZEDSTRING(@"采样速率");
    
    // Do any additional setup after loading the view.
    [self updateHeaderText:[VTSettingMgr sharedInstance].sampleRate];
    
    [self.view addSubview:self.tableView];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 不实时更新,界面退出时更新
- (void)viewWillDisappear:(BOOL)animated {
    VTSampleRateSettingCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    [VTSettingMgr sharedInstance].sampleRate = cell.rate;
}

- (void)updateHeaderText:(NSInteger)value {
    self.headerText = [NSString stringWithFormat:VTLOCALIZEDSTRING(@"采样率 %@/分钟"), @(value)];
}

#pragma mark - VTSampleRateSettingCellDelegate
- (void)didRateChanged:(NSInteger)value {
    [self updateHeaderText:value];
    
    UIView *headerView = [self.tableView headerViewForSection:0];
    UILabel *label = (UILabel *)[headerView viewWithTag:10086];
    if (label) {
        label.text = self.headerText;
    }
}

#pragma mark - UITableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"sampleRateSettingCell";
    
    VTSampleRateSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.rate = [VTSettingMgr sharedInstance].sampleRate;
    cell.delegate = self;
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 300, 30)];
    label.textColor = UIColorFromRGBValueAlpha(0xFFFFFF, 0.5);
    label.font = [UIFont systemFontOfSize:15];
    label.backgroundColor = [UIColor clearColor];
    [view addSubview:label];
    label.text = self.headerText;
    self.headerLabel = label;
    
    [view addSubview:label];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 82;
}

#pragma mark - Properties

- (void)setHeaderText:(NSString *)headerText {
    _headerText = headerText;
    _headerLabel.text = _headerText;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.backgroundColor = UIColorFromRGBValue(0x303030);
        _tableView.separatorColor = UIColorFromRGBValueAlpha(0xffffff, 0.2);
        
        [_tableView registerClass:[VTSampleRateSettingCell class] forCellReuseIdentifier:@"sampleRateSettingCell"];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.allowsSelection = NO;
        _tableView.tableFooterView = [UIView new];
        _tableView.bounces = NO;
    }
    return _tableView;
}

@end
