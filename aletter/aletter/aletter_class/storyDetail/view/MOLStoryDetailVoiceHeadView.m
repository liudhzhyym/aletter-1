//
//  MOLStoryDetailVoiceHeadView.m
//  aletter
//
//  Created by moli-2017 on 2018/8/11.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLStoryDetailVoiceHeadView.h"
#import "MOLAnimateVoiceView.h"
#import "MOLHead.h"
#import "MOLStatisticsRequest.h"

@interface MOLStoryDetailVoiceHeadView ()
@property (nonatomic, weak) MOLAnimateVoiceView *voiceView;
@property (nonatomic, weak) YYLabel *contentLabel;
@end

@implementation MOLStoryDetailVoiceHeadView

- (void)dealloc
{
    if (!self.needPlay) {
        [[MOLPlayVoiceManager sharePlayVoiceManager] playManager_pause];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupStoryDetailVoiceHeadViewUI];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playStatusChange_refreshUI) name:@"STKAudioPlayerSingle_statusChange" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playProcess_refreshUI) name:@"STKAudioPlayerSingle_process" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playFinish_refreshUI) name:@"STKAudioPlayerSingle_finish" object:nil];
    }
    return self;
}

#pragma mark - 按钮的点击
- (void)button_clickVoiceView
{
    [[MOLPlayVoiceManager sharePlayVoiceManager] playManager_playVoiceWithFileUrlString:self.storyModel.audioUrl modelId:self.storyModel.storyId playType:MOLPlayVoiceManagerType_stream];
    
    if (self.storyModel.privateSign == 2) {
        MOLStatisticsRequest *r = [[MOLStatisticsRequest alloc] initRequest_statisticsPlayStoryWithParameter:nil parameterId:self.storyModel.storyId];
        [r baseNetwork_startRequestWithcompletion:nil failure:nil];
    }
}

#pragma mark -  NSNotificationCenter
- (void)playStatusChange_refreshUI
{
    if ([[MOLPlayVoiceManager sharePlayVoiceManager].currentMusicId isEqualToString:self.storyModel.storyId] &&
        [[MOLPlayVoiceManager sharePlayVoiceManager].currentMusicPath isEqualToString:self.storyModel.audioUrl]) {
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
        self.voiceView.showTime = self.storyModel.time;
    }
}

- (void)playProcess_refreshUI
{
    if ([[MOLPlayVoiceManager sharePlayVoiceManager].currentMusicId isEqualToString:self.storyModel.storyId] &&
        [[MOLPlayVoiceManager sharePlayVoiceManager].currentMusicPath isEqualToString:self.storyModel.audioUrl]) {
        [self.voiceView animateVoiceView_start];
        NSInteger time = (NSInteger)[MOLPlayVoiceManager sharePlayVoiceManager].totalDuration - [MOLPlayVoiceManager sharePlayVoiceManager].currentDuration;
        self.voiceView.showTime = [NSString stringWithFormat:@"%ld",time];
    }else{
        [self.voiceView animateVoiceView_stop];
        self.voiceView.showTime = self.storyModel.time;
    }
}

- (void)playFinish_refreshUI
{
    [self.voiceView animateVoiceView_stop];
    self.voiceView.showTime = self.storyModel.time;
}

#pragma mark - UI
- (void)setStoryModel:(MOLStoryModel *)storyModel
{
    _storyModel = storyModel;
    self.voiceView.showTime = storyModel.time;
    
    NSMutableAttributedString *text = [NSMutableAttributedString new];
    UIFont *font = MOL_REGULAR_FONT(16);
    UIColor *color = HEX_COLOR(0x074D81);
    NSString *title = storyModel.content;
    [text appendAttributedString:[[NSAttributedString alloc] initWithString:title attributes:nil]];
    
    text.yy_font = font;
    text.yy_color = color;
    
    if (storyModel.topicVO.topicName.length) {
        NSRange range = [storyModel.content rangeOfString:storyModel.topicVO.topicName];
        [text yy_setColor:HEX_COLOR(0x4A90E2) range:range];
        [text yy_setFont:MOL_MEDIUM_FONT(16) range:range];
        @weakify(self);
        [text yy_setTextHighlightRange:range color:HEX_COLOR(0x4A90E2) backgroundColor:[UIColor clearColor] tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            @strongify(self);
            if (self.clickHighText) {
                self.clickHighText(storyModel);
            }
            
        }];
    }
    
    CGSize introSize = CGSizeMake(self.width, CGFLOAT_MAX);
    YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:introSize text:text];
    self.height = layout.textBoundingSize.height + 60;
    self.contentLabel.attributedText = text;
    self.contentLabel.height = layout.textBoundingSize.height;
}

#pragma mark - UI
- (void)setupStoryDetailVoiceHeadViewUI
{
    
    MOLAnimateVoiceView *voiceView = [[MOLAnimateVoiceView alloc] init];
    _voiceView = voiceView;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(button_clickVoiceView)];
    [voiceView.backViewButton addGestureRecognizer:tap];
    [self addSubview:voiceView];
    
    YYLabel *contentLabel = [[YYLabel alloc] init];
    _contentLabel = contentLabel;
    contentLabel.numberOfLines = 0;
    [self addSubview:contentLabel];
}

- (void)calculatorStoryDetailVoiceHeadViewFrame
{
    self.voiceView.width = self.width;
    self.voiceView.height = 40;
    
    self.contentLabel.width = self.width - 30;
    self.contentLabel.x = 15;
    self.contentLabel.y = self.voiceView.bottom + 20;
    
    if (self.resetTableHeadViewBlock) {
        self.resetTableHeadViewBlock(self.height);
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self calculatorStoryDetailVoiceHeadViewFrame];
}
@end
