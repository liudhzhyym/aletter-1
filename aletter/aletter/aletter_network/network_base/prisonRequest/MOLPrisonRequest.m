//
//  MOLPrisonRequest.m
//  aletter
//
//  Created by 徐天牧 on 2018/8/29.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLPrisonRequest.h"
#import "MOLPrisonModel.h"



@interface MOLPrisonRequest()

@property (nonatomic, strong) NSDictionary *parameter;
@end

@implementation MOLPrisonRequest

/// 封号到期时间
- (instancetype)initRequest_PrisonWithParameter:(NSDictionary *)parameter{
    self = [super init];
    if (self) {
        _parameter = parameter;
    }
    
    return self;
}
- (Class)modelClass
{
        return [MOLPrisonModel class];
}
- (NSString *)requestUrl
{
    
//    switch (_type) {
//        case MOLPrisonRequestType_channelCatogery:
//        {
////            NSString *url = @"/style/styleList";
//             NSString *url = @"/userclosure/userclosureInfo";
//
//            return url;
//        }
//            break;
//        case MOLPrisonRequestType_getPrison:
//        {
//            NSString *url = @"/userclosure/userclosureInfo";
//
//            return url;
//        }
//            break;
//        default:
//            return @"";
//            break;
//    }
     NSString *url = @"/userclosure/userclosureInfo";
     return url;
}
-(id)requestArgument{
    return _parameter;
}
@end
