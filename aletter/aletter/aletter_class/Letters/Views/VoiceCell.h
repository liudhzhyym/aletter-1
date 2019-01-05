//
//  VoiceCell.h
//  aletter
//
//  Created by xujin on 2018/8/20.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MOLAnimateVoiceView;
@interface VoiceCell : UICollectionViewCell
@property (nonatomic, strong) UIButton *voiceButton;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, assign) NSInteger row;
@property (nonatomic, strong) MOLAnimateVoiceView *voiceView;
@property (nonatomic, strong) UIButton *deleteBtn;

- (void)setContent:(NSInteger)type fileUrl:(NSString *)fileUrl sec:(NSInteger)sec;
@end
