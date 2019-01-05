//
//  MOLCheckInfoViewModel.m
//  aletter
//
//  Created by moli-2017 on 2018/8/3.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLCheckInfoViewModel.h"
#import "MOLChooseBoxModel.h"
#import "MOLLoginRequest.h"

@implementation MOLCheckInfoViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupCheckInfoViewModel];
    }
    return self;
}

- (void)setupCheckInfoViewModel
{
    @weakify(self);
    self.sexInfoCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        
        RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            NSMutableArray *array = [NSMutableArray array];
            NSArray *nameArray = @[MOL_SEX_MAN,MOL_SEX_WOMAN];
            // 获取数据
            MOLChooseBoxModel *left_model = [[MOLChooseBoxModel alloc] init];
            left_model.modelType = MOLChooseBoxModelType_leftText;
            left_model.leftImageString = INTITLE_LEFT_Highlight;
            left_model.leftTitle = @"你需要填写少量的个人信息，通过智能匹配，遇见有同感的人";
            left_model.leftHighLight = YES;
            [array addObject:left_model];
            
            for (NSInteger i = 0; i < nameArray.count; i++) {
                MOLChooseBoxModel *model = [[MOLChooseBoxModel alloc] init];
                model.modelType = MOLChooseBoxModelType_rightChooseButton;
                model.buttonTitle = nameArray[i];
                [array addObject:model];
            }
            
            [subscriber sendNext:@{@"dataSource":array,@"nameArray":nameArray}];
            [subscriber sendCompleted];
            
            return nil;
        }];
        
        return signal;
    }];
    
    self.ageInfoCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        
        RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            @strongify(self);
            NSMutableArray *array = [NSMutableArray array];
            NSArray *nameArray = @[MOL_AGE_00,MOL_AGE_95,MOL_AGE_90,MOL_AGE_85,MOL_AGE_80,MOL_AGE_75];
            // 获取数据
            MOLChooseBoxModel *left_model1 = [[MOLChooseBoxModel alloc] init];
            left_model1.modelType = MOLChooseBoxModelType_leftText;
            left_model1.leftImageString = INTITLE_LEFT_Normal;
            left_model1.leftTitle = @"你需要填写少量的个人信息，通过智能匹配，遇见有同感的人。";
            left_model1.leftHighLight = NO;
            [array addObject:left_model1];
            
            MOLChooseBoxModel *left_model2 = [[MOLChooseBoxModel alloc] init];
            left_model2.modelType = MOLChooseBoxModelType_leftText;
            left_model2.leftImageString = INTITLE_LEFT_Normal;
            left_model2.leftTitle = @"你的性别是";
            left_model2.leftHighLight = NO;
            [array addObject:left_model2];
            
            MOLChooseBoxModel *right_model = [[MOLChooseBoxModel alloc] init];
            right_model.modelType = MOLChooseBoxModelType_rightText;
            right_model.rightImageString = INTITLE_RIGHT_Normal;
            right_model.rightTitle = self.sexString;
            right_model.rightHighLight = NO;
            [array addObject:right_model];
            
            MOLChooseBoxModel *left_model = [[MOLChooseBoxModel alloc] init];
            left_model.modelType = MOLChooseBoxModelType_leftText;
            left_model.leftImageString = INTITLE_LEFT_Highlight;
            left_model.leftTitle = @"你的年龄是？";
            left_model.leftHighLight = YES;
            [array addObject:left_model];
            
            for (NSInteger i = 0; i < nameArray.count; i++) {
                MOLChooseBoxModel *model = [[MOLChooseBoxModel alloc] init];
                model.modelType = MOLChooseBoxModelType_rightChooseButton;
                model.buttonTitle = nameArray[i];
                [array addObject:model];
            }
            
            [subscriber sendNext:@{@"dataSource":array,@"nameArray":nameArray}];
            [subscriber sendCompleted];
            
            return nil;
        }];
        
        return signal;
    }];
    
    self.schoolInfoCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        
        RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            @strongify(self);
            NSMutableArray *array = [NSMutableArray array];
            NSArray *nameArray = @[@"添加学校",@"稍后再说"];
            // 获取数据
            MOLChooseBoxModel *left_model1 = [[MOLChooseBoxModel alloc] init];
            left_model1.modelType = MOLChooseBoxModelType_leftText;
            left_model1.leftImageString = INTITLE_LEFT_Normal;
            left_model1.leftTitle = @"你需要填写少量的个人信息，通过智能匹配，遇见有同感的人。";
            left_model1.leftHighLight = NO;
            [array addObject:left_model1];
            
            MOLChooseBoxModel *left_model2 = [[MOLChooseBoxModel alloc] init];
            left_model2.modelType = MOLChooseBoxModelType_leftText;
            left_model2.leftImageString = INTITLE_LEFT_Normal;
            left_model2.leftTitle = @"你的性别是";
            left_model2.leftHighLight = NO;
            [array addObject:left_model2];
            
            MOLChooseBoxModel *right_model = [[MOLChooseBoxModel alloc] init];
            right_model.modelType = MOLChooseBoxModelType_rightText;
            right_model.rightImageString = INTITLE_RIGHT_Normal;
            right_model.rightTitle = self.sexString;
            right_model.rightHighLight = NO;
            [array addObject:right_model];
            
            MOLChooseBoxModel *left_model3 = [[MOLChooseBoxModel alloc] init];
            left_model3.modelType = MOLChooseBoxModelType_leftText;
            left_model3.leftImageString = INTITLE_LEFT_Normal;
            left_model3.leftTitle = @"你的年龄是？";
            left_model3.leftHighLight = NO;
            [array addObject:left_model3];
            
            MOLChooseBoxModel *right_model1 = [[MOLChooseBoxModel alloc] init];
            right_model1.modelType = MOLChooseBoxModelType_rightText;
            right_model1.rightImageString = INTITLE_RIGHT_Normal;
            right_model1.rightTitle = self.ageString;
            right_model1.rightHighLight = NO;
            [array addObject:right_model1];
            
            MOLChooseBoxModel *left_model = [[MOLChooseBoxModel alloc] init];
            left_model.modelType = MOLChooseBoxModelType_leftText;
            left_model.leftImageString = INTITLE_LEFT_Highlight;
            left_model.leftTitle = @"你的学校是？";
            left_model.leftHighLight = YES;
            [array addObject:left_model];
            
            for (NSInteger i = 0; i < nameArray.count; i++) {
                MOLChooseBoxModel *model = [[MOLChooseBoxModel alloc] init];
                model.modelType = MOLChooseBoxModelType_rightChooseButton;
                model.buttonTitle = nameArray[i];
                [array addObject:model];
            }
            
            [subscriber sendNext:@{@"dataSource":array,@"nameArray":nameArray}];
            [subscriber sendCompleted];
            
            return nil;
        }];
        
        return signal;
    }];
    
    self.checkInfoCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        
        RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            @strongify(self);
            NSMutableArray *array = [NSMutableArray array];
            NSArray *nameArray = @[@"确认",@"修改信息"];
            // 获取数据
            MOLChooseBoxModel *left_model1 = [[MOLChooseBoxModel alloc] init];
            left_model1.modelType = MOLChooseBoxModelType_leftText;
            left_model1.leftImageString = INTITLE_LEFT_Normal;
            left_model1.leftTitle = @"你需要填写少量的个人信息，通过智能匹配，遇见有同感的人。";
            left_model1.leftHighLight = NO;
            [array addObject:left_model1];
            
            MOLChooseBoxModel *left_model2 = [[MOLChooseBoxModel alloc] init];
            left_model2.modelType = MOLChooseBoxModelType_leftText;
            left_model2.leftImageString = INTITLE_LEFT_Normal;
            left_model2.leftTitle = @"你的性别是";
            left_model2.leftHighLight = NO;
            [array addObject:left_model2];
            
            MOLChooseBoxModel *right_model = [[MOLChooseBoxModel alloc] init];
            right_model.modelType = MOLChooseBoxModelType_rightText;
            right_model.rightImageString = INTITLE_RIGHT_Normal;
            right_model.rightTitle = self.sexString;
            right_model.rightHighLight = NO;
            [array addObject:right_model];
            
            MOLChooseBoxModel *left_model3 = [[MOLChooseBoxModel alloc] init];
            left_model3.modelType = MOLChooseBoxModelType_leftText;
            left_model3.leftImageString = INTITLE_LEFT_Normal;
            left_model3.leftTitle = @"你的年龄是？";
            left_model3.leftHighLight = NO;
            [array addObject:left_model3];
            
            MOLChooseBoxModel *right_model1 = [[MOLChooseBoxModel alloc] init];
            right_model1.modelType = MOLChooseBoxModelType_rightText;
            right_model1.rightImageString = INTITLE_RIGHT_Normal;
            right_model1.rightTitle = self.ageString;
            right_model1.rightHighLight = NO;
            [array addObject:right_model1];
            
            MOLChooseBoxModel *left_model4 = [[MOLChooseBoxModel alloc] init];
            left_model4.modelType = MOLChooseBoxModelType_leftText;
            left_model4.leftImageString = INTITLE_LEFT_Normal;
            left_model4.leftTitle = @"你的学校是？";
            left_model4.leftHighLight = NO;
            [array addObject:left_model4];
            
            MOLChooseBoxModel *right_model2 = [[MOLChooseBoxModel alloc] init];
            right_model2.modelType = MOLChooseBoxModelType_rightText;
            right_model2.rightImageString = INTITLE_RIGHT_Normal;
            right_model2.rightTitle = self.schoolString;
            right_model2.rightHighLight = NO;
            [array addObject:right_model2];
            
            MOLChooseBoxModel *left_model = [[MOLChooseBoxModel alloc] init];
            left_model.modelType = MOLChooseBoxModelType_leftText;
            left_model.leftImageString = INTITLE_LEFT_Highlight;
            if (self.schoolString.length && ![self.schoolString isEqualToString:@"稍后再说"]) {
                left_model.leftTitle = @"确认后，你的性别、年龄将无法修改，学校信息只能再修改一次";
            }else{
                left_model.leftTitle = @"确认后，你的个人信息无法修改";
            }
            left_model.leftHighLight = YES;
            [array addObject:left_model];
            
            for (NSInteger i = 0; i < nameArray.count; i++) {
                MOLChooseBoxModel *model = [[MOLChooseBoxModel alloc] init];
                model.modelType = MOLChooseBoxModelType_rightChooseButton;
                model.buttonTitle = nameArray[i];
                [array addObject:model];
            }
            
            [subscriber sendNext:@{@"dataSource":array,@"nameArray":nameArray}];
            [subscriber sendCompleted];
            
            return nil;
        }];
        
        return signal;
    }];
    
    self.commitInfoCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        
        RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            @strongify(self);
            // 发送网络请求 - 完善用户信息
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            dic[@"sex"] = [self.sexString isEqualToString:MOL_SEX_MAN] ? @"1" : @"2";
            if ([self.ageString isEqualToString:MOL_AGE_75]) {
                dic[@"age"] = @"75";
            }else if([self.ageString isEqualToString:MOL_AGE_00]){
                dic[@"age"] = @"100";
            }else{
                dic[@"age"] = [self.ageString substringToIndex:self.ageString.length - 1];
            }
            
            if (self.schoolString.length && ![self.schoolString isEqualToString:@"稍后再说"]) {
                dic[@"school"] = self.schoolString;
            }
            
            MOLLoginRequest *r = [[MOLLoginRequest alloc] initRequest_infoCheckWithParameter:dic];
            [r baseNetwork_startRequestWithcompletion:^(__kindof MOLBaseNetRequest *request, MOLBaseModel *responseModel, NSInteger code, NSString *message) {
               
                [subscriber sendNext:responseModel];
                [subscriber sendCompleted];
                
                if (code != MOL_SUCCESS_REQUEST) {
                    [MOLToast toast_showWithWarning:YES title:message];
                }
                
            } failure:^(__kindof MOLBaseNetRequest *request) {
                
                [subscriber sendCompleted];
            }];
            return nil;
        }];
        
        return signal;
    }];
}
@end
