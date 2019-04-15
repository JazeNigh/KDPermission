//
//  KDPermission.h
//  KDPermissionHelper
//
//  Created by mumu on 2019/1/15.
//  Copyright © 2019年 kd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KDPermission : NSObject


/**
 单例

 @return 单例
 */
+ (KDPermission *)helper;

/**
 自动展示权限被拒绝去系统设置的alert,默认NO不展示
 */
@property (nonatomic, assign) BOOL AutoShowAlert;

/**
 获取通相册权限
 
 @param completion 回调
 */
- (void)getLibraryPermission:(void(^)( BOOL isAuth))completion;
- (BOOL)isGetLibraryPermission;

/**
 获取通相机权限
 
 @param completion 回调
 */
- (void)getCameraPermission:(void(^)(BOOL isAuth))completion;
- (BOOL)isGetCameraPermission;

/**
 获取通麦克风权限
 
 @param completion 回调
 */
- (void)getAudioPermission:(void(^)(BOOL isAuth))completion;
- (BOOL)isGetAudioPermission;

/**
 获取通位置权限
 
 @param completion 回调
 */
- (void)getLocationPermission:(void(^)( BOOL isAuth))completion;
- (BOOL)isGetLocationPermission;

/**
 获取通位置权限(WhenInUse)
 
 @param completion 回调
 */
- (void)getLocationWhenInUsePermission:(void(^)( BOOL isAuth))completion;
- (BOOL)isGetLocationWhenInUsePermission;

/**
 获取语音识别权限
 
 @param completion 回调
 */
- (void)getSpeechRecognizerPermission:(void(^)( BOOL isAuth))completion API_AVAILABLE(ios(10.0));
- (BOOL)isGetSpeechRecognizerPermission API_AVAILABLE(ios(10.0));

/**
 获取通讯录权限
 
 @param completion 回调
 */
- (void)getContactPermission:(void(^)(BOOL isAuth))completion;
- (BOOL)isGetContactPermission;

/**
 获取日历权限
 
 @param completion 回调
 */
- (void)getCalendarPermission:(void(^)(BOOL isAuth))completion;
- (BOOL)isGetCalendarPermission;

#pragma mark ====================   Reminder    ====================

/**
 获取提醒事项权限
 
 @param completion 回调
 */
- (void)getReminderPermission:(void(^)(BOOL isAuth))completion;
- (BOOL)isGetReminderPermission;

/**
 获取通知权限
 
 默认把UNUserNotificationCenterDelegate复制给[UIApplication sharedApplication].delegate,请手动实现相关代理处理推送消息
 如果更改请设置[UNUserNotificationCenter currentNotificationCenter].delegate
 
 ios10以下的不会自动申请权限,需要调用getNotificationPermissionBelow10 提前手动申请通知权限

 @param completion 回调
 */
- (void)getNotificationPermission:(void(^)(BOOL isAuth))completion;

/**
 手动申请通知权限,低于ios10的
 */
- (void)getNotificationPermissionBelow10 NS_DEPRECATED_IOS(8_0, 10_0, "Use [KDPermission getNotificationPermission:]");


@end
