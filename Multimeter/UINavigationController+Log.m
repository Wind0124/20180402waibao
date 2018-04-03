//
//  UINavigationController+Log.m
//  SocialFinancialClient
//
//  Created by vincent on 16/5/1.
//  Copyright © 2016年 FreeDo. All rights reserved.
//

#import "UINavigationController+Log.h"
#import "NSObject+Swizzling.h"

@implementation UINavigationController (Log)

+ (void)load {
    [self vt_swizzleMethod:@selector(pushViewController:animated:) withMethod:@selector(lg_pushViewController:animated:)];
    [self vt_swizzleMethod:@selector(popViewControllerAnimated:) withMethod:@selector(lg_popViewControllerAnimated:)];
}


- (void)lg_pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    UIViewController *topVC = viewController;
    NSLog(@">>> Interceptor: %@ %@ %p", @"UINavigationController", NSStringFromSelector(_cmd), topVC);
    
    return [self lg_pushViewController:viewController animated:animated];
}

- (UIViewController *)lg_popViewControllerAnimated:(BOOL)animated {
    UIViewController *topVC = self.topViewController;
    if ([topVC isKindOfClass:NSClassFromString(@"SFCHomePageViewController")]) {
        NSLog(@"Error...");
    }
    NSLog(@">>> Interceptor: %@ %@ %p", @"UINavigationController", NSStringFromSelector(_cmd), topVC);
    return [self lg_popViewControllerAnimated:animated];
}

@end
