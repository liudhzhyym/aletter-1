//
//  MOLInteractNotiViewController.m
//  aletter
//
//  Created by moli-2017 on 2018/8/23.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLInteractNotiViewController.h"
#import "MOLInteractNotiView.h"
#import "MOLNotificationViewModel.h"
#import "MOLInteractNotiCell.h"
#import "MOLHead.h"
#import "MOLNotificationGroupModel.h"
#import "MOLStoryDetailViewController.h"

@interface MOLInteractNotiViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) MOLNotificationViewModel *interactNotiViewModel;
@property (nonatomic, weak) MOLInteractNotiView *interactNotiView;

@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) BOOL refreshMethodMore;
@end

@implementation MOLInteractNotiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.interactNotiViewModel = [[MOLNotificationViewModel alloc] init];
    [self setupInteractNotiViewControllerUI];
    [self bindingSystemNotiViewModel];
    
    @weakify(self);
    self.interactNotiView.tableView.mj_header = [MOLDIYRefreshHeader headerWithRefreshingBlock:^{
        @strongify(self);
        [self request_getSystemNoti:NO];
    }];
    
    self.interactNotiView.tableView.mj_footer = [MOLDIYRefreshFooter footerWithRefreshingBlock:^{
        @strongify(self);
        [self request_getSystemNoti:YES];
    }];
    self.interactNotiView.tableView.mj_footer.hidden = YES;
    
    [self request_getSystemNoti:NO];
    [self basevc_showLoading];
}

#pragma mark - 网络请求
- (void)request_getSystemNoti:(BOOL)isMore
{
    self.refreshMethodMore = isMore;
    if (!isMore) {
        self.currentPage = 1;
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    NSMutableDictionary *para = [NSMutableDictionary dictionary];
    para[@"pageNum"] = @(self.currentPage);
    para[@"pageSize"] = @(10);
    dic[@"para"] = para;
    dic[@"paraId"] = @"2";
    
    [self.interactNotiViewModel.notiCommand execute:dic];
}

- (void)request_readInteract:(NSString *)paraId
{
    [self.interactNotiViewModel.readInteractCommand execute:paraId];
}
#pragma mark - viewModel
- (void)bindingSystemNotiViewModel
{
    @weakify(self);
    [self.interactNotiViewModel.notiCommand.executionSignals.switchToLatest subscribeNext:^(id x) {
        @strongify(self);
        [self basevc_hiddenLoading];
        [self.interactNotiView.tableView.mj_header endRefreshing];
        [self.interactNotiView.tableView.mj_footer endRefreshing];
        MOLNotificationGroupModel *groupModel = (MOLNotificationGroupModel *)x;
        
        if (!self.refreshMethodMore) {
            [self.interactNotiView.dataSourceArray removeAllObjects];
        }
        
        [self.interactNotiView.dataSourceArray addObjectsFromArray:groupModel.resBody];
        
        [self.interactNotiView.tableView reloadData];
        
        if (self.interactNotiView.dataSourceArray.count >= groupModel.total) {
            self.interactNotiView.tableView.mj_footer.hidden = YES;
        }else{
            self.interactNotiView.tableView.mj_footer.hidden = NO;
            self.currentPage += 1;
        }
    }];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // 获取数据
    MOLNotificationModel *model = self.interactNotiView.dataSourceArray[indexPath.row];
    MOLStoryDetailViewController *vc = [[MOLStoryDetailViewController alloc] init];
    vc.storyId = model.storyVO.storyId;
    [self.navigationController pushViewController:vc animated:YES];
    
    // 置为已读
    [self request_readInteract:model.msgId];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.interactNotiView.dataSourceArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MOLNotificationModel *model = self.interactNotiView.dataSourceArray[indexPath.row];
    return model.interactNotiCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MOLNotificationModel *model = self.interactNotiView.dataSourceArray[indexPath.row];
    MOLInteractNotiCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MOLInteractNotiCell_id"];
    cell.notiModel = model;
    return cell;
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
- (void)setupInteractNotiViewControllerUI
{
    MOLInteractNotiView *interactNotiView = [[MOLInteractNotiView alloc] init];
    _interactNotiView = interactNotiView;
    [self.view addSubview:interactNotiView];
    interactNotiView.tableView.delegate = self;
    interactNotiView.tableView.dataSource = self;
    
    [self basevc_setCenterTitle:@"互动通知" titleColor:HEX_COLOR(0xffffff)];
}

- (void)calculatorInteractNotiViewControllerFrame
{
    self.interactNotiView.frame = self.view.bounds;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self calculatorInteractNotiViewControllerFrame];
}

@end
