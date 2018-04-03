//
//  VTMeasureVC.m
//  Multimeter
//
//  Created by vincent on 16/4/10.
//  Copyright © 2016年 vincent. All rights reserved.
//

#import "VTMeasureVC.h"
#import "CBPeripheral+Extra.h"
#import "VTBleDataParser.h"
#import "UIAlertView+Blocks.h"

#import <RESideMenu/RESideMenu.h>
#import "VTScanVC.h"
#import "VTMoreTableVC.h"
#import "VTBlePersistTool.h"

#import "VTFileDetailVC.h"
#import "EverChart.h"

#import "VTLcdView.h"
#import "VTDialView.h"
#import "VTOperationButton.h"

#import "VTSettingMgr.h"
#import "VTSpeechMgr.h"
#import "VTMeasurePresenterProtocol.h"
#import "VTDeviceMgr.h"
#import "VTGridDataView.h"
#import "VTTableDetailVC.h"

#import "MyLivePlot.h"
#import "VTMeasureLanscapeVC.h"
#import "PureLayout.h"
#import "UIView+Helper.h"

//#define  RECEIVE_INTERVAL   (2)
#define MAX_PKG_PER_SECOND    (3)       // 每s最多发几个，跟硬件相关
static NSInteger gRealRecieveCount = 0;

// lcd是否与速率有关
#define LCD_IGNORE_RATE   1

@interface VTMeasureVC ()<CBPeripheralDelegate, UICollectionViewDelegate, UICollectionViewDataSource,MyPlotEventHandler>

@property (weak, nonatomic) IBOutlet UIView *workView;

// 需要更新badge
//@property (weak, nonatomic) IBOutlet VTOperationButton *recordBtn;

// 用来保存到db的原始数据
@property (strong, nonatomic) NSMutableArray *originDatas;
// 开始保存时的位置
@property (assign, nonatomic) NSInteger startSaveIndex;
// 用来图表显示的已解析好的数据
@property (strong, nonatomic) NSMutableArray *analyzedDatas;

// 数据解析器
@property (strong, nonatomic) VTBleDataParser *parser;

//@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;

// 曲线分析
@property (strong, nonatomic) MyLivePlot *chart;
// 列表分析
@property (strong, nonatomic) VTGridDataView *gridView;

// 上次记录的状态，档位、单位等信息,如果变化,则要重刷新datas
@property (strong, nonatomic) NSString *lastState;
// 上次拔盘记录,拔盘变化了,也要重刷新datas
@property (assign, nonatomic) NSInteger lastDial;
// 上次记录的功能信息
@property (strong, nonatomic) NSString *lastFunc;
// 上次记录的单位
@property (strong, nonatomic) NSString *lastUnit;

// 停止后,不接收新的数据
@property (assign, nonatomic) BOOL isPause;
// 显示图表还是显示拔盘
@property (assign, nonatomic) BOOL isShowChart;
// 是否正在连接
@property (assign, nonatomic) BOOL isConnected;
// 量程信息
@property (strong, nonatomic) NSDictionary *range;
// 量程是否变化
@property (assign, nonatomic) BOOL needResetRange;
// 是否强制刷新量程
@property (assign, nonatomic) BOOL needForceResetRange;


// 上次成功保存的文件信息，方便跳转过去查看
@property (strong, nonatomic) VTBleFileModel *lastSavedModel;


@end

@implementation VTMeasureVC

#pragma mark - Life cycle

- (void)awakeFromNib {
    self.startSaveIndex = -1;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"navBar:%@", self.navigationController.navigationBar);
    
    [self setupRightBarItems];
    
    self.originDatas = [NSMutableArray new];
    self.analyzedDatas = [NSMutableArray new];
    
    if (self.peripheral) {
        // 先扫描，点击列表连接进来的情况
        self.isConnected = YES;
        self.peripheral.delegate = self;
        [self discoverServices];
    } else {
        // 从上次成功的连接中，直接进入
        NSUUID *uuid = [VTBlePersistTool getLastConnect];
        if (!uuid) return;
        NSArray *peripherals = [self.manager.centralManager retrievePeripheralsWithIdentifiers:@[uuid]];
        WEAKSELF
        if (!peripherals.count) {
            [UIAlertView showWithTitle:nil message:VTLOCALIZEDSTRING(@"连接上次设备失败，请重新扫描") cancelButtonTitle:VTLOCALIZEDSTRING(@"去扫描") otherButtonTitles:nil tapBlock:^(UIAlertView * _Nonnull alertView, NSInteger buttonIndex) {
                [weakSelf onSwitchButtonClick:nil];
            }];
            return;
        }
        self.manager.delegate = self;
        self.peripheral = peripherals[0];
        self.isConnected = NO;
        self.peripheral.remarkName = [VTBlePersistTool fetchRemarkFromDBWithUUID:uuid.UUIDString];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.manager connectPeripheral:weakSelf.peripheral withTimeOut:TIMEOUT_CONNECT_PROCEDURE];
        });
    }
