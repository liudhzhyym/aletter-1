//
//  MOLAdminHideViewController.h
//  aletter
//
//  Created by moli-2017 on 2018/9/18.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLBaseViewController.h"
#import "MOLStoryModel.h"
@interface MOLAdminHideViewController : MOLBaseViewController

@property (nonatomic, strong) MOLStoryModel *storyModel;

@property (nonatomic, strong) void(^adminHideStoryBlock)(void);

@end
