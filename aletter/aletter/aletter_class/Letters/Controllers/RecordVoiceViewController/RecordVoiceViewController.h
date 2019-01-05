//
//  RecordVoiceViewController.h
//  aletter
//
//  Created by xujin on 2018/8/20.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLBaseViewController.h"

typedef void(^MRecordVoiceViewControllerVoiceBlock)(NSInteger voiceSec,NSString *voiceFile);

@interface RecordVoiceViewController : MOLBaseViewController

@property (nonatomic, copy) MRecordVoiceViewControllerVoiceBlock MRecordVoiceViewControllerVoiceBlock;

@end
