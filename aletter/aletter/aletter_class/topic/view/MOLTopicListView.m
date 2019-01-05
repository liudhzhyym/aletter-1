//
//  MOLTopicListView.m
//  aletter
//
//  Created by moli-2017 on 2018/8/4.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLTopicListView.h"
#import "MOLTopicListCell.h"

@implementation MOLTopicListView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupTopicListViewUI];
        _dataSourceArray = [NSMutableArray array];
    }
    return self;
}

#pragma mark - UI
- (void)setupTopicListViewUI
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
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView registerClass:[MOLTopicListCell class] forCellReuseIdentifier:@"MOLTopicListCell_id"];
    [self addSubview:tableView];
}

- (void)calculatorTopicListViewFrame
{
    self.tableView.frame = self.bounds;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self calculatorTopicListViewFrame];
}
@end
