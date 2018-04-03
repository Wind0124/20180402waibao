//
//  TestBlendImageVC.m
//  Multimeter
//
//  Created by Vincent on 07/10/2016.
//  Copyright © 2016 vincent. All rights reserved.
//

#import "TestBlendImageVC.h"
#import "PureLayout.h"
#import "UIImage+tintColor.h"

@interface VTBlendCell : UICollectionViewCell

@property (strong, nonatomic) UIImageView *imgView;

@end

@implementation VTBlendCell : UICollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    self.contentView.backgroundColor = [UIColor redColor];
    [self.contentView addSubview:self.imgView];
    [self.imgView autoPinEdgesToSuperviewEdges];
    
    return self;
}

- (UIImageView *)imgView {
    if (!_imgView) {
        _imgView = [UIImageView new];
        _imgView.backgroundColor = [UIColor clearColor];
//        _imgView.tintColor = [UIColor blueColor];
    }
    return _imgView;
}

@end


@interface TestBlendImageVC ()

@end

@implementation TestBlendImageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.collectionView registerClass:VTBlendCell.class forCellWithReuseIdentifier:@"VTBlendCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return kCGBlendModePlusLighter+1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    VTBlendCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"VTBlendCell" forIndexPath:indexPath];
    
    UIImage *image = [UIImage imageNamed:@"plot_shape_1"];
    image = [image imageWithTintColor:[UIColor blueColor] blendMode:(CGBlendMode)indexPath.item];
    [cell.imgView setImage:image];

    return cell;
}

@end
