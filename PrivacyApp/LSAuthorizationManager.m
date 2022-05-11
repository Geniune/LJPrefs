//
//  LSAuthorizationManager.m
//  PrivacyApp
//
//  Created by Apple on 2019/11/25.
//  Copyright © 2019 Geniune. All rights reserved.
//

#import "LSAuthorizationManager.h"
#import <UIKit/UIKit.h>
#import <CoreTelephony/CTCellularData.h>
#import <StoreKit/StoreKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import <AVFoundation/AVCaptureDevice.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <CoreLocation/CLLocationManager.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <Contacts/Contacts.h>
#import <AddressBook/AddressBook.h>
#import <EventKit/EventKit.h>
#import <HealthKit/HealthKit.h>
#import <HomeKit/HomeKit.h>
#import <CoreMotion/CoreMotion.h>


/**
 *  单例宏方法
 *
 *  @param block
 *
 *  @return 返回单例
 */
#define DEFINE_SHARED_INSTANCE_USING_BLOCK(block) \
static dispatch_once_t pred = 0; \
static id _sharedObject = nil; \
dispatch_once(&pred, ^{ \
_sharedObject = block(); \
}); \
return _sharedObject; \

@interface LSAuthorizationManager ()<CLLocationManagerDelegate, CBCentralManagerDelegate, HMHomeManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CBCentralManager *bluetoothManager;
@property (nonatomic, strong) HKHealthStore *healthStore;
@property (nonatomic, strong) HMHomeManager *homeManager;
@property (nonatomic, strong) CMMotionActivityManager *motionActivityManager;

@end

@implementation LSAuthorizationManager

+ (LSAuthorizationManager *)sharedInstance{
    
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^{
        
        return [[self alloc] init];
    });
}

#pragma mark - Apple Music 音乐
- (void)checkAppleMusicAuthorization{

    //注意：Apple Music 需要iOS 9.3+
    if(@available(iOS 9.3, *)){
    
        SKCloudServiceAuthorizationStatus status = [SKCloudServiceController authorizationStatus];
        
        switch (status) {
            case SKCloudServiceAuthorizationStatusNotDetermined://用户尚未作出选择
            {
                DebugLog(@"用户还未作出选择，主动弹框询问");
                [SKCloudServiceController requestAuthorization:^(SKCloudServiceAuthorizationStatus status) {
                    
                    switch (status) {

                        case SKCloudServiceAuthorizationStatusRestricted://无权更改此应用程序状态，可能是因为家长控制等原因
                        {
                            DebugLog(@"无权更改此应用程序状态");
                        }
                            break;
                        case SKCloudServiceAuthorizationStatusDenied://用户明确拒绝日历权限
                        {
                            DebugLog(@"用户点击不允许");
                        }
                        break;
                        case SKCloudServiceAuthorizationStatusAuthorized://已获得权限
                        {
                            DebugLog(@"用户点击允许");
                        }
                        break;
                            
                        default:
                            break;
                    }
                }];
            }
                break;
            case SKCloudServiceAuthorizationStatusRestricted://无权更改此应用程序状态，可能是因为家长控制等原因
            {
                DebugLog(@"无权更改此应用程序状态");
            }
                break;
            case SKCloudServiceAuthorizationStatusDenied://用户明确拒绝日历权限
            {
                DebugLog(@"用户明确拒绝Apple Music权限");
            }
            break;
            case SKCloudServiceAuthorizationStatusAuthorized://已获得权限
            {
                DebugLog(@"已获得Apple Music权限");
            }
            break;
        }
    }else{
        
        DebugLog(@"Apple Music 需要iOS 9.3以上版本");
    }
}

