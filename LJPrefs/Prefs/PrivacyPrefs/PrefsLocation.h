//
//  PrefsLocation.h
//  LJPrefs
//
//  Created by Geniune on 2016/12/14.
//  Copyright © 2016年 Geniune. All rights reserved.
//

#import "BasePrefs.h"
#import <CoreLocation/CLLocationManager.h>

typedef void (^MapLocationBlock)(CLLocation *location);

@interface PrefsLocation : BasePrefs

/*!
 @property
 @brief GPS服务实例方法
 */
+ (instancetype)sharedInstance;

/*!
 @method
 @brief 开始GPS定位,并返回地球坐标以及可阅读地理位置
 */
- (void)requetLocationblock:(MapLocationBlock)block;

@end
