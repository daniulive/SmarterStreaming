//
//  ViewController.m
//  SmartiOSScreenPublisherV2
//
//  Created by ni on 2018/3/26.
//  Copyright © 2018年 daniulive. All rights reserved.
//
#import "ViewController.h"

@interface ViewController ()<RPBroadcastActivityViewControllerDelegate,RPBroadcastControllerDelegate>
@property (nonatomic, weak) UIButton *startPusherBtn;
@property (nonatomic, weak) UIButton *stopPusherBtn;
@property RPBroadcastController *broadcastController;
@property NSTimer *timer;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    /*
    UIWebView* web = [[UIWebView alloc] initWithFrame:self.view.bounds];
    web.hidden = YES;
    [web loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.baidu.com"]]];
    [self.view addSubview:web];
    */
    
    [self loadUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadUI {
    NSUInteger lineY = 200;
    
    UIButton *start = [UIButton buttonWithType:UIButtonTypeCustom];
    self.startPusherBtn = start;
    [self.view addSubview:start];
    [start setTitle:@"开始直播" forState:UIControlStateNormal];
    start.frame = CGRectMake(0, lineY, 150, 50);
    start.backgroundColor = [UIColor orangeColor];
    [start addTarget:self action:@selector(startClicked:) forControlEvents:UIControlEventTouchUpInside];
    lineY += 50;
    
    UIButton *stop = [UIButton buttonWithType:UIButtonTypeCustom];
    self.stopPusherBtn = stop;
    [self.view addSubview:stop];
    [stop setTitle:@"停止直播" forState:UIControlStateNormal];
    stop.frame = CGRectMake(0, lineY, 150, 50);
    stop.backgroundColor = [UIColor redColor];
    [stop addTarget:self action:@selector(stopClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.stopPusherBtn.enabled = NO;
    lineY += 50;
}

- (void)startClicked:(UIButton *)btn
{
    [RPBroadcastActivityViewController loadBroadcastActivityViewControllerWithHandler:^(RPBroadcastActivityViewController * _Nullable broadcastActivityViewController, NSError * _Nullable error) {
        if (error) {
            NSLog(@"start broadcastActivityViewController error - %@",error);
        }
        broadcastActivityViewController.delegate = self;
        [self presentViewController:broadcastActivityViewController animated:YES completion:^{
            
        }];
        self.startPusherBtn.enabled = NO;
    }];
}

- (void)stopClicked:(UIButton *)btn
{
    [self.broadcastController finishBroadcastWithHandler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"finishBroadcastWithHandler %@", error);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.startPusherBtn setTitle:@"开始直播" forState:UIControlStateNormal];
            self.startPusherBtn.enabled = YES;
            [self.timer invalidate];
            self.timer = nil;
            self.startPusherBtn.titleLabel.alpha = 1;
        });
    }];
}

- (void)previewController:(RPPreviewViewController *)previewController didFinishWithActivityTypes:(NSSet <NSString *> *)activityTypes
{
    NSLog(@"activity - %@",activityTypes);
}

-(void)broadcastController:(RPBroadcastController *)broadcastController didFinishWithError:(NSError *)error{
    NSLog(@"broadcastController:didFinishWithError: %@", error);
    
}

-(void)screenRecorder:(RPScreenRecorder *)screenRecorder didStopRecordingWithError:(NSError *)error previewViewController:(RPPreviewViewController *)previewViewController{
    NSLog(@"didStopRecordingWithError: %@", error);
}


-(void)broadcastController:(RPBroadcastController *)broadcastController didUpdateServiceInfo:(NSDictionary<NSString *,NSObject<NSCoding> *> *)serviceInfo{
    NSLog(@"broadcastController didUpdateServiceInfo: %@", serviceInfo);
}

-(void)broadcastActivityViewController:(RPBroadcastActivityViewController *)broadcastActivityViewController didFinishWithBroadcastController:(RPBroadcastController *)broadcastController error:(NSError *)error{
    NSLog(@"broadcastActivityViewController");
    
    [broadcastActivityViewController dismissViewControllerAnimated:YES completion:NULL];
    
    if (error)
    {
        NSLog(@"error=%@", error);
        //返回主线程
        dispatch_async(dispatch_get_main_queue(), ^{
            self.startPusherBtn.enabled = YES;
        });
        return;
    }
    
    NSLog(@"broadcastController.broadcasting=%d", broadcastController.broadcasting);
    NSLog(@"broadcastController.paused=%d", broadcastController.paused);
    NSLog(@"broadcastController.broadcastURL=%@", broadcastController.broadcastURL);
    NSLog(@"broadcastController.serviceInfo=%@", broadcastController.serviceInfo);
    NSLog(@"broadcastController.broadcastExtensionBundleID=%@", broadcastController.broadcastExtensionBundleID);
    
    self.broadcastController = broadcastController;
    broadcastController.delegate = self;
    
    [self.startPusherBtn setTitle:@"正在初始化…" forState:UIControlStateNormal];
    
    [broadcastController startBroadcastWithHandler:^(NSError * _Nullable error) {
        if (!error) {
            NSLog(@"直播中....."  );
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.startPusherBtn setTitle:@"直播ing" forState:UIControlStateNormal];
                self.stopPusherBtn.enabled = YES;
                if (self.timer == nil) {
                    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
                        [UIView beginAnimations:@"blink" context:nil];
                        if (self.startPusherBtn.titleLabel.alpha == 0) {
                            self.startPusherBtn.titleLabel.alpha = 1;
                        } else {
                            self.startPusherBtn.titleLabel.alpha = 0;
                        }
                        [UIView commitAnimations];
                    }];
                }
            });
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[error description] delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
            [alert show];
            self.startPusherBtn.enabled = YES;
        }
    }];
}

@end
