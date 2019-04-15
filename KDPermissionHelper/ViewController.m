//
//  ViewController.m
//  KDPermissionHelper
//
//  Created by mumu on 2019/1/15.
//  Copyright © 2019年 kd. All rights reserved.
//

#import "ViewController.h"
#import "PermissionTestVC.h"

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
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 100, 50)];
    [btn setTitle:@"跳转" forState:UIControlStateNormal];
    [btn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(jumpTestVC:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)jumpTestVC:(UIButton *)btn
{
    [self.navigationController pushViewController:[[PermissionTestVC alloc] init] animated:YES];
}

@end
