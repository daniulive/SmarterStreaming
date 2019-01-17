//
//  ViewController.m
//  SmartiOSPlayer
//
//  GitHub: https://github.com/daniulive/SmarterStreaming
//  website: http://www.daniulive.com
//
//  Created by daniulive on 2016/01/03.
//  Copyright © 2015~2017 daniulive. All rights reserved.

#import "ViewController.h"
#import "SettingView.h"

@interface ViewController ()

@end

@implementation ViewController
{
    NSString        *_streamUrl;
    Boolean         is_half_screen_;
    SmartPlayerSDK  * _player;
    UIView          * _glView;
    NSString        *copyRights;
    UILabel         *textModeLabel;             //文字提示
    Boolean         is_audio_only_;
    Boolean         is_fast_startup_;           //是否快速启动模式
    Boolean         is_low_latency_mode_;       //是否开启极速模式
    NSInteger       buffer_time_;               //buffer时间
    Boolean         is_hardware_decoder_;       //默认软解码
    Boolean         is_rtsp_tcp_mode_;          //仅用于rtsp流，设置TCP传输模式
    NSInteger       screenWidth;
    NSInteger       screenHeight;
    NSInteger       playerHeight;
    Boolean         is_mute;                    //静音接口
    Boolean         is_switch_url;              //切换url
    
    UIButton        *backSettingsButton;        //返回按钮
    UILabel         *backSettingLable;          //返回按钮 lable
    UIButton        *muteButton;                //静音 取消静音
    UIButton        *switchUrlButton;           //切换url按钮
    UIButton        *saveImageButton;           //快照按钮
    UIButton        *rotationButton;            //view旋转按钮
    
    UIImage         *image_path;
    NSString        *tmp_path;
    
    NSInteger       rotate_degrees;             //view旋转角度 0则不旋转
}

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

- (NSInteger) handleSmartPlayerEvent:(NSInteger)nID param1:(unsigned long long)param1 param2:(unsigned long long)param2 param3:(NSString*)param3 param4:(NSString*)param4 pObj:(void *)pObj;
{
    if (nID == EVENT_DANIULIVE_ERC_PLAYER_STARTED) {
        NSLog(@"[event]开始播放..");
    }
    else if (nID == EVENT_DANIULIVE_ERC_PLAYER_CONNECTING)
    {
        NSLog(@"[event]连接中..");
    }
    else if (nID == EVENT_DANIULIVE_ERC_PLAYER_CONNECTION_FAILED)
    {
        NSLog(@"[event]连接失败..");
    }
    else if (nID == EVENT_DANIULIVE_ERC_PLAYER_CONNECTED)
    {
        NSLog(@"[event]已连接..");
    }
    else if (nID == EVENT_DANIULIVE_ERC_PLAYER_DISCONNECTED)
    {
        NSLog(@"[event]断开连接..");
    }
    else if (nID == EVENT_DANIULIVE_ERC_PLAYER_STOP)
    {
        NSLog(@"[event]停止播放..");
    }
    else if (nID == EVENT_DANIULIVE_ERC_PLAYER_RESOLUTION_INFO)
    {
        NSLog(@"[event]视频解码分辨率信息..width:%llu, height:%llu", param1, param2);
    }
    else if (nID == EVENT_DANIULIVE_ERC_PLAYER_NO_MEDIADATA_RECEIVED)
    {
        NSLog(@"[event]收不到RTMP数据..");
    }
    else if (nID == EVENT_DANIULIVE_ERC_PLAYER_SWITCH_URL)
    {
        NSLog(@"[event]快速切换url..");
    }
    else if (nID == EVENT_DANIULIVE_ERC_PLAYER_CAPTURE_IMAGE)
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
    else if (nID == EVENT_DANIULIVE_ERC_PLAYER_START_BUFFERING)
    {
        //NSLog(@"[event]开始buffer..");
    }
    else if (nID == EVENT_DANIULIVE_ERC_PLAYER_BUFFERING)
    {
        //NSLog(@"[event]buffer百分比: %lld", param1);
    }
    else if (nID == EVENT_DANIULIVE_ERC_PLAYER_STOP_BUFFERING)
    {
        //NSLog(@"[event]停止buffer..");
    }
    else if (nID == EVENT_DANIULIVE_ERC_PLAYER_DOWNLOAD_SPEED)
    {
        NSInteger speed_kbps = (NSInteger)param1*8/1000;
        NSInteger speed_KBs = (NSInteger)param1/1024;
        
        NSLog(@"[event]download speed :%ld kbps - %ld KB/s", (long)speed_kbps, (long)speed_KBs);
    }
    else
        NSLog(@"[event]nID:%lx", (long)nID);
    
    return 0;
}

