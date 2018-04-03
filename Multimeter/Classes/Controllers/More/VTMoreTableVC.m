//
//  VTMoreTableVC.m
//  Multimeter
//
//  Created by vincent on 16/4/16.
//  Copyright © 2016年 vincent. All rights reserved.
//

#import "VTMoreTableVC.h"
#import "VTBlePersistTool.h"
#import "VTChangeDeviceRemarkVC.h"
#import "VTBleManager.h"
#import <RESideMenu/RESideMenu.h>

@interface VTMoreTableVC ()

@end

@implementation VTMoreTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.title = VTLOCALIZEDSTRING(@"更多");
    self.tableView.tableFooterView = [UIView new];
}

- (void)awakeFromNib {
    self.tableView.backgroundColor = UIColorFromRGBValue(0x303030);
    self.tableView.separatorColor = UIColorFromRGBValueAlpha(0xffffff, 0.2);
}

- (void)viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"pushToRemark"]) {
        VTChangeDeviceRemarkVC *vc = segue.destinationViewController;
        vc.peripheral = self.peripheral;
    }
}

// 主动断开连接
- (void)cancelConnect {
    if (self.peripheral) {
        self.manager.delegate = nil;
        [self.manager.centralManager cancelPeripheralConnection:self.peripheral];
    }
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section==0) return 4;
    else return 3;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 300, 30)];
    label.textColor = UIColorFromRGBValueAlpha(0xFFFFFF, 0.5);
    label.font = [UIFont systemFontOfSize:15];
    label.backgroundColor = [UIColor clearColor];
    [view addSubview:label];
    
    if (section==0) {
        label.text = VTLOCALIZEDSTRING(@"设置");
    } else {
        label.text = VTLOCALIZEDSTRING(@"通用");
    }
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}


//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
//    // 显示当前名字
//    if (indexPath.section==1 && indexPath.row==0) {
//        cell.detailTextLabel.text = self.peripheral.availableName;
//    }
//    cell.backgroundColor = UIColorFromRGBValue(0x353535);
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    UITableViewCell *cell = nil;//
    if (indexPath.section==1 && indexPath.row==0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"moreFuncCell1" forIndexPath:indexPath];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"moreFuncCell" forIndexPath:indexPath];
    }
    cell.backgroundColor = UIColorFromRGBValue(0x454545);

    if (indexPath.section==0) {
        if (indexPath.row==0) {
            cell.textLabel.text = VTLOCALIZEDSTRING(@"关于");
        } else if (indexPath.row==1) {
            cell.textLabel.text = VTLOCALIZEDSTRING(@"语音播报");
        } else if (indexPath.row==2) {
            cell.textLabel.text = VTLOCALIZEDSTRING(@"采样速率");
        } else {
            cell.textLabel.text = VTLOCALIZEDSTRING(@"显示");
        }
    } else {
        if (indexPath.row==0) {
            cell.textLabel.text = VTLOCALIZEDSTRING(@"重命名");
            cell.detailTextLabel.text = self.peripheral.availableName;
        } else if (indexPath.row==1) {
            cell.textLabel.text = VTLOCALIZEDSTRING(@"解除链接");
        } else {
            cell.textLabel.text = VTLOCALIZEDSTRING(@"反馈");
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView performSelector:@selector(deselectRowAtIndexPath:animated:) withObject:indexPath afterDelay:0.5];
    
    if (indexPath.section==0) {
        if (indexPath.row==0) {
//            [self cancelConnect];
//            UINavigationController *nav = STORYBOARD_INSTANT(@"contentViewController");
//            self.sideMenuViewController.contentViewController = nav;
            [self performSegueWithIdentifier:@"pushToAbout" sender:nil];
        } else if (indexPath.row==1) {
            [self performSegueWithIdentifier:@"pushToSpeech" sender:nil];
        } else if (indexPath.row==2) {
            [self performSegueWithIdentifier:@"pushToRate" sender:nil];
        } else if (indexPath.row==3) {
            [self performSegueWithIdentifier:@"pushToDisplay" sender:nil];
        }
    } else if (indexPath.section==1) {
        if (indexPath.row==0) {
            [self performSegueWithIdentifier:@"pushToRemark" sender:nil];
        } else {
            
        }
    }
}

#pragma mark - Properties
- (VTBleManager *)manager {
    return [VTBleManager sharedInstance];
}

@end
