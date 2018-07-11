//
//  VTBleManager.m
//  Multimeter
//
//  Created by vincent on 16/4/12.
//  Copyright © 2016年 vincent. All rights reserved.
//

#import "VTBleManager.h"
#import <objc/runtime.h>
#import "VTBlePersistTool.h"
#import "UIAlertView+Blocks.h"

@interface VTBleManager()<CBCentralManagerDelegate>

@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) NSTimeInterval timeout;
@property (strong, nonatomic, readwrite) NSMutableArray *peripherals;

// 一直扫描
@property (assign, nonatomic) BOOL isScanRepeat;
// 当前是否正在连接设备
@property (assign, nonatomic) BOOL isConnecting;

@end

@implementation VTBleManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static VTBleManager *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [VTBleManager new];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (!self) return self;
    
    _peripherals = [NSMutableArray new];
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    return self;
}

//- (void)setDelegate:(id<VTBleManagerDelegate>)delegate {
//    if (![self.delegate conformsToProtocol:@protocol(VTBleManagerDelegate)]) {
//        NSAssert(0, @"delegate must confirm to VTBleManagerDelegate");
//    }
//}

#pragma mark - Public
- (void)scanWithTimeOut:(NSTimeInterval)timeout {
    self.isScanRepeat = NO;
    self.isConnecting = NO;
    [self.centralManager stopScan];
    [self.centralManager scanForPeripheralsWithServices:nil options:nil];
    self.timeout = timeout;
    [self resetTimer];
}

- (void)rescanWithTimeOut:(NSTimeInterval)timeout {
    [self.peripherals removeAllObjects];
    [self scanWithTimeOut:timeout];
}

// 不停扫描
- (void)scanRepeatWithInterval:(NSTimeInterval)timeInterval {
    [self.centralManager stopScan];
    self.isScanRepeat = YES;
    self.isConnecting = NO;
    [self.centralManager scanForPeripheralsWithServices:nil options:nil];
    self.timeout = timeInterval;
    [self resetTimer];
}

- (void)rescanRepeatWithInterval:(NSTimeInterval)timeInterval {
    [self.peripherals removeAllObjects];
    [self scanRepeatWithInterval:timeInterval];
}

- (void)connectPeripheral:(CBPeripheral *)peripheral withTimeOut:(NSTimeInterval)timeout {
//    if (peripheral == nil) return ;
    
    self.timeout = timeout;
    [self.centralManager stopScan];
    self.isScanRepeat = NO;
    self.isConnecting = YES;
    
    // 只能连接一个设备
    if (self.connectedPeripheral) {
        [self.centralManager cancelPeripheralConnection:self.connectedPeripheral];
        self.connectedPeripheral = nil;
    }
    [self.centralManager connectPeripheral:peripheral options:nil];
    [self resetTimer];
}

#pragma mark - Timer
- (void)resetTimer {
    [_timer invalidate];
    _timer = [NSTimer scheduledTimerWithTimeInterval:self.timeout target:self selector:@selector(timerAction) userInfo:nil repeats:NO];
}

- (void)releaseTimer {
    [_timer invalidate];
    _timer = nil;
}

