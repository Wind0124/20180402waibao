//
//  VTSpeechSettingVC.m
//  Multimeter
//
//  Created by Vincent on 25/09/2016.
//  Copyright © 2016 vincent. All rights reserved.
//

#import "VTSpeechSettingVC.h"
#import "VTSwitchCell.h"
#import "VTSettingMgr.h"

@interface VTSpeechSettingVC ()<UITableViewDataSource, UITableViewDelegate, VTSwitchCellDelegate>

@property (strong, nonatomic) UITableView *tableView;

@end

@implementation VTSpeechSettingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = VTLOCALIZEDSTRING(@"语音播报");
    [self.view addSubview:self.tableView];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - VTSwitchCellDelegate
- (void)didSwitch:(VTSwitchCell *)cell on:(BOOL)onOrOff {
    [VTSettingMgr sharedInstance].speechEnabled = onOrOff;
}

#pragma mark - UITableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"speechSetingSwitchCell";
    
    VTSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.tip = VTLOCALIZEDSTRING(@"语音播报");
    cell.isSwitchOn = [VTSettingMgr sharedInstance].speechEnabled;
    cell.delegate = self;
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 300, 30)];
//    label.textColor = UIColorFromRGBValueAlpha(0xFFFFFF, 0.5);
//    label.font = [UIFont systemFontOfSize:15];
//    label.backgroundColor = [UIColor clearColor];
//    [view addSubview:label];
//    
//    label.text = VTLOCALIZEDSTRING(@"设置");
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

#pragma mark - UITableView Delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - Properties

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.backgroundColor = UIColorFromRGBValue(0x303030);
        _tableView.separatorColor = UIColorFromRGBValueAlpha(0xffffff, 0.2);

        [_tableView registerClass:[VTSwitchCell class] forCellReuseIdentifier:@"speechSetingSwitchCell"];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.allowsSelection = NO;
        _tableView.tableFooterView = [UIView new];
        _tableView.bounces = NO;
    }
    return _tableView;
}

@end
