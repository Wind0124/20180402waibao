//
//  MyPlot.h
//  Plot_Gallery
//
//  Created by Vincent on 9/17/16.
//
//

#import "PlotItem.h"


@protocol MyPlotEventHandler <NSObject>

- (void)touchUP;

@end

@interface MyPlot : PlotItem<CPTPlotDataSource, CPTPlotSpaceDelegate, CPTPlotAreaDelegate>

// 数据源
@property (nonatomic, weak) NSMutableArray *plotData;

@property (weak, nonatomic) id<MyPlotEventHandler> eventHandler;
// 进入编辑模式后,不允许拖拽
@property (assign, nonatomic) BOOL editing;

- (void)reloadData;
- (void)reloadNewData;
- (void)resetRange:(NSDictionary *)range;

@end
