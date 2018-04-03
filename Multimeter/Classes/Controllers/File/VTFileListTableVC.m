//
//  VTFileListTableVC.m
//  Multimeter
//
//  Created by vincent on 16/4/16.
//  Copyright © 2016年 vincent. All rights reserved.
//

#import "VTFileListTableVC.h"
#import "VTBlePersistTool.h"
#import "VTTableDetailVC.h"
#import "UIAlertView+Blocks.h"

@interface VTFileListTableVC ()

@property (strong, nonatomic) NSMutableArray *dataSource;
@property (strong, nonatomic) VTBleFileModel *selectedModel;

@end

@implementation VTFileListTableVC {
    BOOL _isDealingLongPress;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataSource = [[[[VTBlePersistTool fetchIndexInfos] reverseObjectEnumerator] allObjects] mutableCopy];
    [self.tableView reloadData];
    
    self.tableView.tableFooterView = [UIView new];
    self.tableView.rowHeight = 80;
    
    self.title = VTLOCALIZEDSTRING(@"文件");
    self.view.backgroundColor = UIColorFromRGBValue(0x303030);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Datasource

- (void)removeDataAtIndex:(NSInteger)index {
    VTBleFileModel *model = self.dataSource[index];
    [VTBlePersistTool removeDataWithIndexId:model.id];
    [self.dataSource removeObjectAtIndex:index];
}

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    if ([segue.identifier isEqualToString:@"pushToFileDetail"]) {
//        VTFileDetailVC *vc = segue.destinationViewController;
//        vc.fileModel = self.selectedModel;
//    }
//}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"fileReuseCell" forIndexPath:indexPath];
    
    if (cell.tag!=0x11) {
        UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        [cell addGestureRecognizer:recognizer];
        cell.tag = 0x11;
    }
    
    VTBleFileModel *model = self.dataSource[indexPath.row];
    
    cell.textLabel.text = model.fileName;
    cell.detailTextLabel.text = model.func;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [self removeDataAtIndex:indexPath.row];
//        [self.tableView reloadData];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView performSelector:@selector(deselectRowAtIndexPath:animated:) withObject:indexPath afterDelay:0.5];
    self.selectedModel = self.dataSource[indexPath.row];
    
//    VTTableDetailVC *vc =  MS_STORYBOARD_INSTANT(@"VTTableDetailVC");
    VTTableDetailVC *vc = [VTTableDetailVC new];
    vc.fileModel = self.selectedModel;
    [self.navigationController pushViewController:vc animated:YES];
//    [self performSegueWithIdentifier:@"pushToFileDetail" sender:nil];
}


- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer {
    recognizer.enabled = NO;
    if (_isDealingLongPress) return;
    
    _isDealingLongPress = YES;
    
    UITableViewCell *cell = (UITableViewCell *)recognizer.view;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    // 弹窗输入
    [UIAlertView showWithTitle:VTLOCALIZEDSTRING(@"输入文字") message:@"" style:UIAlertViewStylePlainTextInput cancelButtonTitle:VTLOCALIZEDSTRING(@"取消") otherButtonTitles:@[VTLOCALIZEDSTRING(@"确定")] tapBlock:^(UIAlertView * alertView, NSInteger buttonIndex) {
        if (buttonIndex==0) {
            _isDealingLongPress = NO;
            recognizer.enabled = YES;
        }
        
        UITextField *field = [alertView textFieldAtIndex:0];
        NSString *content = field.text;
        
        VTBleFileModel *model = self.dataSource[indexPath.row];
        model.fileName = content;
        [self.tableView reloadData];
        
        [VTBlePersistTool updateIndexFile:model];
        
        _isDealingLongPress = NO;
        recognizer.enabled = YES;
    }];
}

@end
