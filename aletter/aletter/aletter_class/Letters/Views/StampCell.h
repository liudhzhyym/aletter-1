//
//  StampCell.h
//  aletter
//
//  Created by xiaolong li on 2018/8/18.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import <UIKit/UIKit.h>
@class StampModel;
@interface StampCell : UICollectionViewCell
@property (nonatomic, copy) NSString *isAuthority;//yes 有选择权 No无选择权
@property (nonatomic, assign) BOOL isSelectStatus; //yes 是选中 No未选中

- (void)stampCellContent:(StampModel *)stampDto;

@end
