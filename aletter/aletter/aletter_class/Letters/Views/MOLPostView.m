//
//  MOLPostView.m
//  aletter
//
//  Created by xiaolong li on 2018/8/9.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLPostView.h"
#import "MOLAnimateVoiceView.h"

#import "MOLPhotosCell.h"
#import "StampModel.h"
#import "VoiceCell.h"
#import "MOLLightTopicModel.h"
#import "MOLAnimateVoiceView.h"
#import "MOLPlayVoiceManager.h"
#import "MOLMailModel.h"
#import <UIButton+WebCache.h>

static const NSInteger KMaxCount =500;


@interface MOLPostView ()<UITextFieldDelegate,YYTextViewDelegate,UIGestureRecognizerDelegate,UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic,strong) UILabel *dateLable;
@property (nonatomic,strong) UIButton *mailboxButton;
@property (nonatomic,strong) UIButton *mailboxMark;
@property (nonatomic,strong) UILabel *toLable;
@property (nonatomic,strong) UITextField *phoneTextField;
@property (nonatomic,strong) UIView *lineView;
@property (nonatomic,strong) UIButton *addressBookButton;
@property (nonatomic,strong) UIButton *imageButton;
@property (nonatomic,strong) UIButton *addTopic;
@property (nonatomic,strong) UIButton *interactive;
@property (nonatomic,strong) UILabel *wordsCount;
@property (nonatomic,strong) MOLAnimateVoiceView *voiceButotn;
@property (nonatomic,strong) UIButton *voiceDelete;
@property (nonatomic,strong) UIButton *addTopicDelete;
@property (nonatomic,assign) PostBusinessType postBusinessType;
@property (nonatomic,assign) PostContentType postContentType;
@property (nonatomic,strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic,assign) CGFloat yDynamic;
@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,assign) BOOL isSelectOriginalPhoto;  ///< yes 表示是原图
@property (nonatomic,strong) StampModel *stampModel; //邮票数据
@property (nonatomic,strong) MOLLightTopicModel *topicModel; //邮票数据模型
@property (nonatomic,strong) NSString *fileUrl;
@property (nonatomic,assign) NSInteger voiceSec;
@property (nonatomic,strong) UICollectionViewFlowLayout *layout;
@property (nonatomic,strong) UILabel *charNumLable;




@end


@implementation MOLPostView

- (instancetype)init
{
    self = [super init];
    if (self) {        
        [self initData];
        [self akeybordController];
        [self registerForObserver];
        
//        __weak __typeof(self) weakSelf = self;
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            if (weakSelf.postTextView) {
//                [weakSelf.postTextView becomeFirstResponder];
//            }
//        });
    }
    return self;
}

#pragma mark - Notifications

- (void)registerForObserver {
    // 邮票消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stampViewNotification:) name:@"StampViewNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becomeFirstResponderNotification:) name:@"MOLPostViewNotification" object:nil];
    
}

- (void)becomeFirstResponderNotification:(NSNotification *)notif{
    
    NSString *type =(NSString *)notif.object;
    CGFloat time =0.0;
    __weak __typeof(self) weakSelf = self;
    if (!type || ![type isKindOfClass: [NSString class]] || ![type isEqualToString: @"StampView"]) {
        time =0.7;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (weakSelf.postTextView) {
            if (weakSelf.postTextView.resignFirstResponder) {
                [weakSelf.postTextView becomeFirstResponder];
            }
        }
    });
    
}

- (void)stampViewNotification:(NSNotification *)notif{
    self.stampModel =(StampModel *)notif.object;
    
    NSURL *url;
    if (self.stampModel.isAuthority && self.stampModel.isAuthority.integerValue==1) { //表示高亮图
        url =[NSURL URLWithString:self.stampModel.lightImage?self.stampModel.lightImage:@""];
    }else{
        url =[NSURL URLWithString:self.stampModel.darkImage?self.stampModel.darkImage:@""];
    }
    
    __weak __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.mailboxButton sd_setImageWithURL:url forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"卡通邮票默认"]];
    });

}

- (void)initData{
    self.yDynamic = 0.0;
    self.selectedPhotos =[NSMutableArray new];
    self.selectedAssets =[NSMutableArray new];
    self.stampModel =[StampModel new];
    
    self.topicModel =[MOLLightTopicModel new];
    
    if (self.fromviewController==1) {
        self.topicModel =self.ttTopicDto;
    }
    
}

