//
//  MOLMineMessageViewController.h
//  aletter
//
//  Created by moli-2017 on 2018/8/17.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLBaseViewController.h"
#import "MOLMineMessageView.h"

@interface MOLMineMessageViewController : MOLBaseViewController
@property (nonatomic, weak) MOLMineMessageView *messageView;
- (void)request_mineMsg;
@end
