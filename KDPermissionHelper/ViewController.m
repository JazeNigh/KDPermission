//
//  ViewController.m
//  KDPermissionHelper
//
//  Created by mumu on 2019/1/15.
//  Copyright © 2019年 kd. All rights reserved.
//

#import "ViewController.h"
#import "KDPermission/KDPermission.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self addViews];
}
- (void)addViews
{
    [self addButtonWithSel:@"getCamera" tag:1];
    [self addButtonWithSel:@"getAudio" tag:2];
    [self addButtonWithSel:@"getLocation" tag:3];
    [self addButtonWithSel:@"getPhoto" tag:4];
    [self addButtonWithSel:@"getAddressBook" tag:5];
}
- (UIButton *)addButtonWithSel:(NSString *)sel tag:(NSInteger)tag
{
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(50, tag*50, 100, 30)];
    [btn setTitle:sel forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn addTarget:self action:NSSelectorFromString(sel) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    return btn;
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

@end
