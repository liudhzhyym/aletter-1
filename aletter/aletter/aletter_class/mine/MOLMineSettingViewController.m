//
//  MOLMineSettingViewController.m
//  aletter
//
//  Created by moli-2017 on 2018/8/17.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLMineSettingViewController.h"
#import "MOLSettingModel.h"
#import "MOLHead.h"
#import "MOLSettingCell.h"
#import "MOLMineLikeViewController.h"
#import "MOLInTitleViewController.h"
#import "MOLExitViewController.h"
#import "MOLWebViewController.h"
#import "EDChatViewController.h"
#import "MOLMessageRequest.h"
#import "MOLStoryDetailViewController.h"
#import "MOLSearchSchoolViewController.h"

@interface MOLMineSettingViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSMutableArray *dataSourceArray;
@property (nonatomic, weak) UIImageView *bottomImageView;
@property (nonatomic, weak) UIButton *exitButton;
@property (nonatomic, weak) UILabel *levelNameLabel;
@property (nonatomic, weak) UILabel *levelLabel;

@property (nonatomic, strong) NSString *commentName;
@property (nonatomic, strong) NSString *schoolName;

@property (nonatomic, assign) BOOL endDrag;
@end

@implementation MOLMineSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _dataSourceArray = [NSMutableArray array];
    [self setupMineSettingViewControllerUI];
    [self request_getData];
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    MOLUserModel *user = [MOLUserManagerInstance user_getUserInfo];
    if (![self.commentName isEqualToString:user.commentName]) {    
        [self request_getData];
        [self.tableView reloadData];
    }
    
    if (![self.schoolName isEqualToString:user.school]) {
        [self request_getData];
        [self.tableView reloadData];
    }
}

