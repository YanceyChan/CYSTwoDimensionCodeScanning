//
//  ViewController.m
//  CYSTwoDimensionCodeScanning
//
//  Created by YanceyChan on 15/6/4.
//  Copyright (c) 2015年 exmaple. All rights reserved.
//

#import "ViewController.h"
#import "CYSWebViewController.h"
#import <AVFoundation/AVFoundation.h>
@interface ViewController ()<AVCaptureMetadataOutputObjectsDelegate>
@property (weak, nonatomic  ) IBOutlet UIView                     *myVIew;
@property (weak, nonatomic  ) IBOutlet UILabel                    *myLabel;
@property (weak, nonatomic  ) IBOutlet UIButton                   *myButton;

@property (strong, nonatomic) UIView                     *boxView;
@property (assign, nonatomic) BOOL                       isReading;
@property (strong, nonatomic) CALayer                    *scanLayer;

@property (strong, nonatomic) AVCaptureSession           *captureSession;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (strong, nonatomic) NSTimer                    *timer;

//webViewController
@property (strong, nonatomic) CYSWebViewController       *webView;

@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.captureSession = nil;
    self.isReading      = NO;
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.myLabel.text = @"";
    [self.myButton setTitle:@"Star!" forState:UIControlStateNormal];
}

- (IBAction)didTapMyButton:(id)sender {
    if (!self.isReading) {
        if ([self starReading]) {
            [self.myButton setTitle:@"Stop" forState:UIControlStateNormal];
            self.myLabel.text = @"Scanning for QR Code";
        }
    }
    else{
        [self stopReading];
        [self.myButton setTitle:@"Star!" forState:UIControlStateNormal];
    }
    
    self.isReading = !self.isReading;
}

//TODO: 增加背景模糊效果
- (BOOL)starReading{
    NSError *error;
    
    //初始化捕捉设备(AVCaptureDevice)
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //用captureDevice创建输入流
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    if (!input) {
        NSLog(@"%@", [error localizedDescription]);
        return NO;
    }
    
    //创建媒体数据输出流
    AVCaptureMetadataOutput *captureMetadtaOutput = [[AVCaptureMetadataOutput alloc]init];
    
    //实例化捕捉会话
    self.captureSession = [[AVCaptureSession alloc] init];
    
    //将输入流添加到会话
    [self.captureSession addInput:input];
    
    //将媒体输出流添加到会话中
    [self.captureSession addOutput:captureMetadtaOutput];
    
    
    //设置视频输入每帧质量
    self.captureSession.sessionPreset = AVCaptureSessionPresetHigh;
    
    
    //创建串行队列
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("myQueue", NULL);
    //设置代理
    [captureMetadtaOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    //设置输出媒体数据类型为QRCode
    [captureMetadtaOutput setMetadataObjectTypes:[NSArray arrayWithObjects:AVMetadataObjectTypeQRCode, nil]];
    
    //实例化预览图层
    self.videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.captureSession];
    
    //设置预览图层填充方式
    [self.videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    
    //设置图层frame
    [self.videoPreviewLayer setFrame:self.myVIew.layer.bounds];
    
    //将图层添加到预览的view图层上
    [self.myVIew.layer addSublayer:self.videoPreviewLayer];
    
    //设置扫描范围
    //相对于session的videoPreviewLayer的frame 的比例  以横屏的左上角为原点，宽高都是根据横屏比例。
    //videoPreviewLayer 的 VideoGravity 的类型， Aspect 和AspectFill ，上面说的原点取值是以Aspect为准
    captureMetadtaOutput.rectOfInterest = CGRectMake(0.3, 0.2f, 0.4f, 0.6f);
    
    //扫描框
    //TODO: 找个好看的扫描边框
    self.boxView = [[UIView alloc] initWithFrame:CGRectMake(self.myVIew.bounds.size.width * 0.2f, self.myVIew.bounds.size.height * 0.2f, self.myVIew.bounds.size.width - self.myVIew.bounds.size.width * 0.4f, self.myVIew.bounds.size.height - self.myVIew.bounds.size.height * 0.4f)];
    
    self.boxView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.boxView.layer.borderWidth = 1.0f;
    [self.myVIew addSubview:self.boxView];
    
    //扫描线
    //TODO: 找个好看的扫描线
    self.scanLayer = [[CALayer alloc]init];
    self.scanLayer.frame = CGRectMake(0, 0, self.boxView.bounds.size.width, 1);
    self.scanLayer.backgroundColor = [UIColor brownColor].CGColor;
    [self.boxView.layer addSublayer:self.scanLayer];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(moveScanLayer:) userInfo:nil repeats:YES];
    
    [self.timer fire];
    
    //开始扫描
    [self.captureSession startRunning];
    
    return YES;
}

- (void)stopReading{
    [self.captureSession stopRunning];
    self.captureSession = nil;
    [self.scanLayer removeFromSuperlayer];
    [self.videoPreviewLayer removeFromSuperlayer];
    [self.boxView removeFromSuperview];
    [self.timer invalidate];
    
    if ([self.myLabel.text  hasPrefix:@"https://"] || [self.myLabel.text  hasPrefix:@"http://"] ) {
        [self performSegueWithIdentifier:@"pushToWebViewSegue" sender:nil];
    }
    

}


- (void)moveScanLayer:(NSTimer *)timer{
    CGRect frame = self.scanLayer.frame;
    if (self.boxView.frame.size.height < self.scanLayer.frame.origin.y) {
        frame.origin.y = 0;
        self.scanLayer.frame = frame;
    }
    else{
        frame.origin.y += 5;
        [UIView animateWithDuration:0.05 animations:^{
            self.scanLayer.frame = frame;
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    //判断是否有数据
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        //判断回传的数据类型
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            [self.myLabel performSelectorOnMainThread:@selector(setText:) withObject:[metadataObj stringValue] waitUntilDone:YES];
            
            [self performSelectorOnMainThread:@selector(stopReading) withObject:nil waitUntilDone:NO];
            self.isReading = NO;

        }
    }
}

//ios6.0 后 是否支持转向
- (BOOL)shouldAutorotate{
    return NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"pushToWebViewSegue"]) {
        CYSWebViewController *webViewC = segue.destinationViewController;
        webViewC.myUrl = self.myLabel.text;
    }

}


@end
