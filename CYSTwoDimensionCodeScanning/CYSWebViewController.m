//
//  CYSWebViewController.m
//  CYSTwoDimensionCodeScanning
//
//  Created by YanceyChan on 15/6/8.
//  Copyright (c) 2015年 exmaple. All rights reserved.
//

#import "CYSWebViewController.h"

@interface CYSWebViewController ()

@end

@implementation CYSWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:self.myUrl]];
    [self.webView loadRequest:request];
    
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
