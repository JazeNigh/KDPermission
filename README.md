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

block回调


注意线程转换
注意循环引用

info.plist必须要添加对应描述

<string>App需要您的同意,才能访问日历</string>
<key>NSCameraUsageDescription</key>
<string>App需要您的同意,才能访问相机</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>App需要您的同意,才能始终访问位置</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>App需要您的同意,才能在使用期间访问位置</string>
<key>NSLocationUsageDescription</key>
<string>App需要您的同意,才能访问位置</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>App需要您的同意,才能在使用期间访问位置</string>
<key>NSMicrophoneUsageDescription</key>
<string>App需要您的同意,才能访问麦克风</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>App需要您的同意,才能访问语音识别</string>
<key>NSContactsUsageDescription</key>
<string>App需要您的同意,才能访问通讯录</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>App需要您的同意,才能访问相册</string>
<key>NSRemindersUsageDescription</key>
<string>App需要您的同意,才能访问提醒事项</string>
