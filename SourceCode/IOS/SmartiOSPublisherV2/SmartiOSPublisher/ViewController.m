//
//  ViewController.m
//  SmartiOSPublisher
//
//  GitHub: https://github.com/daniulive/SmarterStreaming
//  website: http://www.daniulive.com
//
//  Created by daniulive on 16/3/24.
//  Copyright © 2015~2017 daniulive. All rights reserved.
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
    UIButton    *mirrorSwitchButton;        //镜像切换
    UIButton    *publisherStreamButton;     //NEW: 推送和录像功能分离，推送按钮
    UIButton    *recordStreamButton;        //NEW: 推送和录像功能分离，录像按钮
    UIButton    *saveImageButton;           //快照按钮
    UIButton    *beautyLevelButton;         //美颜级别按钮
    UIButton    *backSettingsButton;        //返回到设置分辨率页面
    UILabel     *textModeLabel;             //文字提示
    DNVideoStreamingQuality videoQuality;   //分辨率选择
    NSString    *copyRights;
    NSInteger   audio_opt_;                 //audio选项 0 1 2
    NSInteger   video_opt_;                 //video选项 0 1 2
    Boolean     is_beauty;                  //是否美颜，默认美颜
    Boolean     is_mute;                    //是否静音
    Boolean     is_mirror;                  //是否镜像模式
    CGFloat     screenWidth;
    CGFloat     screenHeight;
    CGFloat     curBeautyLevel;             //美颜level
    UIImage     *image_path;
    NSString    *tmp_path;
}

@synthesize localPreview;

//(本demo快照最终拷贝保存到iOS设备“照片”目录，实际保存位置可自行设置，或以应用场景为准)
- (void)image: (UIImage *)image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo
{
    if (error != NULL) {
        NSLog(@"保存图片到默认相册失败..");
    }
    else
    {
        NSLog(@"保存图片到默认相册成功..");
    }
    
    //删除文件
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDelete=[fileManager removeItemAtPath:tmp_path error:nil];
    NSLog(@"old file deleted: %d",isDelete);
}

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
    else if (nID == EVENT_DANIULIVE_ERC_PUBLISHER_CAPTURE_IMAGE)
    {
        if ((int)param1 == 0)
        {
            NSLog(@"[event]快照成功: %@", param3);
            
            tmp_path = param3;
            
            image_path = [ UIImage imageNamed:param3];
            
            UIImageWriteToSavedPhotosAlbum(image_path, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
        }
        else
        {
            NSLog(@"[event]快照失败: %@", param3);
        }
    }
    else
        NSLog(@"[event]nID:%lx", (long)nID);
    
    return 0;
}

- (instancetype)initParameter:(NSString*)url
                streamQuality:(DNVideoStreamingQuality)streamQuality
                     audioOpt:(NSInteger)audioOpt
                     videoOpt:(NSInteger)videoOpt
                     isBeauty:(Boolean)isBeauty
{
    self = [super init];
    if (!self) {
        return nil;
    }
    else if(self) {
        publishURL = url;
        videoQuality = streamQuality;
        audio_opt_  = audioOpt;
        video_opt_  = videoOpt;
        is_beauty = isBeauty;
        is_mute = false;
        is_mirror = true;   //默认镜像模式
    }
    
    NSLog(@"[initParameter]videoQuality: %u, audio_opt: %ld, video_opt: %ld",videoQuality, (long)audio_opt_, (long)video_opt_);
    
    return self;
}

