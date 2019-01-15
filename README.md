# KDPermission
iOS 申请判断系统权限

用法:
  引入
#import <KDPermission.h>

  调用
    [[KDPermission helper] getCameraPemission:^(BOOL isAuth) {
    
       
       if (isAuth) 
        {
         NSLog(@"去调起相机");
        }
    }];

block回调注意线程转换
info.plist必须要添加对应描述

    <key>NSCameraUsageDescription</key>
    <string>若不允许,您将无法拍摄照片和视频,也无法使用视频通话和扫码功能</string>
    <key>NSMicrophoneUsageDescription</key>
    <string>若不允许,您将无法发送语音消息或进行音视频通话</string>
    <key>NSPhotoLibraryUsageDescription</key>
    <string>若不允许,您将无法上传照片</string>
    <key>NSContactsUsageDescription</key>
    <string>若不允许,您将无法同步至通讯录</string>
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>若不允许,您将无法分享位置信息</string>
    <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
    <string>若不允许,您将无法分享位置信息</string>
