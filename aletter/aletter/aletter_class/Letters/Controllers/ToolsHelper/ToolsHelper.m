//
//  ToolsHelper.m
//  SuperShopping
//
//  Created by ACTION on 2017/12/2.
//  Copyright © 2017年 xiaoling li. All rights reserved.
//

#import "ToolsHelper.h"
#import <sys/utsname.h>
#import <CommonCrypto/CommonDigest.h>

@implementation ToolsHelper

#pragma mark -
#pragma mark - 获取app版本号
+(NSString *) getAppVersion
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}
#pragma mark -
#pragma mark - 获取build版本号
+(NSString *) getBuildVersion
{
    return [[UIDevice currentDevice] systemVersion];
}
#pragma mark -
#pragma mark - 获取设备系统版本 例如：iOS 10.0...
+(NSString *) getSystemVersion
{
    return [[UIDevice currentDevice] systemVersion];
}

#pragma mark -
#pragma mark - 获取手机类型 例如：iphone or ipad...
+(NSString *)getDeviceModel
{
    return [[UIDevice currentDevice] model];
}

#pragma mark -
#pragma mark - 获取设备名称 如：iPhone6   iPhone6s...
+(NSString*) getDeviceName {
    struct utsname systemInfo;
    
    uname(&systemInfo);
    
    NSString* code = [NSString stringWithCString:systemInfo.machine
                                        encoding:NSUTF8StringEncoding];
    
    static NSDictionary* deviceNamesByCode = nil;
    
    if (!deviceNamesByCode) {
        
        deviceNamesByCode = @{@"i386"      :@"Simulator",
                              @"x86_64"    :@"Simulator",
                              @"iPod1,1"   :@"iPod Touch",      // (Original)
                              @"iPod2,1"   :@"iPod Touch",      // (Second Generation)
                              @"iPod3,1"   :@"iPod Touch",      // (Third Generation)
                              @"iPod4,1"   :@"iPod Touch",      // (Fourth Generation)
                              @"iPod7,1"   :@"iPod Touch",      // (6th Generation)
                              @"iPhone1,1" :@"iPhone",          // (Original)
                              @"iPhone1,2" :@"iPhone",          // (3G)
                              @"iPhone2,1" :@"iPhone",          // (3GS)
                              @"iPad1,1"   :@"iPad",            // (Original)
                              @"iPad2,1"   :@"iPad 2",          //
                              @"iPad3,1"   :@"iPad",            // (3rd Generation)
                              @"iPhone3,1" :@"iPhone 4",        // (GSM)
                              @"iPhone3,3" :@"iPhone 4",        // (CDMA/Verizon/Sprint)
                              @"iPhone4,1" :@"iPhone 4S",       //
                              @"iPhone5,1" :@"iPhone 5",        // (model A1428, AT&T/Canada)
                              @"iPhone5,2" :@"iPhone 5",        // (model A1429, everything else)
                              @"iPad3,4"   :@"iPad",            // (4th Generation)
                              @"iPad2,5"   :@"iPad Mini",       // (Original)
                              @"iPhone5,3" :@"iPhone 5c",       // (model A1456, A1532 | GSM)
                              @"iPhone5,4" :@"iPhone 5c",       // (model A1507, A1516, A1526 (China), A1529 | Global)
                              @"iPhone6,1" :@"iPhone 5s",       // (model A1433, A1533 | GSM)
                              @"iPhone6,2" :@"iPhone 5s",       // (model A1457, A1518, A1528 (China), A1530 | Global)
                              @"iPhone7,1" :@"iPhone 6 Plus",   //
                              @"iPhone7,2" :@"iPhone 6",        //
                              @"iPhone8,1" :@"iPhone 6S",       //
                              @"iPhone8,2" :@"iPhone 6S Plus",  //
                              @"iPhone9,1" :@"iPhone 7",
                              @"iPhone9,2" :@"iPhone 7 Plus",
                              @"iPad4,1"   :@"iPad Air",        // 5th Generation iPad (iPad Air) - Wifi
                              @"iPad4,2"   :@"iPad Air",        // 5th Generation iPad (iPad Air) - Cellular
                              @"iPad4,4"   :@"iPad Mini",       // (2nd Generation iPad Mini - Wifi)
                              @"iPad4,5"   :@"iPad Mini",       // (2nd Generation iPad Mini - Cellular)
                              @"iPad4,7"   :@"iPad Mini"        // (3rd Generation iPad Mini - Wifi (model A1599))
                              };
    }
    
    NSString* deviceName = [deviceNamesByCode objectForKey:code];
    
    if (!deviceName) {
        
        if ([code rangeOfString:@"iPod"].location != NSNotFound) {
            deviceName = @"iPod Touch";
        }
        else if([code rangeOfString:@"iPad"].location != NSNotFound) {
            deviceName = @"iPad";
        }
        else if([code rangeOfString:@"iPhone"].location != NSNotFound){
            deviceName = @"iPhone";
        }
        else {
            deviceName = @"Unknown";
        }
    }
    
    return deviceName;
}


