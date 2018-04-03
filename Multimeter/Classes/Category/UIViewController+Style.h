//
//  UIViewController+Style.h
//  Multimeter
//
//  Created by vincent on 16/4/16.
//  Copyright © 2016年 vincent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Style)

- (void)setLeftBarItemStyle;
- (void)onBackBarItemClick:(id)sender;

- (void)showHUDViewWithInfo:(NSString *)info;
- (void)showSuccessHUDViewWithStatus:(NSString *)status;
- (void)showFailHUDViewWithStatus;
- (void)dismissHUDView;

@end
