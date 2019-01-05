//
//  MOLMeetViewController.m
//  aletter
//
//  Created by moli-2017 on 2018/8/8.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLMeetViewController.h"
#import "MOLHead.h"
#import "MOLMeetView.h"
#import "MOLMeetViewModel.h"
#import "MOLMeetCell.h"
#import "MOLStoryGroupModel.h"
#import "MOLReportViewController.h"
#import "MOLDeleteViewController.h"
#import "MOLPostViewController.h"
#import "MOLAdminHideViewController.h"

#import "MOLAdminRequest.h"

@interface MOLMeetViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) MOLMeetViewModel *meetViewModel;
@property (nonatomic, weak) MOLMeetView *meetView;

@property (nonatomic, assign) NSInteger currentPage;

@property (nonatomic, strong) MOLStoryModel *currentStoryModel;  // 当前的model
@end

@implementation MOLMeetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.meetViewModel = [[MOLMeetViewModel alloc] init];
    [self setupMeetViewControllerUI];
    [self bingingMeetViewModel];
    
    [self request_getMeetListData:NO];
}

#pragma mark - 按钮的点击
- (void)reportStory    // 举报
{
    if (![MOLUserManagerInstance user_isLogin]) {
        [[MOLGlobalManager shareGlobalManager] global_modalChooseViewController];
        return;
    }
    
    if ([MOLUserManagerInstance user_needCompleteInfo]) {
        [[MOLGlobalManager shareGlobalManager] global_modalInfoCheckViewControllerWithAnimated:YES];
        return;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        MOLReportViewController *vc = [[MOLReportViewController alloc] init];
        vc.reportModel = self.currentStoryModel;
        [self presentViewController:vc animated:YES completion:nil];
    });
}

- (void)adminHidenStory  // 管理员隐藏帖子
{
    if (![MOLUserManagerInstance user_isLogin]) {
        [[MOLGlobalManager shareGlobalManager] global_modalChooseViewController];
        return;
    }
    
    if ([MOLUserManagerInstance user_needCompleteInfo]) {
        [[MOLGlobalManager shareGlobalManager] global_modalInfoCheckViewControllerWithAnimated:YES];
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        MOLAdminHideViewController *vc = [[MOLAdminHideViewController alloc] init];
        vc.storyModel = self.currentStoryModel;
        @weakify(self);
        vc.adminHideStoryBlock = ^{
            @strongify(self);
            [self.navigationController popViewControllerAnimated:YES];
        };
        [self presentViewController:vc animated:YES completion:nil];
    });
//    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//    dic[@"isExamine"] = @"2";
//    MOLAdminRequest *r = [[MOLAdminRequest alloc] initRequest_adminHideStoryWithParameter:dic parameterId:self.currentStoryModel.storyId];
//
//    [r baseNetwork_startRequestWithcompletion:^(__kindof MOLBaseNetRequest *request, MOLBaseModel *responseModel, NSInteger code, NSString *message) {
//        if (code == MOL_SUCCESS_REQUEST) {
//            [MOLToast toast_showWithWarning:NO title:@"操作成功"];
//        }else{
//            [MOLToast toast_showWithWarning:YES title:message];
//        }
//    } failure:^(__kindof MOLBaseNetRequest *request) {
//
//    }];
}

- (void)deleteStory   // 删除
{
    // 获取用户信息 判断是否跳转起名字的界面
    if (![MOLUserManagerInstance user_isLogin]) {
        [[MOLGlobalManager shareGlobalManager] global_modalChooseViewController];
        return;
    }
    
    if ([MOLUserManagerInstance user_needCompleteInfo]) {
        [[MOLGlobalManager shareGlobalManager] global_modalInfoCheckViewControllerWithAnimated:YES];
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        MOLDeleteViewController *vc = [[MOLDeleteViewController alloc] init];
        vc.storyModel = self.currentStoryModel;
        @weakify(self);
        vc.deleteStoryBlock = ^{
            @strongify(self);
            [self.navigationController popViewControllerAnimated:YES];
        };
        [self presentViewController:vc animated:YES completion:nil];
    });
}