#pragma mark - 网络请求
- (void)request_getData
{
    MOLUserModel *user = [MOLUserManagerInstance user_getUserInfo];
    self.commentName = user.commentName;
    self.schoolName = user.school;
    MOLSettingModel *model1 = [[MOLSettingModel alloc] init];
    model1.name = @"个人资料";
    NSString *age = [NSString stringWithFormat:@"%@后",user.age];
    if (user.age.integerValue == 75) {
        age = @"80前";
    }
    NSString *sex = user.sex == 1 ? @"男":@"女";
    model1.subName = [NSString stringWithFormat:@"%@,%@",age,sex];
    model1.type = 0;
    
    
    
    MOLSettingModel *schoolM = [[MOLSettingModel alloc] init];
    schoolM.name = @"学校信息";
    if (user.school.length) {
        schoolM.subName = [NSString stringWithFormat:@"%@",user.school];
    }else{
        schoolM.subName = [NSString stringWithFormat:@"%@",@"未设置"];
    }
    if (user.schoolNum < 2) {
        schoolM.type = 2;
    }else{
        schoolM.type = 0;
    }
    
    @weakify(self);
    schoolM.actionBlock = ^{
        @strongify(self);
        if (user.schoolNum >= 2) {
            return;
        }
        // 修改学校
        MOLSearchSchoolViewController *vc = [[MOLSearchSchoolViewController alloc] init];
        vc.changeNum = user.schoolNum;
        vc.enterType = 1;
        [self.navigationController pushViewController:vc animated:YES];
    };
    
    MOLSettingModel *model2 = [[MOLSettingModel alloc] init];
    model2.name = @"评论昵称";
    model2.subName = [NSString stringWithFormat:@"%@",user.commentName];
    model2.type = 2;
    
    model2.actionBlock = ^{
        @strongify(self);
        // 修改名字
        MOLInTitleViewController *vc = [[MOLInTitleViewController alloc] init];
        vc.type = MOLInTitleViewControllerType_comment;
        [self.navigationController pushViewController:vc animated:YES];
    };
    
    MOLSettingModel *model3 = [[MOLSettingModel alloc] init];
    model3.name = @"我喜欢的信件";
    model3.type = 1;
    model3.actionBlock = ^{
        @strongify(self);
        MOLMineLikeViewController *vc = [[MOLMineLikeViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    };
    
    NSArray *arr1 = @[model1,schoolM,model2,model3];
    
    MOLSettingModel *model4 = [[MOLSettingModel alloc] init];
    model4.name = @"邀请好友奖励稀有邮票";
    model4.type = 1;
    model4.actionBlock = ^{
        @strongify(self);
        // H5
 
        MOLWebViewController *vc  = [[MOLWebViewController alloc] init];
     
        NSString *baseUrl = MOL_OFFIC_SERVICE;  // 正式
        NSString *url = @"/h5/static/views/app/stamp/getStamp.html";
#ifdef MOL_TEST_HOST
         baseUrl = MOL_TEST_SERVICE;  // 测试
#endif
        NSString *str =[NSString stringWithFormat:@"%@%@",baseUrl,url];
        vc.urlString = str;
        vc.titleString = @"邀请好友奖励稀有邮票";
        [self.navigationController pushViewController:vc animated:YES];
    };
    
    MOLSettingModel *model5 = [[MOLSettingModel alloc] init];
    model5.name = @"集邮册";
    model5.type = 1;
    model5.actionBlock = ^{
        @strongify(self);
        // H5
        MOLWebViewController *vc  = [[MOLWebViewController alloc] init];
        
        
        NSString *baseUrl = MOL_OFFIC_SERVICE;  // 正式
        NSString *url = @"/h5/static/views/app/stamp/stamp.html";
#ifdef MOL_TEST_HOST
        baseUrl = MOL_TEST_SERVICE;  // 测试
#endif
        NSString *str =[NSString stringWithFormat:@"%@%@",baseUrl,url];
        vc.urlString = str;
        vc.titleString = @"集邮册";
        [self.navigationController pushViewController:vc animated:YES];
    };
    
    MOLSettingModel *model6 = [[MOLSettingModel alloc] init];
    model6.name = @"给有封信提意见";
    model6.type = 1;
    model6.actionBlock = ^{
        @strongify(self);
        // 私信
        [self request_getChatId:^(NSString *chatId) {
            @strongify(self);
            MOLLightUserModel *user = [[MOLLightUserModel alloc] init];
            user.userId = MOL_OFFIC_USER;
            user.userName = @"给有封信提意见";
            user.sex = 1;
            EDChatViewController *vc = [[EDChatViewController alloc] init];
            vc.toUser = user;
            vc.vcType = 1;
            if (chatId.length > 0) {
                vc.chatId = chatId;
            }
            [self.navigationController pushViewController:vc animated:YES];
        }];
    };
    
    MOLSettingModel *model7 = [[MOLSettingModel alloc] init];
    model7.name = @"在App Store 评价有封信";
    model7.type = 1;
    model7.actionBlock = ^{
        NSString *appid = @"1425771494";
        NSString *str = [NSString stringWithFormat:@"http://itunes.apple.com/us/app/id%@",appid];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    };
    
    NSArray *arr2 = @[model4,model5];
    
    MOLSettingModel *model8 = [[MOLSettingModel alloc] init];
    model8.name = @"退出登录";
    model8.type = 3;
    model8.actionBlock = ^{
        @strongify(self);
        [self button_clickExitButton];
    };
    
    NSArray *arr3 = @[model6,model7,model8];
    
    [self.dataSourceArray removeAllObjects];
    
    [self.dataSourceArray addObject:arr1];
    if ([MOLSwitchManager shareSwitchManager].normalStatus) {    
        [self.dataSourceArray addObject:arr2];
    }
    [self.dataSourceArray addObject:arr3];
}

- (void)request_getChatId:(void(^)(NSString *chatId))successBlock
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"storyId"] = @"0";
    dic[@"userId"] = MOL_OFFIC_USER;
    MOLMessageRequest *r = [[MOLMessageRequest alloc] initRequest_checkChatWithParameter:dic];
    
    [r baseNetwork_startRequestWithcompletion:^(__kindof MOLBaseNetRequest *request, MOLBaseModel *responseModel, NSInteger code, NSString *message) {
        
        if (code == MOL_SUCCESS_REQUEST) {
            NSDictionary *dic = request.responseObject[@"resBody"];
            NSString *chatId = [dic mol_jsonString:@"chatId"];
            if (successBlock) {
                successBlock(chatId);
            }
        }
    } failure:^(__kindof MOLBaseNetRequest *request) {
        
    }];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSArray *arr = self.dataSourceArray[indexPath.section];
    MOLSettingModel *model = arr[indexPath.row];
    if (model.actionBlock) {
        model.actionBlock();
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataSourceArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *arr = self.dataSourceArray[section];
    return arr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *arr = self.dataSourceArray[indexPath.section];
    MOLSettingModel *model = arr[indexPath.row];
    MOLSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MOLSettingCell_id"];
    cell.settingModel = model;
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return [UIView new];
    }
    UIView *view = [[UIView alloc] init];
    view.width = MOL_SCREEN_WIDTH;
    UIView *v = [[UIView alloc] init];
    v.backgroundColor = HEX_COLOR_ALPHA(0xffffff, 0.1);
    v.width = MOL_SCREEN_WIDTH - 40;
    v.height = 1;
    v.x = 20;
    [view addSubview:v];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0.01;
    }
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
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

