//
//  VoiceCell.m
//  aletter
//
//  Created by xujin on 2018/8/20.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "VoiceCell.h"
#import "MOLAnimateVoiceView.h"
#import "MOLPlayVoiceManager.h"

@interface VoiceCell()

@property (nonatomic,assign)NSInteger type;
@property (nonatomic,assign)NSInteger voiceSec;
@property (nonatomic,copy)NSString *voiceUrl;

@end

@implementation VoiceCell

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.clipsToBounds = YES;
        self.type =0;
        self.voiceSec =0;
        self.voiceUrl =[NSString new];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playStatusChange_refreshUI) name:@"STKAudioPlayerSingle_statusChange" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playProcess_refreshUI) name:@"STKAudioPlayerSingle_process" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playFinish_refreshUI) name:@"STKAudioPlayerSingle_finish" object:nil];
    }
    
    return self;
    
}
- (void)setContent:(NSInteger)type fileUrl:(NSString *)fileUrl sec:(NSInteger)sec
{
    [self.contentView setBackgroundColor: [UIColor whiteColor]];
    
    for (id views in self.contentView.subviews) {
        [views removeFromSuperview];
        NSLog(@"views %@",views);
    }
    
    //0 图片 1语音
    self.type =type;

    if (type) {
        self.voiceSec =sec;
        self.voiceUrl =[NSString stringWithString:fileUrl];
        
        self.voiceView =[MOLAnimateVoiceView new];
        [self.voiceView setShowTime:[NSString stringWithFormat:@"%ld",sec]];
        
        self.voiceButton =[UIButton buttonWithType:UIButtonTypeCustom];
        [self.voiceButton setBackgroundColor:[UIColor clearColor]];
        [self.voiceView addSubview:self.voiceButton];
        
        [self.contentView addSubview:self.voiceView];
        
        _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteBtn setImage:[UIImage imageNamed:@"关闭添加的图片或声音"] forState:UIControlStateNormal];
        [self.contentView addSubview:_deleteBtn];
        

        
    }else{
        _imageView = [[UIImageView alloc] init];
        _imageView.backgroundColor = [UIColor colorWithWhite:1.000 alpha:0.500];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        [_imageView.layer setMasksToBounds:YES];
        [_imageView.layer setCornerRadius:5];
        [self.contentView addSubview:_imageView];
    }
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.type) {
        [self.voiceView setFrame:CGRectMake(-15, 65-40, 200, 40)];
        [self.voiceButton setFrame:CGRectMake(0, 0, self.voiceView.frame.size.width, self.voiceView.frame.size.height)];
        
         _deleteBtn.frame = CGRectMake(self.voiceView.frame.origin.x+self.voiceView.frame.size.width+10+15,self.voiceView.frame.origin.y+(self.voiceView.frame.size.height-19)/2.0, 19, 19);
        
    }else{
        _imageView.frame = self.bounds;
    }
    
    
}

#pragma mark -  NSNotificationCenter
- (void)playStatusChange_refreshUI
{
    if ([[MOLPlayVoiceManager sharePlayVoiceManager].currentMusicId isEqualToString:@"-1"] &&
        [[MOLPlayVoiceManager sharePlayVoiceManager].currentMusicPath isEqualToString:self.voiceUrl]) {
        NSInteger status = [MOLPlayVoiceManager sharePlayVoiceManager].playType;
        if (status == 0) {
             [self.voiceView animateVoiceView_stop];
            
        }else if (status == 1){
             [self.voiceView animateVoiceView_start];
            
        }else if (status == 2){
             [self.voiceView animateVoiceView_stop];
            
        }else if (status == 3){  // 缓冲。。。
             [self.voiceView animateVoiceView_stop];
        }
    }else{
         [self.voiceView animateVoiceView_stop];
         self.voiceView.showTime = [NSString stringWithFormat:@"%ld",self.voiceSec];
    }
}

- (void)playProcess_refreshUI
{
    if ([[MOLPlayVoiceManager sharePlayVoiceManager].currentMusicId isEqualToString:@"-1"] &&
        [[MOLPlayVoiceManager sharePlayVoiceManager].currentMusicPath isEqualToString:self.voiceUrl]) {
        [self.voiceView animateVoiceView_start];
        NSInteger time = (NSInteger)[MOLPlayVoiceManager sharePlayVoiceManager].totalDuration - [MOLPlayVoiceManager sharePlayVoiceManager].currentDuration;
         self.voiceView.showTime = [NSString stringWithFormat:@"%ld",time];
    }else{
        [self.voiceView animateVoiceView_stop];
         self.voiceView.showTime = [NSString stringWithFormat:@"%ld",self.voiceSec];
    }
}

- (void)playFinish_refreshUI
{
        [self.voiceView animateVoiceView_stop];
        self.voiceView.showTime = [NSString stringWithFormat:@"%ld",self.voiceSec];
    
}

@end
