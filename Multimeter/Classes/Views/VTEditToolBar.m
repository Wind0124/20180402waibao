//
//  VTEditToolBar.m
//  Multimeter
//
//  Created by Vincent on 29/09/2016.
//  Copyright © 2016 vincent. All rights reserved.
//

#import "VTEditToolBar.h"
#import "PureLayout.h"
#import "UIAlertView+Blocks.h"
#import "UIImage+tintColor.h"

#import "UIView+Helper.h"

@interface VTToolCell : UICollectionViewCell

@property (strong, nonatomic) UIImageView *imgView;

@end

@implementation VTToolCell : UICollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    [self.contentView addSubview:self.imgView];
    [self.imgView autoPinEdgesToSuperviewEdges];
    
    return self;
}

- (UIImageView *)imgView {
    if (!_imgView) {
        _imgView = [UIImageView new];
    }
    return _imgView;
}

@end


@interface VTEditToolBar ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (strong, nonatomic) UICollectionView *colorCollectionView;
@property (strong, nonatomic) UICollectionView *toolCollectionView;
@property (strong, nonatomic) UIButton *changeColorBtn;

@property (strong, nonatomic) NSArray *colors;
@property (strong, nonatomic) NSArray *imageNames;
@property (strong, nonatomic) UIColor *strokeColor;
//@property (weak, nonatomic) IBOutlet UIView *canvas;
@property (assign, nonatomic) CGPoint startPoint;

// 已添加的控件
@property (strong, nonatomic) NSMutableArray *floatControls;
@property (strong, nonatomic) UIView *currentPanView;

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIButton *okButton;
@property (strong, nonatomic) UIButton *undoButton;

@property (nonatomic, strong) UIView *barView;
@property (nonatomic, strong) UIView *toolsView;
@property (nonatomic, strong) UIButton *textBtn;

@end

@implementation VTEditToolBar

- (UIView *)canvas_snapshotView {
    if ([self.canvas respondsToSelector:@selector(snapshotViewAfterScreenUpdates:)]) {
        return [self.canvas snapshotViewAfterScreenUpdates:YES];
    } else {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.isOpaque, 0.0f);
        [self.canvas.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return [[UIImageView alloc] initWithImage:image];
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) return nil;
    
    [self addSubview:self.barView];
    [self.barView addSubview:self.titleLabel];
    [self.barView addSubview:self.toolsView];
    
    [self.toolsView addSubview:self.textBtn];
    [self.toolsView addSubview:self.toolCollectionView];
    [self.toolsView addSubview:self.okButton];
    [self.toolsView addSubview:self.undoButton];
    
    [self.barView addSubview:self.changeColorBtn];
    [self.barView addSubview:self.colorCollectionView];
    
    [self setupConstraints];
    
    [self setupOthers];
    return self;
}

