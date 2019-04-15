//
//  KDPermission.m
//  KDPermissionHelper
//
//  Created by mumu on 2019/1/15.
//  Copyright © 2019年 kd. All rights reserved.
//

#import "KDPermission.h"
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import <Contacts/Contacts.h>
#import <ContactsUI/ContactsUI.h>
#import <AddressBookUI/AddressBookUI.h>
#import <CoreLocation/CoreLocation.h>
#import <UserNotifications/UserNotifications.h>
#import <CoreTelephony/CTCellularData.h>
#import <Speech/SFSpeechRecognitionTaskHint.h>
#import <Speech/Speech.h>
#import <EventKit/EventKit.h>
#import <HealthKit/HealthKit.h>


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

#ifndef IS_IOS10_LATER
#define IS_IOS10_LATER ([[UIDevice currentDevice].systemVersion doubleValue]>=10.0)
#endif

typedef NS_ENUM(NSInteger, KDAuthorizationStatus)
{
    KDAuthorizationStatusNotDetermined = 0,// 未确定
    KDAuthorizationStatusRestricted ,//受限制
    KDAuthorizationStatusDenied ,//拒绝
    KDAuthorizationStatusAuthorized//已授权
};

@interface KDPermission ()<CLLocationManagerDelegate>

@property (nonatomic, copy) void (^locationCompletion)(BOOL isAuth);
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
    if (sharedInstance)
    {
        [sharedInstance resetStatus];
    }
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

- (void)resetStatus
{
    _locationCompletion = nil;
    if (_locationManager)
    {
        _locationManager = nil;
    }
}

#pragma mark ====================   block    ====================

// block回调
- (void)returnBlock:(BOOL)result type:(NSString *)typeName completion:(void(^)(BOOL isAuth))completion
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (completion)
        {
            completion(result);
        }
    });

    if (!result)
    {
        [self alertPermissionTip:typeName];
    }

    [self resetStatus];
}

#pragma mark ====================   net    ====================

///**
// 查看是否有网络权限
// 
// @param completion 回调(比较特殊,第一次的请求网络权限不受此控制,这个方法仅能用于提示用户有没有权限)
// */
//- (void)getNetPermission:(void(^)(BOOL isAuth))completion
//{
//    NSString *typeName = KDPermissionLocal(@"net");
//
//    if (IS_IOS9_LATER)
//    {
//        CTCellularData *cellularData = [[CTCellularData alloc] init];
//        
//        __weak typeof(self) weakSelf = self;
//        cellularData.cellularDataRestrictionDidUpdateNotifier =  ^(CTCellularDataRestrictedState state){
//            [weakSelf returnBlock:state == kCTCellularDataNotRestricted  type:typeName completion:completion];
//        };
//    }
//    else
//    {
//        [self returnBlock:YES type:typeName completion:completion];
//    }
//}

#pragma mark ====================   health    ====================


/**
 健康

 @param identifier 类型(如步数HKQuantityTypeIdentifierStepCount)
 @param completion 回调
 */
- (void)getHealthPermission:(HKQuantityTypeIdentifier)identifier completion:(void(^)(BOOL isAuth))completion
{
    // 1.判断设备是否支持HealthKit框架
    
    NSString *typeName = KDPermissionLocal(@"health");

    if ([HKHealthStore isHealthDataAvailable])
    {
        
        HKHealthStore *healthStore = [[HKHealthStore alloc] init];
        HKObjectType *hkObjectType = [HKObjectType quantityTypeForIdentifier:identifier];
        HKAuthorizationStatus status = [healthStore authorizationStatusForType:hkObjectType];
        
        switch (status)
        {
            case HKAuthorizationStatusSharingAuthorized:
                [self returnBlock:YES type:typeName completion:completion];
                break;
            case HKAuthorizationStatusNotDetermined:
            {
                __weak typeof(self) weakSelf = self;
                
                HKQuantityType  *step = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
                HKQuantityType *distance = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
                [healthStore requestAuthorizationToShareTypes:nil readTypes:[NSSet setWithObjects:step,distance, nil] completion:^(BOOL success, NSError * _Nullable error) {
                    [weakSelf returnBlock:success type:typeName completion:completion];
                }];
            }
                break;
            case HKAuthorizationStatusSharingDenied:
            {
                [self returnBlock:NO type:typeName completion:completion];
            }
                break;
            default:
                [self returnBlock:NO type:typeName completion:completion];
                break;
        }
    }
    else
    {
        [self returnBlock:NO type:typeName completion:completion];
    }
}

