//
//  ViewController.m
//  KDPermissionHelper
//
//  Created by mumu on 2019/1/15.
//  Copyright © 2019年 kd. All rights reserved.
//

#import "ViewController.h"
#import "KDPermission.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [KDPermission helper].AutoShowAlert = YES;
    [self addViews];
}
- (void)addViews
{
    [self addButtonWithSel:@"getAll" tag:0];
    [self addButtonWithSel:@"getCamera" tag:1];
    [self addButtonWithSel:@"getAudio" tag:2];
    [self addButtonWithSel:@"getLocation" tag:3];
    [self addButtonWithSel:@"getLocationWhenInUse" tag:4];
    [self addButtonWithSel:@"getPhoto" tag:5];
    [self addButtonWithSel:@"getAddressBook" tag:6];
    [self addButtonWithSel:@"getNotification" tag:7];
    [self addButtonWithSel:@"getSpeechRecognizer" tag:8];

}

- (UIButton *)addButtonWithSel:(NSString *)sel tag:(NSInteger)tag
{
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(50, 100 + tag*50, 200, 30)];
    [btn setTitle:sel forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn addTarget:self action:NSSelectorFromString(sel) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    return btn;
}

- (void)getAll
{
    [[KDPermission helper] getCameraPemission:^(BOOL isAuth) {
        NSLog(@"getCameraPemission: %@,result,%d",NSStringFromSelector(_cmd),isAuth);
        if (isAuth)
        {
            [[KDPermission helper] getAudioPemission:^(BOOL isAuth) {
                NSLog(@"getAudioPemission: %@,result,%d",NSStringFromSelector(_cmd),isAuth);
                if (isAuth)
                {
                    [[KDPermission helper] getLocationPemission:^(BOOL isAuth) {
                        NSLog(@"getLocationPemission: %@,result,%d",NSStringFromSelector(_cmd),isAuth);
                        if (isAuth)
                        {
                            [[KDPermission helper] getLibraryPemission:^(BOOL isAuth) {
                                NSLog(@"getLibraryPemission: %@,result,%d",NSStringFromSelector(_cmd),isAuth);
                                if (isAuth)
                                {
                                    [[KDPermission helper] getContactPemission:^(BOOL isAuth) {
                                        NSLog(@"getContactPemission: %@,result,%d",NSStringFromSelector(_cmd),isAuth);
                                        if (isAuth)
                                        {
                                            [[KDPermission helper] getSpeechRecognizerPemission:^(BOOL isAuth) {
                                                NSLog(@"getSpeechRecognizerPemission: %@,result,%d",NSStringFromSelector(_cmd),isAuth);
                                                if (isAuth)
                                                {
                                                    [[KDPermission helper] getNotificationPermission:^(BOOL isAuth) {
                                                        NSLog(@"getNotificationPermission: %@,result,%d",NSStringFromSelector(_cmd),isAuth);
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
    [[KDPermission helper] getCameraPemission:^(BOOL isAuth) {
        NSLog(@"method: %@,result,%d",NSStringFromSelector(_cmd),isAuth);
    }];
}
- (void)getAudio
{
    [[KDPermission helper] getAudioPemission:^(BOOL isAuth) {
        NSLog(@"method: %@,result,%d",NSStringFromSelector(_cmd),isAuth);
    }];
}
- (void)getLocation
{
    [[KDPermission helper] getLocationPemission:^(BOOL isAuth) {
        NSLog(@"method: %@,result,%d",NSStringFromSelector(_cmd),isAuth);
    }];
}
- (void)getLocationWhenInUse
{
    [[KDPermission helper] getLocationWhenInUsePemission:^(BOOL isAuth) {
        NSLog(@"method: %@,result,%d",NSStringFromSelector(_cmd),isAuth);
    }];
}
- (void)getPhoto
{
    [[KDPermission helper] getLibraryPemission:^(BOOL isAuth) {
        NSLog(@"method: %@,result,%d",NSStringFromSelector(_cmd),isAuth);
    }];
}
- (void)getAddressBook
{
    [[KDPermission helper] getContactPemission:^(BOOL isAuth) {
        NSLog(@"method: %@,result,%d",NSStringFromSelector(_cmd),isAuth);
    }];
}
- (void)getSpeechRecognizer
{
    [[KDPermission helper] getSpeechRecognizerPemission:^(BOOL isAuth) {
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

@end
