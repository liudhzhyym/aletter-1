//
//  MOLSystemNotiViewController.m
//  aletter
//
//  Created by moli-2017 on 2018/8/23.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLSystemNotiViewController.h"
#import "MOLSystemNotiView.h"
#import "MOLNotificationViewModel.h"
#import "MOLSystemNotiCell.h"
#import "MOLHead.h"
#import "MOLNotificationGroupModel.h"

#import "MOLStoryDetailViewController.h"
#import "MOLMailDetailViewController.h"


@interface MOLSystemNotiViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) MOLNotificationViewModel *systemNotiViewModel;
@property (nonatomic, weak) MOLSystemNotiView *systemNotiView;

@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) BOOL refreshMethodMore;
@end

@implementation MOLSystemNotiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.systemNotiViewModel = [[MOLNotificationViewModel alloc] init];
    [self setupSystemNotiViewControllerUI];
    [self bindingSystemNotiViewModel];
    
    @weakify(self);
    self.systemNotiView.tableView.mj_header = [MOLDIYRefreshHeader headerWithRefreshingBlock:^{
        @strongify(self);
        [self request_getSystemNoti:NO];
    }];
    
    self.systemNotiView.tableView.mj_footer = [MOLDIYRefreshFooter footerWithRefreshingBlock:^{
        @strongify(self);
        [self request_getSystemNoti:YES];
    }];
    self.systemNotiView.tableView.mj_footer.hidden = YES;
    
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
    dic[@"paraId"] = @"1";
    
    [self.systemNotiViewModel.notiCommand execute:dic];
}
#pragma mark - viewModel
- (void)bindingSystemNotiViewModel
{
    @weakify(self);
    [self.systemNotiViewModel.notiCommand.executionSignals.switchToLatest subscribeNext:^(id x) {
        @strongify(self);
        [self basevc_hiddenLoading];
        [self.systemNotiView.tableView.mj_header endRefreshing];
        [self.systemNotiView.tableView.mj_footer endRefreshing];
        MOLNotificationGroupModel *groupModel = (MOLNotificationGroupModel *)x;
        
        if (!self.refreshMethodMore) {
            [self.systemNotiView.dataSourceArray removeAllObjects];
        }
        
        [self.systemNotiView.dataSourceArray addObjectsFromArray:groupModel.resBody];
        
        [self.systemNotiView.tableView reloadData];
        
        if (self.systemNotiView.dataSourceArray.count >= groupModel.total) {
            self.systemNotiView.tableView.mj_footer.hidden = YES;
        }else{
            self.systemNotiView.tableView.mj_footer.hidden = NO;
            self.currentPage += 1;
        }
    }];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MOLNotificationModel *model = self.systemNotiView.dataSourceArray[indexPath.row];
    if (model.systemType.integerValue == 0) {
        if ([model.pushType isEqualToString:@"story"]) {
            MOLStoryDetailViewController *vc = [[MOLStoryDetailViewController alloc] init];
            vc.storyId = model.storyVO.storyId;
            [self.navigationController pushViewController:vc animated:YES];
            
        }else if ([model.pushType isEqualToString:@"topic"]){
            MOLMailDetailViewController *vc = [[MOLMailDetailViewController alloc] init];
            vc.topicId = model.topicVO.topicId;
            [self.navigationController pushViewController:vc animated:YES];
        }else if ([model.pushType isEqualToString:@"channel"]){
            MOLMailDetailViewController *vc = [[MOLMailDetailViewController alloc] init];
            vc.channelId = model.channelVO.channelId;
            [self.navigationController pushViewController:vc animated:YES];
            
        }else if ([model.pushType isEqualToString:@"comment"]){
            MOLStoryDetailViewController *vc = [[MOLStoryDetailViewController alloc] init];
            vc.storyId = model.commentVO.storyId;
            [self.navigationController pushViewController:vc animated:YES];
        }else if ([model.pushType isEqualToString:@"chat"]){
            
        }else if ([model.pushType isEqualToString:@"h5"]){
            
        }else if ([model.pushType isEqualToString:@"txt"]){
            
        }
    }else if (model.systemType.integerValue == 3){
        NSString *name = @"该帖子已被删除";
        if ([model.pushType isEqualToString:@"comment"]) {
            name = @"该评论已被删除";
        }else if ([model.pushType isEqualToString:@"chat"]){
            name = @"该对话已被删除";
        }
        [MOLToast toast_showWithWarning:YES title:name];

    }else if (model.systemType.integerValue == 1 || model.systemType.integerValue == 2){
        MOLStoryDetailViewController *vc = [[MOLStoryDetailViewController alloc] init];
        vc.storyId = model.outUrlId;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.systemNotiView.dataSourceArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MOLNotificationModel *model = self.systemNotiView.dataSourceArray[indexPath.row];
    return model.systemNotiCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MOLNotificationModel *model = self.systemNotiView.dataSourceArray[indexPath.row];
    MOLSystemNotiCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MOLSystemNotiCell_id"];
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
- (void)setupSystemNotiViewControllerUI
{
    MOLSystemNotiView *systemNotiView = [[MOLSystemNotiView alloc] init];
    _systemNotiView = systemNotiView;
    [self.view addSubview:systemNotiView];
    systemNotiView.tableView.delegate = self;
    systemNotiView.tableView.dataSource = self;
    
    [self basevc_setCenterTitle:@"系统通知" titleColor:HEX_COLOR(0xffffff)];
}

- (void)calculatorSystemNotiViewControllerFrame
{
    self.systemNotiView.frame = self.view.bounds;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self calculatorSystemNotiViewControllerFrame];
}

@end
