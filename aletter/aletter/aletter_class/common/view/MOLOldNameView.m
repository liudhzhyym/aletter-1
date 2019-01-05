//
//  MOLOldNameView.m
//  aletter
//
//  Created by moli-2017 on 2018/8/10.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLOldNameView.h"
#import "MOLOldNameCell.h"
#import "MOLHead.h"
#import "MOLActionRequest.h"

@interface MOLOldNameView ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) UIView *alphaView;
@property (nonatomic, weak) UIView *backBottomView;
@property (nonatomic, weak) UIButton *closeButton;
@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataSourceArray;

@end

@implementation MOLOldNameView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.dataSourceArray = [NSMutableArray array];
        [self setupOldNameViewUI];
        self.backgroundColor = [HEX_COLOR(0x091F38) colorWithAlphaComponent:0.8];
        [self request_getOldName];
        
    }
    return self;
}

#pragma mark - 网络请求
- (void)request_getOldName
{
    MOLActionRequest *r = [[MOLActionRequest alloc] initRequest_searchCommentNameActionCommentWithParameter:nil];
    [r baseNetwork_startRequestWithcompletion:^(__kindof MOLBaseNetRequest *request, MOLBaseModel *responseModel, NSInteger code, NSString *message) {
       
        MOLOldNameGroupModel *groupModel = (MOLOldNameGroupModel *)responseModel;
        
        if (code == MOL_SUCCESS_REQUEST) {
            
            [self.dataSourceArray removeAllObjects];
            [self.dataSourceArray addObjectsFromArray:groupModel.resBody];
            [self.tableView reloadData];
            
        }else{
            [MOLToast toast_showWithWarning:YES title:message];
        }
        
    } failure:^(__kindof MOLBaseNetRequest *request) {
        
    }];
}

#pragma mark - 按钮点击
- (void)button_clickCloseButton
{
    if ([self.delegate respondsToSelector:@selector(oldNameView_clickCloseButtonOrOldName:)]) {
        [self.delegate oldNameView_clickCloseButtonOrOldName:nil];
    }
    [self removeFromSuperview];
}

- (void)button_clickClose
{
    [self button_clickCloseButton];
//    CGPoint location = [tap locationInView:self];
//    CGPoint pInView = [self.layer convertPoint:location toLayer:self.backBottomView.layer];
//
//    if ([self.backBottomView.layer containsPoint:pInView]) {
//
//    }else{
//
//    }
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // 获取名字 传递出去
    MOLOldNameModel *model = self.dataSourceArray[indexPath.row];
    if ([self.delegate respondsToSelector:@selector(oldNameView_clickCloseButtonOrOldName:)]) {
        [self.delegate oldNameView_clickCloseButtonOrOldName:model.name];
    }
    
    [self removeFromSuperview];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSourceArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MOLOldNameModel *model = self.dataSourceArray[indexPath.row];
    MOLOldNameCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MOLOldNameCell_id"];
    cell.nameModel = model;
    return cell;
}

#pragma mark - UI
- (void)setupOldNameViewUI
{
    UIView *alphaView = [[UIView alloc] init];
    _alphaView = alphaView;
    alphaView.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(button_clickClose)];
    [alphaView addGestureRecognizer:tap];
    [self addSubview:alphaView];
    
    UIView *backBottomView = [[UIView alloc] init];
    _backBottomView = backBottomView;
    backBottomView.backgroundColor = HEX_COLOR(0x4A90E2);
    [self addSubview:backBottomView];
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _closeButton = closeButton;
    [closeButton setTitle:@"退出" forState:UIControlStateNormal];
    [closeButton setTitleColor:HEX_COLOR(0xffffff) forState:UIControlStateNormal];
    closeButton.titleLabel.font = MOL_LIGHT_FONT(14);
    [closeButton addTarget:self action:@selector(button_clickCloseButton) forControlEvents:UIControlEventTouchUpInside];
    [backBottomView addSubview:closeButton];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    _titleLabel = titleLabel;
    titleLabel.text = @"选择曾用名";
    titleLabel.textColor = HEX_COLOR(0xffffff);
    titleLabel.font = MOL_REGULAR_FONT(16);
    [backBottomView addSubview:titleLabel];
    
    UITableView *tableView = [[UITableView alloc] init];
    _tableView = tableView;
    tableView.backgroundColor = [UIColor clearColor];
    if (@available(iOS 11.0, *)) {
        tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    tableView.estimatedRowHeight = 0;
    tableView.estimatedSectionHeaderHeight = 0;
    tableView.estimatedSectionFooterHeight = 0;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView registerClass:[MOLOldNameCell class] forCellReuseIdentifier:@"MOLOldNameCell_id"];
    [backBottomView addSubview:tableView];
}

- (void)calculatorOldNameViewFrame
{
    self.backBottomView.width = self.width;
    self.backBottomView.height = 300 + MOL_TabbarSafeBottomMargin;
    self.backBottomView.y = self.height - self.backBottomView.height;
    
    self.alphaView.height = self.height - self.backBottomView.height;
    self.alphaView.width = self.width;
    
    [self.closeButton sizeToFit];
    self.closeButton.x = 20;
    self.closeButton.y = 15;
    
    [self.titleLabel sizeToFit];
    self.titleLabel.centerX = self.width * 0.5;
    self.titleLabel.centerY = self.closeButton.centerY;
    
    self.tableView.width = self.width;
    self.tableView.y = self.closeButton.bottom + 8;
    self.tableView.height = self.backBottomView.height - MOL_TabbarSafeBottomMargin - self.tableView.y;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self calculatorOldNameViewFrame];
}
@end
