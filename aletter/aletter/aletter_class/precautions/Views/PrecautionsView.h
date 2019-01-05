//
//  PrecautionsView.h
//  aletter
//
//  Created by xujin on 2018/9/6.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MOLSheildModel;
typedef void(^PrecautionsViewAddWordBlock)(MOLSheildModel *model);

@interface PrecautionsView : UIView
@property (nonatomic,copy)PrecautionsViewAddWordBlock precautionsAddWordBlock;


- (void)precautionsView:(NSInteger)type count:(NSInteger)count;

- (void)precautionsViewShowTopEvent:(NSInteger)count;


@end
