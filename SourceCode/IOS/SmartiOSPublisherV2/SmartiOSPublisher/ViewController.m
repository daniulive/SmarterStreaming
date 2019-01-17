//
//  ViewController.m
//  SmartiOSPublisher
//
//  GitHub: https://github.com/daniulive/SmarterStreaming
//  website: https://www.daniulive.com
//
//  Created by daniulive on 16/3/24.
//  Copyright © 2014~2019 daniulive. All rights reserved.
//

#import "ViewController.h"
#import "SettingView.h"
#import "SmartRTSPSeverSDK.h"

@interface ViewController () <UITableViewDelegate, UINavigationControllerDelegate>

//预览视图
@property (nonatomic, strong) UIView *localPreview;
//rtmp推送url文本显示
@property (strong, nonatomic) UILabel *textPubisherUrlLabel;
//event状态显示
@property (strong, nonatomic) UILabel *textPublisherEventLabel;

//推流SDK API
@property (nonatomic,strong) SmartPublisherSDK *smart_publisher_sdk;
//内置轻量级RTSP服务SDK API
@property (nonatomic,strong) SmartRTSPServerSDK *smart_rtsp_server_sdk;

@end


@implementation ViewController{
    NSString    *rtmp_push_url;             //RTMP推送url
    NSString    *rtsp_push_url;             //RTSP推送url
    UIButton    *swapCamerasButton;         //前后摄像头切换
    UIButton    *mirrorSwitchButton;        //镜像切换
    UIButton    *muteButton;                //静音控制
    UIButton    *getRtspSvrSessionNumButton;//获取rtsp server当前的客户会话数
    
    UIButton    *rtmpPusherButton;          //RTMP推送按钮
    UIButton    *rtspPusherButton;          //RTSP推送按钮
    UIButton    *recordStreamButton;        //录像按钮(mp4格式)
    
    UIButton    *rtspServiceButton;         //内置服务按钮, 启动/停止服务
    UIButton    *rtspPublisherButton;       //内置rtsp服务功能
    
    UIButton    *pushUserDataButton;        //发送用户数据按钮
    UIButton    *saveImageButton;           //快照按钮
    UIButton    *beautyLevelButton;         //美颜级别按钮
    UIButton    *backSettingsButton;        //返回到设置分辨率页面
    DNVideoStreamingQuality videoQuality;   //分辨率选择
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
    void        *rtsp_handle_;
    NSInteger   publish_orientation_;       //默认竖屏采集，传1:竖屏，传2:横屏(home键在右侧)
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
    NSString* pubilisher_event = @"";
    NSString* lable = @"";
    
    if (nID == EVENT_DANIULIVE_ERC_PUBLISHER_STARTED) {
        lable = @"开始推流..url:";
        pubilisher_event = [lable stringByAppendingFormat:@"%@", param3];
    }
    else if (nID == EVENT_DANIULIVE_ERC_PUBLISHER_CONNECTING)
    {
        pubilisher_event = @"连接中..";
    }
    else if (nID == EVENT_DANIULIVE_ERC_PUBLISHER_CONNECTION_FAILED)
    {
        pubilisher_event = @"连接失败..";
    }
    else if (nID == EVENT_DANIULIVE_ERC_PUBLISHER_CONNECTED)
    {
        pubilisher_event = @"已连接..";
    }
    else if (nID == EVENT_DANIULIVE_ERC_PUBLISHER_DISCONNECTED)
    {
        pubilisher_event = @"断开连接..";
    }
    else if (nID == EVENT_DANIULIVE_ERC_PUBLISHER_STOP)
    {
        lable = @"停止推流..url:";
        pubilisher_event = [lable stringByAppendingFormat:@"%@", param3];
    }
    else if (nID == EVENT_DANIULIVE_ERC_PUBLISHER_RECORDER_START_NEW_FILE)
    {
        lable = @"录像写入新文件..文件名:";
        pubilisher_event = [lable stringByAppendingFormat:@"%@", param3];
    }
    else if (nID == EVENT_DANIULIVE_ERC_PUBLISHER_ONE_RECORDER_FILE_FINISHED)
    {
        lable = @"一个录像文件完成..文件名:";
        pubilisher_event = [lable stringByAppendingFormat:@"%@", param3];
    }
    else if (nID == EVENT_DANIULIVE_ERC_PUBLISHER_CAPTURE_IMAGE)
    {
        if ((int)param1 == 0)
        {
            lable = @"快照成功:";
            pubilisher_event = [lable stringByAppendingFormat:@"%@", param3];
            
            tmp_path = param3;
            
            image_path = [ UIImage imageNamed:param3];
            
            UIImageWriteToSavedPhotosAlbum(image_path, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
        }
        else
        {
            lable = @"快照失败:";
            pubilisher_event = [lable stringByAppendingFormat:@"%@", param3];
        }
    }
    else if (nID == EVENT_DANIULIVE_ERC_PUBLISHER_RTSP_URL)
    {
        lable = @"RTSP服务URL:";
        pubilisher_event = [lable stringByAppendingFormat:@"%@", param3];
    }
    else
    {
        lable = @"nID:";
        pubilisher_event = [lable stringByAppendingFormat:@"%lx", (long)nID];
    }
    
    NSString* publisher_event_tag = @"当前状态:";
    
    if(nID == EVENT_DANIULIVE_ERC_PUBLISHER_RTSP_URL)
    {
        publisher_event_tag = @"";
    }
    
    NSString* event = [publisher_event_tag stringByAppendingFormat:@"%@", pubilisher_event];
    
    NSLog(@"%@", event);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            self.textPublisherEventLabel.text = event;
        });
    });
    
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
        rtmp_push_url = url;
        videoQuality = streamQuality;
        audio_opt_  = audioOpt;
        video_opt_  = videoOpt;
        is_beauty = isBeauty;
        is_mute = false;
        is_mirror = false;   //默认镜像模式
        rtsp_handle_ = NULL;
        rtsp_push_url = @"";
    }
    
    NSLog(@"[initParameter]videoQuality: %u, audio_opt: %ld, video_opt: %ld",videoQuality, (long)audio_opt_, (long)video_opt_);
    
    return self;
}

