//
//  CBPeripheral+RSSI.m
//  Multimeter
//
//  Created by vincent on 16/4/10.
//  Copyright © 2016年 vincent. All rights reserved.
//

#import "CBPeripheral+Extra.h"
#import <objc/runtime.h>
#import "VTBlePersistTool.h"

@implementation CBPeripheral (Extra)

- (void)setScanRSSI:(NSNumber *)scanRSSIValue {
    objc_setAssociatedObject(self, @selector(scanRSSI), scanRSSIValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)scanRSSI {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setLocalName:(NSString *)localName {
    objc_setAssociatedObject(self, @selector(localName), localName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)localName {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setRemarkName:(NSString *)remarkName {
    objc_setAssociatedObject(self, @selector(remarkName), remarkName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)remarkName {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setLastUpdateTime:(NSDate *)lastUpdateTime {
    objc_setAssociatedObject(self, @selector(lastUpdateTime), lastUpdateTime, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDate *)lastUpdateTime {
    return objc_getAssociatedObject(self, _cmd);
}

- (NSString *)availableName {
    if (self.remarkName.length) {
        return self.remarkName;
    } else if (self.localName.length) {
        return self.localName;
    } else {
        return self.name;
    }
}

@end
