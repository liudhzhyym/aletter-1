//
//  MOLMailDetailViewController.m
//  aletter
//
//  Created by moli-2017 on 2018/8/3.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLMailDetailViewController.h"
#import "MOLTopicListViewController.h"
#import "MOLStoryDetailViewController.h"
#import "MOLMailboxViewController.h"
#import "MOLPostViewController.h"

#import "MOLMailDetailSectionView.h"
#import "MOLMailDetailRichTextCell.h"
#import "MOLMailDetailVoiceCell.h"
#import "MOLMailDetailView.h"
#import "MOLHead.h"
#import "MOLFiltrateView.h"
#import "MOLStoryGroupModel.h"
#import "MOLTopicGroupModel.h"
#import "MOLLightLandModel.h"
#import "MOLLightWeatherModel.h"
#import "MOLLightStampModel.h"

#import "MOLMailDetailViewModel.h"
#import "PrecautionsViewController.h"
#import "MOLSheildRequest.h"

@interface MOLMailDetailViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) MOLMailDetailView *mailDetailView;
@property (nonatomic, strong) MOLMailDetailViewModel *mailDetailViewModel;
@property (nonatomic, strong) MOLMailDetailSectionView *sectionView;
@property (nonatomic, weak) MOLFiltrateView *filtrateView;

@property (nonatomic, strong) MOLMailModel *mailModel;  // 邮箱modle （频道（邮箱）帖子列表用）
@property (nonatomic, strong) MOLLightTopicModel *topicModel;  // 话题modle（话题帖子列表用）

@property (nonatomic, strong) NSMutableArray *ageArray;
@property (nonatomic, strong) NSMutableArray *sexArray;

@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) BOOL refreshMethodMore;

// 参数
@property (nonatomic, strong) NSString *sex;
@property (nonatomic, strong) NSArray *age;
@property (nonatomic, strong) NSString *admin;

@property (nonatomic, weak) UIButton *publishButton;  // 发布按钮

@property (nonatomic, strong) NSMutableArray *sheildArray; // 屏蔽数组
@end

@implementation MOLMailDetailViewController

- (void)dealloc
{
    [_filtrateView removeFromSuperview];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.admin = @"0";
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.sheildArray = [NSMutableArray array];  // 屏蔽数组

    self.ageArray = [NSMutableArray array];
    self.sexArray = [NSMutableArray array];
    
    self.mailDetailViewModel = [[MOLMailDetailViewModel alloc] init];
    
    [self setupMailDetailViewControllerUI];
    [self bindingMailDetailViewModel];
    
    @weakify(self);
    self.mailDetailView.tableView.mj_header = [MOLDIYRefreshHeader headerWithRefreshingBlock:^{
        @strongify(self);
        if (self.channelId.length) {
            if ([MOLUserManagerInstance user_isLogin]) {
                [self request_getSheildList:^{
                    @strongify(self);
                    [self request_getMailStoryListDataWithMore:NO];
                }];
            }else{
                [self request_getMailStoryListDataWithMore:NO];
            }
        }else{
            [self request_getTopicStoryListDataWithMore:NO];
        }
    }];
    
    self.mailDetailView.tableView.mj_footer = [MOLDIYRefreshFooter footerWithRefreshingBlock:^{
        @strongify(self);
        if (self.channelId.length) {
            [self request_getMailStoryListDataWithMore:YES];
        }else{
            [self request_getTopicStoryListDataWithMore:YES];
        }
    }];
    self.mailDetailView.tableView.mj_footer.hidden = YES;
    
    // 获取数据
    if (self.channelId.length) {
        [self.mailDetailViewModel.hotTopicCommand execute:self.channelId];
//        [self request_getMailStoryListDataWithMore:NO];
        if ([MOLUserManagerInstance user_isLogin]) {
            [self request_getSheildList:^{
                @strongify(self);
                [self request_getMailStoryListDataWithMore:NO];
            }];
        }else{
            [self request_getMailStoryListDataWithMore:NO];
        }
    }else{
        [self request_getTopicStoryListDataWithMore:NO];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteStoryNoti:) name:@"MOL_DELETE_STORY" object:nil];
    
}


