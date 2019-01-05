//
//  ChatDetailModel.h
//  aletter
//
//  Created by xujin on 2018/9/1.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLBaseModel.h"
#import "MOLLightUserModel.h"
#import "MOLStoryModel.h"
@interface ChatDetailModel : MOLBaseModel
@property (nonatomic, assign)NSInteger chatId; //话题id
@property (nonatomic, assign)NSInteger createTime;//创建时间
@property (nonatomic, assign)NSInteger isClose; //0未关闭1已关闭2申请重新开启3举报关闭
@property (nonatomic, strong)MOLLightUserModel *ownUser; //用户自己ID
@property (nonatomic, strong)MOLStoryModel *storyVO; //帖子信息
@property (nonatomic, strong)MOLLightUserModel *toUser; //对方用户信息
@end
