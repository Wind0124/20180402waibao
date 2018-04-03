//
//  AppDelegate+Log.m
//  Swizzling
//
//  Created by vincent on 16/3/8.
//  Copyright © 2016年 XXX. All rights reserved.
//

#import "AppDelegate+Log.h"
#import "NSObject+Swizzling.h"
#import "DCIntrospect.h"
#import "VTSpeechMgr.h"
#import "VoiceListTestVC.h"
#import "VTMoreTableVC.h"

#import "VTBleDataParser.h"
#import "TestBlendImageVC.h"

#import "CrcTool.h"

#if DEBUG

#define TEST_STORYBOARD_INSTANT(id)  [[UIStoryboard storyboardWithName:@"test" bundle:nil] instantiateViewControllerWithIdentifier:id];

static void _runLoopObserverCallback(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info);

@implementation AppDelegate (Log)

+ (void)load {
    [self vt_swizzleMethod:@selector(application:didFinishLaunchingWithOptions:) withMethod:@selector(lg_application:didFinishLaunchingWithOptions:)];
}

- (void)testSaySomethingLoud {
    VoiceListTestVC *vc = [VoiceListTestVC new];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
}

// 去除多余的0
- (NSString *)trimData:(NSString *)text {
    // 整数部分,和小数部分
    NSInteger intValue=0, floatValue=0;
    BOOL isPositive=YES;
    
    NSRange range = [text rangeOfString:@"-"];
    if (range.location == 0) {
        isPositive = NO;
        text = [text substringFromIndex:1];
    }
    
    NSArray *cps = [text componentsSeparatedByString:@"."];
    if (cps.count>=2) {
        intValue = atoi([cps[0] UTF8String]);
        floatValue = atoi([cps[1] UTF8String]);
    } else {
        intValue = atoi([text UTF8String]);
    }
    NSString *res = nil;
    if (floatValue != 0.0) {
        res = [NSString stringWithFormat:@"%@.%@", @(intValue), @(floatValue)];
    } else {
        res = [NSString stringWithFormat:@"%@", @(intValue)];
    }
    if (!isPositive) {
        res = [NSString stringWithFormat:@"-%@", res];
    }
    NSLog(@"res:%@", res);
    return res;
}


// 读unit
- (NSString *)unitSpeech:(NSString *)text {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Speech" ofType:@"plist"];
    NSDictionary *rootDict = [NSDictionary dictionaryWithContentsOfFile:path];
    if (rootDict[text]) {
        return rootDict[text];
    }
    return text;
}

- (void)testCRC {
//    unsigned char datas[] = {0x55, 0x12, 0x02, 0x67, 0xC0, 0x52, 0x00, 0x03, 0xFF, 0x92, 0x05, 0x01 ,0x80, 0xA0, 0x0A, 0x20, 0x00};
    unsigned char datas[] = {0x55, 0x12, 0x02, 0x67, 0xC0, 0x52, 0x00, 0x00, 0x73, 0x55, 0x12, 0x02 ,0x67, 0xC0, 0x52, 0x00, 0x03};
    
//    55 12 02 67 C0 52 00 00 73 55 12 02 67 C0 52 00 03 FF 39 00 11 84 A0 0A 00 00 EC
    
    unsigned char crc8 = CRC8_Table(datas, sizeof(datas));
    NSLog(@"crc: %02x", crc8); // 0x75;
}

- (void)testAllTrim {
    [self trimData:@"0800.22"];
    [self trimData:@"0800.00"];
    [self trimData:@"0800.01"];
    [self trimData:@"0800.22"];
    [self trimData:@"-0800."];
    [self trimData:@"-000.0800"];
}

- (void)testUnitSpeech {
    NSLog(@"KV-> %@", [VTBleDataParser unitSpeech:@"KV"]);
    NSLog(@"mV-> %@", [VTBleDataParser unitSpeech:@"mV"]);
    NSLog(@"μV-> %@", [VTBleDataParser unitSpeech:@"μV"]);
}

- (void)testMoreViewController {
    VTMoreTableVC *vc = STORYBOARD_INSTANT(@"VTMoreTableVC");
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
}

- (void)testMeasure {
    UIViewController *vc = STORYBOARD_INSTANT(@"VTMeasureVC");
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
}

- (void)testBlendImage {
    TestBlendImageVC *vc = TEST_STORYBOARD_INSTANT(@"TestBlendImageVC");
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
}

