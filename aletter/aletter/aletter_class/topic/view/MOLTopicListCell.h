//
//  MOLTopicListCell.h
//  aletter
//
//  Created by moli-2017 on 2018/8/4.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MOLLightTopicModel.h"
@interface MOLTopicListCell : UITableViewCell
- (void)topicListCell_hiddenImageView:(BOOL)hidden;
@property (nonatomic, strong) MOLLightTopicModel *topicModel;
@end
