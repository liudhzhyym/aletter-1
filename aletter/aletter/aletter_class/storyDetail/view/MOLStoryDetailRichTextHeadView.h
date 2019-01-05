//
//  MOLStoryDetailRichTextHeadView.h
//  aletter
//
//  Created by moli-2017 on 2018/8/6.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MOLStoryModel.h"
@interface MOLStoryDetailRichTextHeadView : UIView

@property (nonatomic, strong) MOLStoryModel *storyModel;

@property (nonatomic, strong) void (^clickHighText)(MOLStoryModel *model);
/// 自身高度变化的时候刷新tableview
@property (nonatomic, strong) void(^resetTableHeadViewBlock)(CGFloat height);
@end
