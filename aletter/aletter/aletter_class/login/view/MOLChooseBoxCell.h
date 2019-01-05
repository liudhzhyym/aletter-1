//
//  MOLChooseBoxCell.h
//  aletter
//
//  Created by moli-2017 on 2018/8/1.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MOLChooseBoxModel.h"

@protocol MOLChooseBoxCellDelegate <NSObject>
- (void)chooseBoxCell_shouldReturnWithName:(NSString *)name;
@end

@interface MOLChooseBoxCell : UITableViewCell
@property (nonatomic, strong) MOLChooseBoxModel *boxModel;
- (void)chooseBoxCell_drawRadius:(NSInteger)radiusCount backgroundColor:(UIColor *)color;
- (void)chooseBoxCell_keyBoardShow:(BOOL)show;
@property (nonatomic, weak) id <MOLChooseBoxCellDelegate> delegate;
@end
