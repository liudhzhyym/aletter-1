//
//  MOLChatModel.h
//  aletter
//
//  Created by moli-2017 on 2018/8/22.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLBaseModel.h"
#import "MOLMailModel.h"
#import "MOLLightUserModel.h"
#import "MOLLightChatLogModel.h"

@interface MOLChatModel : MOLBaseModel
@property (nonatomic, strong) NSString *chatId;
@property (nonatomic, assign) BOOL isClose;
@property (nonatomic, strong) NSString *unReadNum;
@property (nonatomic, strong) NSString *createTime;
@property (nonatomic, strong) MOLMailModel *channelVO;
@property (nonatomic, strong) MOLLightChatLogModel *chatLogVO;
@property (nonatomic, strong) MOLLightUserModel *ownUser;
@property (nonatomic, strong) MOLLightUserModel *toUser;
@end
