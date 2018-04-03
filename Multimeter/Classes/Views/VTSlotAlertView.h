//
//  VTSlotAlertView.h
//  Multimeter
//
//  Created by Vincent on 28/09/2016.
//  Copyright © 2016 vincent. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol VTSlotAlertViewDelegate <NSObject>

- (void)didTapOnCloseBtn:(id)sender;

@end

@interface VTSlotAlertView : UIView

@property (weak, nonatomic) id<VTSlotAlertViewDelegate> delegate;
- (void)showAnimatiosn;
- (void)setGIFImageName:(NSString *)name;

@end
