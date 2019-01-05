//
//  MOLJSBridgeHelper.h
//  aletter
//
//  Created by 徐天牧 on 2018/9/1.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@interface MOLJSBridgeHelper : NSObject

@property (nonatomic, strong) WKWebView *webView;



//v1.0.0 H5获取app信息
- (void)getAppStarts; // js调用原生，然后再掉js

//v1.0.0 分享
- (void)shareActive:(NSString *)jsonString;
//v1.0.0 复制
- (void)shareWithCopyWord:(NSString *)jsonString; // 复制文字
//告诉H5发起分享
-(void)initiateH5Share;

@end
