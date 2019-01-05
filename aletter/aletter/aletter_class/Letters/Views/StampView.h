//
//  StampView.h
//  aletter
//
//  Created by xiaolong li on 2018/8/18.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StampView : UIView

- (void)showStampView:(NSMutableArray *)stampArr oldSelect:(NSIndexPath *)oldIndexPath;

- (void)closeButtonAction;

@end
