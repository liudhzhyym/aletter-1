//
//  MOLStoryDetailViewController.h
//  aletter
//
//  Created by moli-2017 on 2018/8/3.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLBaseViewController.h"

@interface MOLStoryDetailViewController : MOLBaseViewController
@property (nonatomic, strong) NSString *storyId;
@property (nonatomic, strong) void(^shareMineStoryBlock)(void);
@end
