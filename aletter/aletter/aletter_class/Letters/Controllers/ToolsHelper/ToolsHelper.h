//
//  ToolsHelper.h
//  SuperShopping
//
//  Created by ACTION on 2017/12/2.
//  Copyright © 2017年 xiaoling li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ToolsHelper : NSObject

//获取app版本号
+(NSString *) getAppVersion;

//获取build版本号
+(NSString *) getBuildVersion;

//获取设备系统版本 例如：8.3  9.0...
+ (NSString *) getSystemVersion;

//获取手机类型 例如：iPhone or ipad...
+ (NSString *) getDeviceModel;

//获取设备名称 例如：iPhone6   iPhone6s...
+ (NSString*) getDeviceName;


/* --------------------------------- 服务相关  --------------------------*/
//颜色色值,全局使用
+ (UIColor *) colorWithHexString: (NSString *)color;

//颜色设置，自动设置alpha值
+ (UIColor *) colorWithHexString: (NSString *)color alpha:(CGFloat)alpha;

//数据解析
+ (NSMutableDictionary *)lxlcustomDataToDic:(id)dic;

/**
 判断是否是手机号格式
 
 @param mobileNum 输入手机号字符串对象
 
 @return 返回Bool值，yes，表示是手机号，NO，表示不是手机号
 */
+ (BOOL)isMobileNumber:(NSString *)mobileNum;



/**
 判断验证码位数是否大于等于4位
 
 @param verification 验证码字符串对像
 
 @return 返回Bool值，yes，表示验证码大于等于4位，NO，表示验证码不符合规则
 */
+ (BOOL)isVerificationCode:(NSString *)verification;

/**
 判断验证码位数是否在 6 － 16位之间
 
 @param password 密码对象
 
 @return 返回Bool值，yes，表示密码在6位 至 16位之间，NO，表示密码不符合规则
 */
+ (BOOL)isNormalPassword:(NSString *)password;


+ (NSString *)getDateString;

//MD5加密
+ (NSString *)MD5ByAStr:(NSString *)aSourceStr;

//将图像的中心放在正方形区域的中心，图形未填充的区域用黑色填充，并压缩到40－100k，
+ (NSString *)fileOfImgInSquareFillBlankWithBlackBgAndPressedImage:(UIImage *)image;

/**
 根据时间字符串返回年
 
 @param dateStr 时间字符串
 
 @return 年
 */
+ (NSString *)getYear:(NSString *)dateStr;

/**
 根据时间字符串返回月
 
 @param dateStr 时间字符串
 
 @return 月
 */
+ (NSString *)getMonth:(NSString *)dateStr;

/**
 根据时间字符串返回日
 
 @param dateStr 时间字符串
 
 @return 日
 */
+ (NSString *)getDay:(NSString *)dateStr;


/**
 根据时间字符串返回时、分
 
 @param dateStr 时间字符串
 
 @return 时、分
 */
+ (NSString *)getTimeHAndM:(NSString *)dateStr;


/**
 根据时间字符串返回当前时间
 
 @return 当前时间
 */
+ (NSString *)getCurrentTime;

// 修改图片旋转问题
+(UIImage *) fixOrientationWithImage:(UIImage *)image ;

// 获取图片相对路劲
+(NSString *) imageToPost:(UIImage *)_img imagePlanSize:(CGFloat)_imagePlanSize imageContentSize:(int)_contentSize;

+ (NSString *) dateByAddingMinutes:(NSInteger) timeInterval;

+(BOOL) isBlankString:(NSString *)string;

//去掉发表文字前的回车符
+(NSString *)DelbeforeEnter:(NSString *)str1;

//去掉发表文字后的回车符
+(NSString *)DelbehindEnter:(NSString *)str2;

@end
