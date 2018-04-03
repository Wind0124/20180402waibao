//
//  VTGridDataView.m
//  Multimeter
//
//  Created by Vincent on 27/09/2016.
//  Copyright © 2016 vincent. All rights reserved.
//

#import "VTGridDataView.h"
#import "PureLayout.h"
#import "VTDateFormater.h"
#import "UIView+Helper.h"

#ifdef AUTO_PX
#undef AUTO_PX
#endif

#define AUTO_PX(x) (_scale?((x)*k2PROPOR):(x))

@interface VTGridCell :UICollectionViewCell

@property (strong, nonatomic) UILabel *titleLabel;
@property (nonatomic, assign) BOOL scale;

@end

@implementation VTGridCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) return nil;
    
    [self.contentView addSubview:self.titleLabel];
    [self.titleLabel autoPinEdgesToSuperviewEdges];
    
    return self;
}

- (void)setScale:(BOOL)scale {
    _scale = scale;
    if (_scale) {
        _titleLabel.font = [UIFont systemFontOfSize:AUTO_PX(12)];
    }
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _titleLabel.font = [UIFont systemFontOfSize:AUTO_PX(12)];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

@end


@interface VTGridDataView()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray *datas;

@end

@implementation VTGridDataView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) return nil;
    
    [self setup];
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setup];
}

- (void)setup {
    [self addSubview:self.collectionView];
    [self.collectionView autoPinEdgesToSuperviewEdges];
}

- (void)loadDatas:(NSArray *)datas {
    if (!_datas) {
        _datas = [NSMutableArray new];
        NSInteger total = datas.count;
        for (NSInteger i=total-1; i>=0; i--) {
            [_datas addObject:datas[i]];
        }
    } else {
        [self insertData:datas.lastObject];
    }
    [self.collectionView reloadData];
}

- (void)clearDatas {
    _datas = [NSMutableArray new];
}

- (void)insertData:(NSDictionary *)dict {
    [_datas insertObject:dict atIndex:0];
}

#pragma mark - UICollectionView

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.datas.count+1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 6;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat width = 0;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        if (indexPath.row==0) {
            width = AUTO_PX(49);
        } else if (indexPath.row==1) {
            width = AUTO_PX(80);
        } else {
            width = AUTO_PX(60);
        }
    } else {
        width = floor((SCREENHEIGHT-5)/6.0);
    }
    
    return CGSizeMake(width, AUTO_PX(33));
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    VTGridCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"measureCell" forIndexPath:indexPath];
    cell.scale = self.scale;
    if (indexPath.section == 0) {
        cell.backgroundColor = UIColorFromRGBValue(0x453737);
        NSArray *strings = @[
                             VTLOCALIZEDSTRING(@"序列号"),
                             VTLOCALIZEDSTRING(@"接收时间"),
                             VTLOCALIZEDSTRING(@"设备ID号"),
                             VTLOCALIZEDSTRING(@"数值"),
                             VTLOCALIZEDSTRING(@"单位"),
                             VTLOCALIZEDSTRING(@"时间差"),
                             ];
        cell.titleLabel.text = strings[indexPath.row];
        return cell;
    }
    NSInteger section = indexPath.section-1;
    NSDictionary *dict = self.datas[section];
    cell.titleLabel.numberOfLines = 1;
    if (indexPath.section%2 == 0) {
        cell.backgroundColor = UIColorFromRGBValue(0x332c2c);
    } else {
        cell.backgroundColor = UIColorFromRGBValue(0x424242);
    }
    NSInteger total = collectionView.numberOfSections;
    NSInteger num = total-section-1;
    if (indexPath.row==0) {
        cell.titleLabel.text = [@(num) stringValue];
    } else if (indexPath.row==1) {
        cell.titleLabel.text = [VTDateFormater stringFromDate:dict[@"time"]];
        cell.titleLabel.numberOfLines = 2;
    } else if (indexPath.row==2) {
        cell.titleLabel.text = dict[@"model"];
    } else if (indexPath.row==3) {
        int overload = [dict[@"overload"] intValue];
        if (overload == YES) {
            cell.titleLabel.text = @"0.L";
        } else {
            cell.titleLabel.text = [dict[@"value"] stringValue];
        }
    } else if (indexPath.row==4) {
        cell.titleLabel.text = dict[@"unit"];
    } else if (indexPath.row==5) {
        cell.titleLabel.text = [NSString stringWithFormat:@"%.1fs", [dict[@"interval"]floatValue]/1000.0];
        ;
    } else {
        cell.titleLabel.text = @"";
    }
    
    return cell;
}

- (UICollectionView *)collectionView {
    if (_collectionView) return _collectionView;
    
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
//    layout.itemSize = CGSizeMake(60, 33);
    layout.minimumInteritemSpacing = 1;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
    collectionView.backgroundColor = UIColorFromRGBValue(0x1c1c1c);
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.allowsMultipleSelection = YES;
    [collectionView registerClass:VTGridCell.class forCellWithReuseIdentifier:@"measureCell"];
    
    _collectionView = collectionView;
    return _collectionView;
}

@end
