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

#define kBtnHeight     50
#define kHorMargin     10
#define kVerMargin     80

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
    else
        NSLog(@"[event]nID:%lx", (long)nID);
    
    return 0;
}

- (instancetype)initParameter:(NSString*)url isHalfScreen:(Boolean)isHalfScreenVal
                   bufferTime:(NSInteger)bufferTime
                isFastStartup:(Boolean)isFastStartup
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
        buffer_time_ = bufferTime;
        is_hardware_decoder_ = isHWDecoder;
        is_rtsp_tcp_mode_ = isRTSPTcpMode;
    }
    
    return self;
}

- (void)loadView
{
    copyRights = @"Copyright 2015~2017 www.daniulive.com v1.0.17.0421";
    
    is_mute = NO;
    
    is_switch_url = NO;
    
    is_audio_only_ = NO;
    
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
    
    if (_player.delegate == nil)
    {
        _player.delegate = self;
        NSLog(@"SmartPlayerSDK _player.delegate:%@", _player);
    }
    
    NSString* sdkVersion = [_player SmartPlayerGetSDKVersionID];
    NSLog(@"sdk version:%@",sdkVersion);
    
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
        _glView = (__bridge UIView *)([SmartPlayerSDK SmartPlayerCreatePlayView:0 y:0 width:screenWidth height:playerHeight]);
        
        if (_glView == nil ) {
            NSLog(@"createPlayView failed..");
            return;
        }
        
        [self.view addSubview:_glView];
        
        [_player SmartPlayerSetPlayView:(__bridge void *)(_glView)];
    }
    
    if (_streamUrl.length == 0) {
        NSLog(@"_streamUrl with nil..");
        return;
    }
    
    if(buffer_time_>0)
    {
        [_player SmartPlayerSetBuffer:buffer_time_];
    }
    
    [_player SmartPlayerSetFastStartup:is_fast_startup_];
    
    NSLog(@"playback URL: %@, is_fast_startup_:%d, buffer_time_:%ld", _streamUrl, is_fast_startup_, (long)buffer_time_);
    
    [_player SmartPlayerSetPlayURL:_streamUrl];
    
    [_player SmartPlayerSetRTSPTcpMode:is_rtsp_tcp_mode_];
    
    [_player SmartPlayerStart];

    CGFloat lineWidth = muteButton.frame.size.width * 0.12f;
    
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
    
    //返回按钮
    backSettingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backSettingsButton.frame = CGRectMake(45, playerHeight - 80, 120, 80);
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
        
        if ( is_switch_url )
        {
            _streamUrl = @"rtmp://live.hkstv.hk.lxdns.com/live/hks";
            [switchUrlButton setTitle:@"切换URL2" forState:UIControlStateNormal];
        }
        else
        {
            _streamUrl = @"rtmp://live.hkstv.hk.lxdns.com/live/hks";
            [switchUrlButton setTitle:@"切换URL1" forState:UIControlStateNormal];
        }
        
        [_player SmartPlayerSwitchPlaybackUrl:_streamUrl];
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
