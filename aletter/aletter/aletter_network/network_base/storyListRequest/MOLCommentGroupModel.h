//
//  MOLCommentGroupModel.h
//  aletter
//
//  Created by moli-2017 on 2018/8/11.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLBaseModel.h"
#import "MOLCommentModel.h"

@interface MOLCommentGroupModel : MOLBaseModel
@property (nonatomic, strong) NSArray *commentList;
@property (nonatomic, strong) NSString *commentName;
@end