#pragma mark ====================   Library    ====================

- (BOOL)isGetLibraryPermission
{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    return status == PHAuthorizationStatusAuthorized;
}

- (void)getLibraryPermission:(void(^)(BOOL isAuth))completion
{
    NSString *typeName = KDPermissionLocal(@"photos");
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    switch (status)
    {
        case PHAuthorizationStatusAuthorized:
            [self returnBlock:YES type:typeName completion:completion];
            break;
        case PHAuthorizationStatusNotDetermined:
        {
            __weak typeof(self) weakSelf = self;
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status){
                BOOL isGet = (status == PHAuthorizationStatusAuthorized);
                [weakSelf returnBlock:isGet type:typeName completion:completion];
            }];
        }
            break;
        case PHAuthorizationStatusRestricted:
        case PHAuthorizationStatusDenied:
        {
            [self returnBlock:NO type:typeName completion:completion];
        }
            break;
        default:
            [self returnBlock:NO type:typeName completion:completion];
            break;
    }
}

#pragma mark ====================   Camera    ====================

- (BOOL)isGetCameraPermission
{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    return status == AVAuthorizationStatusAuthorized;
}
- (void)getCameraPermission:(void(^)(BOOL isAuth))completion
{
    NSString *typeName = KDPermissionLocal(@"camera");
    
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    switch (status) {
        case AVAuthorizationStatusAuthorized:
            [self returnBlock:YES type:typeName completion:completion];
            break;
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted:
            [self returnBlock:NO type:typeName completion:completion];
            break;
        case AVAuthorizationStatusNotDetermined:
        {
            __weak typeof(self) weakSelf = self;
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo
                                     completionHandler:^(BOOL granted) {
                [weakSelf returnBlock:granted type:typeName completion:completion];
            }];
        }
            break;
        default:
            [self returnBlock:NO type:typeName completion:completion];
            break;
    }
}

#pragma mark ====================   Audio    ====================

- (BOOL)isGetAudioPermission
{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    return status == AVAuthorizationStatusAuthorized;
}

- (void)getAudioPermission:(void(^)(BOOL isAuth))completion
{
    NSString *typeName = KDPermissionLocal(@"audio");
    
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    
    switch (status) {
        case AVAuthorizationStatusAuthorized:
            [self returnBlock:YES type:typeName completion:completion];
            break;
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted:
            [self returnBlock:NO type:typeName completion:completion];
            break;
        case AVAuthorizationStatusNotDetermined:
        {
            __weak typeof(self) weakSelf = self;
            [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
                [weakSelf returnBlock:granted type:typeName completion:completion];
            }];
        }
            break;
        default:
            [self returnBlock:NO type:typeName completion:completion];
            break;
    }
}

#pragma mark ====================   Location    ====================

- (BOOL)isGetLocationPermission
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    return ((kCLAuthorizationStatusAuthorizedWhenInUse == status) ||
            (kCLAuthorizationStatusAuthorizedAlways == status));
}
- (void)getLocationPermission:(void (^)(BOOL))completion
{
    NSString *typeName = KDPermissionLocal(@"location");

    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    switch (status)
    {
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        case kCLAuthorizationStatusAuthorizedAlways:
            [self returnBlock:YES type:typeName completion:completion];
            break;
        case kCLAuthorizationStatusNotDetermined:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.locationManager = [[CLLocationManager alloc] init];
                self.locationManager.distanceFilter = 5;
                self.locationManager.delegate = self;
                self.locationCompletion = completion;
                self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
                if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])
                {
                    [self.locationManager requestAlwaysAuthorization];
                }
            });
        }
            break;
        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusDenied:
        {
            [self returnBlock:NO type:typeName completion:completion];
        } break;
        default:
            [self returnBlock:NO type:typeName completion:completion];
        break;
    }
}

#pragma mark ====================   LocationAlways    ====================

- (BOOL)isGetLocationWhenInUsePermission
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    return (kCLAuthorizationStatusAuthorizedAlways == status);
}

