//
//  VTMeasureVC+ui.m
//  Multimeter
//
//  Created by Vincent on 27/09/2016.
//  Copyright © 2016 vincent. All rights reserved.
//

#import "VTMeasureVC+ui.h"

#import "NSObject+Swizzling.h"

dispatch_source_t g_timer = NULL;

@implementation VTMeasureVC (ui)

#if TARGET_IPHONE_SIMULATOR
+ (void)load {
    [self vt_swizzleMethod:@selector(viewDidAppear:) withMethod:@selector(ui_viewDidAppear:)];
    [self vt_swizzleMethod:@selector(peripheral:didUpdateValueForCharacteristic:error:) withMethod:@selector(ui_peripheral:didUpdateValueForCharacteristic:error:)];

}
#endif

#define DEC2BCD(data)   ((((data)/10)<<4)+(((data)%10)&0xF))

- (void)testData {
    //    <55120277 82380008 ffffff40 40200a00 00f0>
    //     <55120277 82380015 ff010011 04a00a00 00e9>
    //    55120277823800  15FF26001104A00A0000091
    
    //    <551202dd 453b000d ff770000 00001a00 00fe>
    
    //    <55120267 c0520001 ff330311 04600a40 00eb>
    static int count = 0;
    
    int high = arc4random() % 60;
    int low = arc4random() % 100;
    Byte highByte = DEC2BCD(high);  // 0x00
    Byte lowByte = DEC2BCD(low);    // 0x26
    Byte signByte = 0x11;
    int sign = arc4random()%3;
    if (sign==0) {
        signByte = 0x91;
    }
    int low_battery = 0;
    if (count++ % 10) {
        low_battery = 0x04;
    } else {
        low_battery = 0x04;
    }

    int dial = 0x10;
    if (count%5==0 || count%5==1) {
        lowByte=0xff;
        highByte=0xff;
    }
    
//    lowByte = 0xFF;
//    highByte = 0xFF;
//    unsigned char buf[] = {0x55, 0x12, 0x02, 0x77, 0x45, 0x3b, 0x00, 0x15, 0x07, lowByte, highByte, signByte, low_battery, 0xA0, 0x0A, 0x00, 0x00, 0x91};
//    unsigned char buf[] = {0x55, 0x12, 0x02, 0x77, 0x45, 0x0b, 0x00, dial, 0x07, lowByte, highByte, signByte, low_battery, 0xA0, 0x0A, 0x00, 0x00, 0x91};
//    unsigned char buf[] = {0x55, 0x12, 0x02, 0x77, 0xc0, 0x52, 0x00, 0x15, 0xff, lowByte, highByte, signByte, low_battery, 0xA0, 0x0A, 0x00, 0x00, 0x91};

//    unsigned char buf[] = {0x55, 0x12, 0x02, 0x77, 0x82, 0x38, 0x00, dial, 0xff, lowByte, highByte, signByte, low_battery, 0xA0, 0x0A, 0x00, 0x00, 0x91};

    // ncv
    lowByte = 0x01;
    highByte = 0x00;
    signByte = 0;
    unsigned char buf[] = {0x55, 0x12, 0x02, 0x77, 0x45, 0x0b, 0x00, dial, 0x07, lowByte, highByte, signByte, low_battery, 0xA0, 0x4A, 0x00, 0x00, 0x91};
    // XXX:
//    unsigned char buf[] = {0x55, 0x12, 0x02, 0x67, 0xc0, 0x52, 0x00, 0x01, 0xff, 0x33, 0x03, 0x11, 0x04, 0x60, 0x4a, 0x40, 0x00, 0xeb};
//    unsigned char buf[] = {0x55, 0x12, 0x02, 0x67, 0x82, 0x38, 0x00, 0x0f, 0xff, 0x39, 0x09, 0x11, 0x04, 0x60, 0x0a, 0x40, 0x00, 0xeb};
//    buf[7] = arc4random() % 16;

    NSData *demodata=[NSData dataWithBytes:buf length:sizeof(buf)];
    [self updateUIWithData:demodata];
    [self performSelector:@selector(updateVoice)];
}

static NSMutableArray *g_testDatas = nil;

- (void)loadAllDatas {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ttt" ofType:@"dat"];
    NSString *fc = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSArray *lines = [fc componentsSeparatedByString:@"\n"];
    NSMutableArray *lineDatas = [NSMutableArray new];
    
    for (NSString *l in lines) {
        NSScanner *scanner = [NSScanner scannerWithString:l];
        unsigned hex;
        NSMutableData *mdata = [NSMutableData new];
        while ([scanner isAtEnd] == NO) {
            [scanner scanHexInt:&hex];
            unsigned char cValue = (unsigned char)hex;
            [mdata appendBytes:&cValue length:1];
        }
        [lineDatas addObject:mdata];
    }
    g_testDatas = lineDatas;
}

- (void)testData2 {
    if (!g_testDatas.count) {
        [self loadAllDatas];
    }
    
    static int count = 0;
    NSData *demodata=nil;
    
    if (count < g_testDatas.count) {
        demodata = g_testDatas[count];
    } else {
        unsigned char buf[] = {0x55, 0x12, 0x02, 0x67, 0xc0, 0x52, 0x00, 0x03, 0xFF, 0x08, 0x00, 0x11, 0x84, 0xA0, 0x0A, 0x00, 0x00, 0x53};
        demodata=[NSData dataWithBytes:buf length:sizeof(buf)];

    }
    count++;
    [self updateUIWithData:demodata];
    [self performSelector:@selector(updateVoice)];
}

- (void)ui_peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
    return;
}

    
- (void)ui_viewDidAppear:(BOOL)animated {
    [self ui_viewDidAppear:animated];
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(timer, ^{
        [self doTest];
    });
    dispatch_resume(timer);
    g_timer = timer;
}

- (BOOL)isConnected {
    return YES;
}

#if TARGET_IPHONE_SIMULATOR
- (IBAction)onSwitchButtonClick:(id)sender {
    return;
}

int g_state = 0;
//static int g_innerState = 0;
//- (void)onMoreButtonClick:(id)sender {
//    g_innerState++;
//    if (g_innerState == 18) {
//        g_innerState = 1;
//    }
//    if (g_innerState <= 9) {
//        g_state = g_innerState;
//    } else {
//        g_state = 18-g_innerState;
//    }
//}

#endif

- (void)doTest {
    [self performSelector:@selector(testData)];
}

@end