#pragma mark - 按钮点击
- (void)button_clickExitButton  // 退出登录
{
    MOLExitViewController *vc = [[MOLExitViewController alloc] init];
    @weakify(self);
    vc.exitBlock = ^{
        @strongify(self);
        [MOLUserManagerInstance user_resetUserInfo];
        dispatch_async(dispatch_get_main_queue(), ^{
            CATransition *animation = [CATransition animation];
            animation.duration = 0.35;
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
            animation.type = kCATransitionPush;
            animation.subtype = kCATransitionFromBottom;
            [self.view.window.layer addAnimation:animation forKey:@"CATransition_FromTop"];
            [self dismissViewControllerAnimated:NO completion:nil];
        });
    };
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)button_clickReportLv
{
    MOLStoryDetailViewController *vc = [[MOLStoryDetailViewController alloc] init];
    vc.storyId = @"8541";
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UI
- (void)setupMineSettingViewControllerUI
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, MOL_SCREEN_WIDTH, MOL_SCREEN_HEIGHT) style:UITableViewStyleGrouped];
    _tableView = tableView;
    tableView.backgroundColor = [UIColor clearColor];
    if (@available(iOS 11.0, *)) {
        tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else{
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    tableView.estimatedRowHeight = 0;
    tableView.estimatedSectionHeaderHeight = 0;
    tableView.estimatedSectionFooterHeight = 0;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView registerClass:[MOLSettingCell class] forCellReuseIdentifier:@"MOLSettingCell_id"];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    
    UIImageView *bottomImageView = [[UIImageView alloc] init];
    _bottomImageView = bottomImageView;
    bottomImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(button_clickReportLv)];
    [bottomImageView addGestureRecognizer:tap];
    [self.view addSubview:bottomImageView];
    
    UILabel *levelNameLabel = [[UILabel alloc] init];
    _levelNameLabel = levelNameLabel;
    levelNameLabel.text = @"信之守护";
    levelNameLabel.textColor = HEX_COLOR(0xffffff);
    levelNameLabel.font = MOL_LIGHT_FONT(14);
    [bottomImageView addSubview:levelNameLabel];
    
    MOLUserModel *user = [MOLUserManagerInstance user_getUserInfo];
    UILabel *levelLabel = [[UILabel alloc] init];
    _levelLabel = levelLabel;
    levelLabel.text = [NSString stringWithFormat:@"Lv%@",user.reportLevel];
    levelLabel.textColor = HEX_COLOR(0xFED434);
    levelLabel.font = MOL_LIGHT_FONT(14);
    [bottomImageView addSubview:levelLabel];
    
    levelNameLabel.hidden = (user.reportLevel.integerValue == 0);
    levelLabel.hidden = (user.reportLevel.integerValue == 0);
}

- (void)calculatorMineSettingViewControllerFrame
{
    self.tableView.frame = self.view.bounds;
    
    self.bottomImageView.width = 140;
    self.bottomImageView.height = 50 + MOL_TabbarSafeBottomMargin;
    self.bottomImageView.bottom = self.view.height;
    self.bottomImageView.right = MOL_SCREEN_WIDTH;
    
    [self.levelLabel sizeToFit];
    self.levelLabel.right = self.bottomImageView.width - 20;
    self.levelLabel.y = 0;
    
    [self.levelNameLabel sizeToFit];
    self.levelNameLabel.right = self.levelLabel.x - 5;
    self.levelNameLabel.centerY = self.levelLabel.centerY;
    
    self.tableView.contentInset = UIEdgeInsetsMake(self.tableView.contentInset.top, self.tableView.contentInset.left, self.bottomImageView.height, self.tableView.contentInset.right);
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self calculatorMineSettingViewControllerFrame];
}

@end