#pragma mark - Calendars 日历
- (void)checkCalendarsAuthorization{
    
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    
    switch (status) {
        case EKAuthorizationStatusNotDetermined://用户尚未作出选择
        {
            DebugLog(@"用户还未作出选择，主动弹框询问");
            EKEventStore *store = [[EKEventStore alloc] init];
            [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError * _Nullable error) {
                
                if(error){
                    DebugLog(@"error:%@",error);
                }else{
                    
                    if(granted){
                        //用户点击了“允许”
                        DebugLog(@"用户点击允许");
                    }else{
                        //用户点击了“不允许”
                        DebugLog(@"用户点击不允许");
                    }
                }
            }];
        }
            break;
        case EKAuthorizationStatusRestricted://无权更改此应用程序状态，可能是因为家长控制等原因
        {
            DebugLog(@"无权更改此应用程序状态");
        }
            break;
        case EKAuthorizationStatusDenied://用户明确拒绝日历权限
        {
            DebugLog(@"用户明确拒绝日历权限");
            //可以向用户做一个友好的提示，引导其去“设置”中打开日历权限
        }
            break;
        case EKAuthorizationStatusAuthorized://已获得权限，可使用日历
        {
            DebugLog(@"已获得日历权限");
        }
            break;
    }
}

#pragma mark - Bluetooth 蓝牙
- (void)checkBluetoothAuthorization{
    
    //这里需要注意：
    //如果你用的Xcode版本小于11.0，Deployment Target < iOS 13.0，则在info.plist中使用Privacy - Bluetooth Peripheral Usage Description（NSBluetoothPeripheralUsageDescription）
    //如果你用的Xcode版本是11.0以上，Deployment Target >= iOS 13.0，则在info.plist中使用Privacy - Privacy - Bluetooth Always Usage Description（NSBluetoothAlwaysUsageDescription）
    //若不按照上述方式操作，打包提交构建版本时，处理阶段会被打回，原因为：Missing Purpose String in info.plist
    
    if(!_bluetoothManager){
        
        _bluetoothManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }
    
    if(@available(iOS 13, *)){//iOS 13+ 使用CBManagerAuthorization
        
        [self checkCBManagerAuthorization:_bluetoothManager.authorization];
    }else if(@available(iOS 10, *)){//iOS 10 - 13 使用CBManagerState
        
        [self checkCBManagerState:_bluetoothManager.state];
    }else{
        
    }
}

/*!
*  @enum CBManagerAuthorization
*
*  @discussion Represents the current authorization state of a CBManager.
*
*  @constant CBManagerAuthorizationStatusNotDetermined            User has not yet made a choice with regards to this application.
*  @constant CBManagerAuthorizationStatusRestricted            This application is not authorized to use bluetooth. The user cannot change this application’s status,
*                                                                 possibly due to active restrictions such as parental controls being in place.
*  @constant CBManagerAuthorizationStatusDenied                User has explicitly denied this application from using bluetooth.
*  @constant CBManagerAuthorizationStatusAuthorizedAlways        User has authorized this application to use bluetooth always.
*
*/
//typedef NS_ENUM(NSInteger, CBManagerAuthorization) {
//    CBManagerAuthorizationNotDetermined = 0,
//    CBManagerAuthorizationRestricted,
//    CBManagerAuthorizationDenied,
//    CBManagerAuthorizationAllowedAlways
//} NS_ENUM_AVAILABLE(10_15, 13_0);

//iOS 13使用CBManagerAuthorization

- (void)checkCBManagerAuthorization:(CBManagerAuthorization)state NS_AVAILABLE(10_15, 13_0){
    
    switch (state) {
        case CBManagerAuthorizationNotDetermined://用户尚未作出选择
            {
                DebugLog(@"用户尚未作出选择");
            }
            break;
        case CBManagerAuthorizationRestricted://无权使用蓝牙，可能是因为家长控制等原因
           {
               DebugLog(@"无权更改此应用程序状态");
           }
           break;
        case CBManagerAuthorizationDenied://用户明确拒绝授权蓝牙权限
        {
            DebugLog(@"用户明确拒绝蓝牙权限");
            //可以向用户做一个友好的提示，引导其去“设置”中打开定位功能
        }
        break;
        case CBManagerAuthorizationAllowedAlways://蓝牙可用
        {
            DebugLog(@"已获得蓝牙权限");
        }
        break;
    }
}

