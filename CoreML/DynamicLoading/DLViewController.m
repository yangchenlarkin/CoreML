//
//  DLViewController.m
//  CoreML
//
//  Created by Larkin on 2019/1/14.
//  Copyright © 2019 Larkin. All rights reserved.
//

#import "DLViewController.h"

@interface DLViewController ()

@end

@implementation DLViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    CGFloat width = self.view.bounds.size.width;
    CGFloat height = self.view.bounds.size.height;
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 150, 150)];
    button.center = CGPointMake(width / 2.f, height / 2.f);
    button.backgroundColor = [UIColor greenColor];
    [button setTitle:@"模拟下载\nCore ML文件" forState:UIControlStateNormal];
    [self.view addSubview:button];
    
    [button addTarget:self action:@selector(download) forControlEvents:UIControlEventTouchUpInside];
}

- (void)download {
    //TODO:模拟下载
    //TODO:存储到沙盒
}

@end
