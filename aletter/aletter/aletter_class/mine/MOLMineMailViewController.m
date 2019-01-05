//
//  MOLMineMailViewController.m
//  aletter
//
//  Created by moli-2017 on 2018/8/17.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLMineMailViewController.h"
#import "MOLStoryDetailViewController.h"
#import "MOLHead.h"
#import "MOLMineMailViewModel.h"
#import "MOLMineMailCell.h"
#import "MOLMineMailReusableView.h"
#import "MOLStoryGroupModel.h"
#import "MOLMineMailGroupModel.h"

@interface MOLMineMailViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, strong) MOLMineMailViewModel *mineMailViewModel;

@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) BOOL refreshMethodMore;

@property (nonatomic, assign) BOOL endDrag;
@end

@implementation MOLMineMailViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.mineMailViewModel = [[MOLMineMailViewModel alloc] init];
    [self setupMineMailViewControllerUI];
    [self bindingMineMailViewModel];
    
    @weakify(self);
    self.mineMailView.collectionView.mj_footer = [MOLDIYRefreshFooter footerWithRefreshingBlock:^{
        @strongify(self);
        [self request_getMyStoryData:YES];
    }];
    self.mineMailView.collectionView.mj_footer.hidden = YES;
    
    [self request_mineMail];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteStoryNoti:) name:@"MOL_DELETE_STORY" object:nil];
}

- (void)deleteStoryNoti:(NSNotification *)noti
{
    NSString *storyId = (NSString *)noti.object;
    __block BOOL dobreak = NO;
    for (NSInteger i = 0; !dobreak && i < self.mineMailView.dataSourceArray.count; i++) {
        MOLMineMailModel *model = self.mineMailView.dataSourceArray[i];
        [model.storyList enumerateObjectsUsingBlock:^(MOLStoryModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if ([obj.storyId isEqualToString:storyId]) {
                [model.storyList removeObject:obj];
                [self.mineMailView.collectionView reloadData];
                dobreak = YES;
                *stop = YES;
            }
        }];
    }
}

#pragma mark - viewModel
- (void)bindingMineMailViewModel
{
    // 我的帖子列表信号
    @weakify(self);
    [self.mineMailViewModel.myStoryCommand.executionSignals.switchToLatest subscribeNext:^(id x) {
        @strongify(self);
        [self basevc_hiddenLoading];
        NSMutableArray *newDataArr = [NSMutableArray array];
        
        NSMutableArray *lastArr = [NSMutableArray array];
        
        [self.mineMailView.collectionView.mj_header endRefreshing];
        [self.mineMailView.collectionView.mj_footer endRefreshing];
        MOLMineMailGroupModel *groupModel = (MOLMineMailGroupModel *)x;
        [newDataArr addObjectsFromArray:groupModel.resBody];
        
        if (!self.refreshMethodMore) {
            [self.mineMailView.dataSourceArray removeAllObjects];
        }else{
            
            // 获取新数据第一个对象
            MOLMineMailModel *firModel = newDataArr.firstObject;
            
            // 获取数据源最后一个对象
            MOLMineMailModel *model = self.mineMailView.dataSourceArray.lastObject;
            
            [lastArr addObjectsFromArray:model.storyList];
            
            if ([firModel.name isEqualToString:model.name]) {
                [lastArr addObjectsFromArray:firModel.storyList];
                [newDataArr removeObjectAtIndex:0];
            }
            
            MOLMineMailModel *newModel = [[MOLMineMailModel alloc] init];
            newModel.name = model.name;
            newModel.storyList = lastArr;
            [self.mineMailView.dataSourceArray removeLastObject];
            [self.mineMailView.dataSourceArray addObject:newModel];
        }
        
        [self.mineMailView.dataSourceArray addObjectsFromArray:newDataArr];
        
        [self.mineMailView.collectionView reloadData];
        
        if (!groupModel.resBody.count) {
            self.mineMailView.collectionView.mj_footer.hidden = YES;
        }else{
            self.mineMailView.collectionView.mj_footer.hidden = NO;
            self.currentPage += 1;
        }
        
        if (!self.mineMailView.dataSourceArray.count) {
            [self basevc_showBlankPageWithY:-(100 + MOL_StatusBarHeight) image:@"mine_noData" title:nil superView:self.mineMailView.collectionView];
        }
    }];
}

#pragma mark - 网络请求
- (void)request_mineMail
{
    [self request_getMyStoryData:NO];
    [self basevc_showLoading];
}
- (void)request_getMyStoryData:(BOOL)isMore
{
    self.refreshMethodMore = isMore;
    if (!isMore) {
        self.currentPage = 1;
    }
    
    NSMutableDictionary *para = [NSMutableDictionary dictionary];
    para[@"pageNum"] = @(self.currentPage);
    para[@"pageSize"] = @(MOL_REQUEST_OTHER);
    
    [self.mineMailViewModel.myStoryCommand execute:para];
}

#pragma mark - collectionviewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    MOLMineMailModel *model = self.mineMailView.dataSourceArray[indexPath.section];
    MOLStoryModel *story = model.storyList[indexPath.row];
    MOLStoryDetailViewController *vc = [[MOLStoryDetailViewController alloc] init];
    vc.storyId = story.storyId;
    @weakify(self);
    vc.shareMineStoryBlock = ^{
        @strongify(self);
        story.privateSign = 2;
        [self.mineMailView.collectionView reloadData];
    };
    [self.navigationController pushViewController:vc animated:YES];
}
//分区，组
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.mineMailView.dataSourceArray.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    MOLMineMailModel *model = self.mineMailView.dataSourceArray[section];
    return model.storyList.count;
}

//单元格复用
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MOLMineMailModel *model = self.mineMailView.dataSourceArray[indexPath.section];
    MOLStoryModel *story = model.storyList[indexPath.row];
    MOLMineMailCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MOLMineMailCell_id" forIndexPath:indexPath];
    cell.storyModel = story;
    return cell;
}

//头部大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    CGFloat sizeW = MOL_SCREEN_WIDTH;
    CGFloat sizeH = 80;
    return CGSizeMake(sizeW, sizeH);
    
}

//集合视图头部或者尾部
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    MOLMineMailModel *model = self.mineMailView.dataSourceArray[indexPath.section];
    
    MOLMineMailReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"MOLMineMailReusableView_id" forIndexPath:indexPath];
    view.name = [NSString stringWithFormat:@"%ld月",model.name.integerValue];
    view.count = [NSString stringWithFormat:@"%ld封",model.storyList.count];
    return view;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.endDrag = NO;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    self.endDrag = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.endDrag && (scrollView.contentOffset.y >= MOL_MINE_MINPOP && scrollView.contentOffset.y <= MOL_MINE_MAXPOP)) {
        dispatch_async(dispatch_get_main_queue(), ^{
            CATransition *animation = [CATransition animation];
            animation.duration = 0.35;
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
            animation.type = kCATransitionPush;
            animation.subtype = kCATransitionFromBottom;
            [self.view.window.layer addAnimation:animation forKey:@"CATransition_FromTop"];
            [self dismissViewControllerAnimated:NO completion:nil];
        });
    }
}

#pragma mark - UI
- (void)setupMineMailViewControllerUI
{
    MOLMineMailView *mineMailView = [[MOLMineMailView alloc] init];
    _mineMailView = mineMailView;
    [self.view addSubview:mineMailView];
    mineMailView.collectionView.delegate = self;
    mineMailView.collectionView.dataSource = self;
}

- (void)calculatorMineMailViewControllerFrame
{
    self.mineMailView.frame = self.view.bounds;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self calculatorMineMailViewControllerFrame];
}

@end
