//
//  EDStoryMessageModel.h
//  aletter
//
//  Created by moli-2017 on 2018/8/28.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "EDBaseMessageModel.h"
#import "MOLStoryModel.h"

@interface EDStoryMessageModel : EDBaseMessageModel

@property (nonatomic, assign) CGFloat cellHeight;

/**
 * 用文字初始化message
 */
- (instancetype)initWithStory:(MOLStoryModel *)story;

- (CGFloat)getCellHeight;
@end
