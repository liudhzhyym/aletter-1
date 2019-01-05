//
//  MOLMeetCell.m
//  aletter
//
//  Created by moli-2017 on 2018/8/8.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLMeetCell.h"

#import "MOLHead.h"

@interface MOLMeetCell ()

@end

@implementation MOLMeetCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupMeetCellUI];
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)setStoryModel:(MOLStoryModel *)storyModel
{
    _storyModel = storyModel;
    self.storyDetailView.storyModel = storyModel;
}

#pragma mark - UI
- (void)setupMeetCellUI
{
    MOLStoryDetailView *storyDetailView = [[MOLStoryDetailView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.width, self.contentView.height)];
    _storyDetailView = storyDetailView;
    [self.contentView addSubview:storyDetailView];
}

- (void)calculatorsetupMeetCellFrame
{
    self.layer.cornerRadius = 12;
    self.clipsToBounds = YES;
    
    self.storyDetailView.width = self.contentView.width;
    self.storyDetailView.height = self.contentView.height;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self calculatorsetupMeetCellFrame];
}
@end
