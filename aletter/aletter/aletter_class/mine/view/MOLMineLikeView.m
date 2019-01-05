//
//  MOLMineLikeView.m
//  aletter
//
//  Created by moli-2017 on 2018/8/17.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLMineLikeView.h"
#import "MOLMailDetailRichTextCell.h"
#import "MOLMailDetailVoiceCell.h"
#import "MOLHead.h"

@implementation MOLMineLikeView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _dataSourceArray = [NSMutableArray array];
        [self setupMineLikeViewUI];
    }
    return self;
}

#pragma mark - UI
- (void)setupMineLikeViewUI
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
    [tableView registerClass:[MOLMailDetailRichTextCell class] forCellReuseIdentifier:@"MOLMailDetailRichTextCell_id"];
    [tableView registerClass:[MOLMailDetailVoiceCell class] forCellReuseIdentifier:@"MOLMailDetailVoiceCell_id"];
    [self addSubview:tableView];
}

- (void)calculatorMineLikeViewFrame
{
    self.tableView.frame = self.bounds;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self calculatorMineLikeViewFrame];
}
@end
