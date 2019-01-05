//
//  EDAudioMessageModel.h
//  aletter
//
//  Created by moli-2017 on 2018/8/28.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "EDBaseMessageModel.h"

@interface EDAudioMessageModel : EDBaseMessageModel

@property (nonatomic, assign) CGRect audioViewFrame;  // 音频frame
@property (nonatomic, assign) CGRect audioAnimateFrame;  // 音频frame
@property (nonatomic, assign) CGRect audioTimeFrame;  // 音频frame
@property (nonatomic, assign) CGRect redPointFrame;  // 音频frame

@property (nonatomic, assign) CGFloat cellHeight;

/**
 * 用文字初始化message
 */
- (instancetype)initWithAudio:(NSString *)audio time:(NSString *)time;

- (CGFloat)getCellHeight;
@end
