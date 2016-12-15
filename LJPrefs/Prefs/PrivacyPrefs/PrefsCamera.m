//
//  PrefsCamera.m
//  LJPrefs
//
//  Created by Geniune on 2016/12/14.
//  Copyright © 2016年 Geniune. All rights reserved.
//

#import "PrefsCamera.h"

@implementation PrefsCamera

/**
 相机隐私对应设置中的目录地址
 */
+ (NSString *)getPrefsURL{
    
    return @"prefs:root=Privacy&path=CAMERA";
}

/**
 判断当前APP是否获得相机权限

 @param block YES：获得，NO：未获得
 */
+ (void)adjustPrivacySettingEnable:(void(^)(BOOL pFlag))block{
    
    if(block){
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
            block(NO);
        }else{
            block(YES);
        }
    }
}

@end
