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
@property (nonatomic,strong) SmartPublisherSDK *smart_publisher_sdk;

- (void)swapCameraBtnPressed:(id)sender;

@end


@implementation ViewController{
    NSString    *publishURL;
    UIButton    *medResolution;
    UIButton    *beautyButton;              //美颜设置
    UIButton    *swapCamerasButton;         //前后摄像头切换
    UIButton    *muteButton;                //静音控制
    UIButton    *publisherButton;           //推流控制
    UIButton    *backSettingsButton;        //返回到设置分辨率页面
    UILabel     *textModeLabel;             //文字提示
    NSInteger   randNumber;
    DNVideoStreamingQuality videoQuality;   //分辨率选择
    NSString    *copyRights;
    NSInteger   audio_opt_;                 //audio选项 0 1 2
    NSInteger   video_opt_;                 //video选项 0 1 2
    Boolean     is_recorder;                //默认不录像，如果设为true，则录像
    Boolean     is_beauty;                  //是否美颜，默认美颜
    DN_FILTER_TYPE  filter_type;            //美颜类型
    Boolean     is_mute;                    // 是否静音
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

- (instancetype)initParameter:(DNVideoStreamingQuality)streamQuality audioOpt:(NSInteger)audioOpt videoOpt:(NSInteger)videoOpt
                   isRecorder:(Boolean)isRecorder isBeauty:(Boolean)isBeauty
{
    self = [super init];
    if (!self) {
        return nil;
    }
    else if(self) {
        videoQuality = streamQuality;
        audio_opt_  = audioOpt;
        video_opt_  = videoOpt;
        is_recorder   = isRecorder;
        is_beauty = isBeauty;
        is_mute = false;
    }
    
    NSLog(@"[initParameter]videoQuality: %u, audio_opt: %ld, video_opt: %ld, is_recorder: %d",videoQuality, (long)audio_opt_, (long)video_opt_, is_recorder);
    
    return self;
}

- (void)loadView
{
    copyRights = @"Copyright 2014~2016 www.daniulive.com v1.0.16.1022";
    //当前屏幕宽高
    CGFloat screenWidth  = CGRectGetWidth([UIScreen mainScreen].bounds);
    CGFloat screenHeight = CGRectGetHeight([UIScreen mainScreen].bounds);
    
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    
    _smart_publisher_sdk = [[SmartPublisherSDK alloc] init];
    
    if (_smart_publisher_sdk == nil ) {
        NSLog(@"_mediaCapture with nil..");
        return;
    }
    
    if(_smart_publisher_sdk.delegate == nil)
    {
        _smart_publisher_sdk.delegate = self;
    }
    
    
    NSString* sdkVersion = [_smart_publisher_sdk SmartPublisherGetSDKVersionID];
    NSLog(@"sdk version:%@",sdkVersion);
    
    if([_smart_publisher_sdk SmartPublisherInit:audio_opt_ video_opt:video_opt_] != DANIULIVE_RETURN_OK)
    {
        NSLog(@"Call SmartPublisherInit failed..");
        
        _smart_publisher_sdk = nil;
        return;
    }
    
    DN_BEAUTY_TYPE beauty_type;
    
    if (is_beauty)
    {
        beauty_type = DN_BEAUTY_INTERNAL_BEAUTY;
    }
    else
    {
        beauty_type = DN_BEAUTY_NONE;
    }
    
    if([_smart_publisher_sdk SmartPublisherSetBeauty:beauty_type] != DANIULIVE_RETURN_OK)
    {
        NSLog(@"Call SmartPublisherSetBeauty failed..");

        _smart_publisher_sdk = nil;
        return;
    }
    
    //录像控制
    if([_smart_publisher_sdk SmartPublisherSetRecorder:is_recorder] != DANIULIVE_RETURN_OK)
    {
        NSLog(@"Call SmartPublisherSetRecorder failed..");
    }
    
    if (is_recorder)
    {
        //设置录像目录
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *recorderDir = [paths objectAtIndex:0];
        
        if([_smart_publisher_sdk SmartPublisherSetRecorderDirectory:recorderDir] != DANIULIVE_RETURN_OK)
        {
            NSLog(@"Call SmartPublisherInit failed..");
        }
        
        //每个录像文件大小
        NSInteger size = 200;
        if([_smart_publisher_sdk SmartPublisherSetRecorderFileMaxSize:size] != DANIULIVE_RETURN_OK)
        {
            NSLog(@"Call SmartPublisherInit failed..");
        }
    }
    
    if(video_opt_ == 1)
    {
        self.localPreview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
        
        //self.localPreview = [[UIView alloc] initWithFrame:CGRectMake(100, 130, 200, 200)];    //推流本地回显区域设置测试，默认全屏
        
        if([_smart_publisher_sdk SmartPublisherSetVideoPreview:self.localPreview] != DANIULIVE_RETURN_OK)
        {
            NSLog(@"Call SmartPublisherSetVideoPreview failed..");
            [_smart_publisher_sdk SmartPublisherUnInit];
            _smart_publisher_sdk = nil;
            return;
        }
    }
    else
    {
        self.localPreview = nil;
        
        if([_smart_publisher_sdk SmartPublisherSetVideoPreview:nil] != DANIULIVE_RETURN_OK)
        {
            NSLog(@"Call SmartPublisherSetVideoPreview failed..");
            [_smart_publisher_sdk SmartPublisherUnInit];
            _smart_publisher_sdk = nil;
            return;
        }
    }

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    
    NSLog(@" docDir: %@", docDir);
    
    if([_smart_publisher_sdk SmartPublisherStartCapture:videoQuality] != DANIULIVE_RETURN_OK)
    {
        NSLog(@"Call SmartPublisherStartCapture failed..");
        [_smart_publisher_sdk SmartPublisherUnInit];
        _smart_publisher_sdk = nil;
        return;
    }
    
    if (video_opt_ == 1)
    {
        [self.view addSubview:self.localPreview];
    }
    
    CGFloat lineWidth = swapCamerasButton.frame.size.width * 0.12f;
    
    //muteButton
    muteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    muteButton.frame = CGRectMake(45, self.view.frame.size.height - 400, 120, 60);
    muteButton.center = CGPointMake(self.view.frame.size.width / 6, muteButton.frame.origin.y + muteButton.frame.size.height / 2);
    
    muteButton.layer.cornerRadius = muteButton.frame.size.width / 2;
    muteButton.layer.borderColor = [UIColor greenColor].CGColor;
    muteButton.layer.borderWidth = lineWidth;
    
    [muteButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [muteButton setTitle:@"静音" forState:UIControlStateNormal];
    
    [muteButton addTarget:self action:@selector(MuteBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:muteButton];
    
    
    //美颜设置
    beautyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    beautyButton.frame = CGRectMake(45, self.view.frame.size.height - 320, 60, 60);
    beautyButton.center = CGPointMake(self.view.frame.size.width / 6, beautyButton.frame.origin.y + beautyButton.frame.size.height / 2);
    
    beautyButton.layer.cornerRadius = beautyButton.frame.size.width / 2;
    beautyButton.layer.borderColor = [UIColor greenColor].CGColor;
    beautyButton.layer.borderWidth = lineWidth;
    
    [beautyButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [beautyButton setTitle:@"美颜" forState:UIControlStateNormal];
    
    [beautyButton addTarget:self action:@selector(beautySettingsBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:beautyButton];
    
    //前后摄像头交换
    swapCamerasButton = [UIButton buttonWithType:UIButtonTypeCustom];
    swapCamerasButton.frame = CGRectMake(45, self.view.frame.size.height - 240, 60, 60);
    swapCamerasButton.center = CGPointMake(self.view.frame.size.width / 6, swapCamerasButton.frame.origin.y + swapCamerasButton.frame.size.height / 2);
    
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
}


- (void)MuteBtn:(id)sender {
    if ( _smart_publisher_sdk != nil )
    {
        is_mute = !is_mute;
        
        if ( is_mute )
        {
            [muteButton setTitle:@"取消静音" forState:UIControlStateNormal];
        }
        else
        {
             [muteButton setTitle:@"静音" forState:UIControlStateNormal];
        }
        
        [_smart_publisher_sdk SmartPublisherSetMute:is_mute];
    }
}

- (void)beautySettingsBtn:(id)sender {

    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"美颜选择" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"请选择以下5种美颜效果" otherButtonTitles:@"美颜",@"复古",@"素描",@"高亮",@"高亮+美颜", nil];
    
    actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
    [actionSheet showInView:self.view];
    
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //按照按钮的顺序0-N；
    switch (buttonIndex) {
        case 0:
            NSLog(@"点击了不设置美颜");
            filter_type = DN_FILTER_NONE;
            break;
            
        case 1:
            NSLog(@"点击了美颜");
            filter_type = DN_FILTER_TYPE_BEAUTY;
            break;
            
        case 2:
            NSLog(@"点击了复古");
            filter_type = DN_FILTER_TYPE_SEPIA;
            break;
            
        case 3:
            NSLog(@"点击了素描");
            filter_type = DN_FILTER_TYPE_SKETCH;
            break;
            
        case 4:
            NSLog(@"点击了高亮");
            filter_type = DN_FILTER_TYPE_BRIGHT;
            break;
            
        case 5:
            NSLog(@"点击了高亮+美颜");
            filter_type = DN_FILTER_TYPE_BRIGHT_BEAUTY;
            break;
            
        default:
            break;
    }
    
    if (_smart_publisher_sdk != nil) {
        [_smart_publisher_sdk SmartPublisherSetBeautyFilterType:filter_type];
    }
 
}

- (void)swapCameraBtnPressed:(UIButton *)button
{
    
    NSLog(@"Run into swapCameraBtnPressed..");
    
    button.selected = !button.selected;
    
    [_smart_publisher_sdk SmartPublisherSwitchCamera];
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
    NSLog(@"publishStream++");
    
    button.selected = !button.selected;
    
    if (button.selected)
    {
        NSLog(@"Run into publishStream, start publisher..");
        
        randNumber = arc4random()%(1000000);
        
        NSString *strNumber = [NSString stringWithFormat:@"%ld", (long)randNumber];
        
        NSString *baseURL = @"rtmp://player.daniulive.com:1935/hls/stream";
        
        publishURL = [ baseURL stringByAppendingString:strNumber];
        
        NSLog(@"publishURL: %@",publishURL);
        
        NSString *baseText = @"推送URL：";
        
        textModeLabel.text = [ baseText stringByAppendingString:publishURL];
        
        NSInteger ret = [_smart_publisher_sdk SmartPublisherStartPublish:publishURL];
        
        if(ret != DANIULIVE_RETURN_OK)
        {
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
        
        //only for decoded audio processing test..
        /*
        char aac[] = {0x20, 0x66, 0x00, 0x01, 0x98, 0x00, 0x0e};
        char aac_config[] = {0x12, 0x10};
        [_mediaCapture SmartPublisherSetAudioSpecificConfig:aac_config len:2];
        
        unsigned long long tttt = 0;
        for ( int i = 0; i < 1000; ++i )
        {
            tttt = i*23;
            [_mediaCapture SmartPublisherOnReceivingAACData:aac len:7 isKeyFrame:1 timeStamp:tttt];
        }
        */
        //end
        
    }
    else
    {
        NSLog(@"Run into publishStream, stop publisher..");
        
        medResolution.enabled = YES;
        backSettingsButton.enabled = YES;
        [_smart_publisher_sdk SmartPublisherStopPublish];
    }
    
}

- (void)backSettingsBtn:(UIButton *)button
{
    
    NSLog(@"Run into backSettingsBtn..");
    
    if (_smart_publisher_sdk != nil)
    {
        [_smart_publisher_sdk SmartPublisherStopCaputure];
        [_smart_publisher_sdk SmartPublisherUnInit];
        _smart_publisher_sdk.delegate = nil;
        _smart_publisher_sdk = nil;
    }
    
    //返回设置分辨率页面
    SettingView * settingView =[[SettingView alloc] init];
    [self presentViewController:settingView animated:YES completion:nil];
}

@end