//    [self initChart];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onOrientationChanged:) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
//    [self initCollectonViewOrChart];
//    [VTSpeechMgr sharedInstance].isMute = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    // 改完名字进来,要刷新标题
    self.isConnected = self.isConnected;
    [VTSpeechMgr sharedInstance].isMute = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [VTSpeechMgr sharedInstance].isMute = YES;
}

- (void)initCollectonViewOrChart {
    // 初始化曲线
    if ([VTSettingMgr sharedInstance].displayType==0) {
        if (self.gridView) {
            [self.gridView removeFromSuperview];
            self.gridView = nil;
        }
        [self initChart];
    } else {
        if (self.chart) {
            [self.chart killGraph];
            self.chart = nil;
        }
        [self initGridView];
    }
}

- (void)reInitCollectonViewOrChart {
    if (self.gridView) {
        [self.gridView clearDatas];
    } else {
        [self.chart killGraph];
        self.chart = [MyLivePlot new];
        self.chart.eventHandler = self;
        [self.chart renderInView:self.chartContainer withTheme:nil animated:YES];
    }
    _needForceResetRange = YES;
}

/// ugly but work.
- (void)viewDidLayoutSubviews {
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation != UIDeviceOrientationPortrait) {
        self.workView.transform = CGAffineTransformIdentity;
        [self.view addSubview:self.chartContainer];
        self.chartContainer.frame = CGRectMake(0, 20, SCREENHEIGHT, SCREENWIDTH-20);
        return;
    }
    // 重新移进去
    if (self.chartContainer.superview == self.view) {
        [self.presenter resetContraintsForContainer];
    }
    // scale
    CGFloat scale = VPROPER;
    if (scale != 1.0) {
        CGRect bounds = self.view.frame;
        if (bounds.origin.y==0) {
            bounds.origin.y += 64;
            bounds.size.height -= 64;
        } else {
            bounds.origin.y = 0;
        }
        self.workView.transform = CGAffineTransformScale(CGAffineTransformIdentity, scale, scale);
        self.workView.center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    }
}

// 旋转处理
- (void)onOrientationChanged:(NSNotification *)notification {
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsPortrait(orientation)) {
        [self.navigationController.navigationBar setHidden:NO];
    }
    else if (UIDeviceOrientationIsLandscape(orientation)) {
        [self.navigationController.navigationBar setHidden:YES];
    }
}

- (void)setupRightBarItems {
    UIBarButtonItem *switchBtn =
    [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed: @"menu_switch" ]
                                     style: UIBarButtonItemStylePlain
                                    target: self
                                    action: @selector(onSwitchButtonClick:)
     ];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    
    UIBarButtonItem *moreBtn =
    [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed: @"menu_more" ]
                                     style: UIBarButtonItemStylePlain
                                    target: self
                                    action: @selector(onMoreButtonClick:)
     ];
    negativeSpacer.width = -50;
    self.navigationItem.rightBarButtonItems = @[moreBtn, switchBtn];
}

- (void)initGridView {
    if (self.gridView) {
        self.gridView.frame = [self chartContainer].bounds;
        return;
    }
    self.gridView = [[VTGridDataView alloc] initWithFrame:[self chartContainer].bounds];
    [[self chartContainer] addSubview:self.gridView];
}

- (void)initChart {
    if (self.chart) {
        return;
    }
    
    self.chart = [MyLivePlot new];
    self.chart.eventHandler = self;
    [self.chart renderInView:self.chartContainer withTheme:nil animated:YES];
    _needForceResetRange = YES;
}

