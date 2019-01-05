//
//  MOLCheckInfoView.h
//  aletter
//
//  Created by moli-2017 on 2018/8/3.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MOLHead.h"

typedef NS_ENUM(NSUInteger, MOLCheckInfoViewType) {
    MOLCheckInfoViewType_sex,
    MOLCheckInfoViewType_age,
    MOLCheckInfoViewType_school,
    MOLCheckInfoViewType_check,
};

@interface MOLCheckInfoView : UIView
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) UIButton *headButton;

@property (nonatomic, strong) NSArray *datasourceArray; // 数据源
@property (nonatomic, strong) NSArray *nameArray;  // 选择项数据

@property (nonatomic, assign) MOLCheckInfoViewType currentType;

// 定制信号
@property (nonatomic, strong) RACReplaySubject *chooseSubject;  // 选择信号
@end
