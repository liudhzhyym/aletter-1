//
//  MOLStoryDetailCommentCell.h
//  aletter
//
//  Created by moli-2017 on 2018/8/6.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MOLCommentModel.h"

@interface MOLStoryDetailCommentCell : UITableViewCell
@property (nonatomic, strong) MOLCommentModel *commentModel;
@property (nonatomic, strong) NSString *storyUserId;
@property (nonatomic, strong) void(^clickMsgButtonBlock)(void);
@end
