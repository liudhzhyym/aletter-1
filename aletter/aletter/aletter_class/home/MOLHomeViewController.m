//
//  MOLHomeViewController.m
//  aletter
//
//  Created by moli-2017 on 2018/7/27.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLHomeViewController.h"
#import "MOLMineViewController.h"
#import "MOLChooseLoginViewController.h"
#import "MOLInfoCheckViewController.h"
#import "MOLHomeCollectionViewController.h"
#import "MOLMeetViewController.h"
#import "MOLHead.h"
#import "MOLMailboxViewController.h"
#import "MOLUpdateView.h"
#import <AFNetworkReachabilityManager.h>

#import "MOLHomeMailRequest.h"
#import "MOLActionRequest.h"
#import "MOLPrisonViewController.h"
#import "EDChatViewController.h"
#import "MOLMineMessageViewController.h"
#import "MOLMineViewController.h"
#import "SPPageMenu.h"

@interface MOLHomeViewController ()<JAHorizontalPageViewDelegate, SPPageMenuDelegate>

@property (nonatomic, strong) NSMutableArray *datasourceArray;  // 分类数组
@property (nonatomic, strong) JAHorizontalPageView *pageView;

@property (nonatomic, weak) UIImageView *topView;
@property (nonatomic, weak) SPPageMenu *pageMenu;
@property (nonatomic, weak) MOLUpdateView *updateView;  // 更新view

@property (nonatomic, weak) UIImageView *bottomView;
@property (nonatomic, weak) UIButton *meetButton;  // 遇见
@property (nonatomic, weak) UIButton *mailboxButton;  // 邮箱
@property (nonatomic, weak) UIButton *momentButton;  // 此刻

@property (nonatomic, assign) BOOL needRefreshAgain;

@property (nonatomic, assign) BOOL hasWork;
@end

@implementation MOLHomeViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self listenNetWorkingPort];  // 网络监听
    
    _datasourceArray = [NSMutableArray array];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setupHomeViewControllerUI];
    [self showUI];
    [self request_getUserInfo];
    [self request_getUserLastName];
    
    // 展示广告
    [self launch_checkAD];
    // 展示更新
    [self launch_checkVersionUpdate];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newMessageArrive) name:@"ALETTER_PUSH" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accountLoginSuccess) name:@"MOL_LOGIN_SUCCESS" object:nil];
    
    [self checkFront];
}

- (void)newMessageArrive
{
    UIViewController *vc = [[MOLGlobalManager shareGlobalManager] global_currentViewControl];
    
    if ([vc isKindOfClass:[EDChatViewController class]] ||
        [vc isKindOfClass:[MOLMineMessageViewController class]]) {
        return;
    }
    
    if ([vc isKindOfClass:[MOLMineViewController class]]) {
        MOLMineViewController *v = (MOLMineViewController *)vc;
        if (v.pageMenu.selectedItemIndex == 0) {
            return;
        }
    }
    
    self.mailboxButton.selected = YES;
}

- (void)accountLoginSuccess
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self request_getUserInfo];
    });
}

#pragma mark - 审核
- (void)checkFront
{
    self.meetButton.hidden = YES;
    self.momentButton.hidden = YES;
    @weakify(self);
    [[MOLSwitchManager shareSwitchManager] switch_check:^{
        @strongify(self);
        if ([MOLSwitchManager shareSwitchManager].normalStatus) {
            self.meetButton.hidden = NO;
            self.momentButton.hidden = NO;
        }
    }];
}

#pragma mark - 网络监听
- (void)listenNetWorkingPort
{
    self.hasWork = YES;
    // 设置网络状态变化回调
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusNotReachable:
                self.hasWork = NO;
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                if (self.hasWork == NO) {
                    self.hasWork = YES;
                    [self launch_checkVersionUpdate];
                    [self checkFront];
                }
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                if (self.hasWork == NO) {
                    self.hasWork = YES;
                    [self launch_checkVersionUpdate];
                    [self checkFront];
                }
                break;
            default:
                break;
        }
    }];
    // 启动网络状态监听
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

#pragma mark - AD
- (void)launch_checkAD
{
    
}