-(void)akeybordController{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

#pragma mark-
#pragma mark Keyboard show and hide
- (void)keyboardWillShow:(NSNotification *)note{
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    keyboardBounds = [self convertRect:keyboardBounds toView:nil];
    CGRect containerFrame = self.addTopic.frame;
    self.yDynamic = keyboardBounds.size.height + containerFrame.size.height;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    [self setNeedsLayout];
    [self layoutIfNeeded];
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)note{
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    self.yDynamic = 0.0;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    [self setNeedsLayout];
    [self layoutIfNeeded];
    [UIView commitAnimations];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    __weak __typeof(self) weakSelf = self;
    
    [self.dateLable mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(15);
        make.left.mas_equalTo(15);
    }];
    
    [self.mailboxButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.left.mas_greaterThanOrEqualTo(weakSelf.dateLable.mas_right);
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(51);
    }];
    
  
    
    [self.mailboxMark mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(8);
        make.right.mas_equalTo(-8);
        make.width.mas_equalTo(20);
        make.height.mas_equalTo(20);
    }];
    
    if (self.postBusinessType==PostBusinessUnrequitedLoveType) { //暗恋类型
        
        [self.toLable mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(weakSelf.dateLable.mas_bottom).offset(10);
            make.left.mas_equalTo(15);
            //make.width.mas_equalTo(21);
            make.height.mas_equalTo(20);
        }];
        
        
        [self.phoneTextField mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(weakSelf.dateLable.mas_bottom).offset(10);
            make.left.mas_equalTo(weakSelf.toLable.mas_right).offset(8);
            make.height.mas_equalTo(16);
            make.width.mas_equalTo(MOL_SCREEN_ADAPTER(117));
        }];
        
        [self.lineView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(weakSelf.phoneTextField.mas_bottom);
            make.left.mas_equalTo(weakSelf.phoneTextField.mas_left);
            make.height.mas_equalTo(1);
            make.width.mas_equalTo(weakSelf.phoneTextField);
        }];
        
        [self.addressBookButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(weakSelf.phoneTextField.mas_top);
            make.left.mas_equalTo(weakSelf.phoneTextField.mas_right).offset(7);
            make.height.mas_equalTo(16);
            make.width.mas_equalTo(16);
        }];
        
        [self.postTextView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(weakSelf.toLable.mas_bottom).offset(15);
            make.left.mas_equalTo(15);
            make.right.mas_equalTo(-16);
            make.height.mas_equalTo(iPhone5?42:132-32);
        }];
        
    }else{
        
        [self.postTextView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(weakSelf.dateLable.mas_bottom).offset(15);
            make.left.mas_equalTo(15);
            make.right.mas_equalTo(-16);
            make.height.mas_equalTo(iPhone5?62:132);
        }];
        
    }
    
    [self.charNumLable mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.postTextView.mas_bottom).offset(5);
        make.right.mas_equalTo(-16);
        make.height.mas_equalTo(16);
    }];
    
    [self.addTopicDelete mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.bottom.mas_equalTo(weakSelf).offset(-(weakSelf.yDynamic?weakSelf.yDynamic-10+(17-14)/2.0:weakSelf.yDynamic+15));
        make.height.mas_equalTo(14);
        make.width.mas_equalTo(14);
    }];
    
    
    [self.addTopic mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.addTopicDelete.isHidden?weakSelf:weakSelf.addTopicDelete.mas_right).offset(weakSelf.addTopicDelete.isHidden?15:5);
        make.bottom.mas_equalTo(weakSelf).offset(-(weakSelf.yDynamic?weakSelf.yDynamic-10:weakSelf.yDynamic+15));
        make.height.mas_equalTo(17);
        make.right.mas_lessThanOrEqualTo(weakSelf.interactive.right);
    }];
    
    [self.collectionView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
    make.bottom.mas_equalTo(weakSelf.addTopic.mas_top).offset(-15);
        if (weakSelf.postContentType == PostContentAudioAndWordsType){
            make.width.mas_equalTo(MOL_SCREEN_WIDTH-40-15-16-46);
        }else{
             make.width.mas_equalTo(65*3.0+4*2.0);
        }
        
       
        make.height.mas_equalTo(65);
    }];
    
    
    [self.interactive mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.left.mas_greaterThanOrEqualTo(weakSelf.addTopic.mas_right);
        make.bottom.mas_equalTo(weakSelf.mas_bottom).offset(-(weakSelf.yDynamic?weakSelf.yDynamic-10:weakSelf.yDynamic+15));
        make.height.mas_equalTo(17);
    }];
}