- (void)setupConstraints {
    [self.barView autoPinEdgesToSuperviewEdges];
    
    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeTop];
    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:AUTO_2PX(16)];

    [self.toolsView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
    [self.toolsView autoPinEdgeToSuperviewEdge:ALEdgeRight];
    [self.toolsView autoSetDimension:ALDimensionHeight toSize:AUTO_2PX(104)];
    [self.toolsView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:AUTO_2PX(20)];
    
    [self.textBtn autoSetDimensionsToSize:CGSizeMake(AUTO_2PX(50), AUTO_2PX(64))];
    [self.textBtn autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:AUTO_2PX(32)];
    [self.textBtn autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    
    [self.toolCollectionView autoPinEdgeToSuperviewEdge:ALEdgeTop];
    [self.toolCollectionView autoPinEdgeToSuperviewEdge:ALEdgeBottom];
    [self.toolCollectionView autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.textBtn withOffset:AUTO_2PX(162)];
    [self.toolCollectionView autoSetDimension:ALDimensionWidth toSize:AUTO_2PX(290)];
    
    [self.undoButton autoPinEdgeToSuperviewEdge:ALEdgeTop];
    [self.undoButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [self.undoButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.toolCollectionView withOffset:AUTO_2PX(84)];
    
    [self.okButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.toolCollectionView withOffset:AUTO_2PX(10)];
    [self.okButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    
    [self.changeColorBtn autoSetDimension:ALDimensionWidth toSize:AUTO_2PX(78)];
    [self.changeColorBtn autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:AUTO_2PX(120)];
    [self.changeColorBtn autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.textBtn];
    
    [self.colorCollectionView autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.toolsView];
    [self.colorCollectionView autoPinEdgeToSuperviewEdge:ALEdgeBottom];
    [self.colorCollectionView autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.changeColorBtn];
    [self.colorCollectionView autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.changeColorBtn];
}


- (void)setupOthers {
//    [super awakeFromNib];
    if (!self.colors) {
        // 七种颜色
        self.colors = @[@(0xff0000), @(0xffa500), @(0xffff00),
                       @(0x00ff00), @(0x007fff), @(0x00ffff),
                        @(0x8b00ff)];
    }
    self.strokeColor = UIColorFromRGBValue([self.colors[0] integerValue]);
    [self.colorCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"colorCollectionViewCell"];
    [self.toolCollectionView registerClass:[VTToolCell class] forCellWithReuseIdentifier:@"toolCollectionViewCell"];
    self.changeColorBtn.backgroundColor = self.strokeColor;
    
    self.floatControls = [NSMutableArray new];
    
    self.titleLabel.text = VTLOCALIZEDSTRING(@"工具");
    [self.okButton setTitle:VTLOCALIZEDSTRING(@"确定") forState:UIControlStateNormal];
    [self.undoButton setTitle:VTLOCALIZEDSTRING(@"撤销") forState:UIControlStateNormal];
}

- (void)setCanvas:(UIView *)canvas {
    _canvas = canvas;
    
    UIPanGestureRecognizer *gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [_canvas addGestureRecognizer:gestureRecognizer];
}

- (IBAction)onTextBtnClick:(id)sender {
    // 弹窗输入
    [UIAlertView showWithTitle:VTLOCALIZEDSTRING(@"输入文字") message:@"" style:UIAlertViewStylePlainTextInput cancelButtonTitle:VTLOCALIZEDSTRING(@"取消") otherButtonTitles:@[VTLOCALIZEDSTRING(@"确定")] tapBlock:^(UIAlertView * alertView, NSInteger buttonIndex) {
        if (buttonIndex==0) return;
        
        UITextField *field = [alertView textFieldAtIndex:0];
        NSString *content = field.text;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = content;
        label.textColor = self.strokeColor;
        [label sizeToFit];
        label.center = CGPointMake(CGRectGetMidX(self.canvas.bounds),CGRectGetMidY(self.canvas.bounds));
//        label.backgroundColor = [UIColor whiteColor];
        [self.canvas addSubview:label];
        [self.floatControls addObject:label];
    }];
}

// 写死进去
- (IBAction)onOKBtnClick:(id)sender {
    [self.floatControls removeAllObjects];
}

// 删除控件
- (IBAction)onCancelBtnClick:(id)sender {
    UIView *view = self.floatControls.lastObject;
    [view removeFromSuperview];
    [self.floatControls removeLastObject];
}

- (IBAction)onChangeColor:(id)sender {
    self.colorCollectionView.hidden = NO;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == self.colorCollectionView) {
        return 7;
    } else {
        return 8;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = nil;
    if (collectionView == self.colorCollectionView) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"colorCollectionViewCell" forIndexPath:indexPath];
        NSNumber *colorValue = self.colors[indexPath.row];
        cell.backgroundColor = UIColorFromRGBValue([colorValue intValue]);
    } else {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"toolCollectionViewCell" forIndexPath:indexPath];
        VTToolCell *tcell = (VTToolCell *)cell;
        NSString *imgName = [NSString stringWithFormat:@"plot_shape_%ld", (long)indexPath.item];
        [tcell.imgView setImage:[UIImage imageNamed:imgName]];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.colorCollectionView) {
        collectionView.hidden = YES;
        NSNumber *numValue = self.colors[indexPath.row];
        _strokeColor = UIColorFromRGBValue(numValue.integerValue);
        self.changeColorBtn.backgroundColor = _strokeColor;
    } else {
        NSString *imgName = [NSString stringWithFormat:@"plot_shape_%ld", (long)indexPath.item];
        UIImage *image = [UIImage imageNamed:imgName ];
        image = [image imageWithTintColor:self.strokeColor];
        UIImageView *imgView = [[UIImageView alloc] initWithImage:image];
        imgView.frame = CGRectMake(0, 0, 138, 146);
        imgView.contentMode = UIViewContentModeScaleAspectFit;
        [self.canvas addSubview:imgView];
        imgView.center = CGPointMake(CGRectGetMidX(self.canvas.bounds),CGRectGetMidY(self.canvas.bounds));
        [self.floatControls addObject:imgView];
    }
}

