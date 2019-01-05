//
//  MOLMineMessageView.m
//  aletter
//
//  Created by moli-2017 on 2018/8/21.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLMineMessageView.h"
#import "MOLHead.h"
#import "MOLMessageListCell.h"

@implementation MOLMineMessageView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _dataSourceArray = [NSMutableArray array];
        [self setupMineMessageViewUI];
    }
    return self;
}

#pragma mark - UI
- (void)setupMineMessageViewUI
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, MOL_SCREEN_WIDTH, MOL_SCREEN_HEIGHT) style:UITableViewStyleGrouped];
    _tableView = tableView;
    tableView.backgroundColor = [UIColor clearColor];
    if (@available(iOS 11.0, *)) {
        tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    tableView.estimatedRowHeight = 0;
    tableView.estimatedSectionHeaderHeight = 0;
    tableView.estimatedSectionFooterHeight = 0;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.contentInset = UIEdgeInsetsMake(0, 0, MOL_TabbarSafeBottomMargin, 0);
    [tableView registerClass:[MOLMessageListCell class] forCellReuseIdentifier:@"MOLMessageListCell_id"];
    [self addSubview:tableView];
}

- (void)calculatorMineMessageViewFrame
{
    self.tableView.frame = self.bounds;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self calculatorMineMessageViewFrame];
}

@end
