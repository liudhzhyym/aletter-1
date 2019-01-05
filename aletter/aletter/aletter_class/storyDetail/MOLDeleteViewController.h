//
//  MOLDeleteViewController.h
//  aletter
//
//  Created by moli-2017 on 2018/8/14.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLBaseViewController.h"
#import "MOLStoryModel.h"
#import "MOLCommentModel.h"

@interface MOLDeleteViewController : MOLBaseViewController

@property (nonatomic, strong) MOLStoryModel *storyModel;

@property (nonatomic, strong) void(^deleteStoryBlock)(void);
@end
