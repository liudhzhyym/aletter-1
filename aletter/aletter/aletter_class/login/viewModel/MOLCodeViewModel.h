//
//  MOLCodeViewModel.h
//  aletter
//
//  Created by moli-2017 on 2018/8/21.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLBaseViewModel.h"
#import "MOLHead.h"

@interface MOLCodeViewModel : MOLBaseViewModel
@property (nonatomic, strong) NSString *codeString; // 验证码

@property (nonatomic, strong) RACSignal *canSendCodeSignal;  // 是否可发送验证码
@property (nonatomic, strong) RACCommand *codeCommand;      // 点击获取验证码的命令

@property (nonatomic, strong) RACSignal *continueSignal;     // 是否可点击继续
@property (nonatomic, strong) RACCommand *continueCommand;      // 点击确定的命令去注册账户
@property (nonatomic, strong) RACCommand *continue_GoBindingCommand;   // 点击确定去绑定手机
@end