- (void)molPostView:(MOLPostView *)postView viewPostBusinessType:(PostBusinessType)businessType viewPostContentType:(PostContentType)contentType{
    
    if (self.behaviorType ==PostBehaviorUpdateType) {
        if (self.storyModel) {
            if (self.storyModel.stampVO) {
                self.stampModel.stampId = self.storyModel.stampVO.stampId;
                self.stampModel.lightImage =self.storyModel.stampVO.stampImg;
                self.stampModel.isAuthority=@"1";
            }
            
            if (self.storyModel.audioUrl && self.storyModel.audioUrl.length>0) {
                self.fileUrl =self.storyModel.audioUrl;
            }
            
            if (self.storyModel.time && self.storyModel.time.length>0) {
                self.voiceSec =self.storyModel.time.integerValue;
            }
        }
        
    }
    
    self.postBusinessType =businessType;
    self.postContentType =contentType;
    
    //[self addGestureRecognizer:self.tapGesture];
    
    [self addSubview:self.dateLable];
    [self addSubview:self.mailboxButton];
    [self addSubview:self.mailboxMark];
    
    if (self.postBusinessType==PostBusinessUnrequitedLoveType) { //暗恋类型
        [self addSubview:self.toLable];
        [self addSubview:self.phoneTextField];
        [self.phoneTextField addSubview:self.lineView];
        [self addSubview:self.addressBookButton];
    }
    
    [self addSubview:self.postTextView];
    [self addSubview:self.charNumLable];
    [self addSubview:self.collectionView];
    [self addSubview:self.addTopicDelete];
    [self addSubview:self.addTopic];
    [self addSubview:self.interactive];
    
    
    [self.addTopicDelete setHidden:YES];
    
    if (self.behaviorType ==PostBehaviorUpdateType) {
        
        if (self.storyModel) {
            if (self.storyModel.topicVO) {
                self.topicModel =self.storyModel.topicVO;
                [self.addTopicDelete setHidden:NO];
                
            }
        }
    }

    
    if (self.postBusinessType == PostBusinessUnrequitedLoveType) {
        
        
        
        if (self.postContentType == PostContentAudioAndWordsType)
        {//文字音频类型
            
        }
        else
        {
            
        }
        
    }else{
        
        if (self.postContentType == PostContentAudioAndWordsType)
        {//文字音频类型
            
        }
        else
        {
            
        }
        
    }
    
}

- (void)molPostView:(MOLPostView *)postView date:(NSString *)date weather:(NSString *)weather{
    
    [self.dateLable setText:[NSString stringWithFormat:@"%@\n%@",date?date:@"",weather?weather:@""]];
    
}

- (void)molPostView:(MOLPostView *)postView topicData:(MOLLightTopicModel *)topicData{
    
    if (topicData) {
        self.topicModel =topicData;
    }
    
    [self.addTopicDelete setHidden:NO];
    
    [self.addTopic setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [self.addTopic setTitle:[NSString stringWithFormat:@"%@",topicData.topicName?topicData.topicName:@""] forState:UIControlStateNormal];
    [self.addTopic setTitleColor:HEX_COLOR(0x074D81) forState:UIControlStateNormal];
    
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)molPostView:(MOLPostView *)postView addressBookData:(NSString *)addressBookData{
    [self.phoneTextField setText: [NSString stringWithFormat:@"%@",addressBookData?addressBookData:@""]];
}

- (void)molPostView:(MOLPostView *)postView selectedPhotos:(NSMutableArray *)selectedPhotos selectedAssets:(NSMutableArray *)selectedAssets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto{
    self.selectedPhotos =selectedPhotos;
    self.selectedAssets =selectedAssets;
    self.isSelectOriginalPhoto =isSelectOriginalPhoto;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
    });
}

