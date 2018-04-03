//
//  VTGridDataView.h
//  Multimeter
//
//  Created by Vincent on 27/09/2016.
//  Copyright © 2016 vincent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VTGridDataView : UIView

@property (nonatomic, assign) BOOL scale;
- (void)loadDatas:(NSArray *)datas;
- (void)clearDatas;

@end