// 刷新表格
- (void)renderTable {
    [self.gridView loadDatas:self.analyzedDatas];
}

- (void)renderChart {
    self.chart.plotData = self.analyzedDatas;
    if (self.needResetRange || self.needForceResetRange) {
        [self.chart resetRange:self.range];
        self.needForceResetRange = NO;
        self.needResetRange = NO;
        [self.chart reloadData];
    }
    else {
        [self.chart reloadNewData];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:@"NewPlotDataNotificationName" object:nil];
}

- (void)renderChartOrTable {
    if (self.gridView) {
        [self renderTable];
    } else {
        [self renderChart];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)discoverServices {
    CBUUID *serviceUUID = [CBUUID UUIDWithString:kDeviceNotifyServiceUUID];
    [self.peripheral discoverServices:@[serviceUUID]];
}


- (void)setIsConnected:(BOOL)yesOrNo {
    _isConnected = yesOrNo;
    
    NSString *peripheralName = self.peripheral.remarkName;
    if (!peripheralName) {
        peripheralName = self.peripheral.name;
    }
    if (yesOrNo) {
        self.title = [NSString stringWithFormat:@"%@(%@)", peripheralName, VTLOCALIZEDSTRING(@"已连接")];
    } else {
        self.title = [NSString stringWithFormat:@"%@(%@)", peripheralName, VTLOCALIZEDSTRING(@"已断开")];
    }
    [self.presenter updateBleButton:yesOrNo];
    if (!yesOrNo)
        [self.presenter updateWhenDeviceDisconnected];
}

// 主动断开连接
- (void)cancelConnect {
    if (self.peripheral) {
        self.manager.delegate = nil;
        [self.manager.centralManager cancelPeripheralConnection:self.peripheral];
    }
}


#pragma mark - Events
- (IBAction)onSwitchButtonClick:(id)sender {
    [self cancelConnect];
    
//    [self performSegueWithIdentifier:@"pushToList2" sender:nil];
    UINavigationController *nav = STORYBOARD_INSTANT(@"contentViewController");
    self.sideMenuViewController.contentViewController = nav;
    [nav.topViewController performSegueWithIdentifier:@"pushToList" sender:nil];
}

- (void)onMoreButtonClick:(id)sender {
    [self performSegueWithIdentifier:@"pushToMoreFunc" sender:nil];
}

- (void)touchUP {
//    VTMeasureLanscapeVC *vc = MS_STORYBOARD_INSTANT(@"VTMeasureLanscapeVC");
//    vc.datas = self.analyzedDatas;
//    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Private methods

// 档位或其他信息如果发生变化,则要重刷数据
- (BOOL)isBleDataChanged {
    self.lastUnit = self.parser.unitString;
    NSString *newStateString = [NSString stringWithFormat:@"%@",self.parser.funcString];
    
    self.lastFunc = self.parser.funcString;
    self.lastDial = self.parser.dialType;
    
    if (self.lastState.length && ![self.lastState isEqualToString:newStateString]){
        self.lastState = newStateString;
        self.needResetRange = YES;
        return YES;
    }
    self.lastState = newStateString;
//    if (self.lastDial && self.lastDial!=self.parser.dialType) {
//        self.lastDial = self.parser.dialType;
//        self.needResetRange = YES;
//        return YES;
//    }
    
    return NO;
}

- (void)updateUIWithData:(NSData *)data {
    VTLog(@"Log: -> %@", data);
    if ([self.parser parseWithData:data]==NO) {
        NSLog(@"解析数据失败");
        return;
    }
    
    // 如果没有默认名,根据型号产生一个
    if (!self.peripheral.remarkName.length) {
        self.peripheral.remarkName = [self.parser deviceModelName];
        [VTBlePersistTool saveDeviceToDB:self.peripheral];
        self.isConnected = self.isConnected;
    }
    if (!self.presenter) {
        [self.presenter remove];
        self.presenter = [VTDeviceMgr presenterForModel:self.parser.deviceModel];
        self.presenter.targetVC = self;
        [self.presenter addToView:self.workView];
    }
    [self.presenter updateUIWithParser:self.parser];
    
    // 如果电压档位或单位发生改变,则数组要重刷新
    if ([self isBleDataChanged]) {
        self.originDatas = [NSMutableArray new];
        self.analyzedDatas = [NSMutableArray new];
        if (self.startSaveIndex>0) {
            self.startSaveIndex = 0;
        }
        [self reInitCollectonViewOrChart];
    } else {
        [self initCollectonViewOrChart];
    }
    // 更新量程
    self.range  = [self.parser getRange];

    [self addToAnalyze:data];
    
    // 更新按钮badge
    if (self.startSaveIndex >= 0) {
        NSInteger saveCount = self.originDatas.count - self.startSaveIndex;
        if (saveCount>0) {
            [self.presenter.recordBtn setBadgeText:[@(saveCount) stringValue]];
        } else {
            [self.presenter.recordBtn setBadgeText:@""];
        }
    }
}

- (void)setRange:(NSDictionary *)newRange {
    if (!_range) {
        _range = newRange;
        _needResetRange = YES;
        return;
    }
    CGFloat oldMin = [(NSNumber *)_range[@"min"] floatValue];
    CGFloat oldMax = [(NSNumber *)_range[@"max"] floatValue];
    CGFloat newMin = [(NSNumber *)newRange[@"min"] floatValue];
    CGFloat newMax = [(NSNumber *)newRange[@"max"] floatValue];
    
    // 没变化
    if (fabs(newMax-oldMax)<=1.0e-5 && fabs(newMin-oldMin)<=1.0e-5) {
        return;
    }
    _range = newRange;
    _needResetRange = YES;
}

- (void)updateVoice {
    if ([VTSettingMgr sharedInstance].speechEnabled) {
        NSString *toReadText = [self.parser convertToSpeechText];
        [[VTSpeechMgr sharedInstance] say:toReadText];
    }
}

#pragma mark - Analyze
// 画图分析
- (void)addToAnalyze:(NSData *)data {
#if LCD_IGNORE_RATE
    if (gRealRecieveCount%self.RECEIVE_INTERVAL==0) {
#endif
        [self updateVoice];
        if (!self.parser.isDrawable) {
            return;
        }
        NSDictionary *dict = self.parser.analyzedDict;
        [self.originDatas addObject:@{@"time":dict[@"time"], @"data": data}];
        [self.analyzedDatas addObject:dict];
        [self renderChartOrTable];
#if LCD_IGNORE_RATE
    }
#endif
}

#pragma mark - Events
// 暂停和继续
- (void)onPauseBtnClick:(UIButton *)sender {
    // 点击了暂停
    sender.selected = !sender.selected;
    self.isPause = sender.selected;
}

// 保存数据
- (void)onRecordBtnClick:(VTOperationButton *)sender {
    // 用来记录状态,第一次点击,开始保存,第二次点击保存包
    
    sender.selected = !sender.selected;
    if (sender.selected) {
        self.startSaveIndex = self.originDatas.count;
        return;
    }
    [sender setBadgeText:@""];
    
//    [self showHUDViewWithInfo:VTLOCALIZEDSTRING(@"正在保存")];
    NSArray *toSaveArray = [self.originDatas subarrayWithRange:NSMakeRange(self.startSaveIndex, self.originDatas.count-self.startSaveIndex)];
    
    VTBleFileModel *model = [VTBleFileModel new];
    model.startTime = [NSDate date];
    model.saveTime = [NSDate date];
    model.fileName = [model genfileName];
    model.count = toSaveArray.count;
    model.min = [(NSNumber *)self.range[@"min"] floatValue];
    model.max = [(NSNumber *)self.range[@"max"] floatValue];
    model.type = self.lastDial;
    model.func = self.lastFunc;
    model.unit = self.lastUnit;

    BOOL res = NO;
    if (toSaveArray.count > 0) {
        res = [VTBlePersistTool saveDatasToDB:toSaveArray withIndexInfo:model];
    }
    // 保存完index重置
    self.startSaveIndex = -1;
//    [self dismissHUDView];
    
    WEAKSELF
    if (res) {
        weakSelf.lastSavedModel = model;
        NSString *tip = [NSString stringWithFormat:VTLOCALIZEDSTRING(@"文件成功保存在'%@'中"), model.fileName];
        [UIAlertView showWithTitle:nil message:tip cancelButtonTitle:VTLOCALIZEDSTRING(@"知道了") otherButtonTitles:@[VTLOCALIZEDSTRING(@"查看")] tapBlock:^(UIAlertView * __nonnull alertView, NSInteger buttonIndex){
            if (buttonIndex==1) {
//                VTTableDetailVC *vc = MS_STORYBOARD_INSTANT(@"VTTableDetailVC");
                VTTableDetailVC *vc = [VTTableDetailVC new];
                vc.fileModel = weakSelf.lastSavedModel;
                [weakSelf.navigationController pushViewController:vc animated:YES];
            }
        }];
    } else {
        [UIAlertView showWithTitle:nil message:VTLOCALIZEDSTRING(@"保存数据失败") cancelButtonTitle:VTLOCALIZEDSTRING(@"知道了") otherButtonTitles:nil tapBlock:nil];
    }
}

// 分析
- (void)onAnalyzeBtnClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.isShowChart = sender.selected;
    
    [self.presenter switchAnalyzeOrDial:self.isShowChart];
}

#pragma mark - VTBleManagerDelegate
// 重连
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    self.peripheral = peripheral;
    self.peripheral.delegate = self;
    [self discoverServices];
    self.isConnected = YES;
}

