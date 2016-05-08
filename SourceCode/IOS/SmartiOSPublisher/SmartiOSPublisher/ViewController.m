//
//  ViewController.m
//  SmartiOSPublisher
//
//  GitHub: https://github.com/daniulive/SmarterStreaming
//
//  Created by daniulive on 16/3/24.
//  Copyright © 2016年 daniulive. All rights reserved.
//

#import "ViewController.h"
#import "SettingView.h"


@interface ViewController () <UITableViewDelegate, UINavigationControllerDelegate>

//相机预览视图
@property (nonatomic, strong) UIView *localPreview;


//直播SDK API
@property (nonatomic,strong) SmartPublisherSDK *mediaCapture;

- (void)swapCameraBtnPressed:(id)sender;

@end


@implementation ViewController{
    NSString    *publishURL;
    UIButton    *medResolution;
    UIButton    *swapCamerasButton;         //前后摄像头切换
    UIButton    *publisherButton;           //推流控制
    UIButton    *backSettingsButton;        //返回到设置分辨率页面
    UILabel     *textModeLabel;             //文字提示
    NSInteger   randNumber;
    DNVideoStreamingQuality videoQuality;   //分辨率选择
    NSString    *copyRights;
}

@synthesize localPreview;

- (instancetype)initParameter:(DNVideoStreamingQuality)streamQuality
{
    self = [super init];
    if (!self) {
        return nil;
    }
    else if(self) {
        videoQuality = streamQuality;
    }
    
    NSLog(@"[initParameter]videoQuality: %u",videoQuality);
    
    return self;
}