- (void)setCurrentStoryModel:(MOLStoryModel *)currentStoryModel
{
    _currentStoryModel = currentStoryModel;
    // 设置标题
    [self basevc_setCenterTitle:[NSString stringWithFormat:@"%@の信箱",currentStoryModel.channelVO.channelName] titleColor:HEX_COLOR(0xffffff)];
    
    if ([MOLUserManagerInstance user_isPower]) {
        NSArray *items = [UIBarButtonItem mol_barButtonItemWithTitleNames:@[@"删除",@"隐藏"] targat:self actions:@[@"deleteStory",@"adminHidenStory"]];
        self.navigationItem.rightBarButtonItems = items;
    }else{
        // 设置右边按钮
        UIBarButtonItem *rightItem = [UIBarButtonItem mol_barButtonItemWithTitleName:@"举报" targat:self action:@selector(reportStory)];
        self.navigationItem.rightBarButtonItem = rightItem;
    }
    

}

#pragma mark - 网络请求
- (void)request_getMeetListData:(BOOL)isMore
{
    if (!isMore) {
        self.currentPage = 1;
        [self basevc_showLoading];
    }

    NSMutableDictionary *para = [NSMutableDictionary dictionary];
    para[@"pageNum"] = @(self.currentPage);
    para[@"pageSize"] = @(5);

    [self.meetViewModel.meetStoryListCommand execute:para];
}

#pragma mark - viewModel
- (void)bingingMeetViewModel
{
    @weakify(self);
    [self.meetViewModel.meetStoryListCommand.executionSignals.switchToLatest subscribeNext:^(id x) {
        @strongify(self);
        [self basevc_hiddenLoading];
        MOLStoryGroupModel *groupModel = (MOLStoryGroupModel *)x;
        
        if (groupModel.resBody.count) {
            
            [self.meetView.dataSourceArray addObjectsFromArray:groupModel.resBody];
            
            [self.meetView.collectionView reloadData];
            
            self.currentPage += 1;
            
            if (self.currentStoryModel == nil) {
                self.currentStoryModel = self.meetView.dataSourceArray.firstObject;
            }
        }
        
    }];
}


#pragma mark - collectionviewdelegate
//分区，组
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

//每一分区的单元个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.meetView.dataSourceArray.count;
}

//单元格复用
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MOLStoryModel *model = self.meetView.dataSourceArray[indexPath.row];
    // 获取数据
    MOLMeetCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MOLMeetCell_id" forIndexPath:indexPath];
    cell.storyModel = model;
    return cell;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    float pageWidth = scrollView.width - 20 + 10; // width + space
    
    float currentOffset = scrollView.contentOffset.x;
    float targetOffset = targetContentOffset->x;
    float newTargetOffset = 0;
    
    if (targetOffset > currentOffset)
        newTargetOffset = ceilf(currentOffset / pageWidth) * pageWidth;
    else
        newTargetOffset = floorf(currentOffset / pageWidth) * pageWidth;
    
    if (newTargetOffset < 0)
        newTargetOffset = 0;
    else if (newTargetOffset > scrollView.contentSize.width)
        newTargetOffset = scrollView.contentSize.width;
    
    targetContentOffset->x = currentOffset;
    [scrollView setContentOffset:CGPointMake(newTargetOffset, 0) animated:YES];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    CGPoint pInView = [self.view convertPoint:self.meetView.collectionView.center toView:self.meetView.collectionView];
    // 获取这一点的indexPath
    NSIndexPath *indexPathNow = [self.meetView.collectionView indexPathForItemAtPoint:pInView];
    // 赋值给记录当前坐标的变量
    MOLStoryModel *model = self.meetView.dataSourceArray[indexPathNow.row];
    self.currentStoryModel = model;
    
    if (indexPathNow.row > (self.meetView.dataSourceArray.count - 3)) {
        [self request_getMeetListData:YES];
    }
}

#pragma mark - UI
- (void)setupMeetViewControllerUI
{
    MOLMeetView *meetView = [[MOLMeetView alloc] init];
    _meetView = meetView;
    [self.view addSubview:meetView];
    
    meetView.collectionView.delegate = self;
    meetView.collectionView.dataSource = self;
}

- (void)calculatorMeetViewControllerFrame
{
    self.meetView.frame = self.view.bounds;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self calculatorMeetViewControllerFrame];
}

@end
