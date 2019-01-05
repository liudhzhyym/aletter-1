//
//  MOLNotificationModel.m
//  aletter
//
//  Created by moli-2017 on 2018/8/23.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLNotificationModel.h"
#import "MOLHead.h"

@implementation MOLNotificationModel
+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{
             @"outUrlId" : @"jumpStoryId"
             };
}

- (CGFloat)systemNotiCellHeight
{
    if (_systemNotiCellHeight == 0) {
        
        // 间距
        _systemNotiCellHeight += 15;
        
        // 时间
        _systemNotiCellHeight += 17;
        
        // 间距
        _systemNotiCellHeight += 20;
        
        // 正文
        CGSize maxS = CGSizeMake(MOL_SCREEN_WIDTH - 39 - 20, MAXFLOAT);
        CGFloat h = [self.content boundingRectWithSize:maxS options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:MOL_LIGHT_FONT(14)} context:nil].size.height;
        _systemNotiCellHeight += h;
        
        // 间距
        _systemNotiCellHeight += 15;
        
        if (self.systemType.integerValue == 1 || self.systemType.integerValue == 2) { // 违反、回收站
            // 社区礼仪按钮
            _systemNotiCellHeight += 20;
            
            // 间距
            _systemNotiCellHeight += 15;
        }
        
        if (![self.pushType isEqualToString:@"h5"] && ![self.pushType isEqualToString:@"txt"]) {
            
            // 卡片
            _systemNotiCellHeight += 80;
        }
    }
    
    return _systemNotiCellHeight;
}

- (CGFloat)interactNotiCellHeight
{
    if (_interactNotiCellHeight == 0) {
        
        // 间距 25
        _interactNotiCellHeight += 25;
        
        // title 20
        _interactNotiCellHeight += 25;
        
        // 间距 + 评论内容
        if (self.commentVO) {
            _interactNotiCellHeight += 5;
            CGSize maxS = CGSizeMake(MOL_SCREEN_WIDTH - 39 - 20, MAXFLOAT);
            CGFloat h = [self.commentVO.content boundingRectWithSize:maxS options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:MOL_LIGHT_FONT(14)} context:nil].size.height;
            _interactNotiCellHeight += h;
        }
        
        // 间距 + 未读按钮
        if (self.unReadNum.integerValue > 0 && self.msgType.integerValue == 2) {
            _interactNotiCellHeight += 15;
            _interactNotiCellHeight += 20;
        }
        
        // 间距 + 卡片
        _interactNotiCellHeight += 15;
        _interactNotiCellHeight += 80;
    }
    
    return _interactNotiCellHeight;
}
@end
