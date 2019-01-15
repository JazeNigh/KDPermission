//
//  KDPermission.m
//  KDPermissionHelper
//
//  Created by mumu on 2019/1/15.
//  Copyright © 2019年 kd. All rights reserved.
//

#import "KDPermission.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import "AppDelegate.h"
#import <Contacts/Contacts.h>
#import <ContactsUI/ContactsUI.h>
#import <AddressBookUI/AddressBookUI.h>
#import <CoreLocation/CoreLocation.h>

// 需要拼接的本地化格式,str是需要拼接的字符
#define KDPermissionFormat(key,str) \
[NSString stringWithFormat:KDPermissionLocal(key),str]
#define KDPermissionLocal(key) \
KDPermissionLocalized(key, key)
#define KDPermissionLocalized(key, comment) \
NSLocalizedStringFromTableInBundle(key, @"KDPermission", [NSBundle bundleWithPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"KDPermission.bundle"]], nil)

#ifndef IS_IOS9_LATER
#define IS_IOS9_LATER ([[UIDevice currentDevice].systemVersion doubleValue]>=9.0)
#endif

typedef NS_ENUM(NSInteger, KDAuthorizationStatus)
{
    KDAuthorizationStatusNotDetermined = 0,// 未确定
    KDAuthorizationStatusRestricted ,//受限制
    KDAuthorizationStatusDenied ,//拒绝
    KDAuthorizationStatusAuthorized//已授权
};

@interface KDPermission ()<CLLocationManagerDelegate>

@property (nonatomic, copy) void (^completion)(BOOL isAuth);
@property (nonatomic, strong) CLLocationManager  *locationManager;

@end

@implementation KDPermission

+ (KDPermission *)helper
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}
- (instancetype)init
{
    self = [super init];
    if (self)
    {
        
    }
    return self;
}
// block回调
- (void)returnBlock:(BOOL)result type:(NSString *)typeName
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.completion)
        {
            self.completion(result);
            if (!result)
            {
                [self alertPemissionTip:typeName];
            }
        }
        self.completion = nil;
    });
    if (_locationManager)
    {
        _locationManager = nil;
    }
}

- (BOOL)isGetLibraryPemission
{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    return status == PHAuthorizationStatusAuthorized;
}

- (void)getLibraryPemission:(void(^)(BOOL isAuth))completion
{
    NSString *typeName = KDPermissionLocal(@"photos");
    _completion = completion;
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    switch (status)
    {
        case PHAuthorizationStatusAuthorized:
            [self returnBlock:YES type:typeName];
            break;
        case PHAuthorizationStatusNotDetermined:
        {
            __weak typeof(self) weakSelf = self;
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status){
                BOOL isGet = (status == PHAuthorizationStatusAuthorized);
                [weakSelf returnBlock:isGet type:typeName];
            }];
        }
            break;
        case PHAuthorizationStatusRestricted:
        case PHAuthorizationStatusDenied:
        {
            [self returnBlock:NO type:typeName];
        }
            break;
        default:
            [self returnBlock:NO type:typeName];
            break;
    }
}
- (BOOL)isGetLocationPemission
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    return ((kCLAuthorizationStatusAuthorizedWhenInUse == status) ||
            (kCLAuthorizationStatusAuthorizedAlways == status));
}
- (void)getLocationPemission:(void (^)(BOOL))completion
{
    NSString *typeName = KDPermissionLocal(@"location");
    
    _completion = completion;
    
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    switch (status)
    {
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        case kCLAuthorizationStatusAuthorizedAlways:
            [self returnBlock:YES type:typeName];
            break;
        case kCLAuthorizationStatusNotDetermined:
        {
            // 未选择
            _locationManager = [[CLLocationManager alloc] init];
            _locationManager.distanceFilter = 5;
            _locationManager.delegate = self;
            _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            //                [locationManager requestWhenInUseAuthorization];
            if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                [_locationManager requestWhenInUseAuthorization];
            }
        }
            break;
        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusDenied:
        {
            [self returnBlock:NO type:typeName];
        } break;
        default:
            [self returnBlock:NO type:typeName];
        break;
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (_completion && status != kCLAuthorizationStatusNotDetermined)
    {
        [self getLocationPemission:_completion];
    }
}
- (BOOL)isGetAudioPemission
{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    return status == AVAuthorizationStatusAuthorized;
}
- (void)getAudioPemission:(void(^)(BOOL isAuth))completion
{
    NSString *typeName = KDPermissionLocal(@"audio");
    
    _completion = completion;
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    
    switch (status) {
        case AVAuthorizationStatusAuthorized:
            [self returnBlock:YES type:typeName];
            break;
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted:
            [self returnBlock:NO type:typeName];
            break;
        case AVAuthorizationStatusNotDetermined:
        {
            __weak typeof(self) weakSelf = self;
            [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
                [weakSelf returnBlock:granted type:typeName];
            }];
        }
            break;
        default:
            [self returnBlock:NO type:typeName];
            break;
    }
}

