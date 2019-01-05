//
//  MOLPhoneLoginViewModel.h
//  aletter
//
//  Created by moli-2017 on 2018/8/2.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLBaseViewModel.h"
#import "MOLHead.h"

@interface MOLPhoneLoginViewModel : MOLBaseViewModel

@property (nonatomic, strong) NSString *pwdString;
@property (nonatomic, strong) RACSignal *canContinueSignal;
@property (nonatomic, strong) RACCommand *continueCommand;  // 点击继续的命令（登录请求）
@property (nonatomic, strong) RACCommand *getLastNameCommand;  // 获取最新名字的请求
@end
