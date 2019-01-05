//
//  PostModel.h
//  aletter
//
//  Created by xujin on 2018/8/22.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLBaseModel.h"
#import "MOLLightWeatherModel.h"
#import "StampModel.h"
#import "MOLMailModel.h"
#import "MOLLightTopicModel.h"
#import "TZLocationManager.h"

@interface PostModel : MOLBaseModel
@property (nonatomic ,strong)MOLLightWeatherModel *weatherModel; //天气model
@property (nonatomic ,strong)StampModel *stampModel; //邮票model
@property (nonatomic ,strong)MOLMailModel *mailModel; //频道model
@property (nonatomic ,strong)MOLLightTopicModel *topicModel; //添加话题model
@property (nonatomic ,copy)NSString *content; //帖子摘要内容
@property (nonatomic ,copy)NSString *audioUrl;//音频链接
@property (nonatomic ,copy)NSString *channelId;//频道ID
@property (nonatomic ,copy)NSString *chatOpen;//是否允许互动  1y 0n
@property (nonatomic ,copy)NSString *name;//频道昵称
@property (nonatomic ,strong)NSMutableArray *photos;//帖子图片集合
@property (nonatomic ,copy)NSString *privateSign;//私信标识 0私信 2公开
@property (nonatomic ,copy)NSString *storyType;//帖子类型  0 语音 1图文
@property (nonatomic ,copy)NSString *time; //音频时长
@property (nonatomic ,copy)NSString *toPhoneId;//接收人手机号
@property (nonatomic ,strong)CLLocation *location;//经纬度
@property (nonatomic ,copy)NSString *storyId; //帖子ID

@end
