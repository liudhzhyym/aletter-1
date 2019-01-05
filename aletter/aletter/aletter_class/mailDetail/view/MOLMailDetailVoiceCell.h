//
//  MOLMailDetailVoiceCell.h
//  aletter
//
//  Created by moli-2017 on 2018/8/3.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MOLStoryModel.h"
@interface MOLMailDetailVoiceCell : UITableViewCell
@property (nonatomic, strong) MOLStoryModel *storyModel;

@property (nonatomic, strong) void (^clickHighText)(MOLStoryModel *model);
@end
