//
//  MOLMeetView.m
//  aletter
//
//  Created by moli-2017 on 2018/8/8.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLMeetView.h"
#import "MOLHead.h"
#import "MOLMeetCell.h"

@interface MOLMeetView ()
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@end

@implementation MOLMeetView

- (instancetype)init
{
    self = [super init];
    if (self) {
        _dataSourceArray = [NSMutableArray array];
        [self setupMeetViewUI];
    }
    return self;
}

#pragma mark - UI
- (void)setupMeetViewUI
{
    // collectionView
    self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
    self.flowLayout.minimumLineSpacing = 10;
    self.flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
    _collectionView = collectionView;
    collectionView.backgroundColor = [UIColor clearColor];
    if (@available(iOS 11.0, *)) {
        collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [collectionView registerClass:[MOLMeetCell class] forCellWithReuseIdentifier:@"MOLMeetCell_id"];
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 20);
    [self addSubview:collectionView];
}

- (void)calculatorMeetViewframe
{
    self.collectionView.width = self.width - 20;
    self.collectionView.height = self.height - 15;
    self.collectionView.x = 20;
    self.flowLayout.itemSize = CGSizeMake(self.collectionView.width-20, self.collectionView.height);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self calculatorMeetViewframe];
}
@end
