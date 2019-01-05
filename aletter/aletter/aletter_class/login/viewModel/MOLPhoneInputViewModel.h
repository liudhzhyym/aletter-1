//
//  MOLPhoneInputViewModel.h
//  aletter
//
//  Created by moli-2017 on 2018/8/2.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLBaseViewModel.h"
#import "MOLHead.h"

@interface MOLPhoneInputViewModel : MOLBaseViewModel
//@property (nonatomic, assign) NSInteger showTime;

@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) RACSignal *canContinueSignal; // 是否可以点击继续
@property (nonatomic, strong) RACCommand *continueCommand;   // 点击继续的命令（请求）

@property (nonatomic, strong) RACReplaySubject *timeChangeSubject;  // 时间改变的信号
@end
