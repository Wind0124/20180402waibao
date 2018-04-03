//
//  VTScanVC.m
//  Multimeter
//
//  Created by vincent on 16/4/12.
//  Copyright © 2016年 vincent. All rights reserved.
//

#import "VTScanVC.h"
#import "RESideMenu.h"
#import "VTBleManager.h"
#import "UIAlertView+Blocks.h"

#import "XHRadarView.h"

static BOOL gIsFirstLoadBle = YES;

@interface VTScanVC ()<UITabBarDelegate,VTBleManagerDelegate>

@property (weak, nonatomic) IBOutlet UIView *notFountView;
@property (weak, nonatomic) IBOutlet UIView *defaultView;
@property (weak, nonatomic) IBOutlet UIView *scanView;

@property (weak, nonatomic) IBOutlet UIButton *scanButton;

@property (weak, nonatomic) IBOutlet UIView *radarPlaceHolder;
@property (strong, nonatomic) XHRadarView *radarView;

// 是否正在scan，如果不是正在scan，就算扫描到设备,也不处理
@property (assign, nonatomic) BOOL isScanning;

@end

@implementation VTScanVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    self.title = infoDict[@"CFBundleDisplayName"];
//    self.title = VTLOCALIZEDSTRING(@"Multimeter");
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)viewDidAppear:(BOOL)animated {
    self.manager.delegate = self;
    
    if (!_radarView) {
        _radarView = [[XHRadarView alloc] initWithFrame:self.radarPlaceHolder.bounds];
        _radarView.radius = CGRectGetWidth(self.radarPlaceHolder.bounds)/2.0-1;
        _radarView.backgroundColor = UIColorFromRGBValue(0x303030);
        _radarView.backgroundImage = [UIImage imageNamed:@"net"];
        _radarView.indicatorStartColor = UIColorFromRGBValueAlpha(0xc4292c,0.7);
        _radarView.indicatorEndColor = UIColorFromRGBValueAlpha(0x000000,0.0);
        [self.radarPlaceHolder addSubview:_radarView];
    }
//    [_radarView scan];
//    [self stopScan];
    if (!gIsFirstLoadBle) {
        [self updateBleStateManual];
    } else {
        gIsFirstLoadBle = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [self stopScan];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateBleStateManual {
    if (self.manager.centralManager.state != CBCentralManagerStatePoweredOn) {
        [self.view bringSubviewToFront:self.defaultView];
        [UIAlertView showWithTitle:nil message:VTLOCALIZEDSTRING(@"手机蓝牙未开启，请打开手机蓝牙") cancelButtonTitle:VTLOCALIZEDSTRING(@"知道了") otherButtonTitles:nil tapBlock:^(UIAlertView * _Nonnull alertView, NSInteger buttonIndex) {
        }];
    } else {
        [self.view bringSubviewToFront:self.scanView];
    }
}



- (IBAction)onButtonClick:(id)sender {
    [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"secondViewController"]]
                                                 animated:YES];
}

- (void)dealloc {
    
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    NSLog(@"index: %ld", item.tag);
}

#pragma mark - Private
- (void)startScanAnimation {
    [self.radarView scan];
    self.scanButton.selected = YES;
}

- (void)stopScanAnimation {
    [self.radarView stop];
    self.scanButton.selected = NO;
}

- (IBAction)startScan:(UIButton *)sender {
    if (self.scanButton.selected) {
        return;
    }
    [self startScanAnimation];
    self.isScanning = YES;
    [self.manager rescanWithTimeOut:TIMEOUT_BLE_DISCOVER_PROCEDURE];
}

- (IBAction)startScanAfterFail:(id)sender {
    [self.view bringSubviewToFront:self.scanView];
    [self startScan:nil];
}

- (void)stopScan {
    [self stopScanAnimation];
    self.scanButton.selected = NO;
    self.isScanning = NO;
}

#pragma mark - VTBleManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    [self updateBleStateManual];
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI {
    // 一有设备被搜索到,立即跳转到列表界面
    if (self.isScanning) {
        [self stopScan];
        self.manager.delegate = nil;
        [self performSegueWithIdentifier:@"pushToList" sender:nil];
    }
}

// 搜索设备失败
- (void)didFailToDiscoverPeripheralAtBleManager:(VTBleManager *)manager {
    [self.manager.centralManager stopScan];
    [self stopScan];
    [self.view bringSubviewToFront:self.notFountView];
}

#pragma mark - Properties
- (VTBleManager *)manager {
    return [VTBleManager sharedInstance];
}

@end
