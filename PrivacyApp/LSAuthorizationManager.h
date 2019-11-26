//
//  LSAuthorizationManager.h
//  PrivacyApp
//
//  Created by Apple on 2019/11/25.
//  Copyright © 2019 Geniune. All rights reserved.
//

#import <Foundation/Foundation.h>

#define AUTHORIZATIONMANAGER [LSAuthorizationManager sharedInstance]

@interface LSAuthorizationManager : NSObject

//全局管理对象
+ (LSAuthorizationManager *)sharedInstance;

//Apple Music
- (void)checkAppleMusicAuthorization;
//Bluetooth
- (void)checkBluetoothAuthorization;
//Calendars
- (void)checkCalendarsAuthorization;
//Camera
- (void)checkCameraAuthorization;
//Contacts
- (void)checkContactsAuthorization;
//Health
- (void)checkHealthAuthorization;
//Home
- (void)checkHomeKitAuthorization;
//Location
- (void)checkLocationAuthorization;
//Microphone
- (void)checkMicrophoneAuthorization;
//Motion
- (void)checkMotionAuthorization;
//Photos
- (void)checkPhotosAuthorization;
//Reminders
- (void)checkRemindersAuthorization;
//Siri
- (void)checkSiriAuthorization;

@end


