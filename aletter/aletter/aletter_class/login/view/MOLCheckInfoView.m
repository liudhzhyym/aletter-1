//
//  MOLCheckInfoView.m
//  aletter
//
//  Created by moli-2017 on 2018/8/3.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLCheckInfoView.h"
#import "MOLChooseBoxCell.h"
#import "MOLHead.h"

@interface MOLCheckInfoView ()<UITableViewDelegate, UITableViewDataSource>

@end

@implementation MOLCheckInfoView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupCheckInfoViewUI];
        self.chooseSubject = [RACReplaySubject subject];
    }
    return self;
}

#pragma mark - delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MOLChooseBoxModel *model = self.datasourceArray[indexPath.row];
    if (model.modelType == MOLChooseBoxModelType_rightChooseButton) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[@"currentType"] = @(self.currentType);
        dic[@"choose"] = model.buttonTitle;
        [self.chooseSubject sendNext:dic];
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
- (void)setupCheckInfoViewUI
{
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
    [tableView registerClass:[MOLChooseBoxCell class] forCellReuseIdentifier:@"MOLChooseBoxCell_id"];
    [self addSubview:tableView];
    
    UIButton *headButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _headButton = headButton;
    self.tableView.tableHeaderView = headButton;
}

- (void)calculatorCheckInfoViewFrame
{
    self.tableView.frame = self.bounds;
    self.headButton.width = self.tableView.width;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self calculatorCheckInfoViewFrame];
}

@end