- (BOOL)isGetCameraPemission
{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    return status == AVAuthorizationStatusAuthorized;
}
- (void)getCameraPemission:(void(^)(BOOL isAuth))completion
{
    NSString *typeName = KDPermissionLocal(@"camera");
    
    _completion = completion;
    
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    switch (status) {
        case AVAuthorizationStatusAuthorized:
            [self returnBlock:YES type:typeName];
            break;
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted:
            [self returnBlock:NO type:typeName];
            break;
        case AVAuthorizationStatusNotDetermined:
        {
            __weak typeof(self) weakSelf = self;
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                [weakSelf returnBlock:granted type:typeName];
            }];
        }
            break;
        default:
            [self returnBlock:NO type:typeName];
            break;
    }
}

/**
 是否已经获取通讯录权限
 
 @return 结果
 */
- (BOOL)isGetContactPemission
{
    KDAuthorizationStatus status = [self getContactStatus];
    return status == KDAuthorizationStatusAuthorized;
}

/**
 通讯录权限状态
 
 @return 具体的状态
 */
- (KDAuthorizationStatus)getContactStatus
{
    if (IS_IOS9_LATER)
    {
        CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
        switch (status) {
            case CNAuthorizationStatusNotDetermined:
                return KDAuthorizationStatusNotDetermined;
                break;
            case CNAuthorizationStatusRestricted:
                return KDAuthorizationStatusRestricted;
                break;
            case CNAuthorizationStatusDenied:
                return KDAuthorizationStatusDenied;
                break;
            case CNAuthorizationStatusAuthorized:
                return KDAuthorizationStatusAuthorized;
                break;
            default:
                return KDAuthorizationStatusDenied;
                break;
        }
    }
    else
    {
        ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
        switch (status) {
            case kABAuthorizationStatusNotDetermined:
                return KDAuthorizationStatusNotDetermined;
                break;
            case kABAuthorizationStatusRestricted:
                return KDAuthorizationStatusRestricted;
                break;
            case kABAuthorizationStatusDenied:
                return KDAuthorizationStatusDenied;
                break;
            case kABAuthorizationStatusAuthorized:
                return KDAuthorizationStatusAuthorized;
                break;
            default:
                return KDAuthorizationStatusDenied;
                break;
        }
    }
}
- (void)getContactPemission:(void(^)(BOOL isAuth))completion
{
    NSString *typeName = KDPermissionLocal(@"addressbook");
    
    _completion = completion;
    
    KDAuthorizationStatus status = [self getContactStatus];
    
    switch (status) {
        case KDAuthorizationStatusAuthorized:
            [self returnBlock:YES type:typeName];
            break;
        case KDAuthorizationStatusDenied:
        case KDAuthorizationStatusRestricted:
            [self returnBlock:NO type:typeName];
            break;
        case KDAuthorizationStatusNotDetermined:
        {
            __weak typeof(self) weakSelf = self;
            [self showAddressBookAuthrity:^(BOOL succeed) {
                [weakSelf returnBlock:succeed type:typeName];
            }];
        }
            break;
        default:
            break;
    }
}
- (void)showAddressBookAuthrity:(void(^)(BOOL bAuthrity))block
{
    if (IS_IOS9_LATER)
    {
        CNContactStore *store = [CNContactStore new];
        [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (block)
            {
                block(granted);
            }
        }];
    }
    else
    {
        ABAddressBookRef _abAddressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        
        ABAddressBookRequestAccessWithCompletion(_abAddressBook, ^(bool granted, CFErrorRef error){
            if (block)
            {
                block(granted);
            }
        });
    }
}

- (void)alertPemissionTip:(NSString *)pemissionType
{
    if (!_isAutoShowAlert)
    {
        return;
    }
    // 已经拒绝
    NSString *strTip = KDPermissionFormat(@"_get.sys.permission.of", pemissionType);
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:nil message:strTip preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionGoSet = [UIAlertAction actionWithTitle:KDPermissionLocal(@"go.setting") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]])
        {
            //跳转到系统设置界面
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
    }];
    [alertVc addAction:actionGoSet];
    
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:KDPermissionLocal(@"cancel") style:UIAlertActionStyleCancel handler:nil];
    [alertVc addAction:actionCancel];
    
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertVc animated:YES completion:^{
    }];
}

@end
