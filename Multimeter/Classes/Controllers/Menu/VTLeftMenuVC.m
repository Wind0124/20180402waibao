//
//  VTLeftMenuVC.m
//  Multimeter
//
//  Created by vincent on 16/4/12.
//  Copyright © 2016年 vincent. All rights reserved.
//

#import "VTLeftMenuVC.h"
#import "RESideMenu.h"

#import "VTFileListTableVC.h"

@interface VTLeftMenuVC ()<UITableViewDataSource, UITableViewDelegate, RESideMenuDelegate>

@property (strong, readwrite, nonatomic) UITableView *tableView;

@end

@implementation VTLeftMenuVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 90 * 3) style:UITableViewStylePlain];
        tableView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.opaque = NO;
        tableView.backgroundColor = [UIColor clearColor];
        tableView.backgroundView = nil;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.bounces = NO;
        tableView.scrollsToTop = NO;
        tableView;
    });
    [self.view addSubview:self.tableView];
    self.view.backgroundColor = UIColorFromRGBValue(0x252525);
}

#pragma mark -
#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0: {
            VTFileListTableVC *vc = STORYBOARD_INSTANT(@"VTFileListTableVC");
            UINavigationController *nav = (UINavigationController *)self.sideMenuViewController.contentViewController;
            [nav pushViewController:vc animated:YES];
            [self.sideMenuViewController hideMenuViewController];
            break;
        }
        case 1: {
            UIViewController *vc = STORYBOARD_INSTANT(@"aboutViewController");
            UINavigationController *nav = (UINavigationController *)self.sideMenuViewController.contentViewController;
            [nav pushViewController:vc animated:YES];
            [self.sideMenuViewController hideMenuViewController];
            break;
        }
        case 2: {
            UIViewController *vc = STORYBOARD_INSTANT(@"helpViewController");
            UINavigationController *nav = (UINavigationController *)self.sideMenuViewController.contentViewController;
            [nav pushViewController:vc animated:YES];
            [self.sideMenuViewController hideMenuViewController];
            break;
        }
        default:
            break;
    }
}

#pragma mark -
#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:21];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.highlightedTextColor = [UIColor lightGrayColor];
        cell.selectedBackgroundView = [[UIView alloc] init];
    }
    
    NSArray *titles = @[VTLOCALIZEDSTRING(@"文件"), VTLOCALIZEDSTRING(@"关于"), VTLOCALIZEDSTRING(@"帮助"), ];
    NSArray *images = @[@"icon_file", @"icon_about", @"icon_help"];
    cell.textLabel.text = titles[indexPath.row];
    cell.imageView.image = [UIImage imageNamed:images[indexPath.row]];
    
    return cell;
}

@end