- (void)getLocationWhenInUsePermission:(void(^)( BOOL isAuth))completion
{
    NSString *typeName = KDPermissionLocal(@"location");
    
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    switch (status)
    {
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        case kCLAuthorizationStatusAuthorizedAlways:
            [self returnBlock:YES type:typeName completion:completion];
            break;
        case kCLAuthorizationStatusNotDetermined:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.locationManager = [[CLLocationManager alloc] init];
                self.locationManager.distanceFilter = 5;
                self.locationManager.delegate = self;
                self.locationCompletion = completion;
                self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
                if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
                {
                    [self.locationManager requestWhenInUseAuthorization];
                }
            });
        }
            break;
        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusDenied:
        {
            [self returnBlock:NO type:typeName completion:completion];
        } break;
        default:
            [self returnBlock:NO type:typeName completion:completion];
            break;
    }
}

// CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (_locationManager && status != kCLAuthorizationStatusNotDetermined)
    {
        [self getLocationPermission:_locationCompletion];
    }
}


#pragma mark ============================ SpeechRecognizer ============================


- (BOOL)isGetSpeechRecognizerPermission
{
    if (@available(iOS 10.0, *)) {
        SFSpeechRecognizerAuthorizationStatus status = [SFSpeechRecognizer authorizationStatus];
        return status == SFSpeechRecognizerAuthorizationStatusAuthorized;
    } else {
        // Fallback on earlier versions
        return NO;
    }
}

- (void)getSpeechRecognizerPermission:(void(^)( BOOL isAuth))completion
{
    NSString *typeName = KDPermissionLocal(@"speechRecognizer");

    if (@available(iOS 10.0, *))
    {
        SFSpeechRecognizerAuthorizationStatus status = [SFSpeechRecognizer authorizationStatus];
        switch (status) {
            case SFSpeechRecognizerAuthorizationStatusAuthorized:
                [self returnBlock:YES type:typeName completion:completion];
                break;
            case SFSpeechRecognizerAuthorizationStatusDenied:
            case SFSpeechRecognizerAuthorizationStatusRestricted:
                [self returnBlock:NO type:typeName completion:completion];
                break;
            case SFSpeechRecognizerAuthorizationStatusNotDetermined:
            {
                __weak typeof(self) weakSelf = self;
                [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status)
                 {
                     [weakSelf returnBlock:status == SFSpeechRecognizerAuthorizationStatusAuthorized type:typeName completion:completion];
                 }];
            }
                break;
            default:
                [self returnBlock:NO type:typeName completion:completion];
                break;
        }
    }
    else
    {
        [self returnBlock:NO type:typeName completion:completion];
    }
}


#pragma mark ====================   Contact    ====================

- (BOOL)isGetContactPermission
{
    KDAuthorizationStatus status = [self getContactStatus];
    return status == KDAuthorizationStatusAuthorized;
}

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

