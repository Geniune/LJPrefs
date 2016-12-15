//
//  PrefsAddressBook.m
//  LJPrefs
//
//  Created by Geniune on 2016/12/14.
//  Copyright © 2016年 Geniune. All rights reserved.
//

#import "PrefsAddressBook.h"

@implementation PrefsAddressBook

+ (NSString *)getPrefsURL{
    
    return @"prefs:root=Privacy&path=CONTACTS";
}

+ (void)adjustPrivacySettingEnable:(void(^)(BOOL pFlag))block{
    
    if(block){
        //通讯录判断
//        ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
        ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
        if(status == kABAuthorizationStatusRestricted || status == kABAuthorizationStatusDenied){
            block(NO);
        }else{
            block(YES);
        }
    }
}

@end
