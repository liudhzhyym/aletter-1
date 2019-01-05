//
//  StampView.m
//  aletter
//
//  Created by xiaolong li on 2018/8/18.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "StampView.h"
#import "MOLHead.h"
#import "StampCell.h"
#import "StampModel.h"

const CGFloat contentHeight =160;

@interface StampView ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, strong) UIView *contentBgView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIView *backGroundView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) NSMutableArray *stampArr;
@property (nonatomic, strong) NSIndexPath *oldIndexPath;
@property (nonatomic, strong) UILabel *tipLable;


@end

@implementation StampView


- (void)showStampView:(NSMutableArray *)stampArr oldSelect:(NSIndexPath *)oldIndexPath{
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
    __weak __typeof(self) weakSelf = self;
    self.stampArr = [NSMutableArray arrayWithArray:stampArr];
    self.oldIndexPath =oldIndexPath;
    [[[[UIApplication sharedApplication] delegate] window] addSubview:self];
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.backGroundView.backgroundColor = HEX_COLOR_ALPHA(0x000000, 0.5);
        weakSelf.contentView.y = weakSelf.height-weakSelf.contentView.height;
    }];
    
    [self.collectionView reloadData];
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.backGroundView];
        [self addSubview:self.contentView];
        
        [self.contentView addSubview:self.collectionView];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    [self.backGroundView setFrame:CGRectMake(0, 0, self.width, self.height)];
    [self.contentView setFrame:CGRectMake(0,self.height, self.width, contentHeight)];
    [self.collectionView setFrame:CGRectMake(0, 0, self.contentView.width, self.contentView.height)];
    
    CGFloat contentWidth =self.contentView.width;
    if (self.stampArr && ((20+self.stampArr.count*(100+10))>self.contentView.width)) {
        contentWidth = 20+self.stampArr.count*(100+10);
    }
    [self.collectionView setContentSize:CGSizeMake(contentWidth, self.contentView.height)];
    
}

- (UIView *)backGroundView{
    if (!_backGroundView) {
        _backGroundView =[UIView new];
        [_backGroundView setUserInteractionEnabled:YES];
        [_backGroundView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeButtonAction)]];
    }
    return _backGroundView;
}

- (UIView *)contentView{
    if (!_contentView) {
        _contentView =[UIView new];
        [_contentView setBackgroundColor:[UIColor whiteColor]];
    }
    return _contentView;
}

- (UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout =[UICollectionViewFlowLayout new];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        [layout setItemSize:CGSizeMake(110, 160)];
        _collectionView =[[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.pagingEnabled = YES;
        _collectionView.scrollsToTop = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.contentOffset = CGPointMake(0, 0);
        [_collectionView registerClass:[StampCell class] forCellWithReuseIdentifier:@"StampCell"];
    }
    return _collectionView;
}

#pragma mark - UICollectionViewDataSource && Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.stampArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    StampModel *model =[StampModel new];
    if (self.stampArr && self.stampArr.count>indexPath.item) {
        model =self.stampArr[indexPath.row];
    }
    
    StampCell *cell;
    cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"StampCell" forIndexPath:indexPath];
    [cell stampCellContent:model];
    
    
    
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    StampCell *cell =(StampCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    if (cell.isAuthority && cell.isAuthority.integerValue==1) {
        if (!cell.isSelectStatus) {
            
            if (self.oldIndexPath) {
                StampCell *oldCell =(StampCell *)[collectionView cellForItemAtIndexPath:self.oldIndexPath];
                oldCell.isSelectStatus=NO;
            }
            
            
            cell.isSelectStatus =YES;
            StampModel *model;
            model =[StampModel new];
            
            if (self.stampArr && self.stampArr.count>indexPath.row) {
                model = self.stampArr[indexPath.row];
                NSLog(@"%ld",indexPath.row);
                model.isSelectStatus =YES;
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"StampViewNotification" object:model];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"StampViewSelectItemNotification" object:indexPath];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"MOLPostViewNotification" object:@"StampView"];
            [self closeButtonAction];
        }
    }

}

- (void)closeButtonAction {
    [UIView animateWithDuration:0.3 animations:^{
        self.contentView.y = self.height;
        self.backGroundView.backgroundColor = [UIColor clearColor];
    } completion:^(BOOL finished) {
        if (finished) {
            [self.contentView removeFromSuperview];
            [self.backGroundView removeFromSuperview];
            [self removeFromSuperview];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MOLPostViewNotification" object:@"StampView"];
    }];
}

- (void)dealloc{
    NSLog(@"dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