#pragma mark - Update
- (void)launch_checkVersionUpdate
{
    // 获取当前版本
    NSString *version = [STSystemHelper getApp_version];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"platForm"] = MOL_IOS;
    dic[@"version"] = version;
    MOLHomeMailRequest *r = [[MOLHomeMailRequest alloc] initRequest_versionCheckWithParameter:dic];
    [r baseNetwork_startRequestWithcompletion:^(__kindof MOLBaseNetRequest *request, MOLBaseModel *responseModel, NSInteger code, NSString *message) {
       
        if (code == MOL_SUCCESS_REQUEST) {
            NSDictionary *dic = request.responseObject[@"resBody"];
            // 跟新内容
            NSString *content = [dic mol_jsonString:@"content"];
            
            // 最新版本号
            NSString *ver_new = [dic mol_jsonString:@"version"];
            
            // 判断是否需要跟新
            if ([ver_new compare:version options:NSNumericSearch] == NSOrderedDescending) { // 需要更新
                
                BOOL forceUpdate = [dic mol_jsonBool:@"isImpose"];
                
                [self.updateView removeFromSuperview];
                MOLUpdateView *updateV = [[MOLUpdateView alloc] init];
                self.updateView = updateV;
                updateV.width = MOL_SCREEN_WIDTH;
                updateV.height = MOL_SCREEN_HEIGHT;
                [updateV showUpdateWithVersion:ver_new content:content force:forceUpdate];
                [[[[MOLGlobalManager shareGlobalManager] global_rootNavigationViewControl] view] addSubview:updateV];
            }else{
                
            }
        }
    } failure:^(__kindof MOLBaseNetRequest *request) {
        
    }];
}

#pragma mark - 网络请求
- (void)request_getUserInfo
{
    if ([MOLUserManagerInstance user_isLogin]) {
        // 同步用户信息
        MOLActionRequest *r = [[MOLActionRequest alloc] initRequest_getUserInfoActionCommentWithParameter:nil];
        [r baseNetwork_startRequestWithcompletion:^(__kindof MOLBaseNetRequest *request, MOLBaseModel *responseModel, NSInteger code, NSString *message) {
            MOLUserModel *user = (MOLUserModel *)responseModel;
            if (user.code == MOL_SUCCESS_REQUEST) {
                [MOLUserManagerInstance user_saveUserInfoWithModel:user];
            }
        } failure:^(__kindof MOLBaseNetRequest *request) {
            
        }];
    }
}

- (void)request_getUserLastName
{
    if ([MOLUserManagerInstance user_isLogin]) {
        MOLActionRequest *r = [[MOLActionRequest alloc] initRequest_lastCommentNameActionCommentWithParameter:nil parameterId:@"1"];// 获取上次使用昵称-nameType:1发帖/私信昵称 2评论名称
        [r baseNetwork_startRequestWithcompletion:^(__kindof MOLBaseNetRequest *request, MOLBaseModel *responseModel, NSInteger code, NSString *message) {
            if (code == MOL_SUCCESS_REQUEST) {
                NSString *name = request.responseObject[@"resBody"];
                [MOLUserManagerInstance user_saveUserLastNameWithName:name];
            }
        } failure:^(__kindof MOLBaseNetRequest *request) {
            
        }];
    }
}

- (void)showUI
{
    @WeakObj(self);
    [self request_getCategoryArray:^{
        @StrongObj(self);
        [self.pageView reloadPage];
        
        NSMutableArray *titles = [NSMutableArray array];
        for (NSInteger i = 0; i < self.datasourceArray.count; i++) {
            MOLCatogeryModel *model = self.datasourceArray[i];
            NSString *title = model.styleName;
            [titles addObject:title];
        }
        
        [self.pageMenu removeAllItems];
        [self.pageMenu setItems:titles selectedItemIndex:0];
        self.pageMenu.bridgeScrollView = (UIScrollView *)self.pageView.horizontalCollectionView;
    }];
}
- (void)request_getCategoryArray:(void(^)(void))finish
{
    if ([NSString mol_fileExistWithName:@"mol_channelsCatogery"]) {
        self.needRefreshAgain = NO;
        NSString *filename = [NSString mol_creatFileWithFileName:@"mol_channelsCatogery"];
        // 读取本地缓存数据
        NSArray* arr = [NSKeyedUnarchiver unarchiveObjectWithFile:filename];
        [self.datasourceArray removeAllObjects];
        [self.datasourceArray addObjectsFromArray:arr];
        finish();
    }else{
        self.needRefreshAgain = YES;
        [self basevc_showLoading];
    }
    
    MOLHomeMailRequest *r = [[MOLHomeMailRequest alloc] initRequest_channelCatogeryWithParameter:nil];
  
    [r baseNetwork_startRequestWithcompletion:^(__kindof MOLBaseNetRequest *request, MOLBaseModel *responseModel, NSInteger code, NSString *message) {
        [self basevc_hiddenLoading];
        if (code == MOL_SUCCESS_REQUEST) {
            MOLCatogeryGroupModel *groupmodel = (MOLCatogeryGroupModel *)responseModel;
            NSMutableArray *arrM = [NSMutableArray array];
            [arrM addObjectsFromArray:groupmodel.resBody];
            
            MOLCatogeryModel *model = [[MOLCatogeryModel alloc] init];
            model.styleId = @"0";
            model.styleName = @"全部";
            [arrM insertObject:model atIndex:0];
            NSString *filename = [NSString mol_creatFileWithFileName:@"mol_channelsCatogery"];
            [NSKeyedArchiver archiveRootObject:arrM toFile:filename];
            
            // 刷新界面
            [self.datasourceArray removeAllObjects];
            self.datasourceArray = arrM;
            finish();
        }
        
    } failure:^(__kindof MOLBaseNetRequest *request) {
        if (self.needRefreshAgain) {
            [self basevc_showErrorPageWithY:0 select:@selector(showUI) superView:self.view];
        }
    }];
}

