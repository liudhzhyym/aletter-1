//
//  MOLStoryModel.m
//  aletter
//
//  Created by moli-2017 on 2018/8/4.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLStoryModel.h"
#import "MOLHead.h"

@implementation MOLStoryModel

//+ (NSDictionary *)mj_replacedKeyFromPropertyName
//{
//    return @{@"images" : @""};
//}

+ (NSDictionary *)mj_objectClassInArray {
    return @{
             @"photos":[MOLLightPhotoModel class]
             };
}

- (CGFloat)richTextCellHeight
{
    if (_richTextCellHeight == 0) {
        
        // 顶部间距 20 名字 20 名和文间距 10  文字 xx  文字和图片间距 10 图片 文字和展开全部间距 5 展开全文 20  展开全文下间距  15
        // 底部控件 17  底部间距 20
        
        // 计算文字高度
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:self.content];
        text.yy_font = MOL_LIGHT_FONT(14);
        CGSize introSize = CGSizeMake(MOL_SCREEN_WIDTH-40-30, CGFLOAT_MAX);
        YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:introSize text:text];
        CGFloat textH = layout.textBoundingSize.height;
    
        if (textH > MOL_TextMaxHeight) {
            textH = MOL_TextMaxHeight;
            self.showAllButton = YES;
        }else{
            self.showAllButton = NO;
        }
        
        // 顶部间距、名字、间距、正文
        _richTextCellHeight = 20 + 20 + 10 + textH;
        
        // 展开全文及间距
        if (self.showAllButton) {
            _richTextCellHeight = _richTextCellHeight + 5 + 20;
        }
        
        // 图片及间距
        if (self.photos.count) {
            _richTextCellHeight = _richTextCellHeight + (self.showAllButton?15:10) + 65;
        }
        
        // 刚刚、喜欢、评论及间距
        _richTextCellHeight = _richTextCellHeight + 20 + (self.photos.count?10:(self.showAllButton?15:10));
        
        _richTextCellHeight = _richTextCellHeight + 20; //底部间距
    }
    
    return _richTextCellHeight;
}

- (CGFloat)voiceCellHeight
{
    if (_voiceCellHeight == 0) {
        
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:self.content];
        text.yy_font = MOL_LIGHT_FONT(14);
        CGSize introSize = CGSizeMake(MOL_SCREEN_WIDTH-40-30, CGFLOAT_MAX);
        YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:introSize text:text];
        CGFloat textH = layout.textBoundingSize.height;
        
        if (textH > MOL_TextMaxHeight) {
            textH = MOL_TextMaxHeight;
            self.showAllButton = YES;
        }else{
            self.showAllButton = NO;
        }
        
        // 顶部间距、名字、间距、音频view、间距、正文
        _voiceCellHeight = 20 + 20 + 10 + 40 + 10 + textH;
        
        // 展开全文及间距
        if (self.showAllButton) {
            _voiceCellHeight = _voiceCellHeight + 5 + 20;
        }
        
        // 刚刚、喜欢、评论及间距
        _voiceCellHeight = _voiceCellHeight + 20 + (self.showAllButton?15:10);
        
        _voiceCellHeight = _voiceCellHeight + 20; //底部间距
    }
    
    return _voiceCellHeight;
}

- (NSString *)content
{
    if (_topicVO.topicName.length) {
        NSString *con = [NSString stringWithFormat:@"%@%@",_topicVO.topicName,_content];
        return con;
    }else{
        return _content;
    }
}

- (NSString *)content_original
{
    return _content;
}
@end
