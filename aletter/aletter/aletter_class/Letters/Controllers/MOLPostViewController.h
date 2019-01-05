//
//  MOLPostViewController.h
//  aletter
//
//  Created by xiaolong li on 2018/8/8.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//
//  发帖类，实现发帖功能

#import "MOLBaseViewController.h"
#import "TZLocationManager.h"
#import "MOLMailModel.h"
#import "MOLPostView.h"
#import "MOLStoryModel.h"
@class MOLLightTopicModel;
typedef void(^MOLPostViewControllerBlock)(MOLStoryModel *storyModel);

@interface MOLPostViewController : MOLBaseViewController

@property (strong, nonatomic) CLLocation *location;
@property (strong, nonatomic) MOLMailModel *mailModel;
@property (assign, nonatomic) PostBehaviorType behaviorType;
@property (nonatomic, strong) MOLStoryModel *storyModel;
@property (nonatomic, copy) MOLPostViewControllerBlock molPostViewControllerBlock;
@property (nonatomic, assign) NSInteger fromviewController;//1 表示来自MOLMailDetailViewController 类
@property (nonatomic, strong) MOLLightTopicModel *ttTopicDto;

@end
