//
//  MOLMineLikeViewController.m
//  aletter
//
//  Created by moli-2017 on 2018/8/17.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLMineLikeViewController.h"
#import "MOLMineLikeView.h"
#import "MOLMineLikeViewModel.h"
#import "MOLHead.h"
#import "MOLStoryGroupModel.h"

#import "MOLStoryDetailViewController.h"
#import "MOLMailDetailViewController.h"
#import "MOLMailDetailRichTextCell.h"
#import "MOLMailDetailVoiceCell.h"

@interface MOLMineLikeViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) MOLMineLikeViewModel *mineLikeViewModel;
@property (nonatomic, weak) MOLMineLikeView *mineLikeView;

@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) BOOL refreshMethodMore;
@end

@implementation MOLMineLikeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.mineLikeViewModel = [[MOLMineLikeViewModel alloc] init];
    [self setupMineLikeViewControllerUI];
    [self bindingMineLikeViewModel];
    
    @weakify(self);
    self.mineLikeView.tableView.mj_header = [MOLDIYRefreshHeader headerWithRefreshingBlock:^{
        @strongify(self);
        [self request_getLikeStoryData:NO];
    }];
    
    self.mineLikeView.tableView.mj_footer = [MOLDIYRefreshFooter footerWithRefreshingBlock:^{
        @strongify(self);
        [self request_getLikeStoryData:YES];
    }];
    self.mineLikeView.tableView.mj_footer.hidden = YES;
    
    [self request_getLikeStoryData:NO];
}

#pragma mark - viewModel
- (void)bindingMineLikeViewModel
{
    // 喜欢帖子列表信号
    @weakify(self);
    [self.mineLikeViewModel.likeStoryCommand.executionSignals.switchToLatest subscribeNext:^(id x) {
        @strongify(self);
        
        [self.mineLikeView.tableView.mj_header endRefreshing];
        [self.mineLikeView.tableView.mj_footer endRefreshing];
        MOLStoryGroupModel *groupModel = (MOLStoryGroupModel *)x;
        
        if (!self.refreshMethodMore) {
            [self.mineLikeView.dataSourceArray removeAllObjects];
        }
        
        [self.mineLikeView.dataSourceArray addObjectsFromArray:groupModel.resBody];
        
        [self.mineLikeView.tableView reloadData];
        
        if (self.mineLikeView.dataSourceArray.count >= groupModel.total || !groupModel.resBody.count) {
            self.mineLikeView.tableView.mj_footer.hidden = YES;
        }else{
            self.mineLikeView.tableView.mj_footer.hidden = NO;
            self.currentPage += 1;
        }
        
        if (!self.mineLikeView.dataSourceArray.count) {
            [self basevc_showBlankPageWithY:0 image:@"mine_noData" title:nil superView:self.mineLikeView.tableView];
        }
    }];
}

#pragma mark - 网络请求
- (void)request_getLikeStoryData:(BOOL)isMore
{
    self.refreshMethodMore = isMore;
    if (!isMore) {
        self.currentPage = 1;
    }
    
    NSMutableDictionary *para = [NSMutableDictionary dictionary];
    para[@"pageNum"] = @(self.currentPage);
    para[@"pageSize"] = @(MOL_REQUEST_STORY);
    
    [self.mineLikeViewModel.likeStoryCommand execute:para];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MOLStoryModel *model = self.mineLikeView.dataSourceArray[indexPath.row];
    MOLStoryDetailViewController *vc = [[MOLStoryDetailViewController alloc] init];
    vc.storyId = model.storyId;
    [self.navigationController pushViewController:vc animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.mineLikeView.dataSourceArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MOLStoryModel *model = self.mineLikeView.dataSourceArray[indexPath.row];
    if (!model.audioUrl.length) {
        return model.richTextCellHeight;
    }else{
        return model.voiceCellHeight;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MOLStoryModel *model = self.mineLikeView.dataSourceArray[indexPath.row];
    if (!model.audioUrl.length) {
        MOLMailDetailRichTextCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MOLMailDetailRichTextCell_id"];
        @weakify(self);
        cell.clickHighText = ^(MOLStoryModel *model) {
            @strongify(self);
            MOLMailDetailViewController *vc = [[MOLMailDetailViewController alloc] init];
            vc.topicId = model.topicVO.topicId;
            [self.navigationController pushViewController:vc animated:YES];
        };
        cell.storyModel = model;
        return cell;
    }else{
        MOLMailDetailVoiceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MOLMailDetailVoiceCell_id"];
        @weakify(self);
        cell.clickHighText = ^(MOLStoryModel *model) {
            @strongify(self);
            MOLMailDetailViewController *vc = [[MOLMailDetailViewController alloc] init];
            vc.topicId = model.topicVO.topicId;
            [self.navigationController pushViewController:vc animated:YES];
        };
        cell.storyModel = model;
        return cell;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

#pragma mark - UI
- (void)setupMineLikeViewControllerUI
{
    MOLMineLikeView *mineLikeView = [[MOLMineLikeView alloc] init];
    _mineLikeView = mineLikeView;
    [self.view addSubview:mineLikeView];
    mineLikeView.tableView.delegate = self;
    mineLikeView.tableView.dataSource = self;
    
    [self basevc_setCenterTitle:@"我喜欢的信件" titleColor:HEX_COLOR(0xffffff)];
}

- (void)calculatorMineLikeViewControllerFrame
{
    self.mineLikeView.frame = self.view.bounds;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self calculatorMineLikeViewControllerFrame];
}
@end
