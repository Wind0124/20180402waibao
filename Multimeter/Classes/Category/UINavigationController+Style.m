//
//  UINavigationController+Style.m
//  Multimeter
//
//  Created by vincent on 16/4/16.
//  Copyright © 2016年 vincent. All rights reserved.
//

#import "NSObject+Swizzling.h"
#import "UINavigationController+Style.h"
#import "UIViewController+Style.h"

@implementation UINavigationController (Style)

+ (void)load {
    [self vt_swizzleMethod:@selector(pushViewController:animated:) withMethod:@selector(vt_pushViewController:animated:)];
//    [self vt_swizzleMethod:@selector(shouldAutorotate) withMethod:@selector(vt_shouldAutorotate)];
//    [self vt_swizzleMethod:@selector(supportedInterfaceOrientations) withMethod:@selector(vt_supportedInterfaceOrientations)];
}

- (void)vt_pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.viewControllers.count>0) {
        [viewController setLeftBarItemStyle];
    }
    [self vt_pushViewController:viewController animated:animated];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

// rotate
//- (BOOL)vt_shouldAutorotate {
//    NSString *clsName = NSStringFromClass(self.class);
//    
//    if ([clsName isEqualToString:@"UINavigationController"]) {
//        return [[(UINavigationController *)self viewControllers].lastObject shouldAutorotate];
//    }
//    return [self vt_shouldAutorotate];
//}
//
//- (UIInterfaceOrientationMask)vt_supportedInterfaceOrientations {
//    NSString *clsName = NSStringFromClass(self.class);
//    
//    if ([clsName isEqualToString:@"UINavigationController"]) {
//        return [[(UINavigationController *)self viewControllers].lastObject supportedInterfaceOrientations];
//    }
//
//    return [self vt_supportedInterfaceOrientations];
//}

@end