#pragma mark - 按钮的点击
- (void)button_ClickMeetButton:(UIButton *)button    // 点击遇见
{
    MOLMeetViewController *meetVc = [[MOLMeetViewController alloc] init];
    [self.navigationController pushViewController:meetVc animated:YES];
}
- (void)button_ClickMailboxButton:(UIButton *)button  // 点击邮箱
{
    if (button.selected) {
        button.selected = NO;
    }
    if ([MOLUserManagerInstance user_isLogin]) {
        
        if (![MOLUserManagerInstance user_needCompleteInfo]) {
            
            CATransition *animation = [CATransition animation];
            animation.duration = 0.35;
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            animation.type = kCATransitionPush;
            animation.subtype = kCATransitionFromTop;
            [self.view.window.layer addAnimation:animation forKey:@"CATransition_FromTop"];
            
            MOLMineViewController *mineVc = [[MOLMineViewController alloc] init];
            MOLBaseNavigationController *nav = [[MOLBaseNavigationController alloc] initWithRootViewController:mineVc];
            [self presentViewController:nav animated:NO completion:nil];
            
        }else{
            [[MOLGlobalManager shareGlobalManager] global_modalInfoCheckViewControllerWithAnimated:YES];
        }
    }else{
        [[MOLGlobalManager shareGlobalManager] global_modalChooseViewController];
    }
    
}
- (void)button_ClickMomentButton:(UIButton *)button   // 点击此刻
{
    if ([MOLUserManagerInstance user_isLogin]) {
        if (![MOLUserManagerInstance user_needCompleteInfo]) {
            MOLMailboxViewController *mailBoxView =[MOLMailboxViewController new];
            MOLMailModel *mailDto =[MOLMailModel new];
            mailDto.channelId=@"999";
            mailBoxView.mailModel=mailDto;
            [self.navigationController pushViewController:mailBoxView animated:YES];
        }else{
            [[MOLGlobalManager shareGlobalManager] global_modalInfoCheckViewControllerWithAnimated:YES];
        }
    }else{
        [[MOLGlobalManager shareGlobalManager] global_modalChooseViewController];
    }
}

#pragma mark - 页面delegate
- (NSInteger)numberOfSectionPageView:(JAHorizontalPageView *)view   // 返回几个控制器
{
    return self.datasourceArray.count;
}

- (UIScrollView *)horizontalPageView:(JAHorizontalPageView *)pageView viewAtIndex:(NSInteger)index   // 返回每个控制器的view
{
    MOLCatogeryModel *model = self.datasourceArray[index];
    MOLHomeCollectionViewController *vc = [[MOLHomeCollectionViewController alloc] init];
    vc.catogeryId = model.styleId.integerValue;
    vc.catogeryName = model.styleName;
    vc.view.backgroundColor = [UIColor clearColor];
    [self addChildViewController:vc];
    return (UIScrollView *)vc.collectionView;
}

- (UIView *)headerViewInPageView:(JAHorizontalPageView *)pageView     // 返回头部
{
    return nil;
}

- (CGFloat)headerHeightInPageView:(JAHorizontalPageView *)pageView    // 返回头部高度
{
    return 0;
}

- (CGFloat)topHeightInPageView:(JAHorizontalPageView *)pageView   // 控制在什么地方悬停
{
    return 0;
}

- (void)horizontalPageView:(JAHorizontalPageView *)pageView scrollTopOffset:(CGFloat)offset   // 滚动的偏移量
{}

- (void)pageMenu:(SPPageMenu *)pageMenu itemSelectedFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex
{
    [_pageView scrollToIndex:toIndex];
}