#pragma mark - 手势
- (void)handlePan:(UIPanGestureRecognizer *)gestureRecognizer {
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint location = [gestureRecognizer locationInView:self.canvas];
        self.startPoint = CGPointMake(roundf(location.x), location.y);
        for (UIView *control in  self.floatControls) {
            if (CGRectContainsPoint(control.frame, self.startPoint)) {
                self.currentPanView = control;
            }
        }
    } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gestureRecognizer translationInView:self.canvas];
        CGPoint center = self.currentPanView.center;
        center.x += translation.x;
        center.y += translation.y;
        
        
        
        self.currentPanView.center = center;
        [gestureRecognizer setTranslation:CGPointZero inView:self.canvas];
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded || gestureRecognizer.state == UIGestureRecognizerStateCancelled) {
        self.currentPanView = nil;
    }
}

#pragma mark - Properties
- (UIView *)barView {
    if (!_barView) {
        _barView = [UIView new];
        _barView.backgroundColor = UIColorFromRGBValue(0x393A3A);
    }
    return _barView;
}

- (UIView *)toolsView {
    if (!_toolsView) {
        _toolsView = [UIView new];
        _toolsView.backgroundColor = UIColorFromRGBValue(0x717171);
    }
    return _toolsView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.textColor = UIColorFromRGBValue(0x999897);
        _titleLabel.font = [UIFont systemFontOfSize:AUTO_2PX(34)];
        _titleLabel.text = @"Tools";
    }
    return _titleLabel;
}

- (UIButton *)textBtn {
    if (!_textBtn) {
        _textBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_textBtn setImage:[UIImage imageNamed:@"plot_edit_text"] forState:UIControlStateNormal];
        [_textBtn addTarget:self action:@selector(onTextBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _textBtn;
}

- (UICollectionView *)toolCollectionView {
    if (!_toolCollectionView) {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.itemSize = CGSizeMake(AUTO_2PX(60), AUTO_2PX(40));
        layout.minimumLineSpacing = AUTO_2PX(4);
        layout.minimumInteritemSpacing = AUTO_2PX(10);
        layout.sectionInset = UIEdgeInsetsZero;
        
        _toolCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _toolCollectionView.delegate = self;
        _toolCollectionView.dataSource = self;
        _toolCollectionView.backgroundColor = [UIColor clearColor];
    }
    return _toolCollectionView;
}

- (UIButton *)okButton {
    if (!_okButton) {
        _okButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_okButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_okButton setTitle:@"OK" forState:UIControlStateNormal];
        _okButton.titleLabel.font = [UIFont systemFontOfSize:AUTO_2PX(28)];
        [_okButton addTarget:self action:@selector(onOKBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _okButton;
}

- (UIButton *)undoButton {
    if (!_undoButton) {
        _undoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_undoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_undoButton setTitle:@"Undo" forState:UIControlStateNormal];
        _undoButton.titleLabel.font = [UIFont systemFontOfSize:AUTO_2PX(28)];
        [_undoButton addTarget:self action:@selector(onCancelBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _undoButton;
}

- (UICollectionView *)colorCollectionView {
    if (!_colorCollectionView) {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.itemSize = CGSizeMake(AUTO_2PX(78), AUTO_2PX(40));
        layout.minimumLineSpacing = AUTO_2PX(4);
        layout.minimumInteritemSpacing = AUTO_2PX(0);
        layout.sectionInset = UIEdgeInsetsZero;
        
        _colorCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _colorCollectionView.dataSource = self;
        _colorCollectionView.delegate = self;
        _colorCollectionView.backgroundColor = [UIColor whiteColor];
        _colorCollectionView.hidden = YES;

    }
    return _colorCollectionView;
}

- (UIButton *)changeColorBtn {
    if (!_changeColorBtn) {
        _changeColorBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_changeColorBtn addTarget:self action:@selector(onChangeColor:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _changeColorBtn;
}

@end
