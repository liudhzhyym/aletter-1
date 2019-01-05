//
//  LocationViewController.h
//  aletter
//
//  Created by xujin on 2018/9/4.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLBaseViewController.h"
@class PostModel;
typedef void(^LocationViewControllerBlock)(void);

@interface LocationViewController : MOLBaseViewController
@property (nonatomic, strong) PostModel *postModel;
@property (nonatomic, strong) NSArray *dataArray;

@property(nonatomic,copy) LocationViewControllerBlock locationViewControllerBlock;

@end
