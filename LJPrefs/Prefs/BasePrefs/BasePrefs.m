//
//  BasePrefs.m
//  LJPrefs
//
//  Created by Geniune on 2016/12/14.
//  Copyright © 2016年 Geniune. All rights reserved.
//

#import "BasePrefs.h"

@implementation BasePrefs

/**
 在判断当前APP对应权限被限制时，引导用户去设置中打开对应设置
 */
+ (void)openPrivacySetting{
    
    if(iOSv10){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }else{
        NSURL *url = [NSURL URLWithString:[[self class] getPrefsURL]];
        if (url && [[UIApplication sharedApplication] canOpenURL:url])
        {
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}

/**
 获取当前权限对应设置目录的URL
 */
+ (NSString *)getPrefsURL{
    return @"";
}

/**
  判断当前APP是否获得该模块权限
 
  @param block YES：已获得，NO：未获得
 */
+ (void)adjustPrivacySettingEnable:(void(^)(BOOL pFlag))block{
    
    if(block){
        block(YES);
    }
}

@end
