//
//  MOLMineMailViewController.h
//  aletter
//
//  Created by moli-2017 on 2018/8/17.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLBaseViewController.h"
#import "MOLMineMailView.h"

@interface MOLMineMailViewController : MOLBaseViewController
@property (nonatomic, weak) MOLMineMailView *mineMailView;
- (void)request_mineMail;
@end
