//
//  MOLStoryDetailView.h
//  aletter
//
//  Created by moli-2017 on 2018/8/6.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MOLStoryModel.h"
#import "MOLStoryDetailBottomToolView.h"
#import <RACReplaySubject.h>

@interface MOLStoryDetailView : UIView
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSourceArray;

@property (nonatomic, strong) MOLStoryModel *storyModel;

@property (nonatomic, assign) BOOL needPlay;
@end
