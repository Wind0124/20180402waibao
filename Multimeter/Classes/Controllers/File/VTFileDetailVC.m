//
//  VTFileDetailVC.m
//  Multimeter
//
//  Created by vincent on 16/4/16.
//  Copyright © 2016年 vincent. All rights reserved.
//

#import "VTFileDetailVC.h"
#import "EverChart.h"
#import "VTBlePersistTool.h"
#import "VTBleDataParser.h"

@interface VTFileDetailVC ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIView *chartContainer;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) EverChart *chart;

@property (strong, nonatomic) VTBleDataParser *parser;
@property (strong, nonatomic) NSArray *analyzedDatas;

@end

@implementation VTFileDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = self.fileModel.fileName;
    
    // 从数据库中读取data
    NSMutableArray *analyzedDatas = [NSMutableArray new];
    NSArray *datas = [VTBlePersistTool fetchBleDatasWithFileName:self.fileModel.fileName];
    for (VTBleDataModel *model in datas) {
        if (![self.parser parseWithData:model.data]) {
            continue;
        }
        [analyzedDatas addObject:@(self.parser.floatValue)];
    }
    self.analyzedDatas = [analyzedDatas copy];
//    self.view.backgroundColor = UIColorFromRGBValue(0x303030);
    self.tableView.tableFooterView = [UIView new];
}


- (void)initEverChart {
    self.chart = [[EverChart alloc] initWithFrame:self.chartContainer.bounds];
    [self.chartContainer addSubview:self.chart];
    
    NSMutableArray *padding = [@[@"0",@"0",@"10",@"10"] mutableCopy];
    [self.chart setPadding:padding]; //设置内边距
    
    [self.chart addSection:@"1"];
    [[[self.chart sections] objectAtIndex:0] addYAxis:0];
    [self.chart getYAxis:0 withIndex:0].tickInterval = 10; //设置虚线数量
    self.chart.range = 50; //设置显示区间大小
    
    NSMutableArray *series = [[NSMutableArray alloc] init];
    
    NSMutableArray *secOne = [[NSMutableArray alloc] init];
    NSMutableDictionary *serie = [[NSMutableDictionary alloc] init];
    NSMutableArray *data = [[NSMutableArray alloc] init];
    
    serie = [[NSMutableDictionary alloc] init];
    data = [[NSMutableArray alloc] init];
    [serie setObject:kFenShiNowNameLine forKey:@"name"];
    [serie setObject:@"数值" forKey:@"label"];
    [serie setObject:data forKey:@"data"];
    [serie setObject:kFenShiLine forKey:@"type"];
    [serie setObject:@"1" forKey:@"yAxisType"];
    [serie setObject:@"0" forKey:@"section"];
    [serie setObject:kFenShiNowColor forKey:@"color"];
    [series addObject:serie];
    [secOne addObject:serie];
    
    [self.chart setSeries:series];
    [[[self.chart sections] objectAtIndex:0] setSeries:secOne];
}

#if 1
- (void)renderChart {
    // 刷新量程
    YAxis *yaxis = [self.chart getYAxis:0 withIndex:0];
    yaxis.min = self.fileModel.min;
    yaxis.max = self.fileModel.max;
    
    [self.chart reset];
    [self.chart clearData];
    [self.chart clearCategory];
    
    NSMutableArray *datas = [NSMutableArray new];
    NSMutableArray *category =[[NSMutableArray alloc] init];
    
    // 数据进行转换
    for(int i = 0;i<self.analyzedDatas.count;i++){
        [category addObject:[@(i) stringValue]];
        
        NSArray *item = @[self.analyzedDatas[i]];
        [datas addObject:item];
    }
    
    //上面构造数据的方法，可以按照需求更改；数据源构建完毕后，赋值到分时图上
    [self.chart appendToData:datas forName:kFenShiNowNameLine];
    
    //当被选中时，要显示的数据or文字
    [self.chart appendToCategory:category forName:kFenShiNowNameLine];
    
    //重绘图表
    [self.chart setNeedsDisplay];
}
#endif

- (void)viewDidAppear:(BOOL)animated {
    if (!self.chart) {
        [self initEverChart];
        [self renderChart];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"fileCellReuse";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (indexPath.row == 0) {
        cell.textLabel.text = VTLOCALIZEDSTRING(@"数量");
        cell.detailTextLabel.text = @(self.fileModel.count).stringValue;
    } else if (indexPath.row == 1) {
        cell.textLabel.text = VTLOCALIZEDSTRING(@"模式");
        cell.detailTextLabel.text = self.fileModel.func;
    } else {
        cell.textLabel.text = VTLOCALIZEDSTRING(@"量程");
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@~%@ %@", @(self.fileModel.min).stringValue,
                                     @(self.fileModel.max).stringValue, self.fileModel.unit];
    }
    
    return cell;
}

#pragma mark - Properties
- (VTBleDataParser *)parser {
    if (!_parser) {
        _parser = [VTBleDataParser new];
    }
    return _parser;
}

@end
