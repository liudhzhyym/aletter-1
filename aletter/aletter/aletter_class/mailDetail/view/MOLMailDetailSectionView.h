//
//  MOLMailDetailSectionView.h
//  aletter
//
//  Created by moli-2017 on 2018/8/3.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MOLHead.h"

@interface MOLMailDetailSectionView : UIView
@property (nonatomic, assign) BOOL needTap;
@property (nonatomic, strong) NSString *warningName;  // 是否需要雷区 雷区的名字
@property (nonatomic, strong) NSArray *topicArray;  // 话题数组

@property (nonatomic, strong) RACReplaySubject *moreSubject;
@property (nonatomic, strong) RACReplaySubject *topicSubject;
@property (nonatomic, strong) RACReplaySubject *landSubject;
@end
