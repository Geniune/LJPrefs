//
//  PrefsPhoto.m
//  LJPrefs
//
//  Created by Geniune on 2016/12/14.
//  Copyright © 2016年 Geniune. All rights reserved.
//

#import "PrefsPhoto.h"

@implementation PrefsPhoto

+ (NSString *)getPrefsURL{
    
    return @"prefs:root=Privacy&path=PHOTOS";
}

+ (void)adjustPrivacySettingEnable:(void(^)(BOOL pFlag))block{
    
    if(block){
        //相册判断
        ALAuthorizationStatus authStatus = [ALAssetsLibrary authorizationStatus];
        if (authStatus == ALAuthorizationStatusDenied || authStatus == ALAuthorizationStatusRestricted) {
            block(NO);
        }else{
            block(YES);
        }
    }
}

@end