- (void)loadView
{
    copyRights = @"Copyright 2014~2017 www.daniulive.com v1.0.17.0417";
    
    //当前屏幕宽高
    screenWidth  = CGRectGetWidth([UIScreen mainScreen].bounds);
    screenHeight = CGRectGetHeight([UIScreen mainScreen].bounds);
    
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    
    _smart_publisher_sdk = [[SmartPublisherSDK alloc] init];
    
    if (_smart_publisher_sdk == nil ) {
        NSLog(@"_smart_publisher_sdk with nil..");
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
    
    //NSInteger publish_orientation = 2;	//默认竖屏采集，传1:竖屏，传2:横屏
    
    //[_smart_publisher_sdk SmartPublisherSetPublishOrientation:publish_orientation];
    
    /*
    NSInteger gop_interval = 30;
    [_smart_publisher_sdk SmartPublisherSetGopInterval:gop_interval];
    
    NSInteger fps = 15;
    [_smart_publisher_sdk SmartPublisherSetFPS:fps];
    
    NSInteger avg_bit_rate = 500;
    NSInteger max_bit_rate = 1000;
    
    [_smart_publisher_sdk SmartPublisherSetVideoBitRate:avg_bit_rate maxBitRate:max_bit_rate];
    
    Boolean clip_mode = true;
    [_smart_publisher_sdk SmartPublisherSetClippingMode:clip_mode];
    */
    
    NSInteger image_flag = 1;
    [_smart_publisher_sdk SmartPublisherSaveImageFlag:image_flag];
    
    DN_BEAUTY_TYPE beauty_type;
    
    if (is_beauty)
    {
        beauty_type = DN_BEAUTY_INTERNAL_BEAUTY;
        
        if ( _smart_publisher_sdk != nil )
        {
            curBeautyLevel = 0.1;
            
            [_smart_publisher_sdk SmartPublisherSetBeautyBrightness:curBeautyLevel];
        }
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
    
    if(video_opt_ == 1)
    {
        self.localPreview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
        
        //self.localPreview = [[UIView alloc] initWithFrame:CGRectMake(150, 100, 200, 150)];    //推流本地回显区域设置测试，默认全屏
        
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
    
    //快照按钮
    saveImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    saveImageButton.frame = CGRectMake(45, self.view.frame.size.height - 480, 120, 60);
    saveImageButton.center = CGPointMake(self.view.frame.size.width / 6, saveImageButton.frame.origin.y + saveImageButton.frame.size.height / 2);
    
    saveImageButton.layer.cornerRadius = saveImageButton.frame.size.width / 2;
    saveImageButton.layer.borderColor = [UIColor greenColor].CGColor;
    saveImageButton.layer.borderWidth = lineWidth;
    
    [saveImageButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [saveImageButton setTitle:@"快照" forState:UIControlStateNormal];
    
    [saveImageButton addTarget:self action:@selector(SaveImageBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:saveImageButton];
    
    //美颜level设置
    if(is_beauty)
    {
        beautyLevelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        beautyLevelButton.frame = CGRectMake(45, self.view.frame.size.height - 420, 120, 60);
        beautyLevelButton.center = CGPointMake(self.view.frame.size.width / 6, beautyLevelButton.frame.origin.y + beautyLevelButton.frame.size.height / 2);
        
        beautyLevelButton.layer.cornerRadius = beautyLevelButton.frame.size.width / 2;
        beautyLevelButton.layer.borderColor = [UIColor greenColor].CGColor;
        beautyLevelButton.layer.borderWidth = lineWidth;
        
        [beautyLevelButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        [beautyLevelButton setTitle:@"美颜level" forState:UIControlStateNormal];
        
        [beautyLevelButton addTarget:self action:@selector(beautyLevelBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:beautyLevelButton];
    }
    
    //镜像切换
    mirrorSwitchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    mirrorSwitchButton.frame = CGRectMake(45, self.view.frame.size.height - 360, 120, 60);
    mirrorSwitchButton.center = CGPointMake(self.view.frame.size.width / 6, mirrorSwitchButton.frame.origin.y + mirrorSwitchButton.frame.size.height / 2);
    
    mirrorSwitchButton.layer.cornerRadius = mirrorSwitchButton.frame.size.width / 2;
    mirrorSwitchButton.layer.borderColor = [UIColor greenColor].CGColor;
    mirrorSwitchButton.layer.borderWidth = lineWidth;
    
    [mirrorSwitchButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [mirrorSwitchButton setTitle:@"关镜像" forState:UIControlStateNormal];
    
    [mirrorSwitchButton addTarget:self action:@selector(mirrorSwitchBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:mirrorSwitchButton];
    
    //muteButton
    muteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    muteButton.frame = CGRectMake(45, self.view.frame.size.height - 300, 120, 60);
    muteButton.center = CGPointMake(self.view.frame.size.width / 6, muteButton.frame.origin.y + muteButton.frame.size.height / 2);
    
    muteButton.layer.cornerRadius = muteButton.frame.size.width / 2;
    muteButton.layer.borderColor = [UIColor greenColor].CGColor;
    muteButton.layer.borderWidth = lineWidth;
    
    [muteButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [muteButton setTitle:@"静音" forState:UIControlStateNormal];
    
    [muteButton addTarget:self action:@selector(MuteBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:muteButton];
    
    //前后摄像头交换
    swapCamerasButton = [UIButton buttonWithType:UIButtonTypeCustom];
    swapCamerasButton.frame = CGRectMake(45, self.view.frame.size.height - 240, 120, 60);
    swapCamerasButton.center = CGPointMake(self.view.frame.size.width / 6, swapCamerasButton.frame.origin.y + swapCamerasButton.frame.size.height / 2);
    
    swapCamerasButton.layer.cornerRadius = swapCamerasButton.frame.size.width / 2;
    swapCamerasButton.layer.borderColor = [UIColor greenColor].CGColor;
    swapCamerasButton.layer.borderWidth = lineWidth;
    
    [swapCamerasButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [swapCamerasButton setTitle:@"切后置摄像头" forState:UIControlStateNormal];
    
    swapCamerasButton.selected = NO;
    [swapCamerasButton setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    [swapCamerasButton setTitle:@"切前置摄像头" forState:UIControlStateSelected];
    
    [swapCamerasButton addTarget:self action:@selector(swapCameraBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:swapCamerasButton];
    
    publisherStreamButton = [UIButton buttonWithType:UIButtonTypeCustom];
    publisherStreamButton.frame = CGRectMake(45, self.view.frame.size.height - 180, 120, 60);
    publisherStreamButton.center = CGPointMake(self.view.frame.size.width / 6, publisherStreamButton.frame.origin.y + publisherStreamButton.frame.size.height / 2);
    
    publisherStreamButton.layer.cornerRadius = publisherStreamButton.frame.size.width / 2;
    publisherStreamButton.layer.borderColor = [UIColor greenColor].CGColor;
    publisherStreamButton.layer.borderWidth = lineWidth;
    
    [publisherStreamButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [publisherStreamButton setTitle:@"开推流" forState:UIControlStateNormal];
    
    publisherStreamButton.selected = NO;
    [publisherStreamButton setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    [publisherStreamButton setTitle:@"关推流" forState:UIControlStateSelected];
    
    [publisherStreamButton addTarget:self action:@selector(publisherStreamBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:publisherStreamButton];
    
    
    recordStreamButton = [UIButton buttonWithType:UIButtonTypeCustom];
    recordStreamButton.frame = CGRectMake(45, self.view.frame.size.height - 120, 120, 60);
    recordStreamButton.center = CGPointMake(self.view.frame.size.width / 6, recordStreamButton.frame.origin.y + recordStreamButton.frame.size.height / 2);
    
    recordStreamButton.layer.cornerRadius = recordStreamButton.frame.size.width / 2;
    recordStreamButton.layer.borderColor = [UIColor greenColor].CGColor;
    recordStreamButton.layer.borderWidth = lineWidth;
    
    [recordStreamButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [recordStreamButton setTitle:@"开录像" forState:UIControlStateNormal];
    
    recordStreamButton.selected = NO;
    [recordStreamButton setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    [recordStreamButton setTitle:@"关录像" forState:UIControlStateSelected];
    
    [recordStreamButton addTarget:self action:@selector(recordStreamBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:recordStreamButton];
    
    backSettingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backSettingsButton.frame = CGRectMake(45, self.view.frame.size.height - 60, 60, 60);
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

- (void)publisherStreamBtn:(UIButton *)button{
    NSLog(@"publish Stream only++");
    
    button.selected = !button.selected;
    
    if (button.selected)
    {
        NSLog(@"Run into publisherStreamBtn, start publisher only..");
        
        //NSInteger type = 0;
        
        //[_smart_publisher_sdk SmartPublisherSetRtmpPublishingType:type];
        
        NSLog(@"publishURL: %@",publishURL);
        
        NSString *baseText = @"推送URL：";
        
        textModeLabel.text = [ baseText stringByAppendingString:publishURL];
        
        NSInteger ret = [_smart_publisher_sdk SmartPublisherStartPublisher:publishURL];
        
        if(ret != DANIULIVE_RETURN_OK)
        {
            NSLog(@"Call SmartPublisherStartPublisher failed..ret:%ld", (long)ret);
            
            if (ret == DANIULIVE_RETURN_SDK_EXPIRED) {
                textModeLabel.text = @"单推流失败，返回 DANIULIVE_RETURN_SDK_EXPIRED，请联系daniulive（QQ：89030985 or 2679481035）授权";
            }
            else
            {
                textModeLabel.text = @"单推流失败，返回 DANIULIVE_RETURN_ERROR";
            }
            
            return;
        }
        else
        {
            medResolution.enabled = NO;
            backSettingsButton.enabled = NO;
            [publisherStreamButton setTitle:@"关推流" forState:UIControlStateNormal];
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
        NSLog(@"Run into publish Stream, stop publisher only..");
        
        medResolution.enabled = YES;
        backSettingsButton.enabled = YES;
        [_smart_publisher_sdk SmartPublisherStopPublisher];
        [publisherStreamButton setTitle:@"开推流" forState:UIControlStateNormal];
    }
}

- (void)recordStreamBtn:(UIButton *)button{
    NSLog(@"record Stream only++");
    
    button.selected = !button.selected;
    
    if (button.selected)
    {
        NSInteger recorder = 1;
        if([_smart_publisher_sdk SmartPublisherSetRecorder:recorder] != DANIULIVE_RETURN_OK)
        {
            NSLog(@"Call SmartPublisherSetRecorder failed..");
        }
        
        //设置录像目录
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *recorderDir = [paths objectAtIndex:0];
        
        if([_smart_publisher_sdk SmartPublisherSetRecorderDirectory:recorderDir] != DANIULIVE_RETURN_OK)
        {
            NSLog(@"Call SmartPublisherSetRecorderDirectory failed..");
        }
        
        //每个录像文件大小
        NSInteger size = 200;
        if([_smart_publisher_sdk SmartPublisherSetRecorderFileMaxSize:size] != DANIULIVE_RETURN_OK)
        {
            NSLog(@"Call SmartPublisherSetRecorderFileMaxSize failed..");
        }
        
        [_smart_publisher_sdk SmartPublisherStartRecorder];
        [recordStreamButton setTitle:@"关录像" forState:UIControlStateNormal];
        backSettingsButton.enabled = NO;
    }
    else
    {
        [_smart_publisher_sdk SmartPublisherStopRecorder];
        [recordStreamButton setTitle:@"开录像" forState:UIControlStateNormal];
        backSettingsButton.enabled = YES;
    }
}

- (void)SaveImageBtn:(id)sender {
    if ( _smart_publisher_sdk != nil )
    {
        //设置快照目录
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *saveImageDir = [paths objectAtIndex:0];
        
        NSLog(@"[SaveImageBtn] path: %@", saveImageDir);
        
        NSString* symbol = @"/";
        
        NSString* png = @".png";
        
        // 1.创建时间
        NSDate *datenow = [NSDate date];
        // 2.创建时间格式化
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        // 3.指定格式
        formatter.dateFormat = @"yyyyMMdd_HHmmss";
        // 4.格式化时间
        NSString *timeSp = [formatter stringFromDate:datenow];
        
        NSString* image_name =  [saveImageDir stringByAppendingString:symbol];
        
        image_name = [image_name stringByAppendingString:timeSp];
        
        image_name = [image_name stringByAppendingString:png];
        
        NSLog(@"[SaveImageBtn] image_name: %@", image_name);
        
        [_smart_publisher_sdk SmartPublisherSaveCurImage:image_name];
    }
}

- (void)mirrorSwitchBtn:(id)sender {
    if ( _smart_publisher_sdk != nil )
    {
        is_mirror = !is_mirror;
        
        [_smart_publisher_sdk SmartPublisherSetMirror:is_mirror];
        
        if ( is_mirror )
        {
            [mirrorSwitchButton setTitle:@"关镜像" forState:UIControlStateNormal];
        }
        else
        {
            [mirrorSwitchButton setTitle:@"开镜像" forState:UIControlStateNormal];
        }
    }
}

- (void)beautyLevelBtn:(id)sender {
    //demo是0~1随机设置，具体使用，可根据实际效果，自行调节
    if ( _smart_publisher_sdk != nil )
    {
        if (curBeautyLevel > 1) {
            curBeautyLevel = 0;
        }
        else
        {
            curBeautyLevel = curBeautyLevel + 0.1;
        }
        
        NSLog(@"curBeautyLevel:%f", curBeautyLevel);
        
        [_smart_publisher_sdk SmartPublisherSetBeautyBrightness:curBeautyLevel];
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
