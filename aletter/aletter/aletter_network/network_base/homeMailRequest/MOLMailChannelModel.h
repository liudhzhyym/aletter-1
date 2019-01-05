//
//  MOLMailChannelModel.h
//  aletter
//
//  Created by moli-2017 on 2018/8/11.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLBaseModel.h"
#import "MOLMailModel.h"

@interface MOLMailChannelModel : MOLBaseModel
@property (nonatomic, strong) NSArray *channelVOList;
@property (nonatomic, strong) NSString *styleId;
@property (nonatomic, strong) NSString *styleName;
@end
