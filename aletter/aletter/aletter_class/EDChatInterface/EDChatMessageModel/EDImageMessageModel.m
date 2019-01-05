//
//  EDImageMessageModel.m
//  aletter
//
//  Created by moli-2017 on 2018/8/28.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "EDImageMessageModel.h"
#import "EDImageCell.h"

@implementation EDImageMessageModel
- (instancetype)initWithImage:(NSString *)image width:(CGFloat)width height:(CGFloat)height
{
    if (self = [super init]) {
        self.content = image;
//        self.chatType = 1;
//        self.imageW = width;
//        self.imageH = height;
    }
    return self;
}

- (EDBaseChatCell *)getCellWithReuseIdentifier:(NSString *)identifier
{
    return [[EDImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
}

- (CGFloat)cellHeight
{
    if (_cellHeight == 0) {
        
        CGFloat h = 100;
        CGFloat w = 100;
        
        _cellHeight = h + 2 * kEDBubbleVerticalEdgeSpacing + 2 * kEDCellVerticalEdgeSpacing;
        
        if (self.fromType == MessageFromType_me) {
            self.bubbleImageFrame = CGRectMake(MOL_SCREEN_WIDTH - (w + 2 * kEDBubbleHorizontalEdgeSpacing) - kEDCellHorizontalEdgeSpacing, 10, w + 2 * kEDBubbleHorizontalEdgeSpacing, _cellHeight - 2 * kEDCellVerticalEdgeSpacing);
            
            self.imageViewFrame = CGRectMake(kEDBubbleHorizontalEdgeSpacing, kEDBubbleVerticalEdgeSpacing, w, h);
            self.sendingIndicatorFrame = CGRectMake(self.bubbleImageFrame.origin.x - 10 - 2 * kEDCellVerticalEdgeSpacing, self.bubbleImageFrame.origin.y + (self.bubbleImageFrame.size.height * 0.5 - 20 * 0.5), 20, 20);
        }else{
            self.bubbleImageFrame = CGRectMake(kEDCellHorizontalEdgeSpacing, 10, w + 2 * kEDBubbleHorizontalEdgeSpacing, _cellHeight - 2 * kEDCellVerticalEdgeSpacing);
            
            self.imageViewFrame = CGRectMake(kEDBubbleHorizontalEdgeSpacing, kEDBubbleVerticalEdgeSpacing, w, h);
            self.sendingIndicatorFrame = CGRectMake(self.bubbleImageFrame.origin.x + self.bubbleImageFrame.size.width + 10, self.bubbleImageFrame.origin.y + (self.bubbleImageFrame.size.height * 0.5 - 20 * 0.5), 20, 20);
        }
        
    }
    
    return _cellHeight;
}

- (CGFloat)getCellHeight
{
    return self.cellHeight;
}
@end