- (instancetype)initParameter:(NSString*)url isHalfScreen:(Boolean)isHalfScreenVal
                   bufferTime:(NSInteger)bufferTime
                  isFastStartup:(Boolean)isFastStartup
                  isLowLantecy:(Boolean)isLowLantecy
                  isHWDecoder:(Boolean)isHWDecoder
                isRTSPTcpMode:(Boolean)isRTSPTcpMode
{
    self = [super init];
    if (!self) {
        return nil;
    }
    else if(self) {
        _streamUrl = url;
        is_half_screen_ = isHalfScreenVal;
        is_fast_startup_ = isFastStartup;
        is_low_latency_mode_ = isLowLantecy;
        buffer_time_ = bufferTime;
        is_hardware_decoder_ = isHWDecoder;
        is_rtsp_tcp_mode_ = isRTSPTcpMode;
    }
    
    return self;
}

- (void)loadView
{
    copyRights = @"Copyright 2015~2017 www.daniulive.com v1.0.17.0716";
    
    is_mute = NO;
    
    is_switch_url = NO;
    
    is_audio_only_ = NO;
    
    rotate_degrees = 0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientChange:)name:UIDeviceOrientationDidChangeNotification object:nil];
    
    //当前屏幕宽高
    screenWidth  = CGRectGetWidth([UIScreen mainScreen].bounds);
    screenHeight = CGRectGetHeight([UIScreen mainScreen].bounds);
    
    playerHeight = screenHeight;
    
    if ( is_half_screen_ )
        playerHeight = screenWidth*3/4;
    
    NSLog(@"screenWidth:%ld, screenHeight:%ld",(long)screenWidth, (long)screenHeight);

    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    
    _player = [[SmartPlayerSDK alloc] init];
    
    if (_player ==nil ) {
        NSLog(@"SmartPlayerSDK init failed..");
        return;
    }
    
    //_player.yuvDataBlock = nil; //如不需要回调YUV数据
    
    /*
    _player.yuvDataBlock = ^void(int width, int height, unsigned long long time_stamp,
                                 unsigned char*yData, unsigned char* uData, unsigned char*vData,
                                 int yStride, int uStride, int vStride)
    {
        //NSLog(@"[PlaySideYuvCallback] width:%d, height:%d, ts:%lld, y:%d, u:%d, v:%d", width, height, time_stamp, yStride, uStride, vStride);
        //这里接收底层回调的YUV数据
    };
     */
    
    if (_player.delegate == nil)
    {
        _player.delegate = self;
        NSLog(@"SmartPlayerSDK _player.delegate:%@", _player);
    }
    
    NSInteger initRet = [_player SmartPlayerInitPlayer];
    if ( initRet != DANIULIVE_RETURN_OK )
    {
        NSLog(@"SmartPlayerSDK call SmartPlayerInitPlayer failed, ret=%ld", (long)initRet);
        return;
    }
    
    NSInteger videoDecoderMode = 0;
    
    if (is_hardware_decoder_)
    {
        videoDecoderMode = 1;
    }
    
    [_player SmartPlayerSetVideoDecoderMode:videoDecoderMode];

    if (is_audio_only_) {
        [_player SmartPlayerSetPlayView:nil];
    }
    else
    {
        //如果只需外部回调YUV数据，自己绘制，无需创建view和设置view到SDK
        _glView = (__bridge UIView *)([SmartPlayerSDK SmartPlayerCreatePlayView:0 y:0 width:screenWidth height:playerHeight]);
        
        if (_glView == nil ) {
            NSLog(@"createPlayView failed..");
            return;
        }
    
        [self.view addSubview:_glView];
        
        [_player SmartPlayerSetPlayView:(__bridge void *)(_glView)];
    }
    
    //设置YUV数据回调输出
    [_player SmartPlayerSetYuvBlock:true];
    
    if (_streamUrl.length == 0) {
        NSLog(@"_streamUrl with nil..");
        return;
    }
    
    //超低延迟模式
    [_player SmartPlayerSetLowLatencyMode:(NSInteger)is_low_latency_mode_];
    
    //设置视频view旋转角度
    [_player SmartPlayerSetRotation:rotate_degrees];
    
    if(buffer_time_ >= 0)
    {
        [_player SmartPlayerSetBuffer:buffer_time_];
    }
    
    [_player SmartPlayerSetFastStartup:is_fast_startup_];
    
    NSLog(@"playback URL: %@, is_fast_startup_:%d, buffer_time_:%ld", _streamUrl, is_fast_startup_, (long)buffer_time_);
    
    [_player SmartPlayerSetPlayURL:_streamUrl];
    
    [_player SmartPlayerSetRTSPTcpMode:is_rtsp_tcp_mode_];
    
    NSInteger image_flag = 1;
    [_player SmartPlayerSaveImageFlag:image_flag];
    
    //如需查看实时流量信息，可打开以下接口
    //NSInteger is_report = 1;
    //NSInteger report_interval = 1;
    //[_player SmartPlayerSetReportDownloadSpeed:is_report report_interval:report_interval];
    
    [_player SmartPlayerStart];

    CGFloat lineWidth = muteButton.frame.size.width * 0.12f;
    
    //快照按钮
    saveImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    saveImageButton.frame = CGRectMake(45, playerHeight - 260, 120, 80);
    saveImageButton.center = CGPointMake(self.view.frame.size.width / 6, saveImageButton.frame.origin.y + saveImageButton.frame.size.height / 2);
    
    saveImageButton.layer.cornerRadius = saveImageButton.frame.size.width / 2;
    saveImageButton.layer.borderColor = [UIColor greenColor].CGColor;
    saveImageButton.layer.borderWidth = lineWidth;
    
    [saveImageButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [saveImageButton setTitle:@"快照" forState:UIControlStateNormal];
    
    [saveImageButton addTarget:self action:@selector(SaveImageBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:saveImageButton];

    //静音按钮
    muteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    muteButton.frame = CGRectMake(45, playerHeight - 200, 120, 80);
    muteButton.center = CGPointMake(self.view.frame.size.width / 6, muteButton.frame.origin.y + muteButton.frame.size.height / 2);
    
    muteButton.layer.cornerRadius = muteButton.frame.size.width / 2;
    muteButton.layer.borderColor = [UIColor greenColor].CGColor;
    muteButton.layer.borderWidth = lineWidth;
    
    [muteButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [muteButton setTitle:@"静音" forState:UIControlStateNormal];
    
    [muteButton addTarget:self action:@selector(MuteBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:muteButton];
    
    //切换URL按钮
    switchUrlButton = [UIButton buttonWithType:UIButtonTypeCustom];
    switchUrlButton.frame = CGRectMake(45, playerHeight - 140, 120, 80);
    switchUrlButton.center = CGPointMake(self.view.frame.size.width / 6, switchUrlButton.frame.origin.y + switchUrlButton.frame.size.height / 2);
    
    switchUrlButton.layer.cornerRadius = muteButton.frame.size.width / 2;
    switchUrlButton.layer.borderColor = [UIColor greenColor].CGColor;
    switchUrlButton.layer.borderWidth = lineWidth;
    
    [switchUrlButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [switchUrlButton setTitle:@"切换URL2" forState:UIControlStateNormal];
    
    [switchUrlButton addTarget:self action:@selector(SwitchUrlBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:switchUrlButton];
    
    //view旋转按钮
    rotationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rotationButton.frame = CGRectMake(45, playerHeight - 80, 120, 80);
    rotationButton.center = CGPointMake(self.view.frame.size.width / 6, rotationButton.frame.origin.y + rotationButton.frame.size.height / 2);
    
    rotationButton.layer.cornerRadius = muteButton.frame.size.width / 2;
    rotationButton.layer.borderColor = [UIColor greenColor].CGColor;
    rotationButton.layer.borderWidth = lineWidth;
    
    [rotationButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    
    NSString* rotation_text;
    
    if ( 0 == rotate_degrees )
    {
        rotation_text = @"旋转90度";
    }
    else if ( 90 == rotate_degrees)
    {
        rotation_text = @"旋转180度";
    }
    else if ( 180 == rotate_degrees)
    {
        rotation_text = @"旋转270度";
    }
    else if ( 270 == rotate_degrees)
    {
        rotation_text = @"不旋转";
    }
    
    [rotationButton setTitle:rotation_text forState:UIControlStateNormal];
    
    [rotationButton addTarget:self action:@selector(rotateSettingBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:rotationButton];
    
    //返回按钮
    backSettingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backSettingsButton.frame = CGRectMake(45, playerHeight - 20, 120, 80);
    backSettingsButton.center = CGPointMake(self.view.frame.size.width / 6, backSettingsButton.frame.origin.y + backSettingsButton.frame.size.height / 2);
    
    backSettingsButton.layer.cornerRadius = muteButton.frame.size.width / 2;
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
    
    NSString *str = @"欢迎使用SmartPlayer, ";
    
    textModeLabel.text =  [str stringByAppendingString:copyRights];
    [self.view addSubview:textModeLabel];
}

- (void)SaveImageBtn:(id)sender {
    if ( _player != nil )
    {
        //设置快照目录
        NSLog(@"[SaveImageBtn] path++");
        
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
        
        [_player SmartPlayerSaveCurImage:image_name];
    }
}


- (void)MuteBtn:(id)sender {
    if ( _player != nil )
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
        
        [_player SmartPlayerSetMute:is_mute];
    }
}


- (void)SwitchUrlBtn:(id)sender {
    if ( _player != nil )
    {
        is_switch_url = !is_switch_url;
        
        NSString* switchUrl = @"";
        
        //本demo url在原始rtmp url和hks流中切换
        if ( is_switch_url )
        {
            switchUrl = @"rtmp://live.hkstv.hk.lxdns.com/live/hks";
            [switchUrlButton setTitle:@"切换URL2" forState:UIControlStateNormal];
        }
        else
        {
            switchUrl = _streamUrl;
            [switchUrlButton setTitle:@"切换URL1" forState:UIControlStateNormal];
        }
        
        [_player SmartPlayerSwitchPlaybackUrl:switchUrl];
    }
}

- (void)rotateSettingBtn:(id)sender {
    if ( _player != nil )
    {
        rotate_degrees += 90;
        rotate_degrees = rotate_degrees % 360;
        
        NSString* rotation_text;
        
        if ( 0 == rotate_degrees )
        {
            rotation_text = @"旋转90度";
        }
        else if ( 90 == rotate_degrees)
        {
            rotation_text = @"旋转180度";
        }
        else if ( 180 == rotate_degrees)
        {
            rotation_text = @"旋转270度";
        }
        else if ( 270 == rotate_degrees)
        {
            rotation_text = @"不旋转";
        }
        
        [rotationButton setTitle:rotation_text forState:UIControlStateNormal];
        
        [_player SmartPlayerSetRotation:rotate_degrees];
    }
}

- (void)backSettingsBtn:(UIButton *)button
{
    NSLog(@"Run into backSettingsBtn..");
    
    if (_player != nil)
    {
        [_player SmartPlayerStop];
        [_player SmartPlayerUnInitPlayer];
        //[_player release];
        _player = nil;
    }
    
    if (!is_audio_only_) {
        if (_glView != nil) {
            [_glView removeFromSuperview];
            [SmartPlayerSDK SmartPlayeReleasePlayView:(__bridge void *)(_glView)];
            _glView = nil;
        }
    }
    
    //返回设置分辨率页面
    SettingView * settingView =[[SettingView alloc] init];
    [self presentViewController:settingView animated:YES completion:nil];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)orientChange:(NSNotification *)noti
{
    
    UIDeviceOrientation  orient = [UIDevice currentDevice].orientation;
    
    NSLog(@"[orgientChange] orient:%ld" ,(long)orient);
    
    Boolean isPortrait = false;
    
    switch (orient)
    {
        case UIDeviceOrientationPortrait:
            isPortrait = true;
            break;
        case UIDeviceOrientationLandscapeLeft:
            isPortrait = false;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            isPortrait = false;
            break;
        case UIDeviceOrientationLandscapeRight:
            isPortrait = false;
            break;
        case UIDeviceOrientationFaceUp:
            isPortrait = true;
            break;
        case UIDeviceOrientationFaceDown:
            isPortrait = true;
            break;
            
        default:
            break;
    }
    
    CGRect f = _glView.frame;
    
    if (isPortrait) {
        f.size.width = screenWidth;
        f.size.height = playerHeight;
    }
    else
    {
        f.size.width = screenHeight;
        f.size.height = screenWidth;
    }
    
    _glView.frame = f;
}

@end
