//
//  MOLDeleteCommentViewController.h
//  aletter
//
//  Created by moli-2017 on 2018/8/14.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLBaseViewController.h"
#import "MOLCommentModel.h"
@interface MOLDeleteCommentViewController : MOLBaseViewController
@property (nonatomic, strong) MOLCommentModel *commentModel;
@property (nonatomic, strong) void(^deleteCommentBlock)(void);
@end
