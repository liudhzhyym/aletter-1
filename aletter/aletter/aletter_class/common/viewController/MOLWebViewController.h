//
//  MOLWebViewController.h
//  aletter
//
//  Created by 徐天牧 on 2018/9/1.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLBaseViewController.h"


@interface MOLWebViewController : MOLBaseViewController
@property (nonatomic, assign) NSString *enterType;
@property (nonatomic, copy) NSString *urlString;

@property (nonatomic, copy) NSString *titleString;

@property (nonatomic, assign) NSInteger fromType; // 暂时没用
@end
