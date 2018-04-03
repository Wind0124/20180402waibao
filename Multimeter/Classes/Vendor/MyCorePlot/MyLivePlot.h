//
//  MyLivePlot.h
//  Multimeter
//
//  Created by Vincent on 29/09/2016.
//  Copyright © 2016 vincent. All rights reserved.
//

#import "PlotItem.h"

@protocol MyPlotEventHandler <NSObject>

- (void)touchUP;

@end

@interface MyLivePlot : PlotItem<CPTPlotDataSource, CPTPlotSpaceDelegate, CPTPlotAreaDelegate>

// 数据源
@property (nonatomic, weak) NSMutableArray *plotData;

@property (weak, nonatomic) id<MyPlotEventHandler> eventHandler;

- (void)reloadData;
- (void)reloadNewData;
- (void)resetRange:(NSDictionary *)range;

@end