#pragma mark - UI
- (void)setupHomeViewControllerUI
{
    UIImageView *topView = [[UIImageView alloc] init];
    _topView = topView;
    topView.image = [UIImage imageNamed:@"home_back_top"];
    topView.userInteractionEnabled = YES;
    [self.view addSubview:topView];
    
    SPPageMenu *pageMenu = [SPPageMenu pageMenuWithFrame:CGRectMake(20, 15, MOL_SCREEN_WIDTH-20, 40) trackerStyle:SPPageMenuTrackerStyleLineAttachment];
    _pageMenu = pageMenu;
    _pageMenu.backgroundColor = [UIColor clearColor];
    _pageMenu.permutationWay = SPPageMenuPermutationWayScrollAdaptContent;
    _pageMenu.itemTitleFont = MOL_REGULAR_FONT(17);
    _pageMenu.selectedItemTitleColor = HEX_COLOR(0xffffff);
    _pageMenu.unSelectedItemTitleColor = HEX_COLOR_ALPHA(0xffffff, 0.6);
    _pageMenu.trackerWidth = 12;
    _pageMenu.tracker.backgroundColor = HEX_COLOR(0xffffff);
    _pageMenu.needTextColorGradients = NO;
    _pageMenu.dividingLine.hidden = YES;
    _pageMenu.selectedItemZoomScale = 1.2;
    _pageMenu.itemPadding = 20;
    _pageMenu.delegate = self;
    [topView addSubview:_pageMenu];
    
    UIImageView *bottomView = [[UIImageView alloc] init];
    _bottomView = bottomView;
    bottomView.image = [UIImage imageNamed:@"home_back_bottom"];
    bottomView.userInteractionEnabled = YES;
    [self.view addSubview:bottomView];
    
    UIButton *meetButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _meetButton = meetButton;
    [meetButton setImage:[UIImage imageNamed:@"home_see"] forState:UIControlStateNormal];
    [meetButton setTitle:@"遇见" forState:UIControlStateNormal];
    [meetButton setTitleColor:HEX_COLOR_ALPHA(0xffffff, 0.6) forState:UIControlStateNormal];
    meetButton.titleLabel.font = MOL_MEDIUM_FONT(11);
    [meetButton addTarget:self action:@selector(button_ClickMeetButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:meetButton];
    
    UIButton *mailboxButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _mailboxButton = mailboxButton;
    [mailboxButton setImage:[UIImage imageNamed:@"home_mailbox"] forState:UIControlStateNormal];
    [mailboxButton setImage:[UIImage imageNamed:@"home_mailbox_select"] forState:UIControlStateSelected];
    [mailboxButton addTarget:self action:@selector(button_ClickMailboxButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:mailboxButton];
    
    UIButton *momentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _momentButton = momentButton;
    [momentButton setImage:[UIImage imageNamed:@"home_write"] forState:UIControlStateNormal];
    [momentButton setTitle:@"此刻" forState:UIControlStateNormal];
    [momentButton setTitleColor:HEX_COLOR_ALPHA(0xffffff, 0.6) forState:UIControlStateNormal];
    momentButton.titleLabel.font = MOL_MEDIUM_FONT(11);
    [momentButton addTarget:self action:@selector(button_ClickMomentButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:momentButton];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.topView.width = MOL_SCREEN_WIDTH;
    self.topView.height = MOL_StatusBarAndNavigationBarHeight;
    
    self.pageMenu.y = self.topView.height - 40;
    
    self.bottomView.width = MOL_SCREEN_WIDTH;
    self.bottomView.height = 50 + MOL_TabbarSafeBottomMargin;
    self.bottomView.y = MOL_SCREEN_HEIGHT - self.bottomView.height;
    
    self.mailboxButton.width = 48;
    self.mailboxButton.height = self.mailboxButton.width;
    self.mailboxButton.centerX = self.bottomView.width * 0.5;
    self.mailboxButton.bottom = self.bottomView.height - 4 - MOL_TabbarSafeBottomMargin;
    
    self.meetButton.width = 40;
    self.meetButton.height = self.meetButton.width;
    self.meetButton.centerX = self.bottomView.width * 0.25 - 10;
    self.meetButton.bottom = self.bottomView.height - 4 - MOL_TabbarSafeBottomMargin;
    [self.meetButton mol_setButtonImageTitleStyle:ButtonImageTitleStyleTop padding:0];
    
    self.momentButton.width = 40;
    self.momentButton.height = self.momentButton.width;
    self.momentButton.centerX = self.bottomView.width * 0.75 + 10;
    self.momentButton.bottom = self.bottomView.height - 4 - MOL_TabbarSafeBottomMargin;
    [self.momentButton mol_setButtonImageTitleStyle:ButtonImageTitleStyleTop padding:0];
}

#pragma mark - 懒加载
- (JAHorizontalPageView *)pageView
{
    if (_pageView == nil) {
        CGSize size = [UIScreen mainScreen].bounds.size;
        _pageView = [[JAHorizontalPageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height) delegate:self];
        _pageView.needHeadGestures = NO;
        [self.view insertSubview:_pageView belowSubview:self.topView];
    }
    return _pageView;
}

@end
