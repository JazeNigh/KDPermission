//
//  PermissionTestVC.m
//  KDPermissionHelper
//
//  Created by sinapocket on 2019/4/15.
//  Copyright © 2019 kd. All rights reserved.
//

#import "PermissionTestVC.h"
#import "KDPermission.h"


#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

@interface PermissionTestVC ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *mArrData;
@property (nonatomic, strong) UITableView *tableV;

@end

@implementation PermissionTestVC

- (NSMutableArray *)mArrData
{
    if (!_mArrData)
    {
        _mArrData = [NSMutableArray array];
    }
    return _mArrData;
}
- (UITableView *)tableV
{
    if (!_tableV)
    {
        _tableV = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableV.tableFooterView = [UIView new];
        _tableV.delegate = self;
        _tableV.dataSource = self;
    }
    return _tableV;
}

- (void)dealloc
{
    NSLog(@"PermissionTestVC--dealloc");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    
    [KDPermission helper].AutoShowAlert = YES;
    [self addViews];
}
- (void)addViews
{
    [self addAction:@"getAll"];
    [self addAction:@"getCamera"];
    [self addAction:@"getAudio"];
    [self addAction:@"getLocation"];
    [self addAction:@"getLocationWhenInUse"];
    [self addAction:@"getPhoto"];
    [self addAction:@"getAddressBook"];
    [self addAction:@"getNotification"];
    [self addAction:@"getSpeechRecognizer"];
    [self addAction:@"getCalendar"];
    [self addAction:@"getReminde"];
    [self.view addSubview:self.tableV];
}

- (void)addAction:(NSString *)action
{
    [self.mArrData addObject:@{
                               @"title":action,
                               @"funcName":action
                               }];
}

- (void)getAll
{
    [[KDPermission helper] getCameraPermission:^(BOOL isAuth) {
        NSLog(@"getCameraPermission: %@,result,%d",NSStringFromSelector(_cmd),isAuth);
        if (isAuth)
        {
            [[KDPermission helper] getAudioPermission:^(BOOL isAuth) {
                NSLog(@"getAudioPermission: %@,result,%d",NSStringFromSelector(_cmd),isAuth);
                if (isAuth)
                {
                    [[KDPermission helper] getLocationPermission:^(BOOL isAuth) {
                        NSLog(@"getLocationPermission: %@,result,%d",NSStringFromSelector(_cmd),isAuth);
                        if (isAuth)
                        {
                            [[KDPermission helper] getLibraryPermission:^(BOOL isAuth) {
                                NSLog(@"getLibraryPermission: %@,result,%d",NSStringFromSelector(_cmd),isAuth);
                                if (isAuth)
                                {
                                    [[KDPermission helper] getContactPermission:^(BOOL isAuth) {
                                        NSLog(@"getContactPermission: %@,result,%d",NSStringFromSelector(_cmd),isAuth);
                                        if (isAuth)
                                        {
                                            [[KDPermission helper] getSpeechRecognizerPermission:^(BOOL isAuth) {
                                                NSLog(@"getSpeechRecognizerPermission: %@,result,%d",NSStringFromSelector(_cmd),isAuth);
                                                if (isAuth)
                                                {
                                                    [[KDPermission helper] getNotificationPermission:^(BOOL isAuth) {
                                                        NSLog(@"getNotificationPermission: %@,result,%d",NSStringFromSelector(_cmd),isAuth);
                                                        if (isAuth)
                                                        {
                                                            [[KDPermission helper] getCalendarPermission:^(BOOL isAuth) {
                                                                NSLog(@"getCalendarPermission: %@,result,%d",NSStringFromSelector(_cmd),isAuth);
                                                                if (isAuth)
                                                                {
                                                                    [[KDPermission helper] getReminderPermission:^(BOOL isAuth) {
                                                                        NSLog(@"getReminderPermission: %@,result,%d",NSStringFromSelector(_cmd),isAuth);
                                                                        if (isAuth)
                                                                        {
                                                                            
                                                                        }
                                                                    }];
                                                                }
                                                            }];
                                                        }
                                                    }];
                                                }
                                            }];
                                        }
                                    }];
                                }
                            }];
                        }
                    }];
                }
            }];
        }
    }];
}
- (void)getCamera
{
    [[KDPermission helper] getCameraPermission:^(BOOL isAuth) {
        NSLog(@"method: %@,result,%d",NSStringFromSelector(_cmd),isAuth);
        self.view.backgroundColor = [UIColor redColor];

    }];
}
- (void)getAudio
{
    [[KDPermission helper] getAudioPermission:^(BOOL isAuth) {
        NSLog(@"method: %@,result,%d",NSStringFromSelector(_cmd),isAuth);
    }];
}
- (void)getLocation
{
    [[KDPermission helper] getLocationPermission:^(BOOL isAuth) {
        NSLog(@"method: %@,result,%d",NSStringFromSelector(_cmd),isAuth);
        self.view.backgroundColor = [UIColor grayColor];
    }];
}
- (void)getLocationWhenInUse
{
    [[KDPermission helper] getLocationWhenInUsePermission:^(BOOL isAuth) {
        NSLog(@"method: %@,result,%d",NSStringFromSelector(_cmd),isAuth);
        self.view.backgroundColor = [UIColor yellowColor];
    }];
}
- (void)getPhoto
{
    [[KDPermission helper] getLibraryPermission:^(BOOL isAuth) {
        NSLog(@"method: %@,result,%d",NSStringFromSelector(_cmd),isAuth);
    }];
}
- (void)getAddressBook
{
    [[KDPermission helper] getContactPermission:^(BOOL isAuth) {
        NSLog(@"method: %@,result,%d",NSStringFromSelector(_cmd),isAuth);
    }];
}
- (void)getSpeechRecognizer
{
    [[KDPermission helper] getSpeechRecognizerPermission:^(BOOL isAuth) {
        NSLog(@"method: %@,result,%d",NSStringFromSelector(_cmd),isAuth);
    }];
}