- (void)testFloatPrint {
    double floatValue = 77.7;
    NSLog(@"s:%@", [@(77.7) stringValue]);
    NSLog(@"s:%@", [@(77.8) stringValue]);
    NSLog(@"s:%@", [@(77.9) stringValue]);
    NSLog(@"s:%@", [@(77.0) stringValue]);
    NSLog(@"s:%@", [@(77.1) stringValue]);
    NSLog(@"s:%@", [@(77.2) stringValue]);
    NSLog(@"s:%@", [@(78.9) stringValue]);
    NSLog(@"s:%@", [@(78.1) stringValue]);
    NSLog(@"s:%@", [@(1.9) stringValue]);
    NSLog(@"s:%@", [@(1.1) stringValue]);
    
    NSLog(@"s:%@", [@(1.1) stringValue]);
//    NSLog(@"s:%0f", floatValue);
}

- (BOOL)lg_application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"Home directory: %@", NSHomeDirectory());
    NSLog(@"bundle: %@", [NSBundle allBundles]);
    NSLog(@"frameworks: %@", [NSBundle allFrameworks]);
    
//    [self testCRC];
    
#if TARGET_IPHONE_SIMULATOR
    [[DCIntrospect sharedIntrospector] start];
#endif
    
//    [self performSelector:@selector(setupStyle)];
//    [self testAllTrim];
//    [self testSaySomethingLoud];
//    [self testMoreViewController];
//    [self testUnitSpeech];
//    [self testMeasure];
//    [self testBlendImage];
//    [self testFloatPrint];
    BOOL res = YES;
    res = [self lg_application:application didFinishLaunchingWithOptions:launchOptions];
    
    // always call after makeKeyAndDisplay.

//    [self registerRunLoopObserver];
    return res;
}

- (void)registerRunLoopObserver {
    static CFRunLoopObserverRef observer;

    // defer the commit of the transaction so we can add more during the current runloop iteration
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    CFOptionFlags activities = kCFRunLoopAllActivities;//(kCFRunLoopBeforeWaiting | // before the run loop starts sleeping
                                //kCFRunLoopExit);          // before exiting a runloop run
    CFRunLoopObserverContext context = {
        0,           // version
        (__bridge void *)self,  // info
        &CFRetain,   // retain
        &CFRelease,  // release
        NULL         // copyDescription
    };
    
    observer = CFRunLoopObserverCreate(kCFAllocatorDefault,        // allocator
                                       activities,  // activities
                                       YES,         // repeats
                                       INT_MAX,     // order after CA transaction commits
                                       &_runLoopObserverCallback,  // callback
                                       &context);   // context
    CFRunLoopAddObserver(runLoop, observer, kCFRunLoopCommonModes);
    CFRelease(observer);
}

@end

static void _runLoopObserverCallback(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
    switch (activity) {
            //The entrance of the run loop, before entering the event processing loop.
            //This activity occurs once for each call to CFRunLoopRun and CFRunLoopRunInMode
        case kCFRunLoopEntry:
            NSLog(@">>> Runloop: kCFRunLoopEntry");
            break;
            //Inside the event processing loop before any timers are processed
        case kCFRunLoopBeforeTimers:
            NSLog(@">>> Runloop: kCFRunLoopBeforeTimers");
            break;
            //Inside the event processing loop before any sources are processed
        case kCFRunLoopBeforeSources:
            NSLog(@">>> Runloop: kCFRunLoopBeforeSources");
            break;
            //Inside the event processing loop before the run loop sleeps, waiting for a source or timer to fire.
            //This activity does not occur if CFRunLoopRunInMode is called with a timeout of 0 seconds.
            //It also does not occur in a particular iteration of the event processing loop if a version 0 source fires
        case kCFRunLoopBeforeWaiting:
            NSLog(@">>> Runloop: kCFRunLoopBeforeWaiting");
            break;
            //Inside the event processing loop after the run loop wakes up, but before processing the event that woke it up.
            //This activity occurs only if the run loop did in fact go to sleep during the current loop
        case kCFRunLoopAfterWaiting:
            NSLog(@">>> Runloop: kCFRunLoopAfterWaiting");
            break;
            //The exit of the run loop, after exiting the event processing loop.
            //This activity occurs once for each call to CFRunLoopRun and CFRunLoopRunInMode
        case kCFRunLoopExit:
            NSLog(@">>> Runloop: kCFRunLoopExit");
            break;
            /*
             A combination of all the preceding stages
             case kCFRunLoopAllActivities:
             break;
             */
        default:  
            break;  
    }
}

#endif