#pragma mark -
#pragma mark - 颜色转换 IOS中十六进制的颜色转换为UIColor
+ (UIColor *) colorWithHexString: (NSString *)color
{
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) {
        return [UIColor clearColor];
    }
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"0x"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return [UIColor clearColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    
    //r
    NSString *rString = [cString substringWithRange:range];
    
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:1.0f];
}

+ (UIColor *) colorWithHexString: (NSString *)color alpha:(CGFloat)alpha
{
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) {
        return [UIColor clearColor];
    }
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"0x"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return [UIColor clearColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    
    //r
    NSString *rString = [cString substringWithRange:range];
    
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:alpha];
}




#pragma mark -
#pragma mark -数据解析
+(NSMutableDictionary *)lxlcustomDataToDic:(id)dic{
    
    NSData *data=nil;
    
    if (!dic) {
        return nil;
    }
    
    if([dic isKindOfClass:[NSDictionary class]]){
        
        return dic;
        
    }else if ([dic isKindOfClass:[NSData class]]) {
        
        data=dic;
        
    }else if([dic isKindOfClass:[NSString class]]){
        
        data=[dic dataUsingEncoding:NSUTF8StringEncoding];
        
    }else{
        
        return nil;
        
    }
    
    return [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    
}


/**
 判断是否是手机号格式
 
 @param mobileNum 输入手机号字符串对象
 
 @return 返回Bool值，yes，表示是手机号，NO，表示不是手机号
 */
+ (BOOL)isMobileNumber:(NSString *)mobileNum
{
    
    NSString *regex = @"1[0-9]{10}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [pred evaluateWithObject:mobileNum];
}


/**
 判断验证码位数是否大于等于4位
 
 @param verification 验证码字符串对像
 
 @return 返回Bool值，yes，表示验证码等于4位，NO，表示验证码不符合规则
 */
+ (BOOL)isVerificationCode:(NSString *)verification{
    
    if (verification.length>4) {
        return YES;
    }
    
    return NO;
    
}


/**
 判断密码位数是否在 6 － 12位之间
 
 @param password 密码对象
 
 @return 返回Bool值，yes，表示密码在6位 至 12位之间，NO，表示密码不符合规则
 */
+ (BOOL)isNormalPassword:(NSString *)password{
    
    if (password.length>=6 &&password.length<=12) {
        return YES;
    }
    
    return NO;
}


+ (NSString *)getDateString{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    [formatter setDateFormat:@"YYYYMMddHHmmss"];
    //现在时间,你可以输出来看下是什么格式
    NSDate *datenow = [NSDate date];
    //----------将nsdate按formatter格式转成nsstring
    NSString *currentTimeString = [formatter stringFromDate:datenow];
    NSLog(@"currentTimeString = %@",currentTimeString);
    return currentTimeString;
    
}

//MD5加密
+ (NSString *)MD5ByAStr:(NSString *)aSourceStr{
    const char* cStr = [aSourceStr UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH];
    for (NSInteger i=0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x", result[i]];
    }
    
    return ret;
}

//将图像的中心放在正方形区域的中心，图形未填充的区域用黑色填充，并压缩到40－100k，
+ (NSString *)fileOfImgInSquareFillBlankWithBlackBgAndPressedImage:(UIImage *)image{
    
    // NSLog(@"%@", NSStringFromCGSize(image.size));
    
    NSString *tmpDic = NSTemporaryDirectory(); //生成一个临时目录，生命周期很短
    NSDate *date = [NSDate date];
    NSDateFormatter *formatDate = [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [formatDate setLocale:locale];
    [formatDate setDateFormat:@"yyyyMMddHHmmss"];
    NSString* dateStr = [formatDate stringFromDate:date];
    NSString *imagelocalName_s = [NSString stringWithFormat:@"%@_s.jpg", dateStr];
    NSString *_image_Path=[tmpDic stringByAppendingPathComponent:imagelocalName_s];
    
    CGSize imageSize;
    imageSize.height = image.size.height;
    imageSize.width = image.size.width;
    
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.0);
    UIBezierPath* p = [UIBezierPath bezierPathWithRect:CGRectMake(0,0,image.size.width,image.size.height)];
    [[UIColor blackColor] setFill];
    [p fill];
    
    
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    
    
    UIImage *imageHavePress = UIGraphicsGetImageFromCurrentImageContext();
    //    NSData *pressSizeData1 = UIImageJPEGRepresentation(imageHavePress, 1.0);
    UIGraphicsEndImageContext();
    CGFloat compression = 0.9f;
    CGFloat maxCompression = 0.1f;
    NSData *pressSizeData = UIImageJPEGRepresentation(imageHavePress, compression);
    while ([pressSizeData length] > 200*1024 && compression > maxCompression) {
        compression -= 0.1;
        pressSizeData = UIImageJPEGRepresentation(imageHavePress, compression);
    }
    //    NSData *pressSizeData = UIImageJPEGRepresentation(imageHavePress, 1.0);
    //
    //    if (pressSizeData.length>1024*1024){
    //        pressSizeData = UIImageJPEGRepresentation(imageHavePress, 1.0);
    //    }
    
    [pressSizeData writeToFile:_image_Path atomically:YES];
    
    return _image_Path;
    
}

/**
 根据时间字符串返回年
 
 @param dateStr 时间字符串
 
 @return 年
 */
+ (NSString *)getYear:(NSString *)dateStr{
    
    NSString *yearStr =[NSString new];
    NSString *dateSStr =[NSString stringWithFormat:@"%@",dateStr];
    
    NSArray *dateArr =[dateSStr componentsSeparatedByString:@"-"];
    
    if (dateArr.count>2) {
        yearStr =dateArr[0];
    }
    
    
    return yearStr;
    
}

/**
 根据时间字符串返回月
 
 @param dateStr 时间字符串
 
 @return 月
 */
+ (NSString *)getMonth:(NSString *)dateStr{
    
    NSString *monthStr =[NSString new];
    NSString *dateSStr =[NSString stringWithFormat:@"%@",dateStr];
    
    NSArray *dateArr =[dateSStr componentsSeparatedByString:@"-"];
    
    if (dateArr.count>2) {
        monthStr =dateArr[1];
    }
    
    
    return monthStr;
    
}

/**
 根据时间字符串返回日
 
 @param dateStr 时间字符串
 
 @return 日
 */
+ (NSString *)getDay:(NSString *)dateStr{
    
    NSString *dayStr =[NSString new];
    NSString *dateSStr =[NSString stringWithFormat:@"%@",dateStr];
    
    NSArray *dateArr =[dateSStr componentsSeparatedByString:@"-"];
    
    if (dateArr.count>2) {
        NSArray *dayArr =[dateArr[2] componentsSeparatedByString:@" "];
        dayStr =dayArr[0];
    }
    
    
    return dayStr;
    
}

/**
 根据时间字符串返回时、分
 
 @param dateStr 时间字符串
 
 @return 时、分
 */
+ (NSString *)getTimeHAndM:(NSString *)dateStr{
    
    NSString *timeStr =[NSString new];
    NSString *dateSStr =[NSString stringWithFormat:@"%@",dateStr];
    
    NSArray *dateArr =[dateSStr componentsSeparatedByString:@"-"];
    
    if (dateArr.count>2) {
        NSArray *dayArr =[dateArr[2] componentsSeparatedByString:@" "];
        timeStr =dayArr[1];
        
        
    }
    
    NSArray *timeArr =[timeStr componentsSeparatedByString:@":"];
    
    if (timeArr.count>1) {
        
        return [NSString stringWithFormat:@"%@:%@",timeArr[0],timeArr[1]];
        
    }else{
        
        return [NSString stringWithFormat:@"%@",timeArr[0]];
        
    }
    
    
    
}

/**
 * 根据时间Date返回字符串
 */
+ (NSString*)dateTodateString:(NSDate *)_date{
    
    NSDate *date =_date;
    
    NSTimeZone *timeZone =[NSTimeZone timeZoneWithName:@"UTC"];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc]init];
    
    ;
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    [dateFormatter setTimeZone:timeZone];
    
    NSString *fixString = [NSString new];
    fixString=[dateFormatter stringFromDate:date];
    
    return fixString;
    
}


