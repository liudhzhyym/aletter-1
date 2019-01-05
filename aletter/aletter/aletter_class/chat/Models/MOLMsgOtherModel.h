//
//  MOLMsgOtherModel.h
//  aletter
//
//  Created by xujin on 2018/9/1.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLBaseModel.h"
@class MOLStoryModel;
typedef NS_ENUM(NSInteger, EIMMSGOTHER_TYPE) {
    EIMMSGOTHER_UNDEFINED = 0,         //未知
    EIMMSGOTHER_TIME = 1,              //时间
    EIMMSGOTHER_StoryText = 2,         //帖子文字
    EIMMSGOTHER_StorCard =3,           //帖子卡片
};

@interface MOLMsgOtherModel : MOLBaseModel
@property (nonatomic,assign)EIMMSGOTHER_TYPE msgType;
@property (nonatomic,strong)NSString *msg;
@property (nonatomic,strong)MOLStoryModel *storyDto;
@property (nonatomic,strong)NSDate *stamp;

@end