/*!
*  @enum CBManagerState
*
*  @discussion Represents the current state of a CBManager.
*
*  @constant CBManagerStateUnknown       State unknown, update imminent.
*  @constant CBManagerStateResetting     The connection with the system service was momentarily lost, update imminent.
*  @constant CBManagerStateUnsupported   The platform doesn't support the Bluetooth Low Energy Central/Client role.
*  @constant CBManagerStateUnauthorized  The application is not authorized to use the Bluetooth Low Energy role.
*  @constant CBManagerStatePoweredOff    Bluetooth is currently powered off.
*  @constant CBManagerStatePoweredOn     Bluetooth is currently powered on and available to use.
*
*    @seealso  authorization
*/
//typedef NS_ENUM(NSInteger, CBManagerState) {
//    CBManagerStateUnknown = 0,
//    CBManagerStateResetting,
//    CBManagerStateUnsupported,
//    CBManagerStateUnauthorized,
//    CBManagerStatePoweredOff,
//    CBManagerStatePoweredOn,
//} NS_ENUM_AVAILABLE(10_13, 10_0);

//iOS 10 - 13使用CBManagerState
- (void)checkCBManagerState:(CBManagerState)state NS_AVAILABLE(10_13, 10_0){

    switch (state) {
        case CBManagerStateUnknown://蓝牙状态未知
        {
            DebugLog(@"蓝牙状态未知");
        }
            break;
        case CBManagerStateResetting://蓝牙状态未知
        {
            DebugLog(@"与系统连接的蓝牙丢失");
        }
            break;
        case CBManagerStateUnsupported://设备不支持蓝牙
        {
            DebugLog(@"当前设备不支持蓝牙");
        }
            break;
        case CBManagerStateUnauthorized://用户明确拒绝授权蓝牙权限
        {
            DebugLog(@"用户明确拒绝蓝牙权限");
            //可以向用户做一个友好的提示，引导其去“设置”中打开蓝牙权限
        }
            break;
        case CBManagerStatePoweredOff://蓝牙当前处于“关闭”状态
        {
            DebugLog(@"蓝牙处于关闭状态");
        }
            break;
        case CBManagerStatePoweredOn://蓝牙当前处于“打开”状态且可供使用
        {
            DebugLog(@"蓝牙处于打开状态，且已获得蓝牙权限");
        }
            break;
    }
}

#pragma mark - CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    
    [self checkCBManagerState:central.state];
}


#pragma mark - Camera 相机
- (void)checkCameraAuthorization{
    
    //查询当前设备是否可以打开相机，例如当App运行在模拟器上的话就会判断为NO
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        //判断当前App的AVAuthorizationStatus，注意这个枚举类型需要iOS 7以上才可以使用
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        
        switch (status) {
            case AVAuthorizationStatusNotDetermined://用户尚未作出选择
            {
                DebugLog(@"用户还未作出选择，主动弹框询问");
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {

                    if(granted){
                        //用户点击“允许”
                        DebugLog(@"用户点击允许");
                    }else{
                        //用户点击“不允许”
                        DebugLog(@"用户点击不允许");
                    }
                }];
            }
                break;
            case AVAuthorizationStatusRestricted://无权更改此应用程序状态，可能是因为家长控制等原因
            {
                DebugLog(@"无权更改此应用程序状态");
            }
                break;
            case AVAuthorizationStatusDenied://用户明确拒绝相机权限
            {
                DebugLog(@"用户明确拒绝相机权限");
                //这里可以向用户做一个友好的提示，引导其去“设置”中打开日历权限
            }
                break;
            case AVAuthorizationStatusAuthorized:
            {
                //已授权，可以直接调用UIImagePickerController进行拍照、视频录像
                DebugLog(@"已获取相机权限");
            }
                break;
        }
    }else{
        
        DebugLog(@"当前设备不支持打开相机，请检查是否使用真机测试");
    }
}

