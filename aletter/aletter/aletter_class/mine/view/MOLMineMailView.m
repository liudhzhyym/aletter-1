//
//  MOLMineMailView.m
//  aletter
//
//  Created by moli-2017 on 2018/8/17.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLMineMailView.h"
#import "MOLHead.h"
#import "MOLMineMailCell.h"
#import "MOLMineMailReusableView.h"

@interface MOLMineMailView ()

@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@end

@implementation MOLMineMailView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _dataSourceArray = [NSMutableArray array];
        [self setupMineMailViewUI];
    }
    return self;
}


#pragma mark - UI
- (void)setupMineMailViewUI
{
    CGFloat itemW = MOL_SCREEN_ADAPTER(100);
    CGFloat itemH = itemW * 70 / 100 + 30;
    self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
    self.flowLayout.minimumLineSpacing = 20;
    self.flowLayout.minimumInteritemSpacing = (MOL_SCREEN_WIDTH - 3 * itemW - 40) * 0.5;
    
    self.flowLayout.sectionInset = UIEdgeInsetsMake(0, 20, 0, 20);
    self.flowLayout.itemSize = CGSizeMake(itemW, itemH);
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, MOL_SCREEN_WIDTH, MOL_SCREEN_HEIGHT) collectionViewLayout:self.flowLayout];
    _collectionView = collectionView;
    _collectionView.backgroundColor = [UIColor clearColor];
    if (@available(iOS 11.0, *)) {
        _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    _collectionView.contentInset = UIEdgeInsetsMake(0, 0, MOL_TabbarSafeBottomMargin, 0);
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.showsHorizontalScrollIndicator = NO;
    [_collectionView registerClass:[MOLMineMailCell class] forCellWithReuseIdentifier:@"MOLMineMailCell_id"];
    [_collectionView registerClass:[MOLMineMailReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"MOLMineMailReusableView_id"];
    [self addSubview:_collectionView];
}

- (void)calculatorMineMailViewFrame
{
    self.collectionView.frame = self.bounds;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self calculatorMineMailViewFrame];
}
@end
