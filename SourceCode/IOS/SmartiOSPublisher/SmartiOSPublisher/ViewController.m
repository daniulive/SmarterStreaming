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

//预览视图
@property (nonatomic, strong) UIView *localPreview;

//推流SDK API
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
    Boolean     is_audio_only;              //如果为true，则只推送音频
    Boolean     is_recorder;                //默认不录像，如果设为true，则录像
}

@synthesize localPreview;

- (NSInteger) handleSmartPublisherEvent:(NSInteger)nID param1:(unsigned long long)param1 param2:(unsigned long long)param2 param3:(NSString*)param3 param4:(NSString*)param4 pObj:(void *)pObj;
{
    if (nID == EVENT_DANIULIVE_ERC_PUBLISHER_STARTED) {
        NSLog(@"[event]开始推流..");
    }
    else if (nID == EVENT_DANIULIVE_ERC_PUBLISHER_CONNECTING)
    {
        NSLog(@"[event]连接中..");
    }
    else if (nID == EVENT_DANIULIVE_ERC_PUBLISHER_CONNECTION_FAILED)
    {
        NSLog(@"[event]连接失败..");
    }
    else if (nID == EVENT_DANIULIVE_ERC_PUBLISHER_CONNECTED)
    {
        NSLog(@"[event]已连接..");
    }
    else if (nID == EVENT_DANIULIVE_ERC_PUBLISHER_DISCONNECTED)
    {
        NSLog(@"[event]断开连接..");
    }
    else if (nID == EVENT_DANIULIVE_ERC_PUBLISHER_STOP)
    {
        NSLog(@"[event]停止推流..");
    }
    else if (nID == EVENT_DANIULIVE_ERC_PUBLISHER_RECORDER_START_NEW_FILE)
    {
        NSLog(@"[event]录像写入新文件..文件名: %@", param3);
    }
    else if (nID == EVENT_DANIULIVE_ERC_PUBLISHER_ONE_RECORDER_FILE_FINISHED)
    {
        NSLog(@"[event]一个录像文件完成..文件名: %@", param3);
    }
    else
        NSLog(@"[event]nID:%lx", (long)nID);
    
    return 0;
}

- (instancetype)initParameter:(DNVideoStreamingQuality)streamQuality isAudioOnly:(Boolean)isAudioOnly isRecorder:(Boolean)isRecorder
{
    self = [super init];
    if (!self) {
        return nil;
    }
    else if(self) {
        videoQuality = streamQuality;
        is_audio_only = isAudioOnly;
        is_recorder   = isRecorder;
    }
    
    NSLog(@"[initParameter]videoQuality: %u, is_audio_only: %d, is_recorder: %d",videoQuality, is_audio_only, is_recorder);
    
    return self;
}

- (void)loadView
{
    copyRights = @"Copyright 2014~2016 www.daniulive.com v1.0.16.0623";
    //当前屏幕宽高
    CGFloat screenWidth  = CGRectGetWidth([UIScreen mainScreen].bounds);
    CGFloat screenHeight = CGRectGetHeight([UIScreen mainScreen].bounds);
    
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    
    _mediaCapture = [[SmartPublisherSDK alloc] init];
    
    if (_mediaCapture ==nil ) {
        NSLog(@"_mediaCapture with nil..");
        return;
    }
    
    if(_mediaCapture.delegate == nil)
    {
        _mediaCapture.delegate = self;
    }
    
    if([_mediaCapture SmartPublisherInit:is_audio_only] != DANIULIVE_RETURN_OK){
        NSLog(@"Call SmartPublisherInit failed..");
        //[_mediaCapture release];
        _mediaCapture = nil;
        return;
    }
    
    //录像控制
    if([_mediaCapture SmartPublisherSetRecorder:is_recorder] != DANIULIVE_RETURN_OK){
        NSLog(@"Call SmartPublisherSetRecorder failed..");
        _mediaCapture = nil;
        return;
    }
    
    if (is_recorder)
    {
        //设置录像目录
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *recorderDir = [paths objectAtIndex:0];
        
        if([_mediaCapture SmartPublisherSetRecorderDirectory:recorderDir] != DANIULIVE_RETURN_OK){
            NSLog(@"Call SmartPublisherInit failed..");
            _mediaCapture = nil;
            return;
        }
        
        //每个录像文件大小
        NSInteger size = 200;
        if([_mediaCapture SmartPublisherSetRecorderFileMaxSize:size] != DANIULIVE_RETURN_OK){
            NSLog(@"Call SmartPublisherInit failed..");
            _mediaCapture = nil;
            return;
        }
    }
    
    if(!is_audio_only)
    {
        self.localPreview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
        
        if([_mediaCapture SmartPublisherSetVideoPreview:self.localPreview] != DANIULIVE_RETURN_OK){
            NSLog(@"Call SmartPublisherSetVideoPreview failed..");
            [_mediaCapture SmartPublisherUnInit];
            _mediaCapture = nil;
            return;
        }
    }
    else
    {
        self.localPreview = nil;
        
        if([_mediaCapture SmartPublisherSetVideoPreview:nil] != DANIULIVE_RETURN_OK){
            NSLog(@"Call SmartPublisherSetVideoPreview failed..");
            [_mediaCapture SmartPublisherUnInit];
            _mediaCapture = nil;
            return;
        }

    }

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    
    NSLog(@" docDir: %@", docDir);
    
    if([_mediaCapture SmartPublisherStartCapture:videoQuality] != DANIULIVE_RETURN_OK){
        NSLog(@"Call SmartPublisherStartCapture failed..");
        [_mediaCapture SmartPublisherUnInit];
        _mediaCapture = nil;
        return;
    }
    
    if (!is_audio_only)
    {
        [self.view addSubview:self.localPreview];
    }
    
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

    NSString* sdkVersion = [_mediaCapture SmartPublisherGetSDKVersionID];
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
                textModeLabel.text = @"推流失败，返回 DANIULIVE_RETURN_SDK_EXPIRED，请联系daniulive（QQ：89030985 or 2679481035）授权";
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
        _mediaCapture.delegate = nil;
        _mediaCapture = nil;
    }
    
    //返回设置分辨率页面
    SettingView * settingView =[[SettingView alloc] init];
    [self presentViewController:settingView animated:YES completion:nil];
}

@end