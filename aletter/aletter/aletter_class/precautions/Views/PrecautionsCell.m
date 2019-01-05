//
//  PrecautionsCell.m
//  aletter
//
//  Created by xujin on 2018/9/6.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "PrecautionsCell.h"
#import "MOLSheildModel.h"
#import "MOLHead.h"

@interface PrecautionsCell()
@property(nonatomic,strong) NSIndexPath *indexPath;
@property(nonatomic,strong) MOLSheildModel *model;
@end

@implementation PrecautionsCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.model =[MOLSheildModel new];
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)precautionsCell:(MOLSheildModel *)mode indexPath:(NSIndexPath *)indexPath{
    self.model =mode;
    self.indexPath =indexPath;
    
    for (id views in self.contentView.subviews) {
        [views removeFromSuperview];
    }
    UILabel *content =UILabel.new;
    [content setBackgroundColor:[UIColor clearColor]];
    [content setText: mode.name?mode.name:@""];
    [content setTextColor:HEX_COLOR(0xffffff)];
    [content setFont:MOL_REGULAR_FONT(13)];
    [self.contentView addSubview:content];
    
    UIButton *button =[UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundColor:[UIColor clearColor]];
    [button setImage:[UIImage imageNamed:@"deletePrecautions"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(clearEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:button];
    
    UIView *lineView =UIView.new;
    [lineView setBackgroundColor:HEX_COLOR_ALPHA(0xffffff, 0.2)];
    [self.contentView addSubview:lineView];
    
    __weak __typeof(self) weakSelf = self;
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(weakSelf).offset(-20);
        make.bottom.mas_equalTo(lineView.mas_top).offset(-2);
        make.width.height.mas_equalTo(28);
    }];
    

    [content mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf).offset(20);
        make.bottom.mas_equalTo(lineView.mas_top).offset(-8);
        make.right.lessThanOrEqualTo(button.mas_left);
        make.height.mas_equalTo(18);
    }];
    
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.mas_left).offset(20);
        make.right.mas_equalTo(weakSelf.mas_right).offset(-20);
        make.height.mas_equalTo(1);
        make.top.mas_equalTo(weakSelf.mas_bottom);
    }];
    
}

#pragma mark-
#pragma mark 删除事件
- (void)clearEvent:(UIButton *)sender{
    NSLog(@"触发删除事件");
   self.cellDeleteBlock(self.indexPath, self.model);
}



- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
