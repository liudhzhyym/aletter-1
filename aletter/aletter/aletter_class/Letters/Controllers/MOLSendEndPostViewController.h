//
//  MOLSendEndPostViewController.h
//  aletter
//
//  Created by xujin on 2018/8/23.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLBaseViewController.h"
@class PostModel;
@interface MOLSendEndPostViewController : MOLBaseViewController
@property (nonatomic, strong) PostModel *postModel;
@property (nonatomic, strong) NSArray *dataArray;
@end
