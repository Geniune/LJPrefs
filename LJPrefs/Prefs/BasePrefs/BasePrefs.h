//
//  BasePrefs.h
//  LJPrefs
//
//  Created by Geniune on 2016/12/14.
//  Copyright © 2016年 Geniune. All rights reserved.
//


#define iOS_V               [[[UIDevice currentDevice] systemVersion] floatValue]
#define iOSv10              (iOS_V >= 10.0)
#define iOSv8                (iOS_V >= 8.0)

@interface BasePrefs : NSObject

/**
 获取当前权限对应设置内的URL

 @return 字符串类型，注意判断是否为空
 */
+ (NSString *)getPrefsURL;

/**
 打开当前硬件对应设置URL
 */
+ (void)openPrivacySetting;

/**
 判断当前隐私权限是否已获取

 @param block YES:已获取 NO:未获取
 */
+ (void)adjustPrivacySettingEnable:(void(^)(BOOL pFlag))block;

@end