/**
 根据时间字符串返回当前时间
 
 
 @return 当前时间
 */
+ (NSString *)getCurrentTime{
    
    NSDate *date = [NSDate date];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *currentDate = [NSString stringWithFormat:@"%@",[formatter stringFromDate:date]];
    
    return currentDate;
    
}

// 修改图片旋转问题
+(UIImage *) fixOrientationWithImage:(UIImage *)image {
    
    // No-op if the orientation is already correct
    if (image.imageOrientation == UIImageOrientationUp) return image;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch ((int)image.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
    }
    
    switch ((int)image.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                             CGImageGetBitsPerComponent(image.CGImage), 0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

+(NSString *) imageToPost:(UIImage *)_img imagePlanSize:(CGFloat)_imagePlanSize imageContentSize:(int)_contentSize
{
    if (_imagePlanSize < 0.000001) {
        return nil;
    }
    
    NSString *tmpDic = NSTemporaryDirectory();
    
    //以时间命名图片
    NSDate *date = [NSDate date];
    NSDateFormatter *formatDate = [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [formatDate setLocale:locale];
    [formatDate setDateFormat:@"yyyyMMddHHmmssSSS"];
    NSString* dateStr = [formatDate stringFromDate:date];
    
    NSString *imagelocalName_s = [NSString stringWithFormat:@"%@_s.jpg", dateStr];
    
    NSString *_image_Path  =  [tmpDic stringByAppendingPathComponent:imagelocalName_s];
    
    //    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
    
    CGFloat image_small_v = 0.8;
    UIImage *_image_s =  nil;
    
    if (_img.size.height*_img.size.width < _imagePlanSize) {//518400.0f = 720*720
        _image_s = _img;
    }else {
        
        CGSize _imageSize = CGSizeMake(720, 720);
        CGFloat lv = sqrt(_img.size.width*_img.size.height/_imagePlanSize);
        _imageSize.width = _img.size.width/lv ;
        _imageSize.height = _img.size.height/lv ;
        
        UIGraphicsBeginImageContext(_imageSize); // this will crop
        CGRect thumbnailRect = CGRectZero;
        thumbnailRect.origin = CGPointMake(0, 0);
        thumbnailRect.size.width= _imageSize.width + 10;
        thumbnailRect.size.height = _imageSize.height + 10;
        [_img drawInRect:thumbnailRect];
        _image_s = UIGraphicsGetImageFromCurrentImageContext();
        if(_image_s == nil)
            NSLog(@"could not scale image");
        //pop the context to get back to the default
        UIGraphicsEndImageContext();
    }
    NSData *imageData = UIImageJPEGRepresentation(_image_s, image_small_v);
    while (imageData.length > _contentSize  && image_small_v >0.01f) {
        CGFloat s = ((imageData.length/_contentSize) - 1.0f);
        if (s < 0.1f) {
            s = 0.1f;
        }else if( s < 0.5f && s > 0.1f){
            s = 0.2f;
        }else if( s > 0.5f && s < 1.0f){
            s = 0.4f;
        }else if(s > 1.0f){
            s = 0.6f;
        }
        image_small_v -= s;
        if (image_small_v < 0.001f) {
            image_small_v = 0.001f;
        }
        imageData =  UIImageJPEGRepresentation(_image_s, image_small_v);
    }
    [imageData writeToFile:_image_Path atomically:YES];
    
    return _image_Path;
}

+ (NSString *) dateByAddingMinutes: (NSInteger) timeInterval
{
    NSDate *newDate = [NSDate dateWithTimeIntervalSince1970:timeInterval/1000.0];
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
    });
    formatter.dateFormat = @"yyyy.MM.dd";
//    formatter.timeZone = [NSTimeZone systemTimeZone];
//    formatter.locale =[NSLocale currentLocale];
    return [formatter stringFromDate:newDate];
    
}

//字符串判空
+(BOOL) isBlankString:(NSString *)string {
    
    if (![string isKindOfClass:[NSString class]]) {
        return YES;
    }
    
    if (string == nil || string == NULL) {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([string isEqual:[NSNull null]]) {
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        return YES;
    }
    //    if (string.length==0) {
    //        return YES;
    //    }
    return NO;
}

//去掉发表文字前的回车符
+(NSString *)DelbeforeEnter:(NSString *)str1
{
    //    BOOL isStringtoSpace=YES;//是否是空格
    NSString *newstr = @"";
    NSString *strEnter =@"\n";
    NSString *string;
    for(int i =0;i<[str1 length];i++)    {
        string = [str1 substringWithRange:NSMakeRange(i, 1)];//抽取子字符
        if(![string isEqualToString:strEnter]){//判断是否为空格
            newstr = [str1 substringFromIndex:i];
            //            isStringtoSpace=NO; //如果是则改变 状态
            break;//结束循环
        }
    }
    return newstr;
    
}
//去掉发表文字后的回车符
+(NSString *)DelbehindEnter:(NSString *)str2
{
    NSString *newstr = @"";
    NSString *strEnter =@"\n";
    NSString *string;
    for(long i =[str2 length]-1;i>=0;i--)    {
        string = [str2 substringWithRange:NSMakeRange(i, 1)];//抽取子字符
        if(![string isEqualToString:strEnter]){//判断是否为空格和回车
            newstr = [str2 substringToIndex:(i + 1)];
            break;//结束循环
        }
    }
    return newstr;
    
}



@end
