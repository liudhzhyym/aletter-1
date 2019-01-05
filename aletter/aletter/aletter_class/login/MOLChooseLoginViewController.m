//
//  MOLChooseLoginViewController.m
//  aletter
//
//  Created by moli-2017 on 2018/8/2.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLChooseLoginViewController.h"
#import "MOLHead.h"

#import "MOLChooseBoxCell.h"
#import "MOLPhoneInputViewController.h"

#import "MOLPhoneLoginViewModel.h"

@interface MOLChooseLoginViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) UIButton *headButton;
@property (nonatomic, weak) UIButton *closeButton;

@property (nonatomic, strong) NSMutableArray *datasourceArray;
@property (nonatomic, strong) NSArray *nameArray;

@property (nonatomic, strong) MOLPhoneLoginViewModel *loginViewModel;
@end

@implementation MOLChooseLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.loginViewModel = [[MOLPhoneLoginViewModel alloc] init];
    _datasourceArray = [NSMutableArray array];
    if ([[UMSocialManager defaultManager] isInstall:UMSocialPlatformType_WechatSession]) {
        self.nameArray = @[@"手机登录",@"微信登录",@"QQ登录",@"微博登录",@"返回"];
    }else{
        self.nameArray = @[@"手机登录",@"QQ登录",@"微博登录",@"返回"];
    }
    
    [self setupChooseLoginViewControllerUI];
    
    [self request_getDataSource];
    [self.tableView reloadData];
    
    self.headButton.height = MOL_SCREEN_HEIGHT - 30 - MOL_TabbarSafeBottomMargin - self.tableView.contentSize.height;
    self.tableView.tableHeaderView = self.headButton;
    [self bindingLoginViewModel];
}

#pragma mark - 获取数据
- (void)request_getDataSource
{
    MOLChooseBoxModel *left_model = [[MOLChooseBoxModel alloc] init];
    left_model.modelType = MOLChooseBoxModelType_leftText;
    left_model.leftImageString = INTITLE_LEFT_Highlight;
    left_model.leftTitle = @"我们不会读取社交账户的头像/昵称/身份";
    left_model.leftHighLight = YES;
    [self.datasourceArray addObject:left_model];
    
    for (NSInteger i = 0; i < self.nameArray.count; i++) {
        MOLChooseBoxModel *model = [[MOLChooseBoxModel alloc] init];
        model.modelType = MOLChooseBoxModelType_rightChooseButton;
        model.buttonTitle = self.nameArray[i];
        [self.datasourceArray addObject:model];
    }
}

#pragma mark - 按钮的点击
- (void)buttonClick_closeButton
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

- (void)login_loginWithPhone  // 手机登录
{
    MOLPhoneInputViewController *vc = [[MOLPhoneInputViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    [MobClick event: @"_c_phone_login"];
}

- (void)login_loginWithWX  // 微信登录
{
    [self getUserInfoForPlatform:UMSocialPlatformType_WechatSession];
    [MobClick event: @"_c_wechat_login"];
}

- (void)login_loginWithQQ  // QQ登录
{
 
    [self getUserInfoForPlatform:UMSocialPlatformType_QQ];
    [MobClick event: @"_c_qq_login"];
}

- (void)login_loginWithWB  // 微博登录
{
 
    [self getUserInfoForPlatform:UMSocialPlatformType_Sina];
    [MobClick event:@"_c_weibo_login"];
}

- (void)back_clickBack  // 返回
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

#pragma mark - viewModel
- (void)bindingLoginViewModel
{
    @weakify(self);
    [self.loginViewModel.continueCommand.executionSignals.switchToLatest subscribeNext:^(id x) {
        @strongify(self);
        MOLUserModel *user = (MOLUserModel *)x;
        MOLUserManagerInstance.platUserId = user.userId;
        
        if (user.code == MOL_SUCCESS_REQUEST || user.code == 20000) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self dismissViewControllerAnimated:YES completion:nil];
            });
            
            [self.loginViewModel.getLastNameCommand execute:nil];
            // 保存用户信息以及登录状态
            [[MOLUserManager shareUserManager] user_saveUserInfoWithModel:user];
            [[MOLUserManager shareUserManager] user_saveLoginWithStatus:YES];
        }else if (user.code == 20005){
            // 绑定手机
            MOLPhoneInputViewController *vc = [[MOLPhoneInputViewController alloc] init];
            vc.type = 1;
            [self.navigationController pushViewController:vc animated:YES];
        }else if (user.code == 19999){
            // 绑定手机
            MOLPhoneInputViewController *vc = [[MOLPhoneInputViewController alloc] init];
            vc.type = 2;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }];
}