#pragma mark - Photos 相册
- (void)checkPhotosAuthorization{
    
    //查询当前设备是否支持打开相册
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];//注意PHAuthorizationStatus枚举需iOS 8以上才可以使用，iOS 7需替换为ALAuthorizationStatus
        [self checkPhotoAuthorizationStatus:status];
    }else{
        
        DebugLog(@"当前设备不支持打开相册");
    }
}

- (void)checkPhotoAuthorizationStatus:(PHAuthorizationStatus)authorization{
    
    switch (authorization) {
            
        case PHAuthorizationStatusNotDetermined://用户尚未作出选择
        {
            DebugLog(@"用户还未作出选择，主动弹框询问");
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                
                [self checkPhotoAuthorizationStatus:status];
            }];
        }
            break;
        case PHAuthorizationStatusRestricted:
        {
            DebugLog(@"无权更改此应用程序状态");
        }
            break;
        case PHAuthorizationStatusDenied:
        {
            DebugLog(@"用户明确拒绝相册权限");
        }
            break;
        case PHAuthorizationStatusAuthorized:
        {
            //已授权
            DebugLog(@"已获取相册权限");
        }
            break;
        case PHAuthorizationStatusLimited:
        {
            DebugLog(@"iOS 14新推出的的权限");
        }
            break;
    }
}

#pragma mark - Location 定位
- (void)checkLocationAuthorization{
    
    //查询当前设备是否已打开定位服务
    if(![CLLocationManager locationServicesEnabled]){
        //定位服务不可用
        //出现这个情况是手机设置中的“隐私-定位服务”被关闭了，这个开关一旦关掉所有app都无法获取到定位
        DebugLog(@"定位服务不可用");
    }else{
        
        //判断当前App定位权限状态
        [self checkLocationManagerState:[CLLocationManager authorizationStatus]];
    }
}

- (void)requestLocationAuthorization{
    
    if(!_locationManager){
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
    }
    
    //iOS 8.0+支持两种定位模式：
    //(1) [locationManager requestWhenInUseAuthorization]; App使用过程中定位
    //(2) [locationManager requestAlwaysAuthorization]; 持续定位，支持App进入后台后仍持续获取定位信息
    //注意！使用后台持续定位功能需要对应匹配的业务，否则审核会被拒绝，如果你的应用并非类似导航app，请选择前者
    [_locationManager requestWhenInUseAuthorization];
//    [_locationManager requestAlwaysAuthorization];
}

#pragma mark - CLLocationManagerDelegate
//iOS 14之前
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
 
    //CLLocationManagerDelegate回调，CLAuthorizationStatus更新：
    [self checkLocationManagerState:status];
}

//iOS 14之后
- (void)locationManagerDidChangeAuthorization:(CLLocationManager *)manager{
    if(@available(iOS 14, *)){
        [self checkLocationManagerState:manager.authorizationStatus];
    }
}

- (void)checkLocationManagerState:(CLAuthorizationStatus)status{

    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
        {
            DebugLog(@"用户还未作出选择，主动弹框询问");
            //当前用户还未选择，可以让App主动弹询问用户是否允许
            [self requestLocationAuthorization];
        }
            break;
        case kCLAuthorizationStatusRestricted:
        {
            DebugLog(@"无权更改此应用程序状态");
        }
            break;
        case kCLAuthorizationStatusDenied:
        {
            DebugLog(@"用户明确拒绝定位权限");
            //无权限，可以向用户做一个友好的提示，引导其去“设置”中打开定位功能
        }
            break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        {
            DebugLog(@"已获取定位权限：WhenInUseAuthorization");
//            [_locationManager requestLocation];
        }
            break;
        case kCLAuthorizationStatusAuthorizedAlways:
        {
            DebugLog(@"已获取定位权限：AlwaysAuthorization");
        }
            break;
//        case kCLAuthorizationStatusAuthorized://已授权定位服务（iOS 8.0起这个枚举被废弃）
//        {
//        }
//            break;
    }
}

