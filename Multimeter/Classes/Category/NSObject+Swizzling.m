//
//  NSObject+Swizzling.m
//  Swizzling
//
//  Created by vincent on 16/3/23.
//  Copyright © 2016年 XXX. All rights reserved.
//

#import "NSObject+Swizzling.h"
#import <objc/runtime.h>

@implementation NSObject (Swizzling)

+ (void)vt_swizzleMethod:(SEL)originSel withMethod:(SEL)newSel {
    Class class = self;

    Method originMethod = class_getInstanceMethod(class, originSel);
    Method newMethod = class_getInstanceMethod(class, newSel);
    
    if (class_addMethod(class,
                        newSel,
                        method_getImplementation(newMethod),
                        method_getTypeEncoding(originMethod))) {
        class_replaceMethod(class,
                            newSel,
                            method_getImplementation(originMethod),
                            method_getTypeEncoding(originMethod));
    } else {
        method_exchangeImplementations(originMethod, newMethod);
    }
}

+ (void)vt_swizzleClassMethod:(SEL)originSel withClassMethod:(SEL)newSel {
    [object_getClass((id)self) vt_swizzleMethod:originSel withMethod:newSel];
    return;
}

@end
