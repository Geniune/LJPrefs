//
//  PrefsLocation.m
//  LJPrefs
//
//  Created by Geniune on 2016/12/14.
//  Copyright © 2016年 Geniune. All rights reserved.
//

#import "PrefsLocation.h"
#import "INTULocationManager.h"

@implementation PrefsLocation

+ (NSString *)getPrefsURL{
    
    return @"prefs:root=Privacy&path=LOCATION_SERVICES";
}

+ (void)adjustPrivacySettingEnable:(void(^)(BOOL pFlag))block{
    
    if(block){
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        // kCLAuthorizationStatusNotDetermined                  //用户尚未对该应用程序作出选择
        // kCLAuthorizationStatusRestricted                     //应用程序的定位权限被限制
        // kCLAuthorizationStatusAuthorizedAlways               //一直允许获取定位
        // kCLAuthorizationStatusAuthorizedWhenInUse            //在使用时允许获取定位
        // kCLAuthorizationStatusAuthorized                     //已废弃，相当于一直允许获取定位
        // kCLAuthorizationStatusDenied                         //拒绝获取定位
        if(![CLLocationManager locationServicesEnabled] || status == kCLAuthorizationStatusRestricted || status == kCLAuthorizationStatusDenied){
            block(NO);
        }else{
            block(YES);
        }
    }
}

 static PrefsLocation *_sharedInstance = nil;
+ (instancetype)sharedInstance{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [PrefsLocation new];
    });
    
    return _sharedInstance;
}

- (instancetype)init{
    
    if(self == [super init]){

    }
    return self;
}

- (void)requetLocationblock:(MapLocationBlock)block{
    
    [[INTULocationManager sharedInstance] requestLocationWithDesiredAccuracy:INTULocationAccuracyRoom timeout:5.0f block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
        if(block){
            block(currentLocation);
        }
    }];
}

@end
