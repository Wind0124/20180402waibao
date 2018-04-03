//
//  MyLivePlot.m
//  Multimeter
//
//  Created by Vincent on 29/09/2016.
//  Copyright © 2016 vincent. All rights reserved.
//


#import "MyLivePlot.h"

static const double kFrameRate = 3.0;  // frames per second
static const double kAlpha     = 0.25; // smoothing constant

static const NSUInteger kMaxDataPoints = 52;
static NSString *const kPlotIdentifier = @"Data Source Plot";

@interface MyLivePlot()

@property (nonatomic, readwrite, assign) NSUInteger currentIndex;
@property (assign, nonatomic) BOOL scrollMode;
@property (strong, nonatomic) CPTPlotSpaceAnnotation *markerAnnotation;
// 定时2s后重新刷数据
@property (strong, nonatomic) NSTimer *timer;

@end

@implementation MyLivePlot

@synthesize plotData;
@synthesize currentIndex;
@synthesize scrollMode = _scrollMode;
@synthesize markerAnnotation = _markerAnnotation;


-(nonnull instancetype)init
{
    if ( (self = [super init]) ) {
        //        self.title   = @"My Plot";
    }
    
    return self;
}

-(void)killGraph
{
    [super killGraph];
}

-(void)generateData
{
    //    [self.plotData removeAllObjects];
    self.currentIndex = 0;
}

