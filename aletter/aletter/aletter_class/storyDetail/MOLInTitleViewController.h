//
//  MOLInTitleViewController.h
//  aletter
//
//  Created by moli-2017 on 2018/8/10.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLBaseViewController.h"
#import "MOLMailModel.h"

typedef NS_ENUM(NSUInteger, MOLInTitleViewControllerType) {
    MOLInTitleViewControllerType_comment,
    MOLInTitleViewControllerType_story,
    MOLInTitleViewControllerType_message,
};

@interface MOLInTitleViewController : MOLBaseViewController
@property (nonatomic, assign) MOLInTitleViewControllerType type;

@property (nonatomic, strong) MOLMailModel *mailModel;  // 当类型是MOLInTitleViewControllerType_story时，需要传递
@property (nonatomic, strong) void(^messageActionBlock)(void);
@property (nonatomic, strong) void(^storyActionBlock)(NSArray *array);
@end
