//
//  KDPermission.h
//  KDPermissionHelper
//
//  Created by mumu on 2019/1/15.
//  Copyright © 2019年 kd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KDPermission : NSObject

+ (KDPermission *)helper;


@property (nonatomic, assign) BOOL isAutoShowAlert;
/**
 是否已获取相册权限
 
 @return 结果
 */
- (BOOL)isGetLibraryPemission;
- (void)getLibraryPemission:(void(^)( BOOL isAuth))completion;

/**
 是否已获取位置权限
 
 @return 结果
 */
- (BOOL)isGetLocationPemission;
- (void)getLocationPemission:(void(^)( BOOL isAuth))completion;

/**
 是否已获取麦克风权限
 
 @return 结果
 */
- (BOOL)isGetAudioPemission;
- (void)getAudioPemission:(void(^)(BOOL isAuth))completion;

/**
 是否已获取相机权限
 
 @return 结果
 */
- (BOOL)isGetCameraPemission;
- (void)getCameraPemission:(void(^)(BOOL isAuth))completion;

/**
 是否已经获取通讯录权限
 
 @return 结果
 */
- (BOOL)isGetContactPemission;
- (void)getContactPemission:(void(^)(BOOL isAuth))completion;

- (void)alertPemissionTip:(NSString *)pemissionType;

@end

NS_ASSUME_NONNULL_END