-(void)renderInGraphHostingView:(nonnull CPTGraphHostingView *)hostingView withTheme:(nullable CPTTheme *)theme animated:(BOOL)animated
{
    CGRect bounds = hostingView.bounds;
    
    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:bounds];
    graph.paddingLeft   = 0.0;
    graph.paddingRight  = 0.0;
    graph.paddingTop    = 0.0;
    graph.paddingBottom = 0.0;
    
    [self addGraph:graph toHostingView:hostingView];
    [self applyTheme:theme toGraph:graph withDefault:[CPTTheme themeNamed:kCPTDarkGradientTheme]];
    
    graph.plotAreaFrame.paddingTop    = 8;//self.titleSize * CPTFloat(0.5);
    graph.plotAreaFrame.paddingRight  = 8;//self.titleSize * CPTFloat(0.5);
    graph.plotAreaFrame.paddingBottom = 20;//self.titleSize * CPTFloat(2.625);
    graph.plotAreaFrame.paddingLeft   = 35;//self.titleSize * CPTFloat(2.5);
    graph.plotAreaFrame.masksToBorder = NO;
    graph.plotAreaFrame.borderLineStyle = nil;
    graph.plotAreaFrame.cornerRadius = 0;

    
    // Plot area delegate
    graph.plotAreaFrame.plotArea.delegate = self;
    
    // Setup scatter plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = YES;
    plotSpace.delegate              = self;
    
    // Grid line styles
    CPTMutableLineStyle *majorGridLineStyle = [CPTMutableLineStyle lineStyle];
    majorGridLineStyle.lineWidth = 0.75;
    majorGridLineStyle.lineColor = [[CPTColor colorWithGenericGray:CPTFloat(0.2)] colorWithAlphaComponent:CPTFloat(0.75)];
    
    CPTMutableLineStyle *minorGridLineStyle = [CPTMutableLineStyle lineStyle];
    minorGridLineStyle.lineWidth = 0.25;
    minorGridLineStyle.lineColor = [[CPTColor whiteColor] colorWithAlphaComponent:CPTFloat(0.1)];
    
    // Axes
    // X axis
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    CPTXYAxis *x          = axisSet.xAxis;
    x.labelingPolicy        = CPTAxisLabelingPolicyAutomatic;
    x.orthogonalPosition    = @0.0;
    x.majorGridLineStyle    = majorGridLineStyle;
    x.minorGridLineStyle    = minorGridLineStyle;
    x.minorTicksPerInterval = 9;
    //    x.labelOffset           = 0;//self.titleSize * CPTFloat(0.25);
    //    x.title                 = @"X Axis";
    //    x.titleOffset           = 0;//self.titleSize * CPTFloat(1.5);
    
    NSNumberFormatter *labelFormatter = [[NSNumberFormatter alloc] init];
    labelFormatter.numberStyle = NSNumberFormatterNoStyle;
    x.labelFormatter           = labelFormatter;
    
    // Y axis
    CPTXYAxis *y = axisSet.yAxis;
    y.labelingPolicy        = CPTAxisLabelingPolicyAutomatic;
    y.orthogonalPosition    = @0.0;
    y.majorGridLineStyle    = majorGridLineStyle;
    y.minorGridLineStyle    = minorGridLineStyle;
    y.minorTicksPerInterval = 4;
    y.axisConstraints       = [CPTConstraints constraintWithLowerOffset:0.0];
    
    // Rotate the labels by 45 degrees, just to show it can be done.
    //    x.labelRotation = CPTFloat(M_PI_4);
    
    CPTMutableLineStyle *blueLineStyle = [CPTMutableLineStyle lineStyle];
    blueLineStyle.lineColor = [CPTColor blueColor];
    blueLineStyle.lineWidth = 0.5;
    
    CPTXYAxis *iAxis = [[CPTXYAxis alloc] initWithFrame:CGRectZero];
    iAxis.title          = nil;
    iAxis.labelFormatter = nil;
    iAxis.axisLineStyle  = blueLineStyle;
    
    iAxis.coordinate         = CPTCoordinateY;
    iAxis.plotSpace          = graph.defaultPlotSpace;
    iAxis.majorTickLineStyle = nil;
    iAxis.minorTickLineStyle = nil;
    iAxis.orthogonalPosition = @0.0;
    iAxis.hidden             = YES;
    
    graph.axisSet.axes = @[x, y, iAxis];
    
    // Create the plot
    CPTScatterPlot *dataSourceLinePlot = [[CPTScatterPlot alloc] init];
    dataSourceLinePlot.identifier     = kPlotIdentifier;
    dataSourceLinePlot.cachePrecision = CPTPlotCachePrecisionDouble;
    dataSourceLinePlot.interpolation = CPTScatterPlotInterpolationCurved;
    
    CPTMutableLineStyle *lineStyle = [dataSourceLinePlot.dataLineStyle mutableCopy];
    lineStyle.lineWidth              = 2.0;
    lineStyle.lineColor              = [CPTColor redColor];
    dataSourceLinePlot.dataLineStyle = lineStyle;
    
    dataSourceLinePlot.dataSource = self;
    [graph addPlot:dataSourceLinePlot];
    
    // Plot space
    plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@0.0 length:@(kMaxDataPoints - 2)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@0.0 length:@1.0];
    
    // Setup a style for the annotation
    CPTMutableTextStyle *hitAnnotationTextStyle = [CPTMutableTextStyle textStyle];
    hitAnnotationTextStyle.color    = [CPTColor blackColor];
    hitAnnotationTextStyle.fontName = @"Helvetica-Bold";
    hitAnnotationTextStyle.fontSize = self.titleSize * CPTFloat(0.5);
    
    CPTTextLayer *textLayer = [[CPTTextLayer alloc] initWithText:@"Annotation" style:hitAnnotationTextStyle];
    textLayer.borderLineStyle = blueLineStyle;
    textLayer.fill            = [CPTFill fillWithColor:[CPTColor whiteColor]];
    textLayer.cornerRadius    = 3.0;
    textLayer.paddingLeft     = 2.0;
    textLayer.paddingTop      = 2.0;
    textLayer.paddingRight    = 2.0;
    textLayer.paddingBottom   = 2.0;
    textLayer.hidden          = YES;
    
    CPTPlotSpaceAnnotation *annotation = [[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:plotSpace anchorPlotPoint:@[@0, @0]];
    annotation.contentLayer = textLayer;
    
    [graph addAnnotation:annotation];
    
    self.markerAnnotation = annotation;
}