#pragma mark - Contacts 联系人
- (void)checkContactsAuthorization{
        
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    
    switch (status) {
        case CNAuthorizationStatusNotDetermined://用户尚未作出选择
        {
            DebugLog(@"用户还未作出选择，主动弹框询问");
            CNContactStore *contactStore = [[CNContactStore alloc] init];
            [contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
               
                if(error){
                    DebugLog(@"error:%@",error);
                }else{
                    if(granted){
                        //用户点击了“允许”
                        DebugLog(@"用户点击允许");
                    }else{
                        //用户点击了“不允许”
                        DebugLog(@"用户点击不允许");
                    }
                }
            }];
            
        }
            break;
        case CNAuthorizationStatusRestricted://无权更改此应用程序状态，可能是因为家长控制等原因
        {
            DebugLog(@"无权更改此应用程序状态");
        }
            break;
        case CNAuthorizationStatusDenied://用户明确拒绝访问联系人权限
        {
            DebugLog(@"用户明确拒绝联系人权限");
            //可以向用户做一个友好的提示，引导其去“设置”中打开联系人权限
        }
            break;
        case CNAuthorizationStatusAuthorized://已获得权限，可访问联系人数据
        {
            DebugLog(@"已获取联系人权限");
        }
            break;
    }
}

#pragma mark - Health 健康
- (void)checkHealthAuthorization{
    
    //注意：Health 需要iOS 8.0+
    if([HKHealthStore isHealthDataAvailable]){
        
        if(!_healthStore){
            _healthStore = [[HKHealthStore alloc] init];
        }
        
        //例如获取步数
        HKQuantityType *stepCountType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
        HKAuthorizationStatus status = [self.healthStore authorizationStatusForType:stepCountType];
        
        switch (status) {
            case HKAuthorizationStatusNotDetermined://用户尚未作出选择
            {
                DebugLog(@"用户还未作出选择，主动弹框询问");
                NSSet *typeSet = [NSSet setWithObject:stepCountType];
                [self.healthStore requestAuthorizationToShareTypes:typeSet readTypes:typeSet completion:^(BOOL success, NSError * _Nullable error) {
                    
                    if(error){
                        DebugLog(@"error:%@", error);
                    }else{
                        if(success){
                            //用户点击了“允许”
                            DebugLog(@"用户点击允许");
                        }else{
                            //用户点击了“不允许”
                            DebugLog(@"用户点击不允许");
                        }
                    }
                }];
            }
                break;
            case HKAuthorizationStatusSharingDenied://用户明确拒绝健康权限
            {
                DebugLog(@"用户明确拒绝健康权限");
                //可以向用户做一个友好的提示，引导其去“设置”中打开联系人权限
            }
                break;
            case HKAuthorizationStatusSharingAuthorized://已获得健康权限
            {
                DebugLog(@"已获取健康权限");
            }
                break;
        }
    }
}

#pragma mark - Home Kit
- (void)checkHomeKitAuthorization{
    
    //注意：需要iOS 8.0以上版本才支持Health Kit
    if(!_homeManager){
        _homeManager = [[HMHomeManager alloc] init];
        _homeManager.delegate = self;
    }
}

#pragma mark - HMHomeManagerDelegate
- (void)homeManagerDidUpdateHomes:(HMHomeManager *)manager{
    
    if(manager.homes.count > 0){
        
        DebugLog(@"当前已有HMHome对象存在");
        DebugLog(@"已获取Home Kit权限");
    }else{
        
        DebugLog(@"当前暂无HMHome对象");
        __weak HMHomeManager *weakHomeManager = manager;
        [manager addHomeWithName:@"我的家" completionHandler:^(HMHome * _Nullable home, NSError * _Nullable error) {
            
            if(error){
                if(error.code == HMErrorCodeHomeAccessNotAuthorized){
                    DebugLog(@"用户明确拒绝Home Kit权限");
                }else{
                    DebugLog(@"error:%@", error);
                }
            }else{
                DebugLog(@"已获取Home Kit权限");
            }
            
            if (home) {
                [weakHomeManager removeHome:home completionHandler:^(NSError * _Nullable error) {
                    // ... do something with the result of removing the home ...
                }];
            }
        }];
    }
}

