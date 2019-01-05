//
//  MOLStoryDetailViewController.m
//  aletter
//
//  Created by moli-2017 on 2018/8/3.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLStoryDetailViewController.h"
#import "MOLReportViewController.h"
#import "MOLReportCommentViewController.h"
#import "MOLInTitleViewController.h"
#import "MOLDeleteViewController.h"
#import "MOLDeleteCommentViewController.h"
#import "MOLMailDetailViewController.h"
#import "MOLPostViewController.h"
#import "MOLAdminHideViewController.h"

#import "MOLStoryDetailView.h"
#import "MOLHead.h"
#import "MOLInputView.h"
#import "MOLCommentGroupModel.h"

#import "MOLStoryDetailViewModel.h"
#import "MOLALiyunManager.h"

#import "MOLAdminRequest.h"

@interface MOLStoryDetailViewController ()

@property (nonatomic, strong) MOLStoryDetailViewModel *storyDetailViewModel;
@property (nonatomic, weak) MOLStoryDetailView *storyDetailView;
// 帖子
@property (nonatomic, strong) MOLStoryModel *storyModel;
@end

@implementation MOLStoryDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.storyDetailViewModel = [[MOLStoryDetailViewModel alloc] init];
    [self setupStoryDetailViewControllerUI];
    [self bindingStoryDetailViewModel];
    // 请求数据
    [self.storyDetailViewModel.storyInfoCommand execute:self.storyId];

}

#pragma mark - viewModel
- (void)bindingStoryDetailViewModel
{
    @weakify(self);
    // 帖子详情信号
    [self.storyDetailViewModel.storyInfoCommand.executionSignals.switchToLatest subscribeNext:^(id x) {
        @strongify(self);
        MOLStoryModel *model = (MOLStoryModel *)x;
        if (model.code == MOL_SUCCESS_REQUEST) {        
            self.storyDetailView.storyModel = model;
            self.storyModel = model;
            // 设置导航条
            [self navigation_setNavigation:model];
        }else{
            [MOLToast toast_showWithWarning:YES title:model.message];
        }
        
    }];
    
    // 发布私密帖子
    [self.storyDetailViewModel.publishStoryCommand.executionSignals.switchToLatest subscribeNext:^(id x) {
        @strongify(self);
        
        if ([x integerValue] == MOL_SUCCESS_REQUEST) {
//            self.storyDetailView.storyModel.privateSign = 2;
            self.storyModel.privateSign = 2;
            self.storyDetailView.storyModel = self.storyModel;
            // 设置导航条
            [self navigation_setNavigation:self.storyModel];
            
            if (self.shareMineStoryBlock) {
                self.shareMineStoryBlock();
            }
        }
        
    }];
}
#pragma mark - 按钮的点击
- (void)reportStory    // 举报
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
        MOLReportViewController *vc = [[MOLReportViewController alloc] init];
        vc.reportModel = self.storyModel;
        [self presentViewController:vc animated:YES completion:nil];
    });
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
        vc.storyModel = self.storyModel;
        @weakify(self);
        vc.deleteStoryBlock = ^{
            @strongify(self);
            [self.navigationController popViewControllerAnimated:YES];
        };
        [self presentViewController:vc animated:YES completion:nil];
    });
}

- (void)shareStory  // 分享（发布）
{
    if (![MOLUserManagerInstance user_isLogin]) {
        [[MOLGlobalManager shareGlobalManager] global_modalChooseViewController];
        return;
    }
    
    if ([MOLUserManagerInstance user_needCompleteInfo]) {
        [[MOLGlobalManager shareGlobalManager] global_modalInfoCheckViewControllerWithAnimated:YES];
        return;
    }
    
    // 获取用户信息 判断是否跳转起名字的界面
    MOLInTitleViewController *vc = [[MOLInTitleViewController alloc] init];
    vc.type = MOLInTitleViewControllerType_story;
    @weakify(self);
    vc.storyActionBlock = ^(NSArray *array) {
        @strongify(self);
        [self.storyDetailViewModel.publishStoryCommand execute:self.storyModel.storyId];
        [self.navigationController popViewControllerAnimated:NO];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)editStory   // 修改
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
    
    // 跳转编辑
    MOLPostViewController *vc = [[MOLPostViewController alloc] init];
    vc.behaviorType = PostBehaviorUpdateType;
    vc.storyModel = self.storyModel;
    @weakify(self);
    vc.molPostViewControllerBlock = ^(MOLStoryModel *storyModel) {
        @strongify(self);
        self.storyDetailView.storyModel = storyModel;
        self.storyModel = storyModel;
    };
    [self.navigationController pushViewController:vc animated:YES];
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
        vc.storyModel = self.storyModel;
        @weakify(self);
        vc.adminHideStoryBlock = ^{
            @strongify(self);
            [self.navigationController popViewControllerAnimated:YES];
        };
        [self presentViewController:vc animated:YES completion:nil];
    });
//    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//    dic[@"isExamine"] = @"2";
//    MOLAdminRequest *r = [[MOLAdminRequest alloc] initRequest_adminHideStoryWithParameter:dic parameterId:self.storyModel.storyId];
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
#pragma mark - UI
- (void)navigation_setNavigation:(MOLStoryModel *)model
{
    MOLUserModel *user = [MOLUserManagerInstance user_getUserInfo];
    if ([user.userId isEqualToString:model.user.userId]) {
        
        if (model.privateSign == 0) {
            
            NSArray *items = [UIBarButtonItem mol_barButtonItemWithTitleNames:@[@"删除",@"修改",@"分享"] targat:self actions:@[@"deleteStory",@"editStory",@"shareStory"]];
            self.navigationItem.rightBarButtonItems = items;
        }else if (model.privateSign == 2){
            
            NSArray *items = [UIBarButtonItem mol_barButtonItemWithTitleNames:@[@"删除",@"修改"] targat:self actions:@[@"deleteStory",@"editStory"]];
            self.navigationItem.rightBarButtonItems = items;
        }
        
    }else{
        
        if ([MOLUserManagerInstance user_isPower]) {
            NSArray *items = [UIBarButtonItem mol_barButtonItemWithTitleNames:@[@"删除",@"隐藏"] targat:self actions:@[@"deleteStory",@"adminHidenStory"]];
            self.navigationItem.rightBarButtonItems = items;
        }else{
            
            UIBarButtonItem *rightItem = [UIBarButtonItem mol_barButtonItemWithTitleName:@"举报" targat:self action:@selector(reportStory)];
            self.navigationItem.rightBarButtonItem = rightItem;
        }
    }
    
    [self basevc_setCenterTitle:[NSString stringWithFormat:@"%@の信箱",model.channelVO.channelName] titleColor:HEX_COLOR(0xffffff)];
}

- (void)setupStoryDetailViewControllerUI
{
    MOLStoryDetailView *storyDetailView = [[MOLStoryDetailView alloc] initWithFrame:CGRectMake(20, 0, self.view.width - 40, self.view.height)];
    _storyDetailView = storyDetailView;
    storyDetailView.needPlay = YES;
    [self.view addSubview:storyDetailView];
}

- (void)calculatorStoryDetailViewControllerFrame
{
    self.storyDetailView.width = self.view.width - 40;
    self.storyDetailView.height = self.view.height;
    self.storyDetailView.x = 20;
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.storyDetailView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(12, 12)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.storyDetailView.bounds;
    maskLayer.path = maskPath.CGPath;
    self.storyDetailView.backgroundColor = HEX_COLOR(0xffffff);
    self.storyDetailView.layer.mask = maskLayer;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self calculatorStoryDetailViewControllerFrame];
}

@end
