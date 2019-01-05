//
//  MOLInteractNotiView.m
//  aletter
//
//  Created by moli-2017 on 2018/8/23.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLInteractNotiView.h"
#import "MOLHead.h"
#import "MOLInteractNotiCell.h"

@implementation MOLInteractNotiView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _dataSourceArray = [NSMutableArray array];
        [self setupInteractNotiViewUI];
    }
    return self;
}

#pragma mark - UI
- (void)setupInteractNotiViewUI
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
    [tableView registerClass:[MOLInteractNotiCell class] forCellReuseIdentifier:@"MOLInteractNotiCell_id"];
    tableView.contentInset = UIEdgeInsetsMake(tableView.contentInset.top, tableView.contentInset.left, tableView.contentInset.bottom + MOL_TabbarSafeBottomMargin, tableView.contentInset.right);
    [self addSubview:tableView];
}

- (void)calculatorInteractNotiViewFrame
{
    self.tableView.frame = self.bounds;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self calculatorInteractNotiViewFrame];
}

@end
