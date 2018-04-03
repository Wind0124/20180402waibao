//
//  UIViewController+Style.m
//  Multimeter
//
//  Created by vincent on 16/4/16.
//  Copyright © 2016年 vincent. All rights reserved.
//

#import "UIViewController+Style.h"
#import "NSObject+Swizzling.h"
#import "RESideMenu.h"
//#import "VTRootVC.h"
#import <SVProgressHUD.h>

@implementation UIViewController (Style)

+ (void)load {
//    [self vt_swizzleMethod:@selector(preferredStatusBarStyle) withMethod:@selector(vt_preferredStatusBarStyle)];
//    [self vt_swizzleMethod:@selector(viewDidLoad) withMethod:@selector(vt_viewDidLoad)];
    [self vt_swizzleMethod:@selector(shouldAutorotate) withMethod:@selector(vt_shouldAutorotate)];
    [self vt_swizzleMethod:@selector(supportedInterfaceOrientations) withMethod:@selector(vt_supportedInterfaceOrientations)];
    
    [self vt_swizzleMethod:@selector(prefersStatusBarHidden) withMethod:@selector(vt_prefersStatusBarHidden)];
}

- (BOOL)isSameCorlor:(UIColor *)color {
    if (CGColorEqualToColor(self.view.backgroundColor.CGColor, color.CGColor)) {
        return YES;
    } else {
        return NO;
    }

}

- (void)vt_viewDidLoad {
    NSLog(@"self.view.backgroundColor:%@", self.view.backgroundColor);
    if (self.view.backgroundColor == nil) {
        NSLog(@"back:%@", self.view.backgroundColor);
        self.view.backgroundColor = UIColorFromRGBValue(0x303030);
    }
    if ([self isSameCorlor:[UIColor clearColor]]||[self isSameCorlor:[UIColor whiteColor]]) {
        self.view.backgroundColor = UIColorFromRGBValue(0x303030);
    }
    [self vt_viewDidLoad];
}

- (void)setLeftBarItemStyle {
    UIBarButtonItem *buttonImage =
    [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed: @"icon_back" ]
                                     style: UIBarButtonItemStylePlain
                                    target: self
                                    action: @selector(onBackBarItemClick:)
     ];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -10;
    self.navigationItem.leftBarButtonItems = @[negativeSpacer, buttonImage];
}

- (void)onBackBarItemClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

//- (UIStatusBarStyle)preferredStatusBarStyle {
//    return UIStatusBarStyleLightContent;
//}
- (void)showHUDViewWithInfo:(NSString *)info {
    if (!info) {
        [SVProgressHUD show];
    } else {
        [SVProgressHUD showWithStatus:info];
    }
}

- (void)showSuccessHUDViewWithStatus:(NSString *)status {
    [SVProgressHUD showSuccessWithStatus:status];
}

- (void)showFailHUDViewWithStatus:(NSString *)status {
    [SVProgressHUD showErrorWithStatus:status];
}

- (void)dismissHUDView {
    [SVProgressHUD dismiss];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

// rotate
- (BOOL)vt_shouldAutorotate {
    NSString *clsName = NSStringFromClass(self.class);
//    NSLog(@"auto:clsName:%@", clsName);

    if ([clsName isEqualToString:@"UINavigationController"]) {
        return [[(UINavigationController *)self viewControllers].lastObject shouldAutorotate];
    }
    if ([clsName isEqualToString:@"VTRootVC"]) {
        return [[(RESideMenu *)self contentViewController] shouldAutorotate];
    }

    if ([self respondsToSelector:@selector(my_shouldAutorotate)]) {
        return [self performSelector:@selector(my_shouldAutorotate)];
    }
    return NO;
}

//
- (UIInterfaceOrientationMask)vt_supportedInterfaceOrientations {
    NSString *clsName = NSStringFromClass(self.class);

//    NSLog(@"sup:clsName:%@", clsName);
    if ([clsName isEqualToString:@"UINavigationController"]) {
        return [[(UINavigationController *)self viewControllers].lastObject supportedInterfaceOrientations];
    }
    if ([clsName isEqualToString:@"VTRootVC"]) {
        return [[(RESideMenu *)self contentViewController] supportedInterfaceOrientations];
    }
    if ([self respondsToSelector:@selector(my_supportedInterfaceOrientations)]) {
        return [self performSelector:@selector(my_supportedInterfaceOrientations)];
    }
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)vt_prefersStatusBarHidden {
    return NO;
}

#pragma clang diagnostic pop

@end
