//
//  MOLCardModel.h
//  aletter
//
//  Created by moli-2017 on 2018/8/10.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MOLCardModel : NSObject
@property (nonatomic, strong) NSString *channelImageString;
@property (nonatomic, strong) NSString *channelName;

@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) NSInteger sex;

@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *createTime;

@property (nonatomic, assign) NSInteger cardType;  // 0 有名字性别(举报帖子)  1 没有名字性别(私聊) 2 没有频道信息(举报评论)
@end
