//
//  MOLHomeCollectionViewController.m
//  aletter
//
//  Created by moli-2017 on 2018/7/31.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLHomeCollectionViewController.h"
#import "MOLMailDetailViewController.h"
#import "MOLHomeCollectionViewCell.h"
#import "MOLHead.h"
#import "MOLHomeViewModel.h"
#import "MOLMailGroupModel.h"

@interface MOLHomeCollectionViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) NSMutableArray *dataSourceArray;
@property (nonatomic, strong) MOLHomeViewModel *homeViewModel;
@end

@implementation MOLHomeCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _dataSourceArray = [NSMutableArray array];
    self.homeViewModel = [[MOLHomeViewModel alloc] init];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor clearColor];
    [self setupHomeCollectionViewControllerUI];
    
    [self bindingHomeViewModel];
    [self request_getHome];
}

#pragma mark - 网络请求
- (void)request_getHome
{
    [self.homeViewModel.homeCommand execute:@(self.catogeryId)];
    [self basevc_showLoading];
}

#pragma mark - viewModel
- (void)bindingHomeViewModel
{
    [self.homeViewModel.homeCommand.executionSignals.switchToLatest subscribeNext:^(id x) {
        MOLMailGroupModel *groupModel = (MOLMailGroupModel *)x;
        [self basevc_hiddenLoading];
        [self.dataSourceArray removeAllObjects];
        
        // 创造数据 - 不分组
        for (NSInteger i = 0; i < groupModel.resBody.count; i++) {
            MOLMailChannelModel *model = groupModel.resBody[i];
            for (NSInteger j = 0; j < model.channelVOList.count; j++) {
                MOLMailModel *mailModel = model.channelVOList[j];
                [self.dataSourceArray addObject:mailModel];
            }
        }
        
        // 创造数据 - 分组
//        [self.dataSourceArray addObjectsFromArray:groupModel.resBody];
        
        if (self.dataSourceArray.count) {
            [self.collectionView reloadData];
        }else{
            [self basevc_showBlankPageWithY:0 image:@"mine_noData" title:nil superView:self.collectionView];
        }
    }];
    
    [self.homeViewModel.homeCommand.errors subscribeNext:^(id x) {
        [self basevc_hiddenLoading];
        [self basevc_showErrorPageWithY:0 select:@selector(request_getHome) superView:self.collectionView];
    }];
}

#pragma mark - UI
- (void)setupHomeCollectionViewControllerUI
{
    CGFloat itemW = MOL_SCREEN_ADAPTER(80);
    CGFloat itemH = itemW * 103 / 80;
    self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
    self.flowLayout.minimumLineSpacing = 28;
    self.flowLayout.minimumInteritemSpacing = (MOL_SCREEN_WIDTH - 3 * itemW - 50) * 0.5;
    CGFloat magin = 0;
    if (!iOS10) {
        magin = 10;
    }
    self.flowLayout.sectionInset = UIEdgeInsetsMake(64+MOL_StatusBarHeight-magin, 25, 0, 25);
    self.flowLayout.itemSize = CGSizeMake(itemW, itemH);
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, MOL_SCREEN_WIDTH, MOL_SCREEN_HEIGHT) collectionViewLayout:self.flowLayout];
    _collectionView.backgroundColor = [UIColor clearColor];
    if (@available(iOS 11.0, *)) {
        _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.edgesForExtendedLayout = UIRectEdgeNone;
    _collectionView.contentInset = UIEdgeInsetsMake(0, 0, 70 + MOL_TabbarSafeBottomMargin, 0);
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    [_collectionView registerClass:[MOLHomeCollectionViewCell class] forCellWithReuseIdentifier:@"MOLHomeCollectionViewCell_id"];
    
    [self.view addSubview:_collectionView];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

#pragma mark - collectionviewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    MOLMailModel *model = self.dataSourceArray[indexPath.row];
    MOLMailDetailViewController *vc = [[MOLMailDetailViewController alloc] init];
    vc.channelId = [NSString stringWithFormat:@"%@",model.channelId];
    [self.navigationController pushViewController:vc animated:YES];
}
//分区，组
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
//    return self.dataSourceArray.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataSourceArray.count;
//    MOLMailChannelModel *channelModel = self.dataSourceArray[section];
//    return channelModel.channelVOList.count;
}

//单元格复用
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MOLMailModel *model = self.dataSourceArray[indexPath.row];
//    MOLMailChannelModel *channelModel = self.dataSourceArray[indexPath.section];
//    MOLMailModel *model = channelModel.channelVOList[indexPath.row];
    MOLHomeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MOLHomeCollectionViewCell_id" forIndexPath:indexPath];
    cell.mailModel = model;
    return cell;
}
@end
