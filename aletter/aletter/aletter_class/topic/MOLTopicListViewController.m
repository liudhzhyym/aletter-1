//
//  MOLTopicListViewController.m
//  aletter
//
//  Created by moli-2017 on 2018/8/4.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLTopicListViewController.h"
#import "MOLMailDetailViewController.h"

#import "MOLHead.h"
#import "MOLTopicListView.h"
#import "MOLTopicListViewModel.h"
#import "MOLTopicListCell.h"
#import "MOLTopicGroupModel.h"

@interface MOLTopicListViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) MOLTopicListViewModel *topicListViewModel;
@property (nonatomic, weak) MOLTopicListView *topicListView;
@property (nonatomic, weak) UIView *topView;
@property (nonatomic, weak) UIButton *closeButton;
@property (nonatomic, weak) UILabel *titleLabel;
@end

@implementation MOLTopicListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.topicListViewModel = [[MOLTopicListViewModel alloc] init];
    [self setupTopicListViewControllerUI];
    [self bindingTopicListViewModel];
    
    [self.topicListViewModel.topicListCommand execute:self.channelId];
}

#pragma mark - 按钮点击
- (void)button_clickCloseButton
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - viewModel
- (void)bindingTopicListViewModel
{
    @weakify(self);
    [self.topicListViewModel.topicListCommand.executionSignals.switchToLatest subscribeNext:^(id x) {
        @strongify(self);
        MOLTopicGroupModel *groupModel = (MOLTopicGroupModel *)x;
        if (groupModel.code == MOL_SUCCESS_REQUEST) {
            [self.topicListView.dataSourceArray removeAllObjects];
            [self.topicListView.dataSourceArray addObjectsFromArray:groupModel.resBody];
            [self.topicListView.tableView reloadData];
        }
        
    }];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MOLLightTopicModel *model = self.topicListView.dataSourceArray[indexPath.row];
    if (self.isChooseTopic) {
        if (self.chooseBlock) {
            self.chooseBlock(model);
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        
        // 跳转详情界面
        MOLMailDetailViewController *vc = [[MOLMailDetailViewController alloc] init];
        vc.topicId = model.topicId;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.topicListView.dataSourceArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MOLTopicListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MOLTopicListCell_id"];
    if (self.isChooseTopic) {
        [cell topicListCell_hiddenImageView:YES];
    }else{
        [cell topicListCell_hiddenImageView:NO];
    }
    MOLLightTopicModel *model = self.topicListView.dataSourceArray[indexPath.row];
    cell.topicModel = model;
    return cell;
}

#pragma mark - UI
- (void)setupTopicListViewControllerUI
{
    if (self.isChooseTopic) {
        UIView *topView = [[UIView alloc] init];
        _topView = topView;
        topView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:topView];
        
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeButton = closeButton;
        [closeButton setImage:[UIImage imageNamed:@"黑色关闭"] forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(button_clickCloseButton) forControlEvents:UIControlEventTouchUpInside];
        [topView addSubview:closeButton];
        
        UILabel *titleLabel = [[UILabel alloc] init];
        _titleLabel =titleLabel;
        titleLabel.text = @"选择话题";
        titleLabel.textColor = HEX_COLOR(0x091F38);
        titleLabel.font = MOL_REGULAR_FONT(18);
        [topView addSubview:titleLabel];
    }
    
    MOLTopicListView *topicListView = [[MOLTopicListView alloc] init];
    _topicListView =topicListView;
    if (self.isChooseTopic) {
        topicListView.backgroundColor = [UIColor whiteColor];
    }
    [self.view addSubview:topicListView];
    
    topicListView.tableView.delegate = self;
    topicListView.tableView.dataSource = self;
    
    [self basevc_setCenterTitle:@"热门话题" titleColor:HEX_COLOR(0xffffff)];
}

- (void)calculatorTopicListViewControllerFrame
{
    self.topView.height = 72;
    self.topView.width = MOL_SCREEN_WIDTH;
    self.topView.y = MOL_StatusBarHeight;
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.topView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(10, 10)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.topView.bounds;
    maskLayer.path = maskPath.CGPath;
    self.topView.backgroundColor = HEX_COLOR(0xffffff);
    self.topView.layer.mask = maskLayer;
    
    [self.closeButton sizeToFit];
    self.closeButton.x = 20;
    self.closeButton.y = 14;
    self.closeButton.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
    
    [self.titleLabel sizeToFit];
    self.titleLabel.y = 14;
    self.titleLabel.centerX = self.topView.width * 0.5;
    
    self.topicListView.frame = self.view.bounds;
    self.topicListView.y = self.topView.bottom;
    self.topicListView.height = self.view.height - self.topicListView.y;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self calculatorTopicListViewControllerFrame];
}
@end