- (void)loadView
{
    copyRights = @"Copyright 2014~2016 www.daniulive.com v1.0.16.0505";
    //当前屏幕宽高
    CGFloat screenWidth  = CGRectGetWidth([UIScreen mainScreen].bounds);
    CGFloat screenHeight = CGRectGetHeight([UIScreen mainScreen].bounds);
    
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    
    _mediaCapture = [[SmartPublisherSDK alloc] init];
    
    if (_mediaCapture ==nil ) {
        NSLog(@"_mediaCapture with nil..");
        return;
    }
    
    if([_mediaCapture SmartPublisherInit] != DANIULIVE_RETURN_OK){
        NSLog(@"Call SmartPublisherInit failed..");
        //[_mediaCapture release];
        _mediaCapture = nil;
        return;
    }
    
    self.localPreview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    
    if([_mediaCapture SmartPublisherSetVideoPreview:self.localPreview] != DANIULIVE_RETURN_OK){
        NSLog(@"Call SmartPublisherSetVideoPreview failed..");
        [_mediaCapture SmartPublisherUnInit];
        //[_mediaCapture release];
        _mediaCapture = nil;
        return;
    }

    if([_mediaCapture SmartPublisherStartCapture:videoQuality] != DANIULIVE_RETURN_OK){
        NSLog(@"Call SmartPublisherStartCapture failed..");
        [_mediaCapture SmartPublisherUnInit];
        //[_mediaCapture release];
        _mediaCapture = nil;
        return;
    }
    
    [self.view addSubview:self.localPreview];
    
    swapCamerasButton = [UIButton buttonWithType:UIButtonTypeCustom];
    swapCamerasButton.frame = CGRectMake(45, self.view.frame.size.height - 240, 60, 60);
    swapCamerasButton.center = CGPointMake(self.view.frame.size.width / 6, swapCamerasButton.frame.origin.y + swapCamerasButton.frame.size.height / 2);
    
    CGFloat lineWidth = swapCamerasButton.frame.size.width * 0.12f;
    swapCamerasButton.layer.cornerRadius = swapCamerasButton.frame.size.width / 2;
    swapCamerasButton.layer.borderColor = [UIColor greenColor].CGColor;
    swapCamerasButton.layer.borderWidth = lineWidth;
    
    [swapCamerasButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [swapCamerasButton setTitle:@"前置" forState:UIControlStateNormal];
    
    swapCamerasButton.selected = NO;
    [swapCamerasButton setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    [swapCamerasButton setTitle:@"后置" forState:UIControlStateSelected];
    
    [swapCamerasButton addTarget:self action:@selector(swapCameraBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:swapCamerasButton];
    
    publisherButton = [UIButton buttonWithType:UIButtonTypeCustom];
    publisherButton.frame = CGRectMake(45, self.view.frame.size.height - 160, 60, 60);
    publisherButton.center = CGPointMake(self.view.frame.size.width / 6, publisherButton.frame.origin.y + publisherButton.frame.size.height / 2);
    
    publisherButton.layer.cornerRadius = publisherButton.frame.size.width / 2;
    publisherButton.layer.borderColor = [UIColor greenColor].CGColor;
    publisherButton.layer.borderWidth = lineWidth;
    
    [publisherButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [publisherButton setTitle:@"推流" forState:UIControlStateNormal];
    
    publisherButton.selected = NO;
    [publisherButton setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    [publisherButton setTitle:@"停止" forState:UIControlStateSelected];
    
    [publisherButton addTarget:self action:@selector(publishStream:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:publisherButton];
    
    backSettingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backSettingsButton.frame = CGRectMake(45, self.view.frame.size.height - 80, 60, 60);
    backSettingsButton.center = CGPointMake(self.view.frame.size.width / 6, backSettingsButton.frame.origin.y + backSettingsButton.frame.size.height / 2);
    
    backSettingsButton.layer.cornerRadius = backSettingsButton.frame.size.width / 2;
    backSettingsButton.layer.borderColor = [UIColor greenColor].CGColor;
    backSettingsButton.layer.borderWidth = lineWidth;
    
    [backSettingsButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [backSettingsButton setTitle:@"返回" forState:UIControlStateNormal];
    
    [backSettingsButton addTarget:self action:@selector(backSettingsBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backSettingsButton];
    
    // 创建文字提示 UILable
    textModeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, self.view.frame.size.width, 50)];
    // 设置UILabel的背景色
    textModeLabel.backgroundColor = [UIColor clearColor];
    // 设置UILabel的文本颜色
    textModeLabel.textColor = [UIColor colorWithRed:1.0 green:0.0
                                                blue:1.0 alpha:1.0];
    
    textModeLabel.adjustsFontSizeToFitWidth = YES;
    
    NSString *str = @"欢迎使用SmartPublisher, ";
    
    textModeLabel.text =  [str stringByAppendingString:copyRights];
    [self.view addSubview:textModeLabel];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    BOOL success = YES;
    success = [self requestMediaCapturerAccessWithCompletionHandler:^(BOOL value, NSError* error){
    }];
    if (success ==NO ) {
        return;
    }

    NSString* sdkVersion = [_mediaCapture getSDKVersionID];
    NSLog(@"sdk version:%@",sdkVersion);
}

- (void)swapCameraBtnPressed:(UIButton *)button
{
    
    NSLog(@"Run into swapCameraBtnPressed..");
    
    button.selected = !button.selected;
    
    [_mediaCapture SmartPublisherSwitchCamera];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//推流前，先申请音视频使用权限
- (BOOL)requestMediaCapturerAccessWithCompletionHandler:(void (^)(BOOL, NSError*))handler {
    AVAuthorizationStatus videoAuthorStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    AVAuthorizationStatus audioAuthorStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    
    if (AVAuthorizationStatusAuthorized == videoAuthorStatus && AVAuthorizationStatusAuthorized == audioAuthorStatus) {
        handler(YES,nil);
    }else{
        if (AVAuthorizationStatusRestricted == videoAuthorStatus || AVAuthorizationStatusDenied == videoAuthorStatus) {
            NSString *errMsg = NSLocalizedString(@"需要访问摄像头，请设置", @"需要访问摄像头，请设置");
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey:errMsg};
            NSError *error = [NSError errorWithDomain:@"访问权限" code:0 userInfo:userInfo];
            handler(NO,error);
            
            return NO;
        }
        
        if (AVAuthorizationStatusRestricted == audioAuthorStatus || AVAuthorizationStatusDenied == audioAuthorStatus) {
            NSString *errMsg = NSLocalizedString(@"需要访问麦克风，请设置", @"需要访问麦克风，请设置");
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey:errMsg};
            NSError *error = [NSError errorWithDomain:@"访问权限" code:0 userInfo:userInfo];
            handler(NO,error);
            
            return NO;
        }
        
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (granted) {
                [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
                    if (granted) {
                        handler(YES,nil);
                    }else{
                        NSString *errMsg = NSLocalizedString(@"不允许访问麦克风", @"不允许访问麦克风");
                        NSDictionary *userInfo = @{NSLocalizedDescriptionKey:errMsg};
                        NSError *error = [NSError errorWithDomain:@"访问权限" code:0 userInfo:userInfo];
                        handler(NO,error);
                    }
                }];
            }else{
                NSString *errMsg = NSLocalizedString(@"不允许访问摄像头", @"不允许访问摄像头");
                NSDictionary *userInfo = @{NSLocalizedDescriptionKey:errMsg};
                NSError *error = [NSError errorWithDomain:@"访问权限" code:0 userInfo:userInfo];
                handler(NO,error);
            }
        }];
        
    }
    return YES;
}


- (void)publishStream:(UIButton *)button
{
    NSLog(@"Run into publishStream..");
    
    button.selected = !button.selected;
    
    if (button.selected)
    {
        NSLog(@"Run into publishStream, start publisher..");
        
        randNumber = arc4random()%(1000000);
        
        NSString *strNumber = [NSString stringWithFormat:@"%ld", (long)randNumber];
        
        NSString *baseURL = @"rtmp://daniulive.com:1935/hls/stream";
        
        publishURL = [ baseURL stringByAppendingString:strNumber];
          
        NSLog(@"publishURL: %@",publishURL);
        
        NSString *baseText = @"推送URL：";
        
        textModeLabel.text = [ baseText stringByAppendingString:publishURL];
        
        NSInteger ret = [_mediaCapture SmartPublisherStartPublish:publishURL];
        
        if(ret != DANIULIVE_RETURN_OK){
            NSLog(@"Call SmartPublisherStartPublish failed..ret:%ld", (long)ret);
            
            if (ret == DANIULIVE_RETURN_SDK_EXPIRED) {
                textModeLabel.text = @"推流失败，返回 DANIULIVE_RETURN_SDK_EXPIRED，请联系daniulive（QQ：413229569）授权";
            }
            else
            {
                textModeLabel.text = @"推流失败，返回 DANIULIVE_RETURN_ERROR";
            }
            
            return;
        }
        else
        {
            medResolution.enabled = NO;
            backSettingsButton.enabled = NO;
        }
    }
    else
    {
        NSLog(@"Run into publishStream, stop publisher..");
        
        medResolution.enabled = YES;
        backSettingsButton.enabled = YES;
        [_mediaCapture SmartPublisherStopPublish];
    }
    
}

- (void)backSettingsBtn:(UIButton *)button
{
    
    NSLog(@"Run into backSettingsBtn..");
    
    if (_mediaCapture != nil)
    {
        [_mediaCapture SmartPublisherStopCaputure];
        [_mediaCapture SmartPublisherUnInit];
        //[_mediaCapture release];
        _mediaCapture = nil;
    }
    
    //返回设置分辨率页面
    SettingView * settingView =[[SettingView alloc] init];
    [self presentViewController:settingView animated:YES completion:nil];
}

@end