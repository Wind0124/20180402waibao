//
//  VTOperationButton.h
//  Multimeter
//
//  Created by vincent on 16/4/23.
//  Copyright © 2016年 vincent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VTOperationButton : UIButton

@property (nonatomic, assign) BOOL scale;
- (void)setBadgeText:(NSString *)text;

@end
