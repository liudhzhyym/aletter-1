//
//  MOLMessageListCell.h
//  aletter
//
//  Created by moli-2017 on 2018/8/21.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MOLChatModel.h"
#import "MOLSystemModel.h"

@interface MOLMessageListCell : UITableViewCell
@property (nonatomic, strong) MOLChatModel *chatModel;
@property (nonatomic, strong) MOLSystemModel *systemModel;
@end