- (void)molPostView:(MOLPostView *)postView stamp:(StampModel *)stampDto{
    self.stampModel =stampDto;
    
    NSURL *url;
    if (self.stampModel.isAuthority && self.stampModel.isAuthority.integerValue==1) { //表示高亮图
        url =[NSURL URLWithString:self.stampModel.lightImage?self.stampModel.lightImage:@""];
    }else{
        url =[NSURL URLWithString:self.stampModel.darkImage?self.stampModel.darkImage:@""];
    }
    __weak __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.mailboxButton sd_setImageWithURL:url forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"卡通邮票默认"]];
    });
    
}

- (void)molPostView:(MOLPostView *)postView fileUrl:(NSString *)fileUrl sec:(NSInteger)sec{
    self.fileUrl =[NSString stringWithString:fileUrl?fileUrl:@""];
    self.voiceSec =sec>0?sec:0;
    
    if (self.fileUrl && self.voiceSec && self.fileUrl.length>0 && self.voiceSec>0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.layout.itemSize=CGSizeMake(MOL_SCREEN_WIDTH-40-15-16-46,65);
            [self.collectionView reloadData];
        });
    }
}

- (void)molPostView:(MOLPostView *)postView showTopic:(BOOL)show{
    [self.addTopic setHidden:show];
}

- (void)keyboardEvent{
    [self resignFirstResponderSubEvent];
}


#pragma mark-
#pragma mark UI懒加载
- (UILabel *)dateLable{
    if (!_dateLable) {
        _dateLable =[UILabel new];
        [_dateLable setTextColor:HEX_COLOR(0x091F38)];
        [_dateLable setFont:MOL_MEDIUM_FONT(12)];
        [_dateLable setNumberOfLines:0];
    }
    return _dateLable;
}

