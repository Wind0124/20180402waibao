//
//  VTChartDetailVC.m
//  Multimeter
//
//  Created by Vincent on 28/09/2016.
//  Copyright © 2016 vincent. All rights reserved.
//

#import "VTChartDetailVC.h"
#import "MyPlot.h"
#import "VTEditToolBar.h"
#import "PureLayout.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>

#import "UIAlertView+Blocks.h"
#import "VTOperationButton.h"
#import "UIView+Helper.h"

@interface VTChartDetailVC ()

@property (strong, nonatomic) UIView *containerView;
@property (strong, nonatomic) MyPlot *chart;
@property (strong, nonatomic) VTEditToolBar *toolBar;
@property (strong, nonatomic) UIView *canvas;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *heigthContraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *topContraint;
@property (strong, nonatomic) NSLayoutConstraint *toolBarTopContraint;

@property (nonatomic, strong) UIView *operationView;
@property (strong, nonatomic) VTOperationButton *editButton;
@property (strong, nonatomic) VTOperationButton *saveButton;

@end

@implementation VTChartDetailVC

//- (void)awakeFromNib {
//    [super awakeFromNib];
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
    
    if (!self.chart) {
        self.chart = [MyPlot new];
        [self.chart renderInView:self.containerView withTheme:nil animated:YES];
        self.chart.plotData = self.datas;
        [self.chart reloadData];
    }
    
    [self.editButton setTitle:VTLOCALIZEDSTRING(@"编辑") forState:UIControlStateNormal];
    [self.saveButton setTitle:VTLOCALIZEDSTRING(@"保存") forState:UIControlStateNormal];
}

//- (void)viewDidLayoutSubviews {
//    UIInterfaceOrientation orientation =  [UIApplication sharedApplication].statusBarOrientation;
//    if (orientation==UIInterfaceOrientationPortrait) {
//        NSLog(@"aaaa");
//    } else {
//        NSLog(@"bbbb");
//    }
//}

- (void)setupUI {
    self.view.backgroundColor = UIColorFromRGBValue(0x303030);

    [self.view addSubview:self.containerView];
    [self.view addSubview:self.operationView];
    
    [self.operationView addSubview:self.editButton];
    [self.operationView addSubview:self.saveButton];
    
    [self setupContraints];
}

- (void)setupContraints {
    self.topContraint = [self.containerView autoPinToTopLayoutGuideOfViewController:self withInset:0];
    [self.containerView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
    [self.containerView autoPinEdgeToSuperviewEdge:ALEdgeRight];

    [self.operationView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
    [self.operationView autoPinEdgeToSuperviewEdge:ALEdgeRight];
    self.heigthContraint = [self.operationView autoSetDimension:ALDimensionHeight toSize:AUTO_2PX(200)];
    [self.operationView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.containerView];
    [self.operationView autoPinToBottomLayoutGuideOfViewController:self withInset:0];
    
    [self.editButton autoSetDimensionsToSize:CGSizeMake(AUTO_2PX(110), AUTO_2PX(200))];
    [self.editButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    
    [self.saveButton autoSetDimensionsToSize:CGSizeMake(AUTO_2PX(130), AUTO_2PX(200))];
    [self.saveButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    
    [self.editButton autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:(SCREENWIDTH-AUTO_2PX(84+240))/2.0];
    [self.saveButton autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:(SCREENWIDTH-AUTO_2PX(84+240))/2.0];
}

- (IBAction)onEditBtnClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        if (!self.toolBar.superview) {
            self.toolBar = [VTEditToolBar new];//[[[NSBundle mainBundle] loadNibNamed:@"VTEditToolBar" owner:self options:nil] lastObject];
            [self.view addSubview:self.toolBar];
//            NSArray *contraints = [self.toolBar autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeBottom];
            [self.toolBar autoSetDimension:ALDimensionHeight toSize:AUTO_2PX(180)];
            [self.toolBar autoPinEdgeToSuperviewEdge:ALEdgeLeft];
            [self.toolBar autoPinEdgeToSuperviewEdge:ALEdgeRight];
            [self.toolBar autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.containerView];

//            self.toolBarTopContraint = contraints[0];
//            [self.toolBar autoPinEdgesToSuperviewEdges];
            [self.containerView addSubview:self.canvas];
            [self.canvas autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
            [self.canvas autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:AUTO_2PX(180)];
            self.toolBar.canvas = self.canvas;
        }
        self.toolBar.hidden = NO;
        self.canvas.hidden = NO;
        self.chart.editing = YES;
    } else {
        self.toolBar.hidden = YES;
        self.canvas.hidden = YES;
        self.chart.editing = NO;
    }
}

- (IBAction)onSaveBtnClick:(id)sender {
//    UIView *view = [self.toolBar canvas_snapshotView];
//    view.translatesAutoresizingMaskIntoConstraints = YES;
//    [self.containerView addSubview:view];
    
    UIGraphicsBeginImageContextWithOptions(self.containerView.bounds.size, 1, 0.0f);
    [self.containerView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    ALAssetsLibrary *library =  [[ALAssetsLibrary alloc] init];
    [library writeImageToSavedPhotosAlbum:image.CGImage orientation:(ALAssetOrientation)image.imageOrientation completionBlock:^(NSURL *assetURL, NSError *error ) {
        if (!error) {
            [UIAlertView showWithTitle:VTLOCALIZEDSTRING(@"保存成功") message:nil cancelButtonTitle:VTLOCALIZEDSTRING(@"确定") otherButtonTitles:nil tapBlock:nil];
        }
//        [view removeFromSuperview];
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        _heigthContraint.constant = AUTO_2PX(200);
//        _topContraint.constant = 0;
        _toolBarTopContraint.constant = 0;
    } else {
        _heigthContraint.constant = 0;
//        _topContraint.constant = 20;
        _toolBarTopContraint.constant = 20;
    }
}

- (BOOL)my_shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)my_supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (UIView *)canvas {
    if (!_canvas) {
        _canvas = [UIView new];
    }
    return _canvas;
}

- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [UIView new];
    }
    return _containerView;
}

- (UIView *)operationView {
    if (!_operationView) {
        _operationView = [UIView new];
        _operationView.layer.masksToBounds = YES;
    }
    return _operationView;
}

- (VTOperationButton *)editButton {
    if (!_editButton) {
        _editButton = [VTOperationButton new];
        [_editButton setImage:[UIImage imageNamed:@"btn_edit"] forState:UIControlStateNormal];
        [_editButton setImage:[UIImage imageNamed:@"btn_edit"] forState:UIControlStateHighlighted];
        [_editButton setImage:[UIImage imageNamed:@"btn_edit"] forState:UIControlStateSelected];
        _editButton.scale = YES;
        [_editButton addTarget:self action:@selector(onEditBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _editButton;
}

- (VTOperationButton *)saveButton {
    if (!_saveButton) {
        _saveButton = [VTOperationButton new];
        [_saveButton setImage:[UIImage imageNamed:@"btn_save"] forState:UIControlStateNormal];
        [_saveButton setImage:[UIImage imageNamed:@"btn_save"] forState:UIControlStateHighlighted];
        _saveButton.scale = YES;
        [_saveButton addTarget:self action:@selector(onSaveBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _saveButton;
}

@end
