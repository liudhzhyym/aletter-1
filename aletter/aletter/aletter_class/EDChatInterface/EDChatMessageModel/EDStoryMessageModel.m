//
//  EDStoryMessageModel.m
//  aletter
//
//  Created by moli-2017 on 2018/8/28.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "EDStoryMessageModel.h"
#import "EDStoryCell.h"

@implementation EDStoryMessageModel

/**
 * 用文字初始化message
 */
- (instancetype)initWithStory:(MOLStoryModel *)story
{
    if (self = [super init]) {
    }
    return self;
}

- (EDBaseChatCell *)getCellWithReuseIdentifier:(NSString *)identifier
{
    return [[EDStoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
}
- (CGFloat)getCellHeight
{
    return self.cellHeight;
}
@end
