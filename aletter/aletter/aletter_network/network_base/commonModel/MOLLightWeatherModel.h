//
//  MOLLightWeatherModel.h
//  aletter
//
//  Created by moli-2017 on 2018/8/13.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLBaseModel.h"

@interface MOLLightWeatherModel : MOLBaseModel
@property (nonatomic, strong) NSString *year;
@property (nonatomic, strong) NSString *month;
@property (nonatomic, strong) NSString *day;
@property (nonatomic, strong) NSString *week;
@property (nonatomic, strong) NSString *weather;
@end