- (void)getContactPermission:(void(^)(BOOL isAuth))completion
{
    NSString *typeName = KDPermissionLocal(@"addressbook");

    KDAuthorizationStatus status = [self getContactStatus];
    
    switch (status) {
        case KDAuthorizationStatusAuthorized:
            [self returnBlock:YES type:typeName completion:completion];
            break;
        case KDAuthorizationStatusDenied:
        case KDAuthorizationStatusRestricted:
            [self returnBlock:NO type:typeName completion:completion];
            break;
        case KDAuthorizationStatusNotDetermined:
        {
            __weak typeof(self) weakSelf = self;
            [self showAddressBookAuthrity:^(BOOL succeed) {
                [weakSelf returnBlock:succeed type:typeName completion:completion];
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

#pragma mark ====================   Calendar    ====================

- (BOOL)isGetCalendarPermission
{
    EKAuthorizationStatus status = [EKEventStore  authorizationStatusForEntityType:EKEntityTypeEvent];
    return status == EKAuthorizationStatusAuthorized;
}

- (void)getCalendarPermission:(void(^)(BOOL isAuth))completion
{
    NSString *typeName = KDPermissionLocal(@"calendar");
    
    EKAuthorizationStatus status = [EKEventStore  authorizationStatusForEntityType:EKEntityTypeEvent];

    switch (status) {
        case EKAuthorizationStatusAuthorized:
            [self returnBlock:YES type:typeName completion:completion];
            break;
        case EKAuthorizationStatusDenied:
        case EKAuthorizationStatusRestricted:
            [self returnBlock:NO type:typeName completion:completion];
            break;
        case EKAuthorizationStatusNotDetermined:
        {
            __weak typeof(self) weakSelf = self;
            
            EKEventStore *store = [[EKEventStore alloc]init];
            [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError * _Nullable error) {
                [weakSelf returnBlock:granted type:typeName completion:completion];
            }];
        }
            break;
        default:
            [self returnBlock:NO type:typeName completion:completion];
            break;
    }
}

#pragma mark ====================   Reminder    ====================

- (BOOL)isGetReminderPermission
{
    EKAuthorizationStatus status = [EKEventStore  authorizationStatusForEntityType:EKEntityTypeEvent];
    return status == EKAuthorizationStatusAuthorized;
}

- (void)getReminderPermission:(void(^)(BOOL isAuth))completion
{
    NSString *typeName = KDPermissionLocal(@"reminder");
    
    EKAuthorizationStatus status = [EKEventStore  authorizationStatusForEntityType:EKEntityTypeReminder];

    switch (status) {
        case EKAuthorizationStatusAuthorized:
            [self returnBlock:YES type:typeName completion:completion];
            break;
        case EKAuthorizationStatusDenied:
        case EKAuthorizationStatusRestricted:
            [self returnBlock:NO type:typeName completion:completion];
            break;
        case EKAuthorizationStatusNotDetermined:
        {
            __weak typeof(self) weakSelf = self;
            
            EKEventStore *store = [[EKEventStore alloc]init];
            [store requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError * _Nullable error) {
                [weakSelf returnBlock:granted type:typeName completion:completion];
            }];
        }
            break;
        default:
            [self returnBlock:NO type:typeName completion:completion];
            break;
    }
}

#pragma mark ====================   Notification    ====================

- (void)getNotificationPermissionBelow10
{
    UIUserNotificationSettings *setting = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound) categories:nil];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:setting];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

- (void)getNotificationPermission:(void(^)(BOOL isAuth))completion
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *typeName = KDPermissionLocal(@"notification");

        __weak typeof(self) weakSelf = self;
        if (!NSClassFromString(@"UNUserNotificationCenter") || !IS_IOS10_LATER)
        {
            UIUserNotificationType types = [[UIApplication sharedApplication] currentUserNotificationSettings].types;
            [self returnBlock:(types != UIUserNotificationTypeNone) type:typeName completion:completion];
            return;
        }
        
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = [UIApplication sharedApplication].delegate;
        
        [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            switch (settings.authorizationStatus)
            {
                case UNAuthorizationStatusAuthorized:
                    [weakSelf returnBlock:YES type:typeName completion:completion];
                    break;
                    
                case UNAuthorizationStatusNotDetermined:
                {
                    // 必须写代理，不然无法监听通知的接收与点击
                    [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[UIApplication sharedApplication] registerForRemoteNotifications];
                            [weakSelf returnBlock:granted type:typeName completion:completion];
                        });
                    }];
                }
                    break;
                case UNAuthorizationStatusDenied:
                    [weakSelf returnBlock:NO type:typeName completion:completion];
                    break;
                default:
                    [weakSelf returnBlock:NO type:typeName completion:completion];
                    break;
            }
        }];
    });
}

- (void)getNetPermission:(void(^)(BOOL isAuth))completion
{//检查联网权限==系统会自动弹框提示无需自己弄==iOS9以后
    CTCellularData *cellularData = [[CTCellularData alloc] init];
    cellularData.cellularDataRestrictionDidUpdateNotifier = ^(CTCellularDataRestrictedState state)
    {//获取联网状态
        switch (state)
        {
            case kCTCellularDataRestricted:
                NSLog(@"kCT蜂窝数据限制");
            break;
            case kCTCellularDataNotRestricted:
                NSLog(@"kCT蜂窝数据不受限制的");
            break;
            case kCTCellularDataRestrictedStateUnknown:
                NSLog(@"kCT蜂窝数据限制状态未知");
            break;
            default:
            
            break;
                
        };
    };
}

#pragma mark ====================   NoPermissionAlert    ====================

// 没获取到授权,弹出alert引导去系统设置页面
- (void)alertPermissionTip:(NSString *)permissionType
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self->_AutoShowAlert)
        {
            return;
        }
        NSString *strTip = KDPermissionFormat(@"_get.sys.permission.of", permissionType);
        UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:nil message:strTip preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionGoSet = [UIAlertAction actionWithTitle:KDPermissionLocal(@"go.set") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
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
    });
}

@end
