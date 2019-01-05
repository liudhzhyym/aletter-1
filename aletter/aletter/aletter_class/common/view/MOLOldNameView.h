//
//  MOLOldNameView.h
//  aletter
//
//  Created by moli-2017 on 2018/8/10.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MOLOldNameViewDelegate <NSObject>
- (void)oldNameView_clickCloseButtonOrOldName:(NSString *)name;
@end

@interface MOLOldNameView : UIView
@property (nonatomic, weak) id <MOLOldNameViewDelegate> delegate;
@end