- (void)getUserInfoForPlatform:(UMSocialPlatformType)platformType
{
    [[UMSocialManager defaultManager] getUserInfoWithPlatform:platformType currentViewController:nil completion:^(id result, NSError *error) {
        if (error) {

            [MOLToast toast_showWithWarning:YES title:@"获取三方信息失败"];
        } else {
            UMSocialUserInfoResponse *resp = result;
            // 第三方登录数据(为空表示平台未提供)
            // 发送登录请求
            MOLUserManagerInstance.platType = 1;
            MOLUserManagerInstance.platToken = resp.accessToken;
            MOLUserManagerInstance.platUid = resp.uid;
            if (platformType == UMSocialPlatformType_WechatSession) {
                MOLUserManagerInstance.platType = 2;
                MOLUserManagerInstance.platOpenid = resp.openid;
                MOLUserManagerInstance.platUid = resp.unionId;
            }else if (platformType == UMSocialPlatformType_Sina){
                MOLUserManagerInstance.platType = 3;
            }
            
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            dic[@"accessToken"] = MOLUserManagerInstance.platToken;
            dic[@"loginType"] = @(MOLUserManagerInstance.platType);
            dic[@"loginUID"] = MOLUserManagerInstance.platUid;
            if (MOLUserManagerInstance.platOpenid.length) {
                dic[@"openid"] = MOLUserManagerInstance.platOpenid;
            }
            [self.loginViewModel.continueCommand execute:dic];
        }
    }];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MOLChooseBoxModel *model = self.datasourceArray[indexPath.row];
    if (model.modelType == MOLChooseBoxModelType_rightChooseButton) {
        if ([model.buttonTitle containsString:@"手机"]) {
            [self login_loginWithPhone];
        }else if ([model.buttonTitle containsString:@"返回"]) {
            [self back_clickBack];
        }else if ([model.buttonTitle containsString:@"微信"]) {
            [self login_loginWithWX];
        }else if ([model.buttonTitle containsString:@"QQ"]) {
            [self login_loginWithQQ];
        }else if ([model.buttonTitle containsString:@"微博"]) {
            [self login_loginWithWB];
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.datasourceArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MOLChooseBoxModel *model = self.datasourceArray[indexPath.row];
    return model.cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MOLChooseBoxModel *model = self.datasourceArray[indexPath.row];
    MOLChooseBoxCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MOLChooseBoxCell_id"];
    cell.boxModel = model;
    if (model.modelType == MOLChooseBoxModelType_rightChooseButton) {
        if ([model.buttonTitle isEqualToString:self.nameArray.firstObject]) {
            [cell chooseBoxCell_drawRadius:2 backgroundColor:nil];
        }else if ([model.buttonTitle isEqualToString:self.nameArray.lastObject]){
            [cell chooseBoxCell_drawRadius:1 backgroundColor:nil];
        }else{
            [cell chooseBoxCell_drawRadius:0 backgroundColor:nil];
        }
    }else{
        [cell chooseBoxCell_drawRadius:0 backgroundColor:nil];
    }
    return cell;
}

#pragma mark - UI
- (void)setupChooseLoginViewControllerUI
{
    UITableView *tableView = [[UITableView alloc] init];
    _tableView = tableView;
    tableView.backgroundColor = [UIColor clearColor];
    if (@available(iOS 11.0, *)) {
        tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    tableView.estimatedRowHeight = 0;
    tableView.estimatedSectionHeaderHeight = 0;
    tableView.estimatedSectionFooterHeight = 0;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView registerClass:[MOLChooseBoxCell class] forCellReuseIdentifier:@"MOLChooseBoxCell_id"];
    [self.view addSubview:tableView];
    
    UIButton *headButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _headButton = headButton;
    self.tableView.tableHeaderView = headButton;
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _closeButton = closeButton;
    [closeButton setImage:[UIImage imageNamed:@"common_close"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(buttonClick_closeButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeButton];
}

- (void)calculatorChooseLoginViewControllerFrame
{
    self.tableView.frame = self.view.bounds;
    self.headButton.width = self.tableView.width;
    
    self.closeButton.width = 16;
    self.closeButton.height = self.closeButton.width;
    self.closeButton.x = 20;
    self.closeButton.y = 14 + MOL_StatusBarHeight;
    self.closeButton.hitTestEdgeInsets = UIEdgeInsetsMake(-15, -15, -15, -15);
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self calculatorChooseLoginViewControllerFrame];
}



// 微博
//            NSLog(@"Sina uid: %@", resp.uid);
//            NSLog(@"Sina accessToken: %@", resp.accessToken);
//            NSLog(@"Sina refreshToken: %@", resp.refreshToken);
//            NSLog(@"Sina expiration: %@", resp.expiration);


// QQ
//            NSLog(@"QQ uid: %@", resp.uid);
//            NSLog(@"QQ openid: %@", resp.openid);
//            NSLog(@"QQ unionid: %@", resp.unionId);
//            NSLog(@"QQ accessToken: %@", resp.accessToken);
//            NSLog(@"QQ expiration: %@", resp.expiration);

// 微信
//            NSLog(@"Wechat uid: %@", resp.uid);
//            NSLog(@"Wechat openid: %@", resp.openid);
//            NSLog(@"Wechat unionid: %@", resp.unionId);
//            NSLog(@"Wechat accessToken: %@", resp.accessToken);
//            NSLog(@"Wechat refreshToken: %@", resp.refreshToken);
//            NSLog(@"Wechat expiration: %@", resp.expiration);

// 用户数据
//            NSLog(@" name: %@", resp.name);
//            NSLog(@" iconurl: %@", resp.iconurl);
//            NSLog(@" gender: %@", resp.unionGender);

// 第三方平台SDK原始数据
//            NSLog(@" originalResponse: %@", resp.originalResponse);

@end
