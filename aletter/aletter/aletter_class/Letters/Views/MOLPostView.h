//
//  MOLPostView.h
//  aletter
//
//  Created by xiaolong li on 2018/8/9.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import <UIKit/UIKit.h>
@class StampModel,MOLLightTopicModel,MOLMailModel,MOLLightTopicModel,yyte;
#import "MOLStoryModel.h"
#import "MOLHead.h"

typedef NS_ENUM(NSInteger, PostBehaviorType) { //行为类型
    PostBehaviorNormalType,                // 常规类型
    PostBehaviorUpdateType,         // 修改类型
};

typedef NS_ENUM(NSInteger, PostBusinessType) {
    PostBusinessGeneralType,                // 通用类型
    PostBusinessUnrequitedLoveType,         // 暗恋类型
};

typedef NS_ENUM(NSInteger, PostContentType) {
    PostContentWordsType,           // 文本类型
    PostContentImageType,           // 图片类型
    PostContentImageAndWordsType,   // 图文混合类型
    PostContentAudioType,           // 音频类型
    PostContentAudioAndWordsType,   // 音频文字混合类型
};


typedef void(^MOLPostViewAddTopicBlock)(void);
typedef void(^MOLPostViewDeleteAddTopicBlock)(void);
typedef void(^MOLPostViewAddressBookBlock)(void);
typedef void(^MOLPostViewImageButtonBlock)(NSIndexPath *indexPath);
typedef void(^MOLPostViewVoiceButtonBlock)(NSIndexPath *indexPath);
typedef void(^MOLPostViewMailboxButtonBlock)(void);
typedef void(^MOLPostViewInteractiveBlock)(UIButton *sender);

typedef void(^MailboxTableViewProxyCloseBlock)(NSIndexPath *indexPath);


@interface MOLPostView : UIView
@property (nonatomic,strong) YYTextView *postTextView;
@property (nonatomic, assign) NSInteger fromviewController;//1 表示来自MOLMailDetailViewController 类
@property (nonatomic, strong) MOLLightTopicModel *ttTopicDto;
@property (nonatomic,strong) NSMutableArray *selectedPhotos;  ///< 表示选中图片资源
@property (nonatomic,strong) NSMutableArray *selectedAssets; ///<表示图片相关资源
@property (strong, nonatomic) MOLMailModel *mailModel;
@property (assign, nonatomic) PostBehaviorType behaviorType;
@property (nonatomic, strong) MOLStoryModel *storyModel;
@property (nonatomic, copy) MOLPostViewAddTopicBlock MOLPostViewAddTopicBlock;
@property (nonatomic, copy) MOLPostViewDeleteAddTopicBlock molPostViewDeleteAddTopicBlock;
@property (nonatomic, copy) MOLPostViewAddressBookBlock molPostViewAddressBookBlock;
@property (nonatomic, copy) MOLPostViewImageButtonBlock molPostViewImageButtonBlock;
@property (nonatomic, copy) MOLPostViewVoiceButtonBlock molPostViewVoiceButtonBlock;
@property (nonatomic, copy) MOLPostViewMailboxButtonBlock molPostViewMailboxButtonBlock;
@property (nonatomic, copy) MOLPostViewInteractiveBlock molPostViewInteractiveBlock;

- (void)molPostView:(MOLPostView *)postView viewPostBusinessType:(PostBusinessType)businessType viewPostContentType:(PostContentType)contentType;

- (void)molPostView:(MOLPostView *)postView date:(NSString *)date weather:(NSString *)weather;

- (void)molPostView:(MOLPostView *)postView topicData:(MOLLightTopicModel *)topicData;

- (void)molPostView:(MOLPostView *)postView addressBookData:(NSString *)addressBookData;

- (void)molPostView:(MOLPostView *)postView selectedPhotos:(NSMutableArray *)selectedPhotos selectedAssets:(NSMutableArray *)selectedAssets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto;

- (void)molPostView:(MOLPostView *)postView stamp:(StampModel *)stampDto;

- (void)molPostView:(MOLPostView *)postView fileUrl:(NSString *)fileUrl sec:(NSInteger)sec;

- (void)molPostView:(MOLPostView *)postView showTopic:(BOOL)show;

- (void)keyboardEvent;



@end
