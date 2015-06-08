//
//  CYSWebViewController.h
//  CYSTwoDimensionCodeScanning
//
//  Created by YanceyChan on 15/6/8.
//  Copyright (c) 2015年 exmaple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CYSWebViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (copy, nonatomic) NSString *myUrl;

@end
