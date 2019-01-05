//
//  MOLMailCardView.h
//  aletter
//
//  Created by moli-2017 on 2018/8/10.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MOLCardModel.h"
@interface MOLMailCardView : UIView

- (instancetype)initMailCardViewWithType:(NSInteger)type;  // 0 有名字性别(举报帖子)  1 没有名字性别(私聊) 2 没有频道信息(举报评论)

@property (nonatomic, strong) MOLCardModel *cardModel;
@end