- (void)deleteStoryNoti:(NSNotification *)noti
{
    NSString *storyId = (NSString *)noti.object;
    [self.mailDetailView.dataSourceArray enumerateObjectsUsingBlock:^(MOLStoryModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
       
        if ([obj.storyId isEqualToString:storyId]) {
            [self.mailDetailView.dataSourceArray removeObject:obj];
            [self.mailDetailView.tableView reloadData];
            *stop = YES;
        }
    }];
}

#pragma mark - 网络请求
- (void)request_getSheildList:(void(^)(void))resultBlock
{
    MOLSheildRequest *r = [[MOLSheildRequest alloc] initRequest_sheildListWithParameter:nil];
    [r baseNetwork_startRequestWithcompletion:^(__kindof MOLBaseNetRequest *request, MOLBaseModel *responseModel, NSInteger code, NSString *message) {
        [self.sheildArray removeAllObjects];
        MOLSheildGroupModel *groupM = (MOLSheildGroupModel *)responseModel;
        [self.sheildArray addObjectsFromArray:groupM.resBody];
        
        if (resultBlock) {
            resultBlock();
        }
    } failure:^(__kindof MOLBaseNetRequest *request) {
        if (resultBlock) {
            resultBlock();
        }
    }];
}
- (void)request_getMailStoryListDataWithMore:(BOOL)isMore
{
    self.refreshMethodMore = isMore;
    if (!isMore) {
        self.currentPage = 1;
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    NSMutableDictionary *para = [NSMutableDictionary dictionary];
    para[@"pageNum"] = @(self.currentPage);
    para[@"pageSize"] = @(MOL_REQUEST_STORY);
    if (self.age.count) {
        para[@"age"] = self.age;
    }
    if (self.sex.length) {
        para[@"sex"] = self.sex;
    }
    
    if (self.admin.length && [MOLUserManagerInstance user_isPower]) {
        para[@"adminSign"] = self.admin;
    }
    
    dic[@"para"] = para;
    dic[@"paraId"] = self.channelId;
    [self.mailDetailViewModel.mailStoryListCommand execute:dic];
}

- (void)request_getTopicStoryListDataWithMore:(BOOL)isMore
{
    self.refreshMethodMore = isMore;
    if (!isMore) {
        self.currentPage = 1;
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    NSMutableDictionary *para = [NSMutableDictionary dictionary];
    para[@"pageNum"] = @(self.currentPage);
    para[@"pageSize"] = @(MOL_REQUEST_STORY);
    if (self.age.count) {
        para[@"age"] = self.age;
    }
    if (self.sex.length) {
        para[@"sex"] = self.sex;
    }
    
    dic[@"para"] = para;
    dic[@"paraId"] = self.topicId;
    [self.mailDetailViewModel.topicStoryListCommand execute:dic];
}

#pragma mark - viewModel
- (void)bindingMailDetailViewModel
{
    @weakify(self);
    // 点击雷区
    [self.sectionView.landSubject subscribeNext:^(id x) {
        @strongify(self);
        MOLStoryDetailViewController *vc = [[MOLStoryDetailViewController alloc] init];
        vc.storyId = self.mailModel.landMineVO.storyId;
        [self.navigationController pushViewController:vc animated:YES];
    }];
    
    // 点击组头话题 - 更多按钮
    [self.sectionView.moreSubject subscribeNext:^(id x) {
        @strongify(self);
        MOLTopicListViewController *vc = [[MOLTopicListViewController alloc] init];
        vc.channelId = self.channelId;
        [self.navigationController pushViewController:vc animated:YES];
    }];
    
    // 点击组头话题
    [self.sectionView.topicSubject subscribeNext:^(id x) {
        @strongify(self);
        NSString *topicId = [NSString stringWithFormat:@"%@",x];
        MOLMailDetailViewController *vc = [[MOLMailDetailViewController alloc] init];
        vc.topicId = topicId;
        [self.navigationController pushViewController:vc animated:YES];
    }];
    
    // 热门话题
    [self.mailDetailViewModel.hotTopicCommand.executionSignals.switchToLatest subscribeNext:^(id x) {
        @strongify(self);

        MOLTopicGroupModel *groupModel = (MOLTopicGroupModel *)x;
        if (groupModel.resBody.count) {
            self->_sectionView.topicArray = groupModel.resBody;
        }
        [self.mailDetailView.tableView reloadData];
    }];
    
    // 频道（邮箱）帖子列表
    [self.mailDetailViewModel.mailStoryListCommand.executionSignals.switchToLatest subscribeNext:^(id x) {
        @strongify(self);
        [self.mailDetailView.tableView.mj_header endRefreshing];
        [self.mailDetailView.tableView.mj_footer endRefreshing];
        MOLStoryGroupModel *groupModel = (MOLStoryGroupModel *)x;
        
        if (groupModel.code != MOL_SUCCESS_REQUEST) {
            return;
        }
        
        if (!self.refreshMethodMore) {
            [self.mailDetailView.dataSourceArray removeAllObjects];
            self.mailModel = groupModel.channelVO;
            if ([MOLSwitchManager shareSwitchManager].normalStatus) {
                self.publishButton.hidden = (self.mailModel.isPublish == 3);
            }
            self.mailDetailView.title = [NSString stringWithFormat:@"%@の信箱",self.mailModel.channelName];
            if (self.mailModel.landMineVO.info.length) {
                self->_sectionView.needTap = self.mailModel.landMineVO.storyId.length;
                self->_sectionView.warningName = self.mailModel.landMineVO.info;
            }
        }
        
        NSArray *SheildArr = [self filtrationSheildData:groupModel.storyList];
        
        [self.mailDetailView.dataSourceArray addObjectsFromArray:SheildArr];
        
        [self.mailDetailView.tableView reloadData];
        
        if (self.mailDetailView.dataSourceArray.count >= groupModel.total || !groupModel.storyList.count) {
            self.mailDetailView.tableView.mj_footer.hidden = YES;
        }else{
            self.mailDetailView.tableView.mj_footer.hidden = NO;
            self.currentPage += 1;
        }
    }];
    
    // 话题帖子列表
    [self.mailDetailViewModel.topicStoryListCommand.executionSignals.switchToLatest subscribeNext:^(id x) {
        @strongify(self);
        [self.mailDetailView.tableView.mj_header endRefreshing];
        [self.mailDetailView.tableView.mj_footer endRefreshing];
        MOLStoryGroupModel *groupModel = (MOLStoryGroupModel *)x;
        
        if (groupModel.code != MOL_SUCCESS_REQUEST) {
            return;
        }
        
        if (!self.refreshMethodMore) {
            [self.mailDetailView.dataSourceArray removeAllObjects];
            self.topicModel = groupModel.topicVO;
            self.mailDetailView.title = self.topicModel.topicName;
        }
        
        [self.mailDetailView.dataSourceArray addObjectsFromArray:groupModel.storyList];
        
        // 屏蔽话题发帖
        MOLStoryModel *firstM = self.mailDetailView.dataSourceArray.firstObject;
        self.mailModel = firstM.channelVO;
        if ([MOLSwitchManager shareSwitchManager].normalStatus) {
            self.publishButton.hidden = (self.mailModel.isPublish == 3);
        }
        
        [self.mailDetailView.tableView reloadData];
        
        if (self.mailDetailView.dataSourceArray.count >= groupModel.total) {
            self.mailDetailView.tableView.mj_footer.hidden = YES;
        }else{
            self.mailDetailView.tableView.mj_footer.hidden = NO;
            self.currentPage += 1;
        }
    }];
    
    // 筛选提交信息
    [self.filtrateView.commitReplySubject subscribeNext:^(id x) {
        @strongify(self);
        NSDictionary *dic = (NSDictionary *)x;
        NSArray *sexArr = [dic mol_jsonStringArray:@"sexArr"];
        NSArray *ageArr = [dic mol_jsonStringArray:@"ageArr"];
        NSArray *adminArr = [dic mol_jsonStringArray:@"adminArr"];
        
        NSMutableArray *ageArrM = [NSMutableArray array];
        
        // 获取自己的性别
        MOLUserModel *user = [MOLUserManagerInstance user_getUserInfo];
        NSInteger sex = user.sex;
        NSInteger othersex = user.sex == 1 ? 2 : 1;
        
        if ([sexArr containsObject:@"全部"]) {
            self.sex = nil;
        }else if ([sexArr containsObject:MOL_SEX_SAME]){
            self.sex = [NSString stringWithFormat:@"%ld",(long)sex];
        }else if ([sexArr containsObject:MOL_SEX_UNSAME]){
            self.sex = [NSString stringWithFormat:@"%ld",(long)othersex];
        }else{
            self.sex = nil;
        }
        
        // 管理员
        if ([MOLUserManagerInstance user_isPower]) {
             if ([adminArr containsObject:@"全部"]) {
                 self.admin = @"0";
             }else if ([adminArr containsObject:@"用户"]){
                 self.admin = @"2";
             }else if ([adminArr containsObject:@"官方"]){
                 self.admin = @"1";
             }else{
                self.admin = nil;
             }
        }else{
            self.admin = nil;
        }
        
        
        for (NSInteger i = 0; i < ageArr.count; i++) {
            
            NSString *ageName = ageArr[i];
            if ([ageName isEqualToString:@"全部"]) {
                
            }else if ([ageName isEqualToString:MOL_AGE_75]){
                NSString *name = @"75";
                [ageArrM addObject:name];
            }else if ([ageName isEqualToString:MOL_AGE_00]){
                NSString *name = @"100";
                [ageArrM addObject:name];
            }else{
                NSString *name = [ageName substringToIndex:ageName.length - 1];
                [ageArrM addObject:name];
            }
        }
        
        self.age = ageArrM;
        
        if (self.channelId.length) {
            [self request_getMailStoryListDataWithMore:NO];
        }else{
            [self request_getTopicStoryListDataWithMore:NO];
        }
    }];
}

#pragma mark - 数据过滤
- (NSArray *)filtrationSheildData:(NSArray *)storyArray
{
    NSMutableArray *arr = [NSMutableArray array];
    [storyArray enumerateObjectsUsingBlock:^(MOLStoryModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
       
        if (obj.content.length && self.sheildArray.count) {
            
            BOOL isExist= NO;
            for (NSInteger i = 0; i < self.sheildArray.count; i++) {
                MOLSheildModel *m = self.sheildArray[i];
                if ([obj.content containsString:m.name]) {
                    isExist =YES;
                }
            }
            if (!isExist) {
                [arr addObject:obj];
            }
        }else{
            [arr addObject:obj];
        }
    }];
    return arr;
}

#pragma mark - 按钮的点击
- (void)shieldStory
{
    if (![MOLUserManagerInstance user_isLogin]) {
        [[MOLGlobalManager shareGlobalManager] global_modalChooseViewController];
        return;
    }
    if ([MOLUserManagerInstance user_needCompleteInfo]) {
        // 跳出性别选择
        [[MOLGlobalManager shareGlobalManager] global_modalInfoCheckViewControllerWithAnimated:YES];
        return;
    }
    PrecautionsViewController *vc = [[PrecautionsViewController alloc] init];
   // vc.listArr = self.sheildArray;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)filtrateStoryWithAge
{
    if (![MOLUserManagerInstance user_isLogin]) {
        [[MOLGlobalManager shareGlobalManager] global_modalChooseViewController];
        return;
    }
    if ([MOLUserManagerInstance user_needCompleteInfo]) {
        // 跳出性别选择
        [[MOLGlobalManager shareGlobalManager] global_modalInfoCheckViewControllerWithAnimated:YES];
        return;
    }
    [self.filtrateView filtrateView_show];
}

- (void)button_clickPublishButton  // 去发帖
{
    if (![MOLUserManagerInstance user_isLogin]) {
        [[MOLGlobalManager shareGlobalManager] global_modalChooseViewController];
        return;
    }
    if ([MOLUserManagerInstance user_needCompleteInfo]) {
        // 跳出性别选择
        [[MOLGlobalManager shareGlobalManager] global_modalInfoCheckViewControllerWithAnimated:YES];
        return;
    }
    if (self.channelId) {
        MOLMailboxViewController *vc = [[MOLMailboxViewController alloc] init];
        vc.mailModel = self.mailModel;
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        // 直接跳入编辑界面
        MOLPostViewController *vc = [[MOLPostViewController alloc] init];
        vc.mailModel = self.mailModel;
        vc.ttTopicDto = self.topicModel;
        vc.fromviewController =1;
        vc.behaviorType = PostBehaviorNormalType;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MOLStoryModel *model = self.mailDetailView.dataSourceArray[indexPath.row];
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
    return self.mailDetailView.dataSourceArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MOLStoryModel *model = self.mailDetailView.dataSourceArray[indexPath.row];
    if (!model.audioUrl.length) {
        return model.richTextCellHeight;
    }else{
        return model.voiceCellHeight;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MOLStoryModel *model = self.mailDetailView.dataSourceArray[indexPath.row];
    if (/*model.storyType == 1*/ !model.audioUrl.length) {
        MOLMailDetailRichTextCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MOLMailDetailRichTextCell_id"];
        @weakify(self);
        cell.clickHighText = ^(MOLStoryModel *model) {
            @strongify(self);
            if (![model.topicVO.topicId isEqualToString:self.topicId]) {
                MOLMailDetailViewController *vc = [[MOLMailDetailViewController alloc] init];
                vc.topicId = model.topicVO.topicId;
                [self.navigationController pushViewController:vc animated:YES];
            }
        };
        cell.storyModel = model;
        return cell;
    }else{
        MOLMailDetailVoiceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MOLMailDetailVoiceCell_id"];
        @weakify(self);
        cell.clickHighText = ^(MOLStoryModel *model) {
            @strongify(self);
            if (![model.topicVO.topicId isEqualToString:self.topicId]) {
                MOLMailDetailViewController *vc = [[MOLMailDetailViewController alloc] init];
                vc.topicId = model.topicVO.topicId;
                [self.navigationController pushViewController:vc animated:YES];
            }
        };
        cell.storyModel = model;
        return cell;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return self.sectionView.height > 10 ? self.sectionView : [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return self.sectionView.height > 0 ? self.sectionView.height : 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y > 124) {
        if (self.topicId.length) {
            NSString *name = self.topicModel.topicName;
            [self basevc_setCenterTitle:name titleColor:HEX_COLOR(0xffffff)];
        }else{
            NSString *name = [NSString stringWithFormat:@"%@の信箱",self.mailModel.channelName];
            [self basevc_setCenterTitle:name titleColor:HEX_COLOR(0xffffff)];
        }
    }else{
        [self basevc_setCenterTitle:@"" titleColor:HEX_COLOR(0xffffff)];
    }
}
#pragma mark - UI
- (void)setupMailDetailViewControllerUI
{
    MOLMailDetailView *mailDetailView = [[MOLMailDetailView alloc] init];
    _mailDetailView = mailDetailView;
    [self.view addSubview:mailDetailView];
    mailDetailView.tableView.delegate = self;
    mailDetailView.tableView.dataSource = self;
    
    NSArray *rightItems = [UIBarButtonItem mol_barButtonItemWithTitleNames:@[@"筛选",@"屏蔽"] targat:self actions:@[@"filtrateStoryWithAge",@"shieldStory"]];
    self.navigationItem.rightBarButtonItems = rightItems;
    
    UIButton *publishButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _publishButton = publishButton;
    [publishButton setImage:[UIImage imageNamed:@"storyDetail_publish"] forState:UIControlStateNormal];
    [publishButton addTarget:self action:@selector(button_clickPublishButton) forControlEvents:UIControlEventTouchUpInside];
    publishButton.hidden = YES;
    [self.view addSubview:publishButton];
}

- (void)calculatorMailDetailViewControllerFrame
{
    self.mailDetailView.frame = self.view.bounds;
    
    self.publishButton.width = 50;
    self.publishButton.height = 50;
    self.publishButton.right = self.view.width - 15;
    self.publishButton.bottom = self.view.height - 20 - MOL_TabbarSafeBottomMargin;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self calculatorMailDetailViewControllerFrame];
}

#pragma mark - 懒加载
- (MOLMailDetailSectionView *)sectionView
{
    if (_sectionView == nil) {
     
        _sectionView = [[MOLMailDetailSectionView alloc] init];
        _sectionView.width = MOL_SCREEN_WIDTH;
    }
    return _sectionView;
}

- (MOLFiltrateView *)filtrateView
{
    if (_filtrateView == nil) {
        MOLFiltrateView *filtrateView = [[MOLFiltrateView alloc] init];
        _filtrateView = filtrateView;
        filtrateView.width = MOL_SCREEN_WIDTH;
        filtrateView.height = MOL_SCREEN_HEIGHT;
        _filtrateView.hidden = YES;
        [MOLAppDelegateWindow addSubview:filtrateView];
    }
    
    return _filtrateView;
}
@end
