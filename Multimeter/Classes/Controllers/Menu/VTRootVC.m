//
//  VTRootVC.m
//  Multimeter
//
//  Created by vincent on 16/4/12.
//  Copyright © 2016年 vincent. All rights reserved.
//

#import "VTRootVC.h"
#import "VTMeasureVC.h"
#import "VTBlePersistTool.h"

@interface VTRootVC ()<RESideMenuDelegate>

@end

@implementation VTRootVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)awakeFromNib {
    self.menuPreferredStatusBarStyle = UIStatusBarStyleLightContent;
    self.parallaxEnabled = NO;
    self.scaleContentView = YES;
    self.contentViewScaleValue = 0.95;
//    self.contentViewScaleValue = 1;
    self.scaleMenuView = NO;
    self.contentViewShadowEnabled = YES;
    self.contentViewShadowRadius = 4.5;
    
    // 根据上次连接成功记录进行跳转
    NSUUID *uuid = [VTBlePersistTool getLastConnect];
    if (!uuid) {
        self.contentViewController = STORYBOARD_INSTANT(@"contentViewController");
    }
    else {
        self.contentViewController = STORYBOARD_INSTANT(@"measureNav");
    }
    
    self.leftMenuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"leftMenuViewController"];
//    self.backgroundImage = [UIImage imageNamed:@"Stars"];
    self.view.backgroundColor = UIColorFromRGBValue(0x1c1c1c);
    self.delegate = self;
}

#pragma mark -
#pragma mark RESideMenu Delegate

- (void)sideMenu:(RESideMenu *)sideMenu willShowMenuViewController:(UIViewController *)menuViewController
{
    NSLog(@"willShowMenuViewController: %@", NSStringFromClass([menuViewController class]));
}

- (void)sideMenu:(RESideMenu *)sideMenu didShowMenuViewController:(UIViewController *)menuViewController
{
    NSLog(@"didShowMenuViewController: %@", NSStringFromClass([menuViewController class]));
}

- (void)sideMenu:(RESideMenu *)sideMenu willHideMenuViewController:(UIViewController *)menuViewController
{
    NSLog(@"willHideMenuViewController: %@", NSStringFromClass([menuViewController class]));
}

- (void)sideMenu:(RESideMenu *)sideMenu didHideMenuViewController:(UIViewController *)menuViewController
{
    NSLog(@"didHideMenuViewController: %@", NSStringFromClass([menuViewController class]));
}

@end