- (void)loadView
{
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
    
    if([_smart_publisher_sdk SmartPublisherInit:audio_opt_ video_opt:video_opt_] != DANIULIVE_RETURN_OK)
    {
        NSLog(@"Call SmartPublisherInit failed..");
        
        _smart_publisher_sdk = nil;
        return;
    }
    
    //设置横竖屏采集模式，传1:竖屏，传2:横屏(home键在右侧)
    publish_orientation_ = 1;
    [_smart_publisher_sdk SmartPublisherSetPublishOrientation:publish_orientation_];
     
    NSInteger video_encoder_type = 1;    //1: H.264, 2: H.265编码
    Boolean is_video_hardware_encoder = YES;
    [_smart_publisher_sdk SmartPublisherSetVideoEncoderType:video_encoder_type isHwEncoder:is_video_hardware_encoder];
    
    NSInteger audio_encoder_type = 1;    //1: AAC
    Boolean is_audio_hardware_encoder = NO;
    [_smart_publisher_sdk SmartPublisherSetAudioEncoderType:audio_encoder_type isHwEncoder:is_audio_hardware_encoder];
    
    NSInteger is_enable_vbr = 1;
    NSInteger video_quality = [self CalVideoQuality:videoQuality is_h264:YES];
    NSInteger vbr_max_kbitrate = [self CalVbrMaxKBitRate:videoQuality];
    [_smart_publisher_sdk SmartPublisherSetSwVBRMode:is_enable_vbr video_quality:video_quality vbr_max_kbitrate:vbr_max_kbitrate];
    
    //NSInteger gop_interval = 40;
    //[_smart_publisher_sdk SmartPublisherSetGopInterval:gop_interval];
     
    //NSInteger fps = 20;
    //[_smart_publisher_sdk SmartPublisherSetFPS:fps];
    
    //NSInteger sw_video_encoder_profile = 1;
    //[_smart_publisher_sdk SmartPublisherSetSWVideoEncoderProfile:sw_video_encoder_profile];
    
    //NSInteger sw_video_encoder_speed = 2;
    //[_smart_publisher_sdk SmartPublisherSetSWVideoEncoderSpeed:sw_video_encoder_speed];
    
     /*
     NSInteger avg_bit_rate = 500;
     NSInteger max_bit_rate = 1000;
     
     [_smart_publisher_sdk SmartPublisherSetVideoBitRate:avg_bit_rate maxBitRate:max_bit_rate];
     
     Boolean clip_mode = true;
     [_smart_publisher_sdk SmartPublisherSetClippingMode:clip_mode];
     */
    
    [_smart_publisher_sdk SmartPublisherSetPostUserDataQueueMaxSize:3 reserve:0];
    
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
        if(publish_orientation_ == 1)   //竖屏模式
        {
            self.localPreview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
        }
        else
        {
            self.localPreview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenHeight, screenWidth)];
        }
        
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
    
    NSLog(@"docDir: %@", docDir);
    
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
    [saveImageButton setTitle:@"实时快照" forState:UIControlStateNormal];
    
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
    
    //前后摄像头交换
    swapCamerasButton = [UIButton buttonWithType:UIButtonTypeCustom];
    swapCamerasButton.frame = CGRectMake(45, self.view.frame.size.height - 360, 120, 60);
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
    
    //镜像切换
    mirrorSwitchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    mirrorSwitchButton.frame = CGRectMake(45, self.view.frame.size.height - 360, 120, 60);
    mirrorSwitchButton.center = CGPointMake(self.view.frame.size.width / 2, mirrorSwitchButton.frame.origin.y + mirrorSwitchButton.frame.size.height / 2);
    
    mirrorSwitchButton.layer.cornerRadius = mirrorSwitchButton.frame.size.width / 2;
    mirrorSwitchButton.layer.borderColor = [UIColor greenColor].CGColor;
    mirrorSwitchButton.layer.borderWidth = lineWidth;
    
    [mirrorSwitchButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [mirrorSwitchButton setTitle:@"当前镜像:关闭" forState:UIControlStateNormal];
    
    [mirrorSwitchButton addTarget:self action:@selector(mirrorSwitchBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:mirrorSwitchButton];
    
    //实时静音按钮
    muteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    muteButton.frame = CGRectMake(45, self.view.frame.size.height - 300, 120, 60);
    muteButton.center = CGPointMake(self.view.frame.size.width / 6, muteButton.frame.origin.y + muteButton.frame.size.height / 2);
    
    muteButton.layer.cornerRadius = muteButton.frame.size.width / 2;
    muteButton.layer.borderColor = [UIColor greenColor].CGColor;
    muteButton.layer.borderWidth = lineWidth;
    
    [muteButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [muteButton setTitle:@"实时静音" forState:UIControlStateNormal];
    
    [muteButton addTarget:self action:@selector(muteBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:muteButton];
    
    //获取rtsp server当前的客户会话数
    getRtspSvrSessionNumButton = [UIButton buttonWithType:UIButtonTypeCustom];
    getRtspSvrSessionNumButton.frame = CGRectMake(45, self.view.frame.size.height - 300, 180, 60);
    getRtspSvrSessionNumButton.center = CGPointMake(self.view.frame.size.width / 2, getRtspSvrSessionNumButton.frame.origin.y + getRtspSvrSessionNumButton.frame.size.height / 2);
    
    getRtspSvrSessionNumButton.layer.cornerRadius = getRtspSvrSessionNumButton.frame.size.width / 2;
    getRtspSvrSessionNumButton.layer.borderColor = [UIColor greenColor].CGColor;
    getRtspSvrSessionNumButton.layer.borderWidth = lineWidth;
    
    [getRtspSvrSessionNumButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [getRtspSvrSessionNumButton setTitle:@"获取RTSP会话数" forState:UIControlStateNormal];
    
    [getRtspSvrSessionNumButton addTarget:self action:@selector(getRtspSvrSessionNumBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:getRtspSvrSessionNumButton];
    
    getRtspSvrSessionNumButton.hidden = YES;
    
    //RTSP推流按钮
    rtspPusherButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rtspPusherButton.frame = CGRectMake(45, self.view.frame.size.height - 240, 120, 60);
    rtspPusherButton.center = CGPointMake(self.view.frame.size.width / 6, rtspPusherButton.frame.origin.y + rtspPusherButton.frame.size.height / 2);
    
    rtspPusherButton.layer.cornerRadius = rtmpPusherButton.frame.size.width / 2;
    rtspPusherButton.layer.borderColor = [UIColor greenColor].CGColor;
    rtspPusherButton.layer.borderWidth = lineWidth;
    
    [rtspPusherButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [rtspPusherButton setTitle:@"推送RTSP" forState:UIControlStateNormal];
    
    rtspPusherButton.selected = NO;
    [rtspPusherButton setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    [rtspPusherButton setTitle:@"停止RTSP" forState:UIControlStateSelected];
    
    [rtspPusherButton addTarget:self action:@selector(rtspPusherBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:rtspPusherButton];
    
    //推送用户数据
    pushUserDataButton = [UIButton buttonWithType:UIButtonTypeCustom];
    pushUserDataButton.frame = CGRectMake(45, self.view.frame.size.height - 240, 120, 60);
    pushUserDataButton.center = CGPointMake(self.view.frame.size.width / 2, pushUserDataButton.frame.origin.y + pushUserDataButton.frame.size.height / 2);
    
    pushUserDataButton.layer.cornerRadius = pushUserDataButton.frame.size.width / 2;
    pushUserDataButton.layer.borderColor = [UIColor greenColor].CGColor;
    pushUserDataButton.layer.borderWidth = lineWidth;
    
    [pushUserDataButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [pushUserDataButton setTitle:@"实时发送文本" forState:UIControlStateNormal];
    
    [pushUserDataButton addTarget:self action:@selector(pushUserDataBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:pushUserDataButton];
    
    //RTMP推流按钮
    rtmpPusherButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rtmpPusherButton.frame = CGRectMake(45, self.view.frame.size.height - 180, 120, 60);
    rtmpPusherButton.center = CGPointMake(self.view.frame.size.width / 6, rtmpPusherButton.frame.origin.y + rtmpPusherButton.frame.size.height / 2);
    
    rtmpPusherButton.layer.cornerRadius = rtmpPusherButton.frame.size.width / 2;
    rtmpPusherButton.layer.borderColor = [UIColor greenColor].CGColor;
    rtmpPusherButton.layer.borderWidth = lineWidth;
    
    [rtmpPusherButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [rtmpPusherButton setTitle:@"推送RTMP" forState:UIControlStateNormal];
    
    rtmpPusherButton.selected = NO;
    [rtmpPusherButton setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    [rtmpPusherButton setTitle:@"停止RTMP" forState:UIControlStateSelected];
    
    [rtmpPusherButton addTarget:self action:@selector(rtmpPusherBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:rtmpPusherButton];
    
    //mp4录像按钮
    recordStreamButton = [UIButton buttonWithType:UIButtonTypeCustom];
    recordStreamButton.frame = CGRectMake(45, self.view.frame.size.height - 180, 120, 60);
    recordStreamButton.center = CGPointMake(self.view.frame.size.width / 2, recordStreamButton.frame.origin.y + recordStreamButton.frame.size.height / 2);
    
    recordStreamButton.layer.cornerRadius = recordStreamButton.frame.size.width / 2;
    recordStreamButton.layer.borderColor = [UIColor greenColor].CGColor;
    recordStreamButton.layer.borderWidth = lineWidth;
    
    [recordStreamButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [recordStreamButton setTitle:@"实时录像" forState:UIControlStateNormal];
    
    recordStreamButton.selected = NO;
    [recordStreamButton setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    [recordStreamButton setTitle:@"停止录像" forState:UIControlStateSelected];
    
    [recordStreamButton addTarget:self action:@selector(recordStreamBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:recordStreamButton];
    
    //启动、停止RTSP服务
    rtspServiceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rtspServiceButton.frame = CGRectMake(45, self.view.frame.size.height - 120, 120, 60);
    rtspServiceButton.center = CGPointMake(self.view.frame.size.width / 6, rtspServiceButton.frame.origin.y + rtspServiceButton.frame.size.height / 2);
    
    rtspServiceButton.layer.cornerRadius = rtspServiceButton.frame.size.width / 2;
    rtspServiceButton.layer.borderColor = [UIColor greenColor].CGColor;
    rtspServiceButton.layer.borderWidth = lineWidth;
    
    [rtspServiceButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [rtspServiceButton setTitle:@"启动RTSP服务" forState:UIControlStateNormal];
    
    rtspServiceButton.selected = NO;
    [rtspServiceButton setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    [rtspServiceButton setTitle:@"停止RTSP服务" forState:UIControlStateSelected];
    
    [rtspServiceButton addTarget:self action:@selector(rtspServiceBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:rtspServiceButton];
    
    //rtsp内置服务器
    rtspPublisherButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rtspPublisherButton.frame = CGRectMake(45, self.view.frame.size.height - 120, 120, 60);
    rtspPublisherButton.center = CGPointMake(self.view.frame.size.width / 2, rtspPublisherButton.frame.origin.y + rtspPublisherButton.frame.size.height / 2);
    
    rtspPublisherButton.layer.cornerRadius = rtspPublisherButton.frame.size.width / 2;
    rtspPublisherButton.layer.borderColor = [UIColor greenColor].CGColor;
    rtspPublisherButton.layer.borderWidth = lineWidth;
    
    [rtspPublisherButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [rtspPublisherButton setTitle:@"发布RTSP流" forState:UIControlStateNormal];
    
    rtspPublisherButton.selected = NO;
    [rtspPublisherButton setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    [rtspPublisherButton setTitle:@"停止RTSP流" forState:UIControlStateSelected];
    
    [rtspPublisherButton addTarget:self action:@selector(rtspPublisherBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:rtspPublisherButton];
    
    //启动RTSP服务后，才可以发布RTSP流
    rtspPublisherButton.hidden = YES;
    
    //返回按钮
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
    
    // 创建推流URL文本
    _textPubisherUrlLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, self.view.frame.size.width, 50)];
    // 设置UILabel的背景色
    _textPubisherUrlLabel.backgroundColor = [UIColor clearColor];
    // 设置UILabel的文本颜色
    _textPubisherUrlLabel.textColor = [UIColor colorWithRed:1.0 green:0.0
                                                       blue:1.0 alpha:1.0];
    
    _textPubisherUrlLabel.adjustsFontSizeToFitWidth = YES;
    
    _textPubisherUrlLabel.text = @"推流URL:";
    [self.view addSubview:_textPubisherUrlLabel];
    
    // 创建Event显示文本
    _textPublisherEventLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 50)];
    // 设置UILabel的背景色
    _textPublisherEventLabel.backgroundColor = [UIColor clearColor];
    // 设置UILabel的文本颜色
    _textPublisherEventLabel.textColor = [UIColor colorWithRed:1.0 green:0.0
                                                          blue:1.0 alpha:1.0];
    
    _textPublisherEventLabel.adjustsFontSizeToFitWidth = YES;
    
    _textPublisherEventLabel.text = @"大牛直播SDK daniulive.com v1.0.18.0731";
    [self.view addSubview:_textPublisherEventLabel];
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

- (void)rtmpPusherBtn:(UIButton *)button{
    NSLog(@"rtmpPusherBtn++");
    
    button.selected = !button.selected;
    
    if (button.selected)
    {
        NSLog(@"Run into rtmpPusher, StartPublisher..");
        
        //NSInteger type = 0;
        
        //[_smart_publisher_sdk SmartPublisherSetRtmpPublishingType:type];
        
        NSLog(@"rtmp pusher url: %@",rtmp_push_url);
        
        NSString *baseText = @"RTMP推送URL：";
        
        _textPubisherUrlLabel.text = [ baseText stringByAppendingString:rtmp_push_url];
        
        NSInteger ret = [_smart_publisher_sdk SmartPublisherStartPublisher:rtmp_push_url];
        
        if(ret != DANIULIVE_RETURN_OK)
        {
            NSLog(@"Call SmartPublisherStartPublisher failed..ret:%ld", (long)ret);
            
            if (ret == DANIULIVE_RETURN_SDK_EXPIRED) {
                _textPublisherEventLabel.text = @"SDK已过期，请联系视沃科技(www.daniulive.com QQ:89030985 or 2679481035)获取授权";
            }
            else
            {
                _textPublisherEventLabel.text = @"推流失败，返回ERROR";
            }
            
            return;
        }
        else
        {
            backSettingsButton.enabled = NO;
            [rtmpPusherButton setTitle:@"停止RTMP" forState:UIControlStateNormal];
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
        NSLog(@"Run into rtmpPusher, StopPublisher..");
        
        backSettingsButton.enabled = YES;
        [_smart_publisher_sdk SmartPublisherStopPublisher];
        [rtmpPusherButton setTitle:@"推送RTMP" forState:UIControlStateNormal];
    }
}

- (void)rtspPusherBtn:(UIButton *)button{
    NSLog(@"rtspPusherBtn++");
    
    button.selected = !button.selected;
    
    if (button.selected)
    {
        NSLog(@"Run into rtspPusher, StartPusher..");
        
        //生成个类似于“rtsp://player.daniulive.com:554/live123.sdp”的rtsp推送url 如自建服务器 可直接用自己的url
        NSString *baseURL = @"rtsp://player.daniulive.com:554/live";
        NSString *strNumber = [NSString stringWithFormat:@"%ld", (long)(arc4random()%(1000000))];
        NSString *postfixStr = @".sdp";
    
        baseURL = [baseURL stringByAppendingString:strNumber];
        rtsp_push_url = [baseURL stringByAppendingString:postfixStr];
        
        //rtsp_push_url = @"rtsp://player.daniulive.com:554/live123.sdp";
        
        NSLog(@"rtmp pusher url: %@",rtsp_push_url);
        
        NSString *baseText = @"RTSP推送URL：";
        
        _textPubisherUrlLabel.text = [ baseText stringByAppendingString:rtsp_push_url];
        
        NSInteger transport_protocol = 1;
        [_smart_publisher_sdk SetPushRtspTransportProtocol:transport_protocol];
        
        NSInteger errorCode = [_smart_publisher_sdk SetPushRtspURL:rtsp_push_url];
        
        if(errorCode != DANIULIVE_RETURN_OK)
        {
            NSLog(@"Call SetPushRtspURL failed..ret:%ld", (long)errorCode);
            return;
        }
        
        NSInteger reserve = 0;
        errorCode = [_smart_publisher_sdk StartPushRtsp:reserve];
        
        if(errorCode != DANIULIVE_RETURN_OK)
        {
            NSLog(@"Call StartPushRtsp failed..ret:%ld", (long)errorCode);
            
            if (errorCode == DANIULIVE_RETURN_SDK_EXPIRED) {
                _textPublisherEventLabel.text = @"SDK已过期，请联系视沃科技(www.daniulive.com QQ:89030985 or 2679481035)获取授权";
            }
            else
            {
                _textPublisherEventLabel.text = @"推流失败，返回ERROR";
            }
            
            return;
        }
        else
        {
            backSettingsButton.enabled = NO;
            [rtspPusherButton setTitle:@"停止RTSP" forState:UIControlStateNormal];
        }
    }
    else
    {
        NSLog(@"Run into rtspPusher, StopPushRtsp..");
        
        backSettingsButton.enabled = YES;
        [_smart_publisher_sdk StopPushRtsp];
        [rtspPusherButton setTitle:@"推送RTSP" forState:UIControlStateNormal];
    }
}

- (void)rtspServiceBtn:(UIButton *)button{
    NSLog(@"rtsp service++");
    
    button.selected = !button.selected;
    
    if (button.selected)
    {
        if(_smart_rtsp_server_sdk == nil)
        {
            _smart_rtsp_server_sdk = [[SmartRTSPServerSDK alloc] init];
        }
        
        if(_smart_rtsp_server_sdk != nil)
        {
            rtsp_handle_ = [_smart_rtsp_server_sdk OpenRtspServer:0];
            
            if(rtsp_handle_ == NULL)
            {
                NSLog(@"创建rtsp server实例失败! 请检查SDK有效性");
            }
            else
            {
                NSInteger port = 8554;
                if(DANIULIVE_RETURN_OK != [_smart_rtsp_server_sdk SetRtspServerPort:rtsp_handle_ port:port])
                {
                    [_smart_rtsp_server_sdk CloseRtspServer:rtsp_handle_];
                    rtsp_handle_ = NULL;
                    NSLog(@"创建rtsp server端口失败! 请检查端口是否重复或者端口不在范围内!");
                }
                
                //NSString* user_name = @"admin";
                //NSString* password = @"12345";
                //[_smart_rtsp_server_sdk SetRtspServerUserNamePassword:rtsp_handle_ user_name:user_name password:password];
                
                if(DANIULIVE_RETURN_OK == [_smart_rtsp_server_sdk StartRtspServer:rtsp_handle_ reserve:0])
                {
                    NSLog(@"启动rtsp server 成功!");
                }
                else
                {
                    [_smart_rtsp_server_sdk CloseRtspServer:rtsp_handle_];
                    rtsp_handle_ = NULL;
                    NSLog(@"启动rtsp server失败! 请检查设置的端口是否被占用!");
                }
            }
        }
        
        [rtspServiceButton setTitle:@"停止RTSP服务" forState:UIControlStateNormal];
        
        rtspPublisherButton.hidden = NO;
    }
    else
    {
        [_smart_rtsp_server_sdk StopRtspServer:rtsp_handle_];
        
        [_smart_rtsp_server_sdk CloseRtspServer:rtsp_handle_];
        
        rtsp_handle_ = NULL;
        
        _smart_rtsp_server_sdk = NULL;
        
        [rtspServiceButton setTitle:@"启动RTSP服务" forState:UIControlStateNormal];
        
        rtspPublisherButton.hidden = YES;
        backSettingsButton.enabled = YES;
    }
}

- (void)rtspPublisherBtn:(UIButton *)button{
    NSLog(@"rtsp publisher++");
    
    button.selected = !button.selected;
    
    if (button.selected)
    {
	    if(rtsp_handle_ == nil)
		{
			NSLog(@"请先启动RTSP服务..");
            return;
		}
		
        NSString* rtsp_stream_name = @"stream1";
        [_smart_publisher_sdk SetRtspStreamName:rtsp_stream_name];
        [_smart_publisher_sdk ClearRtspStreamServer];
        
        [_smart_publisher_sdk AddRtspStreamServer:rtsp_handle_ reserve:0];
        
        if(DANIULIVE_RETURN_OK != [_smart_publisher_sdk StartRtspStream:0])
        {
            NSLog(@"调用发布rtsp流接口失败!");
            return;
        }
        
        [rtspPublisherButton setTitle:@"停止RTSP流" forState:UIControlStateNormal];
        
        rtspServiceButton.hidden = YES;
        backSettingsButton.enabled = NO;
        getRtspSvrSessionNumButton.hidden = NO;
    }
    else
    {
        [_smart_publisher_sdk StopRtspStream];
        
        [rtspPublisherButton setTitle:@"发布RTSP流" forState:UIControlStateNormal];
        
        rtspServiceButton.hidden = NO;
        getRtspSvrSessionNumButton.hidden = YES;
        backSettingsButton.enabled = YES;
        
        _textPublisherEventLabel.text = @"";
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
        [recordStreamButton setTitle:@"停止录像" forState:UIControlStateNormal];
        backSettingsButton.enabled = NO;
    }
    else
    {
        [_smart_publisher_sdk SmartPublisherStopRecorder];
        [recordStreamButton setTitle:@"实时录像" forState:UIControlStateNormal];
        backSettingsButton.enabled = YES;
    }
}

- (void)pushUserDataBtn:(id)sender {
    
    if ( _smart_publisher_sdk != nil )
    {
        NSString* daniuString = @"大牛直播iOS推流SDK: ";
    
        // 1.创建时间
        NSDate *datenow = [NSDate date];
        // 2.创建时间格式化
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        // 3.指定格式
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        // 4.格式化时间
        NSString *timeSp = [formatter stringFromDate:datenow];
        
        NSString* utf8_string = [daniuString stringByAppendingFormat:@"%@", timeSp];
        
        [_smart_publisher_sdk SmartPublisherPostUserUTF8StringData:utf8_string reserve:0];
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
            [mirrorSwitchButton setTitle:@"当前镜像:打开" forState:UIControlStateNormal];
        }
        else
        {
            [mirrorSwitchButton setTitle:@"当前镜像:关闭" forState:UIControlStateNormal];
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

- (void)muteBtn:(id)sender {
    if ( _smart_publisher_sdk != nil )
    {
        is_mute = !is_mute;
        
        if ( is_mute )
        {
            [muteButton setTitle:@"取消静音" forState:UIControlStateNormal];
        }
        else
        {
            [muteButton setTitle:@"实时静音" forState:UIControlStateNormal];
        }
        
        [_smart_publisher_sdk SmartPublisherSetMute:is_mute];
    }
}

- (void)getRtspSvrSessionNumBtn:(id)sender
{
    if(_smart_rtsp_server_sdk != NULL && rtsp_handle_ != NULL)
    {
        NSInteger session_numbers = 0;
        [_smart_rtsp_server_sdk GetRtspServerClientSessionNumbers:rtsp_handle_ session_numbers:&session_numbers];
        
        NSLog(@"RTSP服务当前客户会话数: %d", (int)session_numbers);
        
        NSString *stringInt = [NSString stringWithFormat:@"%d", (int)session_numbers];
        
        UIAlertView *mBoxView = [[UIAlertView alloc] initWithTitle:@"RTSP服务当前客户会话数:" message:stringInt
                                                          delegate:nil cancelButtonTitle:@"确定"otherButtonTitles:nil, nil];
        [mBoxView show];
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
        
        if(_smart_publisher_sdk.delegate != nil)
        {
            _smart_publisher_sdk.delegate = nil;
        }
        
        _smart_publisher_sdk = nil;
        self.localPreview = nil;
    }
    
    //返回设置分辨率页面
    SettingView * settingView =[[SettingView alloc] init];
    [self presentViewController:settingView animated:YES completion:nil];
}

- (NSInteger)CalVideoQuality:(DNVideoStreamingQuality)video_quality is_h264:(Boolean)is_h264
{
    NSInteger quality = is_h264 ? 23 : 28;
    
    if ( DN_VIDEO_QUALITY_LOW == video_quality )
    {
        quality = is_h264? 23 : 27;
    }
    else if ( DN_VIDEO_QUALITY_MEDIUM == video_quality )
    {
        quality = is_h264? 26 : 28;
    }
    else if ( DN_VIDEO_QUALITY_HIGH == video_quality )
    {
        quality = is_h264? 27 : 29;
    }
    
    return quality;
}

- (NSInteger)CalVbrMaxKBitRate:(DNVideoStreamingQuality)video_quality
{
     NSInteger max_kbit_rate = 2000;
    
    if ( DN_VIDEO_QUALITY_LOW == video_quality )
    {
        max_kbit_rate = 400;
    }
    else if ( DN_VIDEO_QUALITY_MEDIUM == video_quality )
    {
        max_kbit_rate = 700;
    }
    else if ( DN_VIDEO_QUALITY_HIGH == video_quality  )
    {
        max_kbit_rate = 1400;
    }
    
    return max_kbit_rate;
}

//+++针对横屏模式代码+++
/*
#pragma mark 强制横屏(针对present方式)
- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (UIInterfaceOrientationLandscapeRight | UIInterfaceOrientationLandscapeLeft);
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscapeRight | UIInterfaceOrientationMaskLandscapeLeft;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationLandscapeRight;
}
*/
//---针对横屏模式代码---

@end
