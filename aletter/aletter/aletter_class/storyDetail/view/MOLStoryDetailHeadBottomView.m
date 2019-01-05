//
//  MOLStoryDetailHeadBottomView.m
//  aletter
//
//  Created by moli-2017 on 2018/8/11.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLStoryDetailHeadBottomView.h"
#import "MOLHead.h"

@interface MOLStoryDetailHeadBottomView ()
@property (nonatomic, weak) UILabel *commentCountLabel;
@property (nonatomic, weak) UILabel *likeCountLabel;
@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, weak) UILabel *actionLabel;
@end

@implementation MOLStoryDetailHeadBottomView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupStoryDetailHeadBottomViewUI];
    }
    return self;
}

- (void)setStoryModel:(MOLStoryModel *)storyModel
{
    _storyModel = storyModel;
    if (storyModel.commentCount.integerValue > 0) {
        self.commentCountLabel.hidden = NO;
        self.actionLabel.hidden = NO;
        self.imageView.hidden = NO;
    }else{
        self.commentCountLabel.hidden = YES;
        self.actionLabel.hidden = YES;
        self.imageView.hidden = YES;
    }
    
    self.commentCountLabel.text = [NSString stringWithFormat:@"评论 %@",storyModel.commentCount];
    if (storyModel.privateSign == 2) {
        self.likeCountLabel.text = [NSString stringWithFormat:@"%@喜欢",storyModel.likeCount];
        self.likeCountLabel.hidden = NO;
    }else{
        self.likeCountLabel.hidden = YES;
    }
}

#pragma mark - UI
- (void)setupStoryDetailHeadBottomViewUI
{
    UILabel *commentCountLabel = [[UILabel alloc] init];
    _commentCountLabel = commentCountLabel;
    commentCountLabel.text = @"评论 0";
    commentCountLabel.textColor = HEX_COLOR(0x284D6B);
    commentCountLabel.font = MOL_MEDIUM_FONT(16);
    [self addSubview:commentCountLabel];
    
    UILabel *likeCountLabel = [[UILabel alloc] init];
    _likeCountLabel = likeCountLabel;
    likeCountLabel.text = @"0喜欢";
    likeCountLabel.textColor = HEX_COLOR(0x809FC2);
    likeCountLabel.font = MOL_MEDIUM_FONT(12);
    likeCountLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:likeCountLabel];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:INTITLE_LEFT_Highlight]];
    _imageView = imageView;
    [self addSubview:imageView];
    
    UILabel *actionLabel = [[UILabel alloc] init];
    _actionLabel = actionLabel;
    actionLabel.text = @"长按评论可以删除或举报";
    actionLabel.textColor = HEX_COLOR(0x074D81);
    actionLabel.font = MOL_LIGHT_FONT(14);
    [self addSubview:actionLabel];
}

- (void)calculatorStoryDetailHeadBottomViewFrame
{
    self.commentCountLabel.width = 100;
    self.commentCountLabel.height = 22;
    self.commentCountLabel.x = 15;
    self.commentCountLabel.bottom = self.height * 0.5 - 9;
    
    self.likeCountLabel.width = 100;
    self.likeCountLabel.height = 17;
    self.likeCountLabel.bottom = self.commentCountLabel.bottom;
    self.likeCountLabel.right = self.width - 15;
    
    self.imageView.x = self.commentCountLabel.x;
    self.imageView.y = self.height * 0.5 + 9;
    
    self.actionLabel.width = 160;
    self.actionLabel.height = 20;
    self.actionLabel.centerY = self.imageView.centerY;
    self.actionLabel.x = self.imageView.right + 5;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self calculatorStoryDetailHeadBottomViewFrame];
}
@end
