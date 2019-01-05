//
//  NSString+JACategory.m
//  Jasmine
//
//  Created by xujin on 17/08/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "NSString+JACategory.h"

@implementation NSString (JACategory)

/// 等比缩放，限定在矩形框外:将图缩略成宽度为100，高度为100，按短边优先。
- (NSString *)ja_getFitImageStringWidth:(int)width height:(int)height {
    if (!self.length) {
        return @"";
    }
#if 0
    if ([self containsString:@"moli2017"] || [self containsString:@"file.xsawe.top"]) {
        width = (int)(width*);
        height = (int)(height*[UIScreen mainScreen].scale);
        
        NSString *fitImageString = [self stringByAppendingFormat:@"?x-oss-process=image/resize,m_mfit,h_%d,w_%d",height,width];
        return fitImageString;
    }
#endif
    // 抓取的图片不处理
    return self;
}


/// 固定宽高，自动裁剪:将图自动裁剪成宽度为100，高度为100的效果图
//- (NSString *)ja_getFillImageStringWidth:(int)width height:(int)height {
//    if (!self.length) {
//        return @"";
//    }
//    if ([self containsString:@"moli2017"] || [self containsString:@"file.xsawe.top"]) {
//        width = (int)(width*JA_SCREEN_SCALE);
//        height = (int)(height*JA_SCREEN_SCALE);
//        
//        NSString *fillImageString = [self stringByAppendingFormat:@"?x-oss-process=image/resize,m_fill,h_%d,w_%d",height,width];
//        return fillImageString;
//    }
//    // 抓取的图片不处理
//    return self;
//}

/// 生成指定位数的随机串
+ (NSString *)randomStringWithLength:(NSInteger)len {
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    for (NSInteger i = 0; i < len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex:(NSUInteger)arc4random_uniform((uint32_t)[letters length])]];
    }
    return randomString;
}

// 自定义加密
// 参数排序
+ (NSString *)sortKey:(NSMutableDictionary *)dicM
{
    NSString *paraStr = nil;
    
    NSArray *keys = [dicM allKeys];
    NSArray *sortedArray = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    
    for (NSString *categoryId in sortedArray) {
        
        NSString *str = [NSString stringWithFormat:@"%@",[dicM objectForKey:categoryId]];
        if (paraStr) {
            paraStr = [paraStr stringByAppendingString:str];
        }else{
            paraStr = str;
        }
    }
    
    return paraStr;
}

// 参数MD5 - 小写后 拼接 token  再MD5 后小写
//+ (NSString *)paraMd5:(NSString *)token para:(NSString *)para
//{
//
//    NSString *str = [para md5_origin];
//    NSString *str1 = [str stringByAppendingString:token];
//    NSString *str2 = [str1 md5_origin];
//
//    return str2;
//}

