//
//  MOLMailModel.h
//  aletter
//
//  Created by moli-2017 on 2018/8/4.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLBaseModel.h"
#import "MOLLightLandModel.h"

@interface MOLMailModel : MOLBaseModel
@property (nonatomic, strong) NSString *image; //频道图片
@property (nonatomic, strong) NSString *channelName; //频道名字
@property (nonatomic, strong) NSString *dec; //频道描述

@property (nonatomic, strong) NSString *channelId; //频道id  520暗恋
@property (nonatomic, assign) NSInteger isPublish; //1音频 2图文 3不允许发帖
@property (nonatomic, strong) NSString *prompt; //提示（占位文字）
@property (nonatomic, strong) NSString *question; // 发帖前 - 提问  # title
@property (nonatomic, strong) NSString *agreeContent; // 点赞文案
@property (nonatomic, strong) NSString *successContent; // 发帖后 - 提问  # title

@property (nonatomic, strong) MOLLightLandModel *landMineVO;
@end