// 重连失败
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error {
    [UIAlertView showWithTitle:nil message:VTLOCALIZEDSTRING(@"设备连接失败") cancelButtonTitle:VTLOCALIZEDSTRING(@"知道了") otherButtonTitles:nil tapBlock:nil];
//    [self.navigationController popViewControllerAnimated:YES];
    self.isConnected = NO;
}

// 断开连接了
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error {
    self.isConnected = NO;
//    self.peripheral = nil;
    WEAKSELF
    [UIAlertView showWithTitle:nil message:VTLOCALIZEDSTRING(@"设备已断开") cancelButtonTitle:VTLOCALIZEDSTRING(@"取消") otherButtonTitles:@[VTLOCALIZEDSTRING(@"重新连接")] tapBlock:^(UIAlertView * _Nonnull alertView, NSInteger buttonIndex) {
        if (buttonIndex==1) {
            [weakSelf.manager connectPeripheral:self.peripheral withTimeOut:TIMEOUT_CONNECT_PROCEDURE];
        } else {
            self.peripheral = nil;
            [weakSelf onSwitchButtonClick:nil];
        }
    }];
}

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"pushToMoreFunc"]) {
        VTMoreTableVC *vc = segue.destinationViewController;
        vc.peripheral = self.peripheral;
    }
}

