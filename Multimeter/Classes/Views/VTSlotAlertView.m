//
//  VTSlotAlertView.m
//  Multimeter
//
//  Created by Vincent on 28/09/2016.
//  Copyright © 2016 vincent. All rights reserved.
//

#import "VTSlotAlertView.h"
#import "PureLayout.h"
#import "YLImageView.h"
#import "YLGIFImage.h"

@interface VTSlotAlertView()

@property (weak, nonatomic) IBOutlet UIView *alertView;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIView *gifContainerView;
@property (strong, nonatomic)  YLImageView *gifView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;

@end

@implementation VTSlotAlertView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.alertView.layer.cornerRadius = 6;
    self.alertView.layer.masksToBounds = YES;
    
    self.titleLabel.text = VTLOCALIZEDSTRING(@"请确认表笔是否插入正确");
    [self.closeBtn setTitle:VTLOCALIZEDSTRING(@"确定") forState:UIControlStateNormal];

    _gifView= [[YLImageView alloc] init];
    [_gifContainerView addSubview:_gifView];
    [_gifView autoPinEdgesToSuperviewEdges];
}

- (void)showAnimation {
    self.alertView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidX(self.bounds));
    CGPoint center = self.alertView.center;
    
    self.alertView.transform = CGAffineTransformMakeScale(0.5, 0.5);
    self.alertView.center = center;
    [UIView animateWithDuration:0.25 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0 options:0 animations:^{
        self.alertView.transform = CGAffineTransformIdentity;
        self.alertView.center = center;
    } completion:^(BOOL finished) {
        //        self.alertView.transform = CGAffineTransformIdentity;
        //        self.alertView.center = center;
    }];
}

- (IBAction)onCloseBtnClick:(id)sender {
    [self.gifView stopAnimating];
    if ([self.delegate respondsToSelector:@selector(didTapOnCloseBtn:)]) {
        [self.delegate didTapOnCloseBtn:self];
    }
}

- (void)setGIFImageName:(NSString *)name {
    [self stop];
    YLGIFImage *img = (YLGIFImage *)[YLGIFImage imageNamed:name];
    self.gifView.image = img;
    [self.gifView startAnimating];
}

- (void)stop {
    [self.gifView stopAnimating];
}

@end
