//
//  VTEditToolBar.h
//  Multimeter
//
//  Created by Vincent on 29/09/2016.
//  Copyright © 2016 vincent. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol VTEditToolBarDelegate <NSObject>

- (void)didTapOk:(id)sender;
- (void)didChageColor:(UIColor *)color;
- (void)didTapCannel:(id)sender;

@end

@interface VTEditToolBar : UIView

@property (weak, nonatomic) UIView *canvas;
- (UIView *)canvas_snapshotView;

@end
