//
//  MOLStoryGroupModel.h
//  aletter
//
//  Created by moli-2017 on 2018/8/4.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLBaseModel.h"
#import "MOLStoryModel.h"

@interface MOLStoryGroupModel : MOLBaseModel
@property (nonatomic, strong) MOLMailModel *channelVO;
@property (nonatomic, strong) MOLLightTopicModel *topicVO;
@property (nonatomic, strong) NSArray *storyList;
@property (nonatomic, strong) NSArray *resBody;
@end