#pragma mark - Microphone 麦克风
- (void)checkMicrophoneAuthorization{
    
    if(@available(iOS 8, *)){
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
        
        switch (status) {
            case AVAuthorizationStatusNotDetermined://用户尚未作出选择
            {
                DebugLog(@"用户还未作出选择，主动弹框询问");
                [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
                    if (granted) {
                        //用户点击了“允许”
                        DebugLog(@"用户点击允许");
                    }else{
                        //用户点击了“不允许”
                        DebugLog(@"用户点击不允许");
                    }
                }];
            }
                break;
            case AVAuthorizationStatusRestricted://无权更改此应用程序状态，可能是因为家长控制等原因
            {
                DebugLog(@"无权更改此应用程序状态");
            }
                break;
            case AVAuthorizationStatusDenied://用户明确拒绝麦克风权限
            {
                DebugLog(@"用户明确拒绝麦克风权限");
                //可以向用户做一个友好的提示，引导其去“设置”中打开麦克风权限
            }
                break;
            case AVAuthorizationStatusAuthorized://已获得权限，可使用麦克风
            {
                DebugLog(@"已获取麦克风权限");
            }
                break;
        }
    }
}

#pragma mark - Motion 运动与健身
- (void)checkMotionAuthorization{
    
    //由CoreMotion提供，需要iOS 7及更高版本，并且要求设备有协处理器（iPhone 5s及之后的设备都支持）
    if(@available(iOS 7, *)){
 
        if(![CMMotionActivityManager isActivityAvailable]){
            
            DebugLog(@"运动与健身无法使用");
            return;
        }
        
        if(!_motionActivityManager){
            _motionActivityManager = [[CMMotionActivityManager alloc]init];
        }
        
        [_motionActivityManager startActivityUpdatesToQueue:[[NSOperationQueue alloc] init] withHandler:^(CMMotionActivity * _Nullable activity) {
           
             DebugLog(@"当前状态：");
            if(activity.unknown){
                DebugLog(@"状态未知");
            }else if(activity.walking){
                DebugLog(@"步行");
            }else if(activity.running){
                DebugLog(@"跑步");
            }else if(activity.automotive){
                DebugLog(@"驾车");
            }else if(activity.stationary){
                DebugLog(@"静止");
            }
            
            DebugLog(@"准确度：");
            if(activity.confidence == CMMotionActivityConfidenceLow){
                DebugLog(@"低");
             }else if(activity.confidence == CMMotionActivityConfidenceMedium){
                DebugLog(@"中");
             }else if(activity.confidence == CMMotionActivityConfidenceHigh){
                DebugLog(@"高");
             }
            
            [_motionActivityManager stopActivityUpdates];
        }];

    }else{
        
        DebugLog(@"当前设备或系统版本不支持Motion");
    }
}

#pragma mark - Reminders 提醒事项
- (void)checkRemindersAuthorization{
    
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder];
    
    switch (status) {
        case EKAuthorizationStatusNotDetermined:
        {
            EKEventStore *store = [[EKEventStore alloc] init];
            [store requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError * _Nullable error) {
                
                if(error){
                    DebugLog(@"error:%@", error);
                }else{
                    if (granted) {
                        //用户点击了“允许”
                        DebugLog(@"用户点击允许");
                    }else{
                        //用户点击了“不允许”
                        DebugLog(@"用户点击不允许");
                    }
                }
            }];
        }
            break;
        case EKAuthorizationStatusRestricted:
        {
            DebugLog(@"无权更改此应用程序状态");
        }
            break;
        case EKAuthorizationStatusDenied://用户明确拒绝提醒事项权限
        {
            DebugLog(@"用户明确拒绝提醒事项权限");
        }
            break;
        case EKAuthorizationStatusAuthorized:
        {
            DebugLog(@"已获取提醒事项权限");
        }
            break;
        
    }
}

#pragma mark - Siri
- (void)checkSiriAuthorization{

    //TODO:Siri待完善
}
    
@end
