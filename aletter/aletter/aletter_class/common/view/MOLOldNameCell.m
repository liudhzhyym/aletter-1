//
//  MOLOldNameCell.m
//  aletter
//
//  Created by moli-2017 on 2018/8/10.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLOldNameCell.h"
#import "MOLHead.h"

@interface MOLOldNameCell ()
@property (nonatomic, weak) UILabel *nameLabel;
@property (nonatomic, weak) UILabel *countLabel;
@end

@implementation MOLOldNameCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupOldNameCellUI];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


- (void)setNameModel:(MOLOldNameModel *)nameModel
{
    _nameModel = nameModel;
    self.nameLabel.text = nameModel.name;
    [self.nameLabel sizeToFit];
    self.countLabel.text = [NSString stringWithFormat:@"%@次",nameModel.useNum];
    [self.countLabel sizeToFit];
}

#pragma mark - UI
- (void)setupOldNameCellUI
{
    UILabel *nameLabel = [[UILabel alloc] init];
    _nameLabel = nameLabel;
    nameLabel.text = @" ";
    nameLabel.textColor = HEX_COLOR(0xffffff);
    nameLabel.font = MOL_REGULAR_FONT(14);
    [self.contentView addSubview:nameLabel];
    
    UILabel *countLabel = [[UILabel alloc] init];
    _countLabel = countLabel;
    countLabel.text = @"1次";
    countLabel.textColor = HEX_COLOR(0xffffff);
    countLabel.font = MOL_REGULAR_FONT(14);
    [self.contentView addSubview:countLabel];
}

- (void)calculatorOldNameCellFrame
{
    [self.nameLabel sizeToFit];
    self.nameLabel.y = self.contentView.height - self.nameLabel.height;
    self.nameLabel.x = 20;
    
    [self.countLabel sizeToFit];
    self.countLabel.centerY = self.nameLabel.centerY;
    self.countLabel.right = self.contentView.width - 20;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self calculatorOldNameCellFrame];
}
@end
