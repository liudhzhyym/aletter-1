//
//  MOLStoryDetailRichTextHeadView.m
//  aletter
//
//  Created by moli-2017 on 2018/8/6.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLStoryDetailRichTextHeadView.h"
#import "MOLHead.h"

@interface MOLStoryDetailRichTextHeadView ()
@property (nonatomic, weak) YYLabel *contentLabel;
@end

@implementation MOLStoryDetailRichTextHeadView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setupStoryDetailRichTextHeadViewUI];
    }
    return self;
}

#pragma mark - model
- (void)setStoryModel:(MOLStoryModel *)storyModel
{
    _storyModel = storyModel;
    NSMutableAttributedString *text = [NSMutableAttributedString new];
    UIFont *font = MOL_REGULAR_FONT(16);
    UIColor *color = HEX_COLOR(0x074D81);
    NSString *title = storyModel.content;
    [text appendAttributedString:[[NSAttributedString alloc] initWithString:title attributes:nil]];
    
    NSMutableArray *photoArr = [NSMutableArray array];
    int curIndex = 0;
    
    for (NSInteger i = 0; i < storyModel.photos.count; i++) {
        MOLLightPhotoModel *photo = storyModel.photos[i];
        NSString *imageStr = photo.src;
        [photoArr addObject:imageStr];
        curIndex = (int)i;
        @weakify(self);
        FLAnimatedImageView *imageV = [FLAnimatedImageView new];
//        [MOLAppDelegateWindow addSubview:imageV];
        __weak typeof(imageV) wImage = imageV;
        [imageV sd_setImageWithURL:[NSURL URLWithString:imageStr] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            @strongify(self);
            wImage.width = self.width - 30;
            if (image.size.width == 0) {
                wImage.height = 0;
            }else{
                wImage.height = wImage.width * image.size.height / image.size.width;
            }
            
            NSMutableAttributedString *attachText = [NSMutableAttributedString yy_attachmentStringWithContent:wImage contentMode:UIViewContentModeCenter attachmentSize:CGSizeMake(wImage.size.width, wImage.size.height+5) alignToFont:font alignment:YYTextVerticalAlignmentBottom];
            [text appendAttributedString:attachText];
            
            NSRange range = NSMakeRange(text.length - 1, 1);
            
            [text yy_setTextHighlightRange:range color:[UIColor clearColor] backgroundColor:[UIColor clearColor] tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
                
                HZPhotoBrowser *browser = [[HZPhotoBrowser alloc] init];
                browser.isNeedLandscape = NO;
                browser.currentImageIndex = curIndex;
                browser.imageArray = photoArr;
                [browser show];
                
            }];
            
            [self contentLabel_setTextWithText:text font:font color:color model:storyModel];
        }];
        
//        [imageV sd_setImageWithURL:[NSURL URLWithString:imageStr] placeholderImage:[UIImage imageNamed:@"home_lock"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
//            @strongify(self);
//            [imageV removeFromSuperview];
//            YYAnimatedImageView *imageView = [[YYAnimatedImageView alloc] initWithImage:image];
//            imageView.width = self.width - 30;
//            if (image.size.width == 0) {
//                imageView.height = 0;
//            }else{
//                imageView.height = imageView.width * image.size.height / image.size.width;
//            }
//
//            imageView.autoPlayAnimatedImage = YES;
//
//            NSMutableAttributedString *attachText = [NSMutableAttributedString yy_attachmentStringWithContent:imageView contentMode:UIViewContentModeCenter attachmentSize:CGSizeMake(imageView.size.width, imageView.size.height+5) alignToFont:font alignment:YYTextVerticalAlignmentBottom];
//            [text appendAttributedString:attachText];
//
//            NSRange range = NSMakeRange(text.length - 1, 1);
//
//            [text yy_setTextHighlightRange:range color:[UIColor clearColor] backgroundColor:[UIColor clearColor] tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
//
//                HZPhotoBrowser *browser = [[HZPhotoBrowser alloc] init];
//                browser.isNeedLandscape = NO;
//                browser.currentImageIndex = curIndex;
//                browser.imageArray = photoArr;
//                [browser show];
//
//            }];
//
//            [self contentLabel_setTextWithText:text font:font color:color model:storyModel];
//        }];
    }
    
    [self contentLabel_setTextWithText:text font:font color:color model:storyModel];
}

- (void)contentLabel_setTextWithText:(NSMutableAttributedString *)text font:(UIFont *)font color:(UIColor *)color model:(MOLStoryModel *)storyModel
{
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
    
    CGSize introSize = CGSizeMake(self.width - 30, CGFLOAT_MAX);
    YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:introSize text:text];
    self.height = layout.textBoundingSize.height;
    self.contentLabel.attributedText = text;
}

#pragma mark - UI
- (void)setupStoryDetailRichTextHeadViewUI
{
    YYLabel *contentLabel = [[YYLabel alloc] init];
    _contentLabel = contentLabel;
    contentLabel.numberOfLines = 0;
    [self addSubview:contentLabel];
//    [self calculatorStoryDetailRichTextHeadViewFrame];
}

- (void)calculatorStoryDetailRichTextHeadViewFrame
{
    self.contentLabel.frame = self.bounds;
    self.contentLabel.width = self.width - 30;
    self.contentLabel.x = 15;
    if (self.resetTableHeadViewBlock) {
        self.resetTableHeadViewBlock(self.height);
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self calculatorStoryDetailRichTextHeadViewFrame];
}

@end