- (void)timerAction {
    if (self.isConnecting) {
        // 仍没有连接上
        if (!self.connectedPeripheral) {
            VTLog(@"连接设备超时");
            if ([self.delegate respondsToSelector:@selector(centralManager:didFailToConnectPeripheral:error:)]) {
                [self.delegate centralManager:self.centralManager didFailToConnectPeripheral:self.connectedPeripheral error:nil];
            }
        }
    }

    if (self.isScanRepeat) {
        // 校验时间,超过则重新刷新列表
        NSDate *now = [NSDate date];
        BOOL needRefresh = NO;
        
        for (NSInteger i=self.peripherals.count -1; i>=0; i--) {
            CBPeripheral *peripheral = self.peripherals[i];
            NSTimeInterval interval = [now timeIntervalSinceDate:peripheral.lastUpdateTime];
            if (interval >= TIMEOUT_BLE_LIVE) {
                [self.peripherals removeObjectAtIndex:i];
                needRefresh = YES;
            }
        }
        if (needRefresh && [self.delegate respondsToSelector:@selector(didPeripheralOfflineAtBleManager:)]) {
            [self.delegate didPeripheralOfflineAtBleManager:self];
        }
        [self scanRepeatWithInterval:self.timeout];
        return;
    }
    [self.centralManager stopScan];
    // 仍没有扫描到设备
    if (!self.peripherals.count) {
        if ([self.delegate respondsToSelector:@selector(didFailToDiscoverPeripheralAtBleManager:)]) {
            [self.delegate didFailToDiscoverPeripheralAtBleManager:self];
        }
    }
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    if ([self.delegate respondsToSelector:_cmd]) {
        [self.delegate centralManagerDidUpdateState:central];
        return;
    }
    // 默认处理
    if (central.state != CBCentralManagerStatePoweredOn) {
        [UIAlertView showWithTitle:nil message:VTLOCALIZEDSTRING(@"手机蓝牙未开启，请打开手机蓝牙") cancelButtonTitle:VTLOCALIZEDSTRING(@"知道了") otherButtonTitles:nil tapBlock:^(UIAlertView * _Nonnull alertView, NSInteger buttonIndex) {
        }];
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI {
    
    NSLog(@"peripheral name: %@, %@", peripheral.name, advertisementData[@"kCBAdvDataLocalName"]);
#ifndef TEST_BLE_DISCOVER
    // Wind 新设备的名称不一样
    if (![kDeviceIdentifier2 hasSuffix:peripheral.name]) return;
#endif
    
    peripheral.scanRSSI = RSSI;
    peripheral.localName = advertisementData[@"kCBAdvDataLocalName"];
    peripheral.remarkName = [VTBlePersistTool fetchRemarkFromDBWithUUID:peripheral.identifier.UUIDString];
    peripheral.lastUpdateTime = [NSDate date];
    
//    VTLog(@"remarkName:%@", peripheral.remarkName);
    
    NSInteger index = NSNotFound;
    
    for (CBPeripheral *p in self.peripherals) {
        if ([p.identifier.UUIDString isEqualToString:peripheral.identifier.UUIDString]) {
            index = [self.peripherals indexOfObject:p];
            break;
        }
    }
    if (index != NSNotFound) {
        [self.peripherals replaceObjectAtIndex:index withObject:peripheral];
    } else {
        [self.peripherals addObject:peripheral];
    }
    
    if ([self.delegate respondsToSelector:_cmd]) {
        [self.delegate centralManager:central didDiscoverPeripheral:peripheral advertisementData:advertisementData RSSI:RSSI];
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    VTLog(@"连接设备成功");
    // 尝试获取一次记录的名字
    if (!peripheral.remarkName) {
        peripheral.remarkName = [VTBlePersistTool fetchRemarkFromDBWithUUID:peripheral.identifier.UUIDString];
    }
    self.connectedPeripheral = peripheral;
    [self releaseTimer];
    [self.centralManager stopScan];
    [VTBlePersistTool saveLastConnectIdentifier:peripheral.identifier];
    
    if ([self.delegate respondsToSelector:_cmd]) {
        [self.delegate centralManager:central didConnectPeripheral:peripheral];
    }
}

//
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error {
    VTLog(@"连接设备失败");
    if ([self.delegate respondsToSelector:_cmd]) {
        [self.delegate centralManager:central didFailToConnectPeripheral:peripheral error:error];
    }
}
//
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error {
    VTLog(@"断开设备");
    if ([self.delegate respondsToSelector:_cmd]) {
        [self.delegate centralManager:central didDisconnectPeripheral:peripheral error:error];
    }
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    [invocation invokeWithTarget:self.delegate];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    
    
    return [self.delegate methodSignatureForSelector:sel];
}

//+ (BOOL)respondsToSelector:(SEL)aSelector {
//    BOOL isRespond = NO;
//    if ([super respondsToSelector:aSelector]) {
//        isRespond = YES;
//    }
//    if (!isRespond) {
//        NSString *str = NSStringFromSelector(aSelector);
//        if ([[str substringToIndex:strlen("centralManager")] isEqualToString:@"centralManager"]) {
//            return YES;
//        }
//    }
//    
//    return isRespond;
//}

@end