+ (NSString *)ja_getLibraryCachPath:(NSString *)fileName {
    if (!fileName.length) {
        return @"";
    }
//    NSArray* pathes = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
//    NSString *dictionaryPath = pathes.lastObject;
//    NSString *filePath = [dictionaryPath stringByAppendingPathComponent:fileName];
//    return filePath;
    
    NSString *dictionaryPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/MusicAndNewCount"];
    NSFileManager *filemanager = [NSFileManager defaultManager];
    if (![filemanager fileExistsAtPath:dictionaryPath]) {
        [filemanager createDirectoryAtPath:dictionaryPath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    NSString *filePath = [dictionaryPath stringByAppendingPathComponent:fileName];
    return filePath;
}

+ (NSString *)ja_getPlistFilePath:(NSString *)fileName {
    if (!fileName.length) {
        return @"";
    }
    NSString *dictionaryPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/Plist"];
    NSFileManager *filemanager = [NSFileManager new];
    if (![filemanager fileExistsAtPath:dictionaryPath]) {
        [filemanager createDirectoryAtPath:dictionaryPath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    NSString *filePath = [dictionaryPath stringByAppendingString:fileName];
    return filePath;
}

+ (NSString *)ja_getUploadImageFilePath:(NSString *)fileName {
    if (!fileName.length) {
        return @"";
    }
    NSString *dictionaryPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/UploadImage"];
    NSFileManager *filemanager = [NSFileManager new];
    if (![filemanager fileExistsAtPath:dictionaryPath]) {
        [filemanager createDirectoryAtPath:dictionaryPath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    NSString *filePath = [dictionaryPath stringByAppendingFormat:@"/%@",fileName];
    return filePath;
}

+ (NSString *)ja_getUploadVoiceFilePath:(NSString *)fileName {
    if (!fileName.length) {
        return @"";
    }
    NSString *dictionaryPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/UploadVoice"];
    NSFileManager *filemanager = [NSFileManager new];
    if (![filemanager fileExistsAtPath:dictionaryPath]) {
        [filemanager createDirectoryAtPath:dictionaryPath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    NSString *filePath = [dictionaryPath stringByAppendingFormat:@"/%@",fileName];
    return filePath;
}

+ (BOOL)ja_removeFilePath:(NSString *)filePath {
    if (!filePath.length) {
        return NO;
    }
    NSFileManager *filemanager = [NSFileManager new];
    if ([filemanager fileExistsAtPath:filePath]) {
        return [filemanager removeItemAtPath:filePath error:nil];
    }
    return NO;
}

+ (NSDateFormatter *)getSensorsAnalyticsDateFormat
{
    static NSDateFormatter *format;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    });
    return format;
}


+ (NSString *)getCurrentDateTimeString {
    NSDateFormatter *format = [self getSensorsAnalyticsDateFormat];
    return [format stringFromDate:[NSDate date]];
}


+ (int)getSeconds:(NSString *)timeString {
    NSString *strTime = timeString;
    NSArray *array = [strTime componentsSeparatedByString:@":"];
    if (array.count == 2) {
        NSString *MM= array.firstObject;
        NSString *ss = array.lastObject;
        NSInteger m = [MM integerValue];
        NSInteger s = [ss integerValue];
        int zonghms = (int)(m*60 +s);
        return zonghms;
    }else{
        NSString *ss = array.lastObject;
        NSInteger s = [ss integerValue];
        int zonghms = (int)(s);
        return zonghms;
    }
    
}

+ (NSString *)getStoryVoiceShowTime:(NSString *)time
{
    NSArray *timeArr = [time componentsSeparatedByString:@":"];
    if (timeArr.count == 2) {
        int min = [timeArr.firstObject intValue];
        int sec = [timeArr.lastObject intValue];
        return [NSString stringWithFormat:@"%02d:%02d",min,sec];
    }else{
        int sec = [timeArr.lastObject intValue];
        return [NSString stringWithFormat:@"%02d\"",sec];
    }
}

+ (NSString *)getShowTime:(NSString *)time
{
    NSArray *timeArr = [time componentsSeparatedByString:@":"];
    if (timeArr.count == 2) {
        int min = [timeArr.firstObject intValue];
        int sec = [timeArr.lastObject intValue];
        if (min > 0) {
            return [NSString stringWithFormat:@"%d'%02d\"",min,sec];
        }else{
            return [NSString stringWithFormat:@"%02d\"",sec];
        }
    }else{
        int sec = [timeArr.lastObject intValue];
        return [NSString stringWithFormat:@"%02d\"",sec];
    }
}

// 数目超过一万后的展示形式
+ (NSString *)convertCountStr:(NSString *)countStr {
    if ([countStr integerValue] > 0) {
        if (countStr.integerValue > 10000) {
            countStr = [NSString stringWithFormat:@"%.1fw",countStr.integerValue / 10000.0];
        }
    } else {
        countStr = @"0";
    }
    return countStr;
}

// 计算字符串的数目
+ (int)caculaterName:(NSString *)strtemp
{
    int strlength = 0;
    char* p = (char*)[strtemp cStringUsingEncoding:NSUnicodeStringEncoding];
    for (int i=0 ; i<[strtemp lengthOfBytesUsingEncoding:NSUnicodeStringEncoding] ;i++) {
        if (*p) {
            strlength++;
        }
        p++;
    }
    return (strlength+1)/2;
}
//将时间戳 转换为距离现在还有多少年日时
+(NSMutableArray *)convertToYMHWithTime:(NSString *)timeStr{
    
    
    NSMutableArray * array = [NSMutableArray arrayWithObjects:@"9",@"9",@"年",@"3",@"6",@"4",@"天",@"2",@"3",@"时",nil];
    
    if (!timeStr) {
        return array;
    }
    NSTimeInterval time=[timeStr doubleValue]/1000;//传入的时间戳str如果是精确到毫秒的记得要/1000
    
    //解封时间
    NSDate *PrisonDate = [NSDate dateWithTimeIntervalSince1970:time];
    //当前时间
    NSDate *nowDate = [NSDate date];
    
    //时间差
    NSTimeInterval timeDifference = [PrisonDate timeIntervalSinceDate:nowDate];
    
    NSTimeInterval hour = 60 * 60;//3600
    
    NSTimeInterval day = hour * 24;//86400
    
    NSTimeInterval year = day *365; //year 31536000
    
    if (timeDifference > year * 99) {
        return array;
    }

    //年
    int r0 = timeDifference / (year);
    if (r0 > 99) {
        return array;
    }
    array[0] = [NSString stringWithFormat:@"%d",r0/10];
    array[1] =  [NSString stringWithFormat:@"%d",r0 % 10];
    
    //日
    timeDifference  = timeDifference - r0 * year;
    int r1 = timeDifference / day;
    
    array[3] =  [NSString stringWithFormat:@"%d",r1/100];
    array[4] =  [NSString stringWithFormat:@"%d",(r1/10)%10];
    array[5] =  [NSString stringWithFormat:@"%d",r1%10];
    
    //时
    timeDifference = timeDifference - r1 * day;
    int r2 = timeDifference / hour;
    array[7] =  [NSString stringWithFormat:@"%d",r2/10];
    array[8] =  [NSString stringWithFormat:@"%d",r2%10];
    
    return array;
}
@end
