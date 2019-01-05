//
//  MOLMineMailModel.h
//  aletter
//
//  Created by moli-2017 on 2018/8/18.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLBaseModel.h"
#import "MOLStoryModel.h"

@interface MOLMineMailModel : MOLBaseModel
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSMutableArray *storyList;
@end
