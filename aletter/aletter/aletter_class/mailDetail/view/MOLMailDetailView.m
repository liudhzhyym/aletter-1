//
//  MOLMailDetailView.m
//  aletter
//
//  Created by moli-2017 on 2018/8/3.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLMailDetailView.h"
#import "MOLMailDetailRichTextCell.h"
#import "MOLMailDetailVoiceCell.h"
#import "MOLHead.h"

@interface MOLMailDetailView ()
@property (nonatomic, strong) UIView *headView;
@property (nonatomic, weak) UILabel *mailNameLabel;
@end

@implementation MOLMailDetailView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupMailDetailViewUI];
        _dataSourceArray = [NSMutableArray array];
    }
    return self;
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    self.mailNameLabel.text = title;
}

#pragma mark - UI
- (void)setupMailDetailViewUI
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
    
    self.tableView.tableHeaderView = self.headView;
}

- (void)calculatorMailDetailViewFrame
{
    self.tableView.frame = self.bounds;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self calculatorMailDetailViewFrame];
}

#pragma mark - 懒加载
- (UIView *)headView
{
    if (_headView == nil) {
        
        _headView = [[UIView alloc] init];
        _headView.backgroundColor = [UIColor clearColor];
        _headView.width = MOL_SCREEN_WIDTH;
        _headView.height = 124;
        
        UILabel *label = [[UILabel alloc] init];
        _mailNameLabel = label;
        label.text = @"加载中...";
        label.textColor = HEX_COLOR(0xFAFAF0);
        label.font = MOL_MEDIUM_FONT(32);
        label.width = _headView.width;
        label.height = 45;
        label.bottom = 100;
        label.textAlignment = NSTextAlignmentCenter;
        [_headView addSubview:label];
    }
    
    return _headView;
}
@end
