//
//  VTMeasureLanscapeVC.m
//  Multimeter
//
//  Created by Vincent on 29/09/2016.
//  Copyright © 2016 vincent. All rights reserved.
//

#import "VTMeasureLanscapeVC.h"
#import "MyPlot.h"

@interface VTMeasureLanscapeVC ()

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) MyPlot *chart;

@end

@implementation VTMeasureLanscapeVC


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
//    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (!self.chart) {
        self.chart = [MyPlot new];
        [self.chart renderInView:self.containerView withTheme:nil animated:YES];
        [self.chart reloadData];
    }
    
    // 加数据监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNewPlotData:) name:@"NewPlotDataNotificationName" object:nil];
}

- (void)onNewPlotData:(NSNotification *)notification {
    if (self.chart) {
        [self.chart reloadNewData];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
