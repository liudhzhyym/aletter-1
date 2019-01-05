//
//  MOLSureSchoolViewController.m
//  aletter
//
//  Created by moli-2017 on 2018/9/27.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLSureSchoolViewController.h"
#import "MOLHead.h"
#import "MOLChooseBoxCell.h"
#import "MOLLoginRequest.h"

@interface MOLSureSchoolViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) UIButton *headButton;

@property (nonatomic, strong) NSMutableArray *datasourceArray;
@property (nonatomic, strong) NSArray *nameArray;
@end

@implementation MOLSureSchoolViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.transitioningDelegate = self;
        self.modalPresentationStyle = UIModalPresentationCustom;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _datasourceArray = [NSMutableArray array];
    self.nameArray = @[@"确认",@"重新选择"];
    [self setupExitViewControllerUI];
    
    [self request_getDataSource];
    [self.tableView reloadData];
    
    self.headButton.height = MOL_SCREEN_HEIGHT - 30 - MOL_TabbarSafeBottomMargin - self.tableView.contentSize.height;
    self.tableView.tableHeaderView = self.headButton;
}
#pragma mark - 网络请求
- (void)request_getDataSource
{
    MOLChooseBoxModel *right_model2 = [[MOLChooseBoxModel alloc] init];
    right_model2.modelType = MOLChooseBoxModelType_rightText;
    right_model2.rightImageString = INTITLE_RIGHT_Normal;
    right_model2.rightTitle = self.school;
    right_model2.rightHighLight = NO;
    [self.datasourceArray addObject:right_model2];
    
    MOLChooseBoxModel *left_model = [[MOLChooseBoxModel alloc] init];
    left_model.modelType = MOLChooseBoxModelType_leftText;
    left_model.leftImageString = INTITLE_LEFT_Highlight;
    if (self.changeNum) {
        left_model.leftTitle = @"确认后，你的学校信息将无法修改";
    }else{
        left_model.leftTitle = @"确认后，你的学校信息仅能修改一次";
    }
    left_model.leftHighLight = YES;
    [self.datasourceArray addObject:left_model];
    
    for (NSInteger i = 0; i < self.nameArray.count; i++) {
        MOLChooseBoxModel *model = [[MOLChooseBoxModel alloc] init];
        model.modelType = MOLChooseBoxModelType_rightChooseButton;
        model.buttonTitle = self.nameArray[i];
        [self.datasourceArray addObject:model];
    }
}

#pragma mark - 按钮点击
- (void)button_clickHeadButton
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

- (void)button_clickReportButton:(NSString *)reason
{
    // 修改学校信息
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"name"] = self.school;
    MOLLoginRequest *r = [[MOLLoginRequest alloc] initRequest_changeSchoolWithParameter:dic];
    [r baseNetwork_startRequestWithcompletion:^(__kindof MOLBaseNetRequest *request, MOLBaseModel *responseModel, NSInteger code, NSString *message) {
       
        if (code == MOL_SUCCESS_REQUEST) {
            
            // 修改用户信息
            MOLUserModel *user = [MOLUserManagerInstance user_getUserInfo];
            user.school = self.school;
            user.schoolNum = user.schoolNum + 1;
            [MOLUserManagerInstance user_saveUserInfoWithModel:user];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self dismissViewControllerAnimated:NO completion:^{
                    [[[MOLGlobalManager shareGlobalManager] global_currentNavigationViewControl] popViewControllerAnimated:YES];
                }];
            });
            
        }else{
            [MOLToast toast_showWithWarning:YES title:message];
        }
    } failure:^(__kindof MOLBaseNetRequest *request) {
        
    }];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MOLChooseBoxModel *model = self.datasourceArray[indexPath.row];
    if (model.modelType == MOLChooseBoxModelType_rightChooseButton) {
        if ([model.buttonTitle isEqualToString:self.nameArray.lastObject]) {
            [self button_clickHeadButton]; // 返回
        }else{
            [self button_clickReportButton:model.buttonTitle];
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
            [cell chooseBoxCell_drawRadius:2 backgroundColor:HEX_COLOR_ALPHA(0xffffff, 0.2)];
        }else if ([model.buttonTitle isEqualToString:self.nameArray.lastObject]){
            [cell chooseBoxCell_drawRadius:1 backgroundColor:HEX_COLOR_ALPHA(0xffffff, 0.2)];
        }else{
            [cell chooseBoxCell_drawRadius:0 backgroundColor:HEX_COLOR_ALPHA(0xffffff, 0.2)];
        }
    }else{
        [cell chooseBoxCell_drawRadius:0 backgroundColor:HEX_COLOR_ALPHA(0xffffff, 0.2)];
    }
    return cell;
}

#pragma mark - UI
- (void)setupExitViewControllerUI
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
    [headButton addTarget:self action:@selector(button_clickHeadButton) forControlEvents:UIControlEventTouchUpInside];
    self.tableView.tableHeaderView = headButton;
}

- (void)calculatorExitViewControllerFrame
{
    self.tableView.frame = self.view.bounds;
    self.headButton.width = self.tableView.width;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self calculatorExitViewControllerFrame];
}

@end