-(void)dealloc {
    [self releaseTimer];
}

#pragma mark -
#pragma mark Timer callback

- (void)reloadNewData {
    CPTGraph *theGraph = (self.graphs)[0];
    CPTPlot *thePlot   = [theGraph plotWithIdentifier:kPlotIdentifier];
    
    if (!thePlot) return;
    
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)theGraph.defaultPlotSpace;
    if (!_scrollMode) {
        NSUInteger location       = (self.currentIndex >= kMaxDataPoints ? self.currentIndex - kMaxDataPoints + 2 : 0);
        
        CPTPlotRange *oldRange = [CPTPlotRange plotRangeWithLocation:@( (location > 0) ? (location - 1) : 0 )
                                                              length:@(kMaxDataPoints - 2)];
        CPTPlotRange *newRange = [CPTPlotRange plotRangeWithLocation:@(location)
                                                              length:@(kMaxDataPoints - 2)];
        [CPTAnimation animate:plotSpace
                     property:@"xRange"
                fromPlotRange:oldRange
                  toPlotRange:newRange
                     duration:CPTFloat(1.0 / kFrameRate)];
//        [self scaleToFitPlots];
    }
    [thePlot insertDataAtIndex:self.plotData.count-1 numberOfRecords:1];
    self.currentIndex++;
}

- (void)scaleToFitPlots {
    CPTGraph *theGraph = (self.graphs)[0];
    
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)theGraph.defaultPlotSpace;
    [plotSpace scaleToFitPlots:theGraph.allPlots];
}

- (void)reloadData {
    CPTGraph *theGraph = (self.graphs)[0];
    CPTPlot *thePlot   = [theGraph plotWithIdentifier:kPlotIdentifier];
    
    if (!thePlot) return;
    self.currentIndex = self.plotData.count;
    [thePlot reloadData];
//    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)theGraph.defaultPlotSpace;
//    [plotSpace scaleToFitEntirePlots:[theGraph allPlots]];
}

#pragma mark Plot Space Delegate Methods

-(nullable CPTPlotRange *)plotSpace:(nonnull CPTPlotSpace *)space willChangePlotRangeTo:(nonnull CPTPlotRange *)newRange forCoordinate:(CPTCoordinate)coordinate
{
    CPTGraph *theGraph    = space.graph;
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)theGraph.axisSet;
    
    CPTMutablePlotRange *changedRange = [newRange mutableCopy];
    
    switch ( coordinate ) {
        case CPTCoordinateX:
            [changedRange expandRangeByFactor:@1.025];
            changedRange.location          = newRange.location;
            axisSet.xAxis.visibleAxisRange = changedRange;
            break;
            
        case CPTCoordinateY:
            [changedRange expandRangeByFactor:@1.05];
            axisSet.yAxis.visibleAxisRange = changedRange;
            break;
            
        default:
            break;
    }
    
    return newRange;
}

