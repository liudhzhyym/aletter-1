//
//  MOLInfoCheckViewController.m
//  aletter
//
//  Created by moli-2017 on 2018/8/3.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLInfoCheckViewController.h"
#import "MOLCheckInfoView.h"
#import "MOLCheckInfoViewModel.h"
#import "MOLSearchSchoolViewController.h"

@interface MOLInfoCheckViewController ()
@property (nonatomic, strong) MOLCheckInfoViewModel *checkInfoViewModel;
@property (nonatomic, weak) MOLCheckInfoView *checkInfoView;
@end

@implementation MOLInfoCheckViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.checkInfoViewModel = [[MOLCheckInfoViewModel alloc] init];
    
    [self setupInfoCheckViewControllerUI];
    [self bindingCheckInfoViewModel];
    
    [self.checkInfoViewModel.sexInfoCommand execute:nil];
}

#pragma mark - ViewModel
- (void)bindingCheckInfoViewModel
{
    @weakify(self);
    [self.checkInfoViewModel.sexInfoCommand.executionSignals.switchToLatest subscribeNext:^(id x) {
        @strongify(self);
        NSDictionary *dic = (NSDictionary *)x;
        NSArray *sourceArr = [dic mol_jsonArray:@"dataSource"];
        NSArray *nameArr = [dic mol_jsonArray:@"nameArray"];
        self.checkInfoView.currentType = MOLCheckInfoViewType_sex;
        self.checkInfoView.datasourceArray = sourceArr;
        self.checkInfoView.nameArray = nameArr;
        [self.checkInfoView.tableView reloadData];
        CGFloat height = self.checkInfoView.tableView.contentSize.height - self.checkInfoView.headButton.height;
        self.checkInfoView.headButton.height = self.checkInfoView.tableView.height - 30 - MOL_TabbarSafeBottomMargin - height;
        self.checkInfoView.tableView.tableHeaderView = self.checkInfoView.headButton;
    }];
    
    [self.checkInfoViewModel.ageInfoCommand.executionSignals.switchToLatest subscribeNext:^(id x) {
        @strongify(self);
        NSDictionary *dic = (NSDictionary *)x;
        NSArray *sourceArr = [dic mol_jsonArray:@"dataSource"];
        NSArray *nameArr = [dic mol_jsonArray:@"nameArray"];
        self.checkInfoView.currentType = MOLCheckInfoViewType_age;
        self.checkInfoView.datasourceArray = sourceArr;
        self.checkInfoView.nameArray = nameArr;
        [self.checkInfoView.tableView reloadData];
        CGFloat height = self.checkInfoView.tableView.contentSize.height - self.checkInfoView.headButton.height;
        self.checkInfoView.headButton.height = self.checkInfoView.tableView.height - 30 - MOL_TabbarSafeBottomMargin - height;
        self.checkInfoView.tableView.tableHeaderView = self.checkInfoView.headButton;
        
        [self.checkInfoView.tableView setContentOffset:CGPointZero animated:YES];
    }];
    
    [self.checkInfoViewModel.schoolInfoCommand.executionSignals.switchToLatest subscribeNext:^(id x) {
        @strongify(self);
        NSDictionary *dic = (NSDictionary *)x;
        NSArray *sourceArr = [dic mol_jsonArray:@"dataSource"];
        NSArray *nameArr = [dic mol_jsonArray:@"nameArray"];
        self.checkInfoView.currentType = MOLCheckInfoViewType_school;
        self.checkInfoView.datasourceArray = sourceArr;
        self.checkInfoView.nameArray = nameArr;
        [self.checkInfoView.tableView reloadData];
        CGFloat height = self.checkInfoView.tableView.contentSize.height - self.checkInfoView.headButton.height;
        self.checkInfoView.headButton.height = self.checkInfoView.tableView.height - 30 - MOL_TabbarSafeBottomMargin - height;
        self.checkInfoView.tableView.tableHeaderView = self.checkInfoView.headButton;
        
        [self.checkInfoView.tableView setContentOffset:CGPointZero animated:YES];
    }];
    
    [self.checkInfoViewModel.checkInfoCommand.executionSignals.switchToLatest subscribeNext:^(id x) {
        @strongify(self);
        NSDictionary *dic = (NSDictionary *)x;
        NSArray *sourceArr = [dic mol_jsonArray:@"dataSource"];
        NSArray *nameArr = [dic mol_jsonArray:@"nameArray"];
        self.checkInfoView.currentType = MOLCheckInfoViewType_check;
        self.checkInfoView.datasourceArray = sourceArr;
        self.checkInfoView.nameArray = nameArr;
        [self.checkInfoView.tableView reloadData];
        CGFloat height = self.checkInfoView.tableView.contentSize.height - self.checkInfoView.headButton.height;
        self.checkInfoView.headButton.height = self.checkInfoView.tableView.height - 30 - MOL_TabbarSafeBottomMargin - height;
        self.checkInfoView.tableView.tableHeaderView = self.checkInfoView.headButton;
        
        [self.checkInfoView.tableView setContentOffset:CGPointZero animated:YES];
    }];
    
    [self.checkInfoViewModel.commitInfoCommand.executionSignals.switchToLatest subscribeNext:^(id x) {
        @strongify(self);
        MOLUserModel *user = (MOLUserModel *)x;
        if (user.code == MOL_SUCCESS_REQUEST) {

            dispatch_async(dispatch_get_main_queue(), ^{
                [self dismissViewControllerAnimated:YES completion:nil];
            });
            // 保存用户信息以及登录状态
            [[MOLUserManager shareUserManager] user_saveUserInfoWithModel:user];
        }
    }];
    
    // 监听按钮选择
    [self.checkInfoView.chooseSubject subscribeNext:^(id x) {
        @strongify(self);
        NSDictionary *dic = (NSDictionary *)x;
        MOLCheckInfoViewType type = [dic mol_jsonInteger:@"currentType"];
        NSString *name = [dic mol_jsonString:@"choose"];
        if (type == MOLCheckInfoViewType_sex) {  // 当前点击的是性别
            [MobClick event:@"_c_select_gender"];
            self.checkInfoViewModel.sexString = name;
            // 请求年龄数据
            [self.checkInfoViewModel.ageInfoCommand execute:nil];
        }else if (type == MOLCheckInfoViewType_age){ // 当前点击的是年龄段
            [MobClick event:@"_c_select_age"];
            self.checkInfoViewModel.ageString = name;
            // 请求学校信息数据
            [self.checkInfoViewModel.schoolInfoCommand execute:nil];
        }else if (type == MOLCheckInfoViewType_school){ // 当前点击的是学校
            
            if ([name isEqualToString:@"添加学校"]) {
                [MobClick event:@"_c_select_school"];
                 // 跳转搜索
                MOLSearchSchoolViewController *vc = [[MOLSearchSchoolViewController alloc] init];
                vc.schoolBlock = ^(NSString *school) {
                    @strongify(self);
                    self.checkInfoViewModel.schoolString = school;
                    [self.checkInfoViewModel.checkInfoCommand execute:nil];
                };
                
                [self.navigationController pushViewController:vc animated:YES];
            }else{
                [MobClick event:@"_c_select_school_later"];
                self.checkInfoViewModel.schoolString = name;
                [self.checkInfoViewModel.checkInfoCommand execute:nil];
            }
            
        }else if (type == MOLCheckInfoViewType_check){ // 当前点击的是确认信息？
            if ([name isEqualToString:@"确认"]) {
                [MobClick event:@"_c_confirm_information"];
                // 请求提交信息数据
                [self.checkInfoViewModel.commitInfoCommand execute:nil];
            }else{
                [MobClick event:@"_c_modify_information"];
                // 修改信息
                [self.checkInfoViewModel.sexInfoCommand execute:nil];
                self.checkInfoViewModel.sexString = nil;
                self.checkInfoViewModel.ageString = nil;
            }
        }
    }];
}

#pragma mark - UI
- (void)setupInfoCheckViewControllerUI
{
    MOLCheckInfoView *checkInfoView = [[MOLCheckInfoView alloc] init];
    _checkInfoView = checkInfoView;
    [self.view addSubview:checkInfoView];
}

- (void)calculatorInfoCheckViewControllerFrame
{
    self.checkInfoView.frame = self.view.bounds;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self calculatorInfoCheckViewControllerFrame];
}
@end
