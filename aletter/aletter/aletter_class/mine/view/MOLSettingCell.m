//
//  MOLSettingCell.m
//  aletter
//
//  Created by moli-2017 on 2018/8/17.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLSettingCell.h"
#import "MOLHead.h"
@interface MOLSettingCell ()
@property (nonatomic, weak) UILabel *nameLabel;
@property (nonatomic, weak) UILabel *subNameLabel;
@property (nonatomic, weak) UIImageView *arrowImageView;
@end

@implementation MOLSettingCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupSettingCellUI];
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setSettingModel:(MOLSettingModel *)settingModel
{
    _settingModel = settingModel;
    self.nameLabel.text = settingModel.name;
    [self.nameLabel sizeToFit];
    
    if (settingModel.type == 0) {
        self.subNameLabel.hidden = NO;
        self.arrowImageView.hidden = YES;
        self.subNameLabel.text = settingModel.subName;
        [self.subNameLabel sizeToFit];
    }else if (settingModel.type == 1){
        self.subNameLabel.hidden = YES;
        self.arrowImageView.hidden = NO;
        self.subNameLabel.text = @" ";
    }else if (settingModel.type == 2){
        self.subNameLabel.hidden = NO;
        self.arrowImageView.hidden = NO;
        self.subNameLabel.text = settingModel.subName;
    }else{
        self.subNameLabel.hidden = YES;
        self.arrowImageView.hidden = YES;
        self.subNameLabel.text = @" ";
    }
    
}

#pragma  mark - UI
- (void)setupSettingCellUI
{
    UILabel *nameLabel = [[UILabel alloc] init];
    _nameLabel = nameLabel;
    nameLabel.text = @" ";
    nameLabel.textColor = HEX_COLOR_ALPHA(0xffffff, 0.8);
    nameLabel.font = MOL_MEDIUM_FONT(14);
    [self.contentView addSubview:nameLabel];
    
    UILabel *subNameLabel = [[UILabel alloc] init];
    _subNameLabel = subNameLabel;
    subNameLabel.text = @" ";
    subNameLabel.textColor = HEX_COLOR_ALPHA(0xffffff, 0.6);
    subNameLabel.font = MOL_LIGHT_FONT(14);
    [self.contentView addSubview:subNameLabel];
    
    UIImageView *arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mine_arrow"]];
    _arrowImageView = arrowImageView;
    [self.contentView addSubview:arrowImageView];
}

- (void)calculatorSettingCellFrame
{
    [self.nameLabel sizeToFit];
    self.nameLabel.centerY = self.contentView.height * 0.5;
    self.nameLabel.x = 20;
    
    [self.subNameLabel sizeToFit];
    if (self.subNameLabel.width > self.contentView.width * 0.65) {
        self.subNameLabel.width = self.contentView.width * 0.65;
    }
    self.subNameLabel.centerY = self.nameLabel.centerY;
    self.subNameLabel.right = self.settingModel.type == 2 ? self.contentView.width - 35 : self.contentView.width - 20;
    
    self.arrowImageView.width = 5;
    self.arrowImageView.height = 9;
    self.arrowImageView.centerY = self.nameLabel.centerY;
    self.arrowImageView.right = self.contentView.width - 20;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self calculatorSettingCellFrame];
}
@end
