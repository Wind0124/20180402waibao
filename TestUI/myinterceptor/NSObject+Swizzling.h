//
//  NSObject+Swizzling.h
//  Swizzling
//
//  Created by vincent on 16/3/23.
//  Copyright © 2016年 XXX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Swizzling)

+ (void)vt_swizzleMethod:(SEL)originSel withMethod:(SEL)newSel;
+ (void)vt_swizzleClassMethod:(SEL)originSel withClassMethod:(SEL)newSel;

@end
