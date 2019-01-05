//
//  MOLTopicListCell.m
//  aletter
//
//  Created by moli-2017 on 2018/8/4.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLTopicListCell.h"
#import "MOLHead.h"

@interface MOLTopicListCell ()
@property (nonatomic, weak) UILabel *topicNameLabel;
@property (nonatomic, weak) UIImageView *detailImageView;
@end

@implementation MOLTopicListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupTopicListCellUI];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)topicListCell_hiddenImageView:(BOOL)hidden;
{
    self.detailImageView.hidden = hidden;
    if (hidden) {
        self.topicNameLabel.textColor = HEX_COLOR(0x091F38);
    }else{
        self.topicNameLabel.textColor = HEX_COLOR(0xffffff);
    }
}


- (void)setTopicModel:(MOLLightTopicModel *)topicModel
{
    _topicModel = topicModel;
    self.topicNameLabel.text = topicModel.topicName;
    [self.topicNameLabel sizeToFit];
}

#pragma mark - UI
- (void)setupTopicListCellUI
{
    UILabel *topicNameLabel = [[UILabel alloc] init];
    _topicNameLabel = topicNameLabel;
    topicNameLabel.text = @"# 我有一个脑洞";
    topicNameLabel.textColor = HEX_COLOR(0xffffff);
    topicNameLabel.font = MOL_REGULAR_FONT(14);
    [self.contentView addSubview:topicNameLabel];
    
    UIImageView *detailImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"detail_topic_more"]];
    _detailImageView = detailImageView;
    [self.contentView addSubview:detailImageView];
}

- (void)calculatorTopicListCellFrame
{
    [self.topicNameLabel sizeToFit];
    self.topicNameLabel.x = 20;
    self.topicNameLabel.centerY = self.contentView.height * 0.5;
    
    self.detailImageView.right = self.contentView.width - 20;
    self.detailImageView.centerY = self.topicNameLabel.centerY;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self calculatorTopicListCellFrame];
}
@end