- (void)resetTimer {
    [self.timer invalidate];
    self.timer = [NSTimer timerWithTimeInterval:2.0
                                        target:self
                                       selector:@selector(onTimer)
                                       userInfo:nil
                                        repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)releaseTimer {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)onTimer {
    [self releaseTimer];
    self.scrollMode = NO;
}

//-(void)plotSpace:(nonnull CPTPlotSpace *)space didChangePlotRangeForCoordinate:(CPTCoordinate)coordinate {
////    NSLog(@"xxxxxxxxxxxxxxxxxxx");
//}

- (void)test {
    //    if (dataTimer.isValid) {
    //        [dataTimer invalidate];
    //        dataTimer = nil;
    //    } else {
    //        NSTimer *newTimer = [NSTimer timerWithTimeInterval:1.0 / kFrameRate
    //                                                    target:self
    //                                                  selector:@selector(newData:)
    //                                                  userInfo:nil
    //                                                   repeats:YES];
    //        self.dataTimer = newTimer;
    //        [[NSRunLoop mainRunLoop] addTimer:newTimer forMode:NSRunLoopCommonModes];
    //    }
    _scrollMode = NO;
}


-(BOOL)plotSpace:(CPTPlotSpace *)space shouldHandlePointingDeviceDownEvent:(CPTNativeEvent *)event atPoint:(CGPoint)point
{
    [self releaseTimer];
    [self showLineAtPlotSpace:space event:event atPoint:point];
    return YES;
}

-(BOOL)plotSpace:(nonnull CPTPlotSpace *)space shouldHandlePointingDeviceDraggedEvent:(nonnull CPTNativeEvent *)event atPoint:(CGPoint)point {
    [self releaseTimer];
    return YES;
}

-(BOOL)plotSpace:(CPTPlotSpace *)space shouldHandlePointingDeviceUpEvent:(nonnull CPTNativeEvent *)event atPoint:(CGPoint)point
{
    // 启动定时器
    [self resetTimer];
    return YES;
}

- (void)showLineAtPlotSpace:(CPTPlotSpace *)space event:(CPTNativeEvent *)event atPoint:(CGPoint)point {
    self.scrollMode = YES;
    CPTXYPlotSpace *xySpace = (CPTXYPlotSpace *)space;
    
    CPTGraph *graph = space.graph;
    
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    
    CPTAxisArray *axes = axisSet.axes;
    CPTXYAxis *iAxis   = axes.lastObject;
    
    CPTNumberArray *plotPoint = [space plotPointForEvent:event];
    
    CPTPlotSpaceAnnotation *annotation = self.markerAnnotation;
    
    CPTTextLayer *textLayer = (CPTTextLayer *)annotation.contentLayer;
    
    NSNumber *xNumber = plotPoint[CPTCoordinateX];
    
    if ( [xySpace.xRange containsNumber:xNumber] ) {
        NSUInteger x = (NSUInteger)lround(xNumber.doubleValue / 1);
        
        xNumber = @(x * 1);
        
        NSString *dateValue = [axisSet.xAxis.labelFormatter stringForObjectValue:xNumber];
        if (self.plotData.count > x) {
            CPTDictionary *dict = self.plotData[x];
            NSNumber *plotValue = dict[@"value"];
            if ([dict[@"overload"] boolValue]==1) {
                textLayer.text   = [NSString stringWithFormat:@"(%@,OL)", dateValue];
            } else {
                textLayer.text   = [NSString stringWithFormat:@"(%@,%@)", dateValue,plotValue.stringValue];
            }
            annotation.anchorPlotPoint = @[xNumber, @(plotValue.doubleValue)];
            textLayer.hidden = NO;
            iAxis.orthogonalPosition = xNumber;
            iAxis.hidden             = NO;
        }
        else {
            textLayer.hidden = YES;
            iAxis.hidden     = YES;
        }
    }
    else {
        textLayer.hidden = YES;
        iAxis.hidden     = YES;
    }
    NSLog(@"down down down");
}



#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(nonnull CPTPlot *)plot
{
    return self.plotData.count;
}

-(nullable id)numberForPlot:(nonnull CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSNumber *num = nil;
    CPTDictionary *dict = self.plotData[index];
    if ([dict[@"overload"] boolValue]==1) {
        return nil;
    }
    
    switch ( fieldEnum ) {
        case CPTScatterPlotFieldX:
            num = @(index + self.currentIndex - self.plotData.count);
            break;
            
        case CPTScatterPlotFieldY:{
            CPTDictionary *dict = self.plotData[index];
            num = dict[@"value"];
            break;
        }
        default:
            break;
    }
    
    return num;
}

- (void)resetRange:(NSDictionary *)range {
    CPTGraph *graph = (self.graphs)[0];
    NSNumber *min = range[@"min"];
    NSNumber *max = range[@"max"];
    CGFloat len = max.floatValue - min.floatValue;
    
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:min length:@(len)];
}

@end
