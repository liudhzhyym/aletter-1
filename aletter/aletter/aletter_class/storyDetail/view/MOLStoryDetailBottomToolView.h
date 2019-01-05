//
//  MOLStoryDetailBottomToolView.h
//  aletter
//
//  Created by moli-2017 on 2018/8/6.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MOLStoryModel.h"

typedef NS_ENUM(NSUInteger, MOLStoryDetailBottomToolViewType) {
    MOLStoryDetailBottomToolViewType_other = 1,    // 别人
    MOLStoryDetailBottomToolViewType_own,      // 自己
    MOLStoryDetailBottomToolViewType_invalid,  // 无交互
};

@interface MOLStoryDetailBottomToolView : UIView
@property (nonatomic, weak) UIButton *msgButton;   // 私信
@property (nonatomic, weak) UIButton *commentButton; // 评论
@property (nonatomic, weak) UIButton *likeButton;    // 喜欢
@property (nonatomic, weak) UIButton *invalidButton;    // 禁止交互
@property (nonatomic, assign) MOLStoryDetailBottomToolViewType toolType;  // 工具条类型

@property (nonatomic, strong) MOLStoryModel *storyModel;
@end