- (void)getCalendar
{
    [[KDPermission helper] getCalendarPermission:^(BOOL isAuth) {
        NSLog(@"method: %@,result,%d",NSStringFromSelector(_cmd),isAuth);
    }];
}

- (void)getReminde
{
    [[KDPermission helper] getReminderPermission:^(BOOL isAuth) {
        NSLog(@"method: %@,result,%d",NSStringFromSelector(_cmd),isAuth);
    }];
}


- (void)getNotification
{
    if ([[UIDevice currentDevice].systemVersion doubleValue]<10.0)
    {
        [[KDPermission helper] getNotificationPermissionBelow10];
        /*
         after do this you can use
         [[KDPermission helper] getNotificationPermission:^(BOOL isAuth) {
         NSLog(@"method: %@,result,%d",NSStringFromSelector(_cmd),isAuth);
         }];
         to know is get permission
         */
    }
    else
    {
        [[KDPermission helper] getNotificationPermission:^(BOOL isAuth) {
            NSLog(@"method: %@,result,%d",NSStringFromSelector(_cmd),isAuth);
        }];
    }
}


#pragma mark ============================ table ============================



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.mArrData.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    NSDictionary *dic = self.mArrData[indexPath.row];
    cell.textLabel.text = dic[@"title"];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSDictionary *dic = self.mArrData[indexPath.row];
    NSString *funcName = dic[@"funcName"];
    if ([self respondsToSelector:NSSelectorFromString(funcName)])
    {
        if ([funcName isEqualToString:@"changeIcon"])
        {
            id obj;
            SuppressPerformSelectorLeakWarning(obj = [self performSelector:NSSelectorFromString(funcName)]);
            if ([obj isKindOfClass:[NSString class]])
            {
                NSString *str = (NSString *)obj;
                UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                cell.imageView.image = [UIImage imageNamed:str];
            }
        }
        else
        {
            SuppressPerformSelectorLeakWarning([self performSelector:NSSelectorFromString(funcName)]);
        }
    }
}

@end