- (UIButton *)mailboxButton{
    if (!_mailboxButton) {
        _mailboxButton =[UIButton buttonWithType:UIButtonTypeCustom];
        [_mailboxButton setAdjustsImageWhenHighlighted:NO];
        [_mailboxButton setImage:[UIImage imageNamed:@"卡通邮票默认"] forState:UIControlStateNormal];
        
        if (self.behaviorType ==PostBehaviorUpdateType) {
            if (self.storyModel) {
                if (self.storyModel.stampVO) {
                    NSURL *url=[NSURL URLWithString:self.stampModel.lightImage?self.stampModel.lightImage:@""];
                
                    __weak __typeof(self) weakSelf = self;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.mailboxButton sd_setImageWithURL:url forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"卡通邮票默认"]];
                    });
                    
                }
            }
            
        }
        
               [_mailboxButton addTarget:self action:@selector(mailboxButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _mailboxButton;
}

- (UIButton *)mailboxMark{
    if (!_mailboxMark) {
        _mailboxMark =[UIButton buttonWithType:UIButtonTypeCustom];
        [_mailboxMark setAdjustsImageWhenHighlighted:NO];
        [_mailboxMark setImage:[UIImage imageNamed:@"切换邮票"] forState:UIControlStateNormal];
        [_mailboxMark addTarget:self action:@selector(mailboxButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _mailboxMark;
}

- (UILabel *)toLable{
    if (!_toLable) {
        _toLable =[UILabel new];
        [_toLable setTextColor:HEX_COLOR(0x091F38)];
        [_toLable setText:@"To:"];
        [_toLable setFont:MOL_REGULAR_FONT(14)];
    }
    return _toLable;
}

- (UITextField *)phoneTextField{
    
    if (!_phoneTextField) {
        _phoneTextField =[UITextField new];
        [_phoneTextField setDelegate:self];
        [_phoneTextField setPlaceholder: @"输入手机号,匿名发给Ta"];
        [_phoneTextField setTextColor:HEX_COLOR(0xC6C6C6)];
        [_phoneTextField setFont:MOL_REGULAR_FONT(11)];
        [_phoneTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        //_phoneTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        NSMutableAttributedString *placeholder = [[NSMutableAttributedString alloc] initWithString:_phoneTextField.placeholder];
        
        [placeholder addAttribute:NSForegroundColorAttributeName
                            value:HEX_COLOR(0xC6C6C6)
                            range:NSMakeRange(0, _phoneTextField.placeholder.length)];
        [placeholder addAttribute:NSFontAttributeName
                            value:MOL_REGULAR_FONT(11)
                            range:NSMakeRange(0, _phoneTextField.placeholder.length)];
        _phoneTextField.attributedPlaceholder = placeholder;
        [_phoneTextField setKeyboardType:UIKeyboardTypeNumberPad];
        
        if (self.behaviorType ==PostBehaviorUpdateType) {
            if (self.storyModel) {
                if (self.storyModel.privateSign==2) { //表示公开
                    [_phoneTextField setEnabled:NO];
                }
                
                if (self.storyModel.toPhoneId && self.storyModel.toPhoneId.length>0) {
                    [_phoneTextField setText: self.storyModel.toPhoneId];
                }
            }
        }
    }
    
    return _phoneTextField;
}

- (UIView *)lineView{
    if (!_lineView) {
        _lineView =[UIView new];
        [_lineView setBackgroundColor:HEX_COLOR(0x091F38)];
    }
    return _lineView;
}

- (YYTextView *)postTextView{
    
    if (!_postTextView) {
        _postTextView =[YYTextView new];
        [_postTextView setFont:MOL_LIGHT_FONT(16)];
        [_postTextView setTextColor:HEX_COLOR(0x537A99)];
        [_postTextView setPlaceholderFont:MOL_LIGHT_FONT(16)];
        [_postTextView setPlaceholderTextColor:HEX_COLOR(0x537A99)];
        [_postTextView setKeyboardType:UIKeyboardTypeDefault];
        [_postTextView setPlaceholderText: [NSString stringWithFormat:@"%@",self.mailModel.prompt?self.mailModel.prompt:@"没人知道你是谁,\n在此刻吐露心声吧…"]];
        
        if (self.behaviorType ==PostBehaviorUpdateType) {
            if (self.storyModel.content && self.storyModel.content.length>0) {
                [_postTextView setText: self.storyModel.content_original];
            }
        }
        [_postTextView setDelegate:self];
    }
    return _postTextView;
    
}

- (UILabel *)charNumLable{
    if (!_charNumLable) {
        _charNumLable =[UILabel new];
        [_charNumLable setFont:MOL_REGULAR_FONT(11)];
        [_charNumLable setTextColor:HEX_COLOR(0x9B9B9B)];
        [_charNumLable setTextAlignment:NSTextAlignmentRight];
        [_charNumLable setAlpha:0];
    }
    return _charNumLable;
}

- (UIButton *)addressBookButton{
    if (!_addressBookButton) {
        _addressBookButton =[UIButton buttonWithType:UIButtonTypeCustom];
        [_addressBookButton setAdjustsImageWhenHighlighted:NO];
        [_addressBookButton setImage:[UIImage imageNamed:@"打开通讯录"] forState:UIControlStateNormal];
        [_addressBookButton addTarget:self action:@selector(openAddressBookButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addressBookButton;
}

- (UIButton *)imageButton{
    if (!_imageButton) {
        _imageButton =[UIButton buttonWithType:UIButtonTypeCustom];
        [_imageButton setAdjustsImageWhenHighlighted:NO];
        _imageButton.backgroundColor = HEX_COLOR(0xE9F6FF);
        [_imageButton setImage:[UIImage imageNamed:@"写信添加图片"] forState:UIControlStateNormal];
        [_imageButton addTarget:self action:@selector(imageButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _imageButton;
}

- (UIButton *)addTopicDelete{
    if (!_addTopicDelete) {
        _addTopicDelete =[UIButton buttonWithType:UIButtonTypeCustom];
        [_addTopicDelete setAdjustsImageWhenHighlighted:NO];
        [_addTopicDelete setImage:[UIImage imageNamed:@"关闭添加话题"] forState:UIControlStateNormal];
        [_addTopicDelete addTarget:self action:@selector(addTopicDeleteEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addTopicDelete;
}

- (UIButton *)addTopic{
    if (!_addTopic) {
        _addTopic =[UIButton buttonWithType:UIButtonTypeCustom];
        [_addTopic setAdjustsImageWhenHighlighted:NO];
        
        [_addTopic setHidden:YES];
        [_addTopic setImage:[UIImage imageNamed:@"#添加话题"] forState:UIControlStateNormal];
        [_addTopic setTitle:@" 添加话题" forState:UIControlStateNormal];
        [_addTopic setTitleColor:HEX_COLOR(0x091F38) forState:UIControlStateNormal];
        
        if (self.behaviorType ==PostBehaviorUpdateType) {
            
            if (self.storyModel) {
                if (self.storyModel.topicVO) {
                    [self.addTopic setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
                    [self.addTopic setTitle:[NSString stringWithFormat:@"%@",self.storyModel.topicVO.topicName?self.storyModel.topicVO.topicName:@""] forState:UIControlStateNormal];
                    [self.addTopic setTitleColor:HEX_COLOR(0x074D81) forState:UIControlStateNormal];
                }
            }
        }
        
        [_addTopic.titleLabel setFont:MOL_MEDIUM_FONT(12)];
        
        if (self.fromviewController==1) { //表示只读，不可读写
            [self.addTopic setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
             [self.addTopic setTitle:[NSString stringWithFormat:@"%@",self.ttTopicDto.topicName?self.ttTopicDto.topicName:@""] forState:UIControlStateNormal];
        }else{
        [_addTopic addTarget:self action:@selector(addTopicEvent:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    return _addTopic;
}

- (UIButton *)interactive{
    if (!_interactive) {
        _interactive =[UIButton buttonWithType:UIButtonTypeCustom];
        [_interactive setAdjustsImageWhenHighlighted:NO];
        [_interactive setImage:[UIImage imageNamed:@"不允许互动"] forState:UIControlStateNormal];
        [_interactive setImage:[UIImage imageNamed:@"允许互动"] forState:UIControlStateSelected];
        [_interactive setTitle:@" 允许互动" forState:UIControlStateNormal];
        
        [_interactive setTitleColor:HEX_COLOR(0x091F38) forState:UIControlStateNormal];
        [_interactive.titleLabel setFont:MOL_MEDIUM_FONT(12)];
        [_interactive addTarget:self action:@selector(integerValueEvent:) forControlEvents:UIControlEventTouchUpInside];
        
        [_interactive setSelected:YES];
        if (self.behaviorType ==PostBehaviorUpdateType) {
            
            if (self.storyModel) {
                if (!self.storyModel.chatOpen) {
                    [_interactive setSelected:NO];
                }
            }
        }
        
    }
    return _interactive;
}

- (MOLAnimateVoiceView *)voiceButotn{
    
    if (!_voiceButotn) {
        _voiceButotn =[MOLAnimateVoiceView new];
    }
    return _voiceButotn;
    
}

- (UICollectionView *)collectionView{
    
    if (!_collectionView) {
        
        self.layout =[UICollectionViewFlowLayout new];
       
        //设置item距离上下左右的边距
        self.layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        self.layout.minimumLineSpacing = 0;//行间距
        self.layout.minimumInteritemSpacing = 0;//列间距
        
        if (self.behaviorType ==PostBehaviorUpdateType) {
            if (self.fileUrl && self.fileUrl.length>0 && self.voiceSec && self.voiceSec>0) {
                self.layout.itemSize=CGSizeMake(MOL_SCREEN_WIDTH-40-15-16-46,65);
            }
            else{
                self.layout.itemSize=CGSizeMake(65, 65);
            }
        }
        else{
            self.layout.itemSize=CGSizeMake(65, 65);
        }
        _collectionView =[[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.layout];
        [_collectionView setBackgroundColor: [UIColor whiteColor]];
        [_collectionView setDelegate:self];
        [_collectionView setDataSource:self];
        

        if(self.postContentType == PostContentAudioAndWordsType){
            [_collectionView registerClass:[VoiceCell class] forCellWithReuseIdentifier:@"VoiceCell"];
        }else{
            [_collectionView registerClass:[MOLPhotosCell class] forCellWithReuseIdentifier:@"MOLPhotosCell"];
        }
        
    }
    return _collectionView;
    
}

//- (UITapGestureRecognizer *)tapGesture{
//    if (!_tapGesture) {
//        _tapGesture =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignFirstResponderEvent:)];
//    }
//    return _tapGesture;
//}


#pragma mark -
#pragma mark 事件响应
- (void)addTopicEvent:(UIButton *)sender{
    NSLog(@"触发添加话题事件");
    [self resignFirstResponderSubEvent];
    __weak __typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        weakSelf.MOLPostViewAddTopicBlock();
    });
    
}

- (void)addTopicDeleteEvent:(UIButton *)sender{
    NSLog(@"删除添加话题");
    //初始化数据，有数据处理
    [sender setHidden:YES];
    ///////////////////////////////////
    [self.addTopic setImage:[UIImage imageNamed:@"#添加话题"] forState:UIControlStateNormal];
    [self.addTopic setTitle:@" 添加话题" forState:UIControlStateNormal];
    [self.addTopic setTitleColor:HEX_COLOR(0x091F38) forState:UIControlStateNormal];
    __weak __typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        weakSelf.molPostViewDeleteAddTopicBlock();
    });
}


- (void)integerValueEvent:(UIButton *)sender{
    
    if ([sender isSelected]) { //不允许互动
        [sender setSelected:NO];
        NSLog(@"不需要互动事件");
    }
    else
    { //允许互动
        [sender setSelected:YES];
        NSLog(@"需要互动事件");
    }
    
    self.molPostViewInteractiveBlock(sender);
    
}

- (void)imageButtonEvent:(UIButton *)sender{
    
    NSLog(@"图片事件");
        [self resignFirstResponderSubEvent];
    //
    //    __weak __typeof(self) weakSelf = self;
    //    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //        weakSelf.molPostViewImageButtonBlock();
    //    });
}

-(void)mailboxEvent{
    NSLog(@"邮票事件");
    [self resignFirstResponderSubEvent];
    
    __weak __typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.molPostViewMailboxButtonBlock();
        });
    });
}


- (void)mailboxButtonEvent:(UIButton *)sender{
    [self mailboxEvent];
}

- (void)openAddressBookButton:(UIButton *)sender{
    NSLog(@"打开通讯录事件触发");
    [self resignFirstResponderSubEvent];
    
    __weak __typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        weakSelf.molPostViewAddressBookBlock();
    });
    
}

#if 0
- (void)resignFirstResponderEvent:(UIGestureRecognizer *)gesture{
    [self resignFirstResponderSubEvent];
}
#endif

- (void)resignFirstResponderSubEvent{
    
    if (self.phoneTextField.isFirstResponder) {
        [self.phoneTextField resignFirstResponder];
    }
    
    if (self.postTextView.isFirstResponder) {
        [self.postTextView resignFirstResponder];
    }
    
    
}



#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"选中相册图片");
    
    if (self.postContentType == PostContentAudioAndWordsType)
    {//文字音频类型
        
        if (self.fileUrl && self.voiceSec && self.fileUrl.length>0 && self.voiceSec>0) {
            return;
        }
        [self resignFirstResponderSubEvent];
        __weak __typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.molPostViewVoiceButtonBlock(indexPath);
            });
            
        });
        
    }
    else
    {
        [self resignFirstResponderSubEvent];
        __weak __typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.molPostViewImageButtonBlock(indexPath);
            });
            
        });
    }
    
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    if (self.postContentType == PostContentAudioAndWordsType)
    {//文字音频类型
        return 1;
    }
    else
    {
        return self.selectedPhotos.count>2?self.selectedPhotos.count : self.selectedPhotos.count+1;
    }
    
    
    
}


// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"%ld---%ld",indexPath.item,indexPath.row);
   
    if (self.postContentType == PostContentAudioAndWordsType)
    {//文字音频类型
        
        VoiceCell *voiceCell =[collectionView dequeueReusableCellWithReuseIdentifier:@"VoiceCell" forIndexPath:indexPath];
        [voiceCell setBackgroundColor: [UIColor whiteColor]];
        
        if (self.fileUrl && self.fileUrl.length>0 && self.voiceSec>0) { //音频样式
            
            [voiceCell setContent:1 fileUrl:self.fileUrl sec:self.voiceSec];
            [voiceCell.voiceButton addTarget:self action:@selector(voiceStartBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            voiceCell.deleteBtn.tag = indexPath.item;
            [voiceCell.deleteBtn addTarget:self action:@selector(voiceDeleteBtnClik:) forControlEvents:UIControlEventTouchUpInside];
            
        }else{ //默认样式
            [voiceCell setContent:0 fileUrl:self.fileUrl sec:self.voiceSec];
            [voiceCell.imageView setImage: [UIImage imageNamed:@"麦克风新"]];
        }
        
        
        return voiceCell;
        
    }
    else
    {
        MOLPhotosCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MOLPhotosCell" forIndexPath:indexPath];
        
        if (self.selectedPhotos.count<3) {
            if (indexPath.item == self.selectedPhotos.count) {//
                cell.imageView.image = [UIImage imageNamed:@"图片新"];
                [cell.imageView setBackgroundColor: HEX_COLOR(0xE9F6FF)];
                cell.deleteBtn.hidden = YES;
                
            } else {
                cell.imageView.image = _selectedPhotos[indexPath.item];
                cell.deleteBtn.hidden = NO;
            }

        }
        else{
            cell.imageView.image = _selectedPhotos[indexPath.item];
            cell.deleteBtn.hidden = NO;
        }
        
        cell.deleteBtn.tag = indexPath.item;
        [cell.deleteBtn addTarget:self action:@selector(deleteBtnClik:) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    }
}

- (void)deleteBtnClik:(UIButton *)sender {
    if ([self collectionView:self.collectionView numberOfItemsInSection:0] <= _selectedPhotos.count) {
        if (_selectedPhotos.count>sender.tag) {
            [_selectedPhotos removeObjectAtIndex:sender.tag];
        }
        if (_selectedAssets.count>sender.tag) {
            [_selectedAssets removeObjectAtIndex:sender.tag];
        }
        
        [self.collectionView reloadData];
        return;
    }
    
    if (_selectedPhotos.count>sender.tag) {
        [_selectedPhotos removeObjectAtIndex:sender.tag];
    }
    if (_selectedAssets.count>sender.tag) {
        [_selectedAssets removeObjectAtIndex:sender.tag];
    }
    [_collectionView performBatchUpdates:^{
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:sender.tag inSection:0];
        [self->_collectionView deleteItemsAtIndexPaths:@[indexPath]];
    } completion:^(BOOL finished) {
        [self->_collectionView reloadData];
    }];
}

- (void)voiceDeleteBtnClik:(UIButton *)sender{
    if (self.fileUrl && self.voiceSec && self.fileUrl.length>0 && self.voiceSec>0) {
        [[MOLPlayVoiceManager sharePlayVoiceManager] playManager_pause];        
    }
    self.fileUrl =@"";
    self.voiceSec =0;
    self.layout.itemSize=CGSizeMake(65, 65);
    [self.collectionView reloadData];
}

- (void)voiceStartBtnClick:(UIButton *)sender{
    if (self.fileUrl && self.voiceSec && self.fileUrl.length>0 && self.voiceSec>0) {
        [[MOLPlayVoiceManager sharePlayVoiceManager] playManager_playVoiceWithFileUrlString:self.fileUrl modelId:@"" playType:MOLPlayVoiceManagerType_stream];
    }
}

#pragma mark
#pragma mark UITextFieldDelegate
/**
 *  手机ha控制位数为11位
 */
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    if (textField == self.phoneTextField) { 
        if (string.length == 0) return YES;
        
        if (self.phoneTextField.text.length > 10) {
            return NO;
        }
        
    }
    return YES;
}


- (void)textFieldDidChange:(UITextField *)textField
{
    if (!textField||!textField.text) {
        return;
    }
    //将要结束的时候判断所有数据是否填充完整，来判断下一步是否可以点击
    if ([textField isEqual:self.phoneTextField]) {
        if (textField.text.length > 11) {
            textField.text = [textField.text substringToIndex:11];
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MOLPostViewTextFieldDidChange" object:textField.text];
}

#pragma mark- YYTextViewDelegate
- (BOOL)textView:(YYTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if (textView == self.postTextView) {
        if (text.length == 0) return YES;
        
        if (self.phoneTextField.text.length > 499) {
            return NO;
        }
        
    }
    return YES;
}

- (void)textViewDidChange:(YYTextView *)textView{
    if (!textView||!textView.text) {
        return;
    }
    if (textView.text.length>0) {
        [self.charNumLable setAlpha:1];
    }else{
        [self.charNumLable setAlpha:0];
    }
    //将要结束的时候判断所有数据是否填充完整，来判断下一步是否可以点击
    if ([textView isEqual:self.postTextView]) {
        
        if (textView.text.length > 500) {
            textView.text = [textView.text substringToIndex:500];
        }
        [self.charNumLable setText:[NSString stringWithFormat:@"%ld/%ld",textView.text.length,KMaxCount]];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MOLPostViewTextViewDidChange" object:textView.text];
    }
}



-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
