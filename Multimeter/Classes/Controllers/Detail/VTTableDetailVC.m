//
//  VTTableDetailVC.m
//  Multimeter
//
//  Created by Vincent on 28/09/2016.
//  Copyright © 2016 vincent. All rights reserved.
//

#import "VTTableDetailVC.h"
#import "VTGridDataView.h"
#import "VTChartDetailVC.h"
#import "VTBleDataParser.h"
#import "VTBleDataModel.h"
#import "VTBlePersistTool.h"
#import "VTOperationButton.h"
#import <PureLayout/PureLayout.h>

@interface VTTableDetailVC ()

@property (strong, nonatomic) VTGridDataView *gridView;
@property (strong, nonatomic) VTBleDataParser *parser;
@property (strong, nonatomic) NSArray *analyzedDatas;

@property (nonatomic, strong) UIView *operationView;
@property (strong, nonatomic) VTOperationButton *plotButton;
@property (strong, nonatomic) VTOperationButton *tableButton;

@end

@implementation VTTableDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
    
    // 从数据库中读取data
    NSMutableArray *analyzedDatas = [NSMutableArray new];
    NSArray *datas = [VTBlePersistTool fetchBleDatasWithFileName:self.fileModel.fileName];
    NSDate *lastDate = nil;
    for (VTBleDataModel *model in datas) {
        if (![self.parser parseWithData:model.data]) {
            continue;
        }
        NSMutableDictionary *dict = [self.parser.analyzedDict mutableCopy];
        if (lastDate) {
            dict[@"interval"] = @([model.recvTime timeIntervalSinceDate:lastDate]);
        }
        lastDate = model.recvTime;
        [analyzedDatas addObject:dict];
    }
    self.analyzedDatas = [analyzedDatas copy];
    [self.gridView loadDatas:self.analyzedDatas];
    
    [self.plotButton setTitle:VTLOCALIZEDSTRING(@"曲线") forState:UIControlStateNormal];
    [self.tableButton setTitle:VTLOCALIZEDSTRING(@"表格") forState:UIControlStateNormal];
}

- (void)setupUI {
    self.view.backgroundColor = UIColorFromRGBValue(0x303030);
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self.view addSubview:self.gridView];
    [self.view addSubview:self.operationView];
    
    [self.operationView addSubview:self.tableButton];
    [self.operationView addSubview:self.plotButton];
    
    [self setupContraints];
}

- (void)setupContraints {
    [self.gridView autoPinToTopLayoutGuideOfViewController:self withInset:AUTO_2PX(40)];
    [self.gridView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
    [self.gridView autoPinEdgeToSuperviewEdge:ALEdgeRight];
    
    [self.operationView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
    [self.operationView autoPinEdgeToSuperviewEdge:ALEdgeRight];
    [self.operationView autoSetDimension:ALDimensionHeight toSize:AUTO_2PX(200)];
    [self.operationView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.gridView];
    [self.operationView autoPinToBottomLayoutGuideOfViewController:self withInset:0];
    
    [self.tableButton autoSetDimensionsToSize:CGSizeMake(AUTO_2PX(140), AUTO_2PX(200))];
    [self.tableButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    
    [self.plotButton autoSetDimensionsToSize:CGSizeMake(AUTO_2PX(140), AUTO_2PX(200))];
    [self.plotButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    
    [self.tableButton autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:(SCREENWIDTH-AUTO_2PX(84+140*2))/2.0];
    [self.plotButton autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:(SCREENWIDTH-AUTO_2PX(84+140*2))/2.0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onPlotBtnClick:(id)sender {
//    VTChartDetailVC *vc = MS_STORYBOARD_INSTANT(@"VTChartDetailVC");
    VTChartDetailVC *vc = [VTChartDetailVC new];
    vc.datas = self.analyzedDatas;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Properties
- (VTBleDataParser *)parser {
    if (!_parser) {
        _parser = [VTBleDataParser new];
    }
    return _parser;
}

- (BOOL)my_shouldAutorotate {
    return YES;
}

- (VTGridDataView *)gridView {
    if (!_gridView) {
        _gridView = [VTGridDataView new];
        _gridView.scale = YES;
    }
    return _gridView;
}

- (UIView *)operationView {
    if (!_operationView) {
        _operationView = [UIView new];
    }
    return _operationView;
}

- (VTOperationButton *)plotButton {
    if (!_plotButton) {
        _plotButton = [VTOperationButton new];
        [_plotButton setImage:[UIImage imageNamed:@"btn_plot"] forState:UIControlStateNormal];
        [_plotButton setImage:[UIImage imageNamed:@"btn_plot"] forState:UIControlStateHighlighted];
        [_plotButton setImage:[UIImage imageNamed:@"btn_plot"] forState:UIControlStateSelected];
        _plotButton.scale = YES;
        [_plotButton addTarget:self action:@selector(onPlotBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _plotButton;
}

- (VTOperationButton *)tableButton {
    if (!_tableButton) {
        _tableButton = [VTOperationButton new];
        [_tableButton setImage:[UIImage imageNamed:@"btn_chart_hl"] forState:UIControlStateNormal];
        [_tableButton setImage:[UIImage imageNamed:@"btn_chart_hl"] forState:UIControlStateHighlighted];
        _tableButton.scale = YES;

    }
    return _tableButton;
}

@end
