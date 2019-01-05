//
//  EDRecordInputView.h
//  aletter
//
//  Created by moli-2017 on 2018/8/30.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EDRecordInputViewDelegate <NSObject>
- (void)record_endWithFile:(NSString *)file time:(NSInteger)time ifyResult:(NSArray *)result;
- (void)record_fail;
@end

@interface EDRecordInputView : UIView
@property (nonatomic, weak) id <EDRecordInputViewDelegate> delegate;
@end
