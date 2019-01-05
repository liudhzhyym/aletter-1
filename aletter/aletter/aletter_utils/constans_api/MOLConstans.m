//
//  MOLConstans.m
//  aletter
//
//  Created by moli-2017 on 2018/7/30.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLConstans.h"
/// 正式服
NSString *const MOL_OFFIC_SERVICE = @"http://aletter.api.urmoli.com/";
/// 测试服
NSString *const MOL_TEST_SERVICE = @"http://dev.aletter.yourmoli.com/";
/// 官方userid
NSString *const MOL_OFFIC_USER = @"666";
/// 消息时间间隔
NSInteger const MOL_TIME_MARGIN = 180;

NSInteger const MOL_SUCCESS_REQUEST = 10000;

NSInteger  const MOL_PRISON_CODE = 12009;//封号Code

NSInteger const MOL_CODETIME = 60;

NSInteger const MOL_TextMaxHeight = 125;

NSInteger const MOL_RecordMax_Time = 90;

NSInteger const MOL_Ifly_Time = 60;

/// 请求帖子的最大数量
NSInteger const MOL_REQUEST_STORY = 6;

/// 请求评论的最大数量
NSInteger const MOL_REQUEST_COMMENT = 10;

/// 请求其他的最大数量
NSInteger const MOL_REQUEST_OTHER = 20;

/// 年龄段
NSString *const MOL_AGE_05 = @"05后";
NSString *const MOL_AGE_00 = @"00后";
NSString *const MOL_AGE_95 = @"95后";
NSString *const MOL_AGE_90 = @"90后";
NSString *const MOL_AGE_85 = @"85后";
NSString *const MOL_AGE_80 = @"80后";
NSString *const MOL_AGE_75 = @"80前";

/// 性别
NSString *const MOL_SEX_WOMAN = @"性别女";
NSString *const MOL_SEX_MAN = @"性别男";

NSString *const MOL_SEX_SAME = @"同性";
NSString *const MOL_SEX_UNSAME = @"异性";

// 取名字用图片
NSString *const INTITLE_Warning_Read = @"toast_red";
NSString *const INTITLE_LEFT_Highlight = @"common_leftBubble_high";
NSString *const INTITLE_LEFT_Normal = @"common_leftBubble";
NSString *const INTITLE_RIGHT_Normal = @"common_rightBubble";
NSString *const INTITLE_RIGHT_Tick = @"common_changeName";

/// 个人中心滑动返回
CGFloat const MOL_MINE_MAXPOP = -190;
CGFloat const MOL_MINE_MINPOP = -200;
