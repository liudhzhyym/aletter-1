//
//  MOLSystemNotiView.m
//  aletter
//
//  Created by moli-2017 on 2018/8/23.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLSystemNotiView.h"
#import "MOLSystemNotiCell.h"
#import "MOLHead.h"

@interface MOLSystemNotiView ()

@end

@implementation MOLSystemNotiView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _dataSourceArray = [NSMutableArray array];
        [self setupSystemNotiViewUI];
    }
    return self;
}

#pragma mark - UI
- (void)setupSystemNotiViewUI
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
    [tableView registerClass:[MOLSystemNotiCell class] forCellReuseIdentifier:@"MOLSystemNotiCell_id"];
    tableView.contentInset = UIEdgeInsetsMake(tableView.contentInset.top, tableView.contentInset.left, tableView.contentInset.bottom + MOL_TabbarSafeBottomMargin, tableView.contentInset.right);
    [self addSubview:tableView];
}

- (void)calculatorSystemNotiViewFrame
{
    self.tableView.frame = self.bounds;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self calculatorSystemNotiViewFrame];
}
@end
