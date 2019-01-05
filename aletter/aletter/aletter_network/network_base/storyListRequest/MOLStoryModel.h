//
//  MOLStoryModel.h
//  aletter
//
//  Created by moli-2017 on 2018/8/4.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLBaseModel.h"
#import "MOLLightUserModel.h"
#import "MOLMailModel.h"
#import "MOLLightPhotoModel.h"
#import "MOLLightTopicModel.h"
#import "MOLLightStampModel.h"
#import "MOLLightWeatherModel.h"

@interface MOLStoryModel : MOLBaseModel
@property (nonatomic, strong) NSString *audioUrl;  // 音频地址
@property (nonatomic, strong) MOLMailModel *channelVO;
@property (nonatomic, strong) NSString *chatCount;  // 聊天数
@property (nonatomic, assign) BOOL chatOpen;  // 是否交互
@property (nonatomic, strong) NSString *commentCount;  // 评论数
@property (nonatomic, strong) NSString *content;  // 内容
@property (nonatomic, strong) NSString *content_original;  // 原始内容
@property (nonatomic, strong) NSString *createTime;  // 创作时间
@property (nonatomic, strong) NSString *likeCount;  // 喜欢数
@property (nonatomic, assign) BOOL isAgree;    // 是否点赞
@property (nonatomic, strong) NSArray *photos;    // 图片
@property (nonatomic, assign) NSInteger privateSign;   // 私信标识  0 私信 2 公开
@property (nonatomic, strong) NSString *storyId;  // id
@property (nonatomic, assign) NSInteger storyType;  // 帖子类型
@property (nonatomic, strong) NSString *time;      // 音频时间
@property (nonatomic, strong) MOLLightUserModel *user;  // 用户实体
@property (nonatomic, strong) MOLLightTopicModel *topicVO; // 话题实体
@property (nonatomic, strong) MOLLightStampModel *stampVO;  // 邮票实体
@property (nonatomic, strong) MOLLightWeatherModel *weatherInfo;  // 天气实体

@property (nonatomic, assign) BOOL showAllButton;  // 是否显示查看全部

@property (nonatomic, assign) CGFloat richTextCellHeight;
@property (nonatomic, assign) CGFloat voiceCellHeight;


@property (nonatomic, strong) NSString *title;   // 标题
@property (nonatomic, strong) NSString *toPhoneId; //手机号

@property (nonatomic, assign) NSInteger sort; // 排序

@end