#pragma mark - CBPeripheralDelegate
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(nullable NSError *)error {
    CBUUID *characterUUID = [CBUUID UUIDWithString:kCharacteristicUUID];
    
    for (CBService *service in peripheral.services) {
        [self.peripheral discoverCharacteristics:@[characterUUID] forService:service];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(nullable NSError *)error {
    for (CBCharacteristic *character in service.characteristics) {
        if (character.properties & CBCharacteristicPropertyNotify) {
            [self.peripheral setNotifyValue:YES forCharacteristic:character];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
    VTLog(@"update notification ok");
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
    if (self.isPause) {
        return;
    }
#if !LCD_IGNORE_RATE
    if (gRealRecieveCount%self.RECEIVE_INTERVAL==0) {
#endif
        [self updateUIWithData:characteristic.value];
#if !LCD_IGNORE_RATE
    }
#endif

    gRealRecieveCount++;
    if (gRealRecieveCount==1000*self.RECEIVE_INTERVAL) gRealRecieveCount=0;
}

#pragma mark - Properties
- (VTBleDataParser *)parser {
    if (!_parser) {
        _parser = [VTBleDataParser new];
    }
    return _parser;
}

#pragma mark - Properties
- (VTBleManager *)manager {
    return [VTBleManager sharedInstance];
}

// 收到几个包当成1个包处理才能达到设置的速率
- (NSInteger)RECEIVE_INTERVAL {
    // 一分钟处理几个包
    NSInteger rate = [VTSettingMgr sharedInstance].sampleRate;
    CGFloat count = (MAX_PKG_PER_SECOND*60.0/rate);
    return count;
}

- (UIView *)chartContainer {
    return self.presenter.chartContainer;
}

- (BOOL)my_shouldAutorotate {
    if (self.isShowChart) {
        return YES;
    }
    return NO;
}

- (UIInterfaceOrientationMask)my_supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}


@end
