//
//  MOLCommentModel.h
//  aletter
//
//  Created by moli-2017 on 2018/8/11.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLBaseModel.h"

@interface MOLCommentModel : MOLBaseModel
@property (nonatomic, strong) NSString *audioUrl;
@property (nonatomic, strong) NSString *commentUserId;
@property (nonatomic, strong) NSString *commentUserName;
@property (nonatomic, assign) NSInteger commentUserSex;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *commentId;
@property (nonatomic, strong) NSString *storyId;
@property (nonatomic, strong) NSString *beCommentUserId;
@property (nonatomic, strong) NSString *beCommentUserName;
@property (nonatomic, strong) NSString *time;
@property (nonatomic, strong) NSString *createTime;

@property (nonatomic, assign) CGFloat commentCellHeight;

@property (nonatomic, strong) NSString *commentUserSchool;   // 学校
@end
