//
//  MOLMailboxViewController.h
//  aletter
//
//  Created by xiaolong li on 2018/8/8.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//
//  投掷邮筒类，处理投掷信件业务功能

#import "MOLBaseViewController.h"
@class MOLMailModel;

@interface MOLMailboxViewController : MOLBaseViewController
@property (nonatomic ,strong) MOLMailModel *mailModel; //频道数模

@end
