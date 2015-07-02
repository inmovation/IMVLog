//
//  ViewController.m
//  IMVLog
//
//  Created by 陈少华 on 15/7/2.
//  Copyright (c) 2015年 inmovation. All rights reserved.
//

#import "ViewController.h"
#import "IMVLogger.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSLogDebug(@"%@", @"msg for debug");
    NSLogError(@"%@", @"msg for error");
    NSLogWarn(@"%@", @"msg for warn");
    NSLogInfo(@"%@", @"msg for info");

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
