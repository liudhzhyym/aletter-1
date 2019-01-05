//
//  MOLActionChatViewController.m
//  aletter
//
//  Created by moli-2017 on 2018/9/2.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLActionChatViewController.h"
#import "MOLHead.h"
#import "MOLChooseBoxCell.h"
#import "MOLMessageRequest.h"

@interface MOLActionChatViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) UIButton *headButton;

@property (nonatomic, strong) NSMutableArray *datasourceArray;
@property (nonatomic, strong) NSArray *nameArray;
@end

@implementation MOLActionChatViewController

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
    if (self.type == 0) {
        self.nameArray = @[@"举报对话",@"我再想想"];
    }else{
        self.nameArray = @[@"关闭对话",@"举报对话",@"我再想想"];
    }
    
    [self setupActionChatViewControllerUI];
    
    [self request_getDataSource];
    [self.tableView reloadData];
    
    self.headButton.height = MOL_SCREEN_HEIGHT - 30 - MOL_TabbarSafeBottomMargin - self.tableView.contentSize.height;
    self.tableView.tableHeaderView = self.headButton;
}

#pragma mark - 网络请求
- (void)request_getDataSource
{
    MOLChooseBoxModel *left_model = [[MOLChooseBoxModel alloc] init];
    left_model.modelType = MOLChooseBoxModelType_leftText;
    left_model.leftImageString = INTITLE_LEFT_Highlight;
    left_model.leftTitle = @"你想要...";
    left_model.leftHighLight = YES;
    [self.datasourceArray addObject:left_model];
    
    for (NSInteger i = 0; i < self.nameArray.count; i++) {
        MOLChooseBoxModel *model = [[MOLChooseBoxModel alloc] init];
        model.modelType = MOLChooseBoxModelType_rightChooseButton;
        model.buttonTitle = self.nameArray[i];
        [self.datasourceArray addObject:model];
    }
}

- (void)request_getReportDataSource
{
    [self.datasourceArray removeAllObjects];
    
    self.nameArray = @[@"性骚扰",@"强烈冒犯性的内容",@"垃圾广告",@"我再想想"];
    
    MOLChooseBoxModel *left_model = [[MOLChooseBoxModel alloc] init];
    left_model.modelType = MOLChooseBoxModelType_leftText;
    left_model.leftImageString = INTITLE_LEFT_Normal;
    left_model.leftTitle = @"你想要...";
    left_model.leftHighLight = NO;
    [self.datasourceArray addObject:left_model];
    
    MOLChooseBoxModel *right_model = [[MOLChooseBoxModel alloc] init];
    right_model.modelType = MOLChooseBoxModelType_rightText;
    right_model.rightImageString = INTITLE_RIGHT_Normal;
    right_model.rightTitle = @"举报对话";
    right_model.rightHighLight = NO;
    [self.datasourceArray addObject:right_model];
    
    MOLChooseBoxModel *left_model1 = [[MOLChooseBoxModel alloc] init];
    left_model1.modelType = MOLChooseBoxModelType_leftText;
    left_model1.leftImageString = INTITLE_LEFT_Highlight;
    left_model1.leftTitle = @"选择举报理由";
    left_model1.leftHighLight = YES;
    [self.datasourceArray addObject:left_model1];
    
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

- (void)button_clickActionButton:(NSString *)buttonTitle
{
    if ([buttonTitle containsString:@"关闭"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:NO completion:nil];
        });
        
        if (self.closeChatBlock) {
            self.closeChatBlock();
        }
    }else if ([buttonTitle containsString:@"举报"]){
        // 切换数据源
        self.tableView.tableHeaderView = nil;
        [self request_getReportDataSource];
        [self.tableView reloadData];
        self.headButton.height = MOL_SCREEN_HEIGHT - 30 - MOL_TabbarSafeBottomMargin - self.tableView.contentSize.height;
        self.tableView.tableHeaderView = self.headButton;
    }else{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:NO completion:nil];
        });
        if (self.reportChatBlock) {
            self.reportChatBlock(buttonTitle);
        }
    }
    
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
            [self button_clickActionButton:model.buttonTitle];
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
- (void)setupActionChatViewControllerUI
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

- (void)calculatorActionChatViewControllerFrame
{
    self.tableView.frame = self.view.bounds;
    self.headButton.width = self.tableView.width;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self calculatorActionChatViewControllerFrame];
}
@end
