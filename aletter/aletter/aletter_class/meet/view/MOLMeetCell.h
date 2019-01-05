//
//  MOLMeetCell.h
//  aletter
//
//  Created by moli-2017 on 2018/8/8.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MOLStoryModel.h"
#import "MOLStoryDetailView.h"

@interface MOLMeetCell : UICollectionViewCell
@property (nonatomic, strong) MOLStoryModel *storyModel;
@property (nonatomic, weak) MOLStoryDetailView *storyDetailView;
@end
