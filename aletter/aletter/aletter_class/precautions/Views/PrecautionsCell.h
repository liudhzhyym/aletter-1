//
//  PrecautionsCell.h
//  aletter
//
//  Created by xujin on 2018/9/6.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MOLSheildModel;
typedef void(^PrecautionsCellDeleteBlock)(NSIndexPath *indexPath,MOLSheildModel *model);
@interface PrecautionsCell : UITableViewCell
@property (nonatomic, copy)PrecautionsCellDeleteBlock cellDeleteBlock;
- (void)precautionsCell:(MOLSheildModel *)mode indexPath:(NSIndexPath *)indexPath;
@end
