//
//  PrefsMicrophone.m
//  LJPrefs
//
//  Created by Geniune on 2016/12/14.
//  Copyright © 2016年 Geniune. All rights reserved.
//

#import "PrefsMicrophone.h"

@implementation PrefsMicrophone

+ (NSString *)getPrefsURL{
    
    return @"prefs:root=Privacy&path=MICROPHONE";
}

+ (void)adjustPrivacySettingEnable:(void(^)(BOOL pFlag))block{
    
    if(block){
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(granted);
            });
        }];
    }
}

@end
