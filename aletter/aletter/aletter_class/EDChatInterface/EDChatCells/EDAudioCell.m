//
//  EDAudioCell.m
//  aletter
//
//  Created by moli-2017 on 2018/8/28.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "EDAudioCell.h"
#import "EDAudioMessageModel.h"
#import "MOLHead.h"
@interface EDAudioCell ()
@property (nonatomic, weak) UIView *audioView;
@property (nonatomic, weak) UIImageView *animateImageView;
@property (nonatomic, weak) UILabel *timeLabel;
@property (nonatomic, weak) UIView *redPointView;
@property (nonatomic, strong) EDAudioMessageModel *audio;
@property (nonatomic, strong) NSString *fileString;
@property (nonatomic, strong) NSString *time;
@end

@implementation EDAudioCell

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupAudioCellUI];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playVoice)];
        [self addGestureRecognizer:tap];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playStatusChange_refreshUI) name:@"STKAudioPlayerSingle_statusChange" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playProcess_refreshUI) name:@"STKAudioPlayerSingle_process" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playFinish_refreshUI) name:@"STKAudioPlayerSingle_finish" object:nil];
    }
    return self;
}

#pragma mark -  NSNotificationCenter
- (void)playStatusChange_refreshUI
{
    if ([[MOLPlayVoiceManager sharePlayVoiceManager].currentMusicId isEqualToString:@"-1"] &&
        [[MOLPlayVoiceManager sharePlayVoiceManager].currentMusicPath isEqualToString:self.fileString]) {
        NSInteger status = [MOLPlayVoiceManager sharePlayVoiceManager].playType;
        if (status == 0) {
            [self.animateImageView stopAnimating];
            
        }else if (status == 1){
            [self.animateImageView startAnimating];
            
        }else if (status == 2){
            [self.animateImageView stopAnimating];
            
        }else if (status == 3){  // 缓冲。。。
            [self.animateImageView stopAnimating];
        }
    }else{
        [self.animateImageView stopAnimating];
        self.timeLabel.text = [NSString stringWithFormat:@"%@s",self.time];
    }
}

- (void)playProcess_refreshUI
{
    if ([[MOLPlayVoiceManager sharePlayVoiceManager].currentMusicId isEqualToString:@"-1"] &&
        [[MOLPlayVoiceManager sharePlayVoiceManager].currentMusicPath isEqualToString:self.fileString]) {
        [self.animateImageView startAnimating];
        NSInteger time = (NSInteger)[MOLPlayVoiceManager sharePlayVoiceManager].totalDuration - [MOLPlayVoiceManager sharePlayVoiceManager].currentDuration;
        self.timeLabel.text = [NSString stringWithFormat:@"%lds",time];
    }else{
        [self.animateImageView stopAnimating];
        self.timeLabel.text = [NSString stringWithFormat:@"%@s",self.time];
    }
}

- (void)playFinish_refreshUI
{
    [self.animateImageView stopAnimating];
    self.timeLabel.text = [NSString stringWithFormat:@"%@s",self.time];
}

- (void)playVoice
{
    if ([self.audio isKindOfClass:[EDAudioMessageModel class]]) {
        // 播放语音 置为已读
        self.audio.isRead = YES;
        self.redPointView.hidden = YES;
        [[MOLPlayVoiceManager sharePlayVoiceManager] playManager_playVoiceWithFileUrlString:self.fileString modelId:nil playType:MOLPlayVoiceManagerType_stream];
    }
}

- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    if(error) {
        NSLog(@"json解析失败：%@",error);
        return nil;
    }
    return dic;
}

- (void)updateCellWithCellModel:(EDBaseMessageModel *)model
{
    [super updateCellWithCellModel:model];
    EDAudioMessageModel *audioM = (EDAudioMessageModel *)model;
    self.audio = audioM;
    
    // 解析content
    NSDictionary *dic = [self dictionaryWithJsonString:model.content];
    // 解析content
//    NSDictionary *dic = [self dictionaryWithJsonString:self.audio.content];
    self.fileString = [dic mol_jsonString:@"audioUrl"];
    self.time = [dic mol_jsonString:@"audioTime"];
    
    self.timeLabel.text = [NSString stringWithFormat:@"%@s",[dic mol_jsonString:@"audioTime"]];
    self.bubbleImageView.frame = model.bubbleImageFrame;
//    self.sendIndicatorView.frame = model.sendingIndicatorFrame;
//    [self.sendIndicatorView startAnimating];
    
    self.audioView.frame = audioM.audioViewFrame;
    self.timeLabel.frame = audioM.audioTimeFrame;
    self.animateImageView.frame = audioM.audioAnimateFrame;
    self.redPointView.frame = audioM.redPointFrame;
    if (model.isRead) {
        self.redPointView.hidden = YES;
    }else{
        self.redPointView.hidden = NO;
    }
}

#pragma mark - UI
- (void)setupAudioCellUI
{
    UIView *audioView = [[UIView alloc] init];
    _audioView = audioView;
    [self.bubbleImageView addSubview:audioView];
    
    UIImageView *animateImageView = [[UIImageView alloc] init];
    _animateImageView = animateImageView;
    NSMutableArray *images = [NSMutableArray array];
    for (NSInteger i = 0; i < 3; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"detail_microphone_ani_%ld",i+1]];
        [images addObject:image];
    }
    _animateImageView.animationImages = images;
    _animateImageView.image = [UIImage imageNamed:@"detail_microphone_ani_3"];
    _animateImageView.animationDuration=1;
    _animateImageView.animationRepeatCount=1;
    [audioView addSubview:animateImageView];
    
    UILabel *timeLabel = [[UILabel alloc] init];
    _timeLabel = timeLabel;
    timeLabel.text = @"0s";
    timeLabel.textColor = HEX_COLOR(0xffffff);
    timeLabel.font = MOL_REGULAR_FONT(12);
    timeLabel.textAlignment = NSTextAlignmentCenter;
    [audioView addSubview:timeLabel];
    
    UIView *redPointView = [[UIView alloc] init];
    _redPointView = redPointView;
    redPointView.backgroundColor = HEX_COLOR(0xFF7054);
    redPointView.layer.cornerRadius = 3;
    redPointView.clipsToBounds = YES;
    [self.contentView addSubview:redPointView];
    
}

- (void)calculaotorAudioCellFrame{}
- (void)layoutSubviews
{
    [super layoutSubviews];
    [self calculaotorAudioCellFrame];
}
@end
