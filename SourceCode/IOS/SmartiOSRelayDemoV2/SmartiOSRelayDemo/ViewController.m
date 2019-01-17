//
//  ViewController.m
//  SmartiOSRelayDemo
//
//  GitHub: https://github.com/daniulive/SmarterStreaming
//  website: https://www.daniulive.com
//
//  Created by daniulive on 2017/12/28.
//  Copyright © 2014~2019 daniulive. All rights reserved.
//

#import "ViewController.h"

#import "RecorderView.h"
#import "SmartRTSPSeverSDK.h"

@interface ViewController ()

@end

@implementation ViewController
{
    SmartPlayerSDK  *_smart_player_sdk;         //拉流SDK API
    SmartPublisherSDK *_smart_publisher_sdk;    //推流SDK API
    SmartRTSPServerSDK *_smart_rtsp_server_sdk; //内置轻量级RTSP服务SDK API
    
    UIView          * _glView;
    
    Boolean         is_inited_player_;
    Boolean         is_inited_publisher_;
    
    NSString        *playback_url_;             //拉流url
    NSString        *relay_url_;                //转发url
    
    Boolean         is_half_screen_;
    
    Boolean         is_audio_only_;
    Boolean         is_fast_startup_;           //是否快速启动模式
    Boolean         is_low_latency_mode_;       //是否开启极速模式
    NSInteger       buffer_time_;               //buffer时间
    Boolean         is_hardware_decoder_;       //默认软解码
    Boolean         is_rtsp_tcp_mode_;          //仅用于rtsp流，设置TCP传输模式
    
    NSInteger       screen_width_;
    NSInteger       screen_height_;
    
    NSInteger       player_view_width_;
    NSInteger       player_view_height_;
    
    Boolean         is_switch_url_;              //切换url flag
    Boolean         is_mute_;                    //静音flag
    
    UIButton        *muteButton;                //静音 取消静音
    UIButton        *switchUrlButton;           //切换url按钮
    UIButton        *playbackButton;            //录像按钮
    UIButton        *recButton;                 //录像按钮
    UIButton        *pullStreamButton;          //拉流按钮
    UIButton        *rtspServiceButton;         //内置服务按钮, 启动/停止服务
    UIButton        *rtspPublisherButton;       //内置rtsp服务功能
    UIButton        *getRtspSvrSessionNumButton;//获取rtsp server当前的客户会话数
    UIButton        *quitButton;                //退出按钮
    
    NSString        *copyRights;
    UILabel         *textModeLabel;             //文字提示
    
    UIImage         *image_path_;
    NSString        *tmp_path_;
    
    NSInteger       rotate_degrees_;             //view旋转角度 0则不旋转
    
    NSInteger       stream_width_;               //视频宽
    NSInteger       stream_height_;              //视频高
    
    Boolean         is_playing_;                 //是否播放状态
    Boolean         is_recording_;               //是否录像状态
    Boolean         is_pulling_;                 //是否pull状态
    Boolean         isRTSPServiceRunning;        //RTSP服务状态
    Boolean         isRTSPPublisherRunning;      //RTSP流发布状态
    Boolean         is_stream_data_callback_started;    //拉流数据状态回调
    void            *rtsp_handle_;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientChange:)name:UIDeviceOrientationDidChangeNotification object:nil];
    
    //当前屏幕宽高
    screen_width_  = CGRectGetWidth([UIScreen mainScreen].bounds);
    screen_height_ = CGRectGetHeight([UIScreen mainScreen].bounds);
    
    player_view_width_ = screen_width_;
    player_view_height_ = screen_height_;
    
    stream_width_ = 480;
    stream_height_ = 288;
    
    is_half_screen_ = YES;
    is_switch_url_ = NO;
    is_mute_ = NO;
    
    is_inited_player_ = NO;
    is_inited_publisher_ = NO;
    
    is_playing_ = NO;
    is_recording_ = NO;
    is_pulling_ = NO;
    isRTSPServiceRunning = NO;    //RTSP服务状态
    isRTSPPublisherRunning = NO;  //RTSP流发布状态
    is_stream_data_callback_started = NO;
    
    //用户可自定义显示view区域
    if ( is_half_screen_ )
    {
        player_view_height_ = screen_width_*stream_height_/stream_width_;
    }
    else
    {
        player_view_height_ = screen_height_;
    }
    
    NSLog(@"screenWidth:%ld, screenHeight:%ld playerViewWidth:%ld, playerViewHeight:%ld",
          (long)screen_width_, (long)screen_height_,
          (long)player_view_width_, (long)player_view_height_);
    
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    //拉流url可以自定义
    playback_url_ = @"rtmp://live.hkstv.hk.lxdns.com/live/hks1";
    //playback_url_ = @"rtmp://player.daniulive.com:1935/hls/stream1";
    
    //转发url可以自定义
    NSInteger randNumber = arc4random()%(1000000);
    NSString *strNumber = [NSString stringWithFormat:@"%ld", (long)randNumber];
    NSString *baseURL = @"rtmp://player.daniulive.com:1935/hls/stream";
    
    relay_url_ = [ baseURL stringByAppendingString:strNumber];
    
    //relay_url_ = @"rtmp://player.daniulive.com:1935/hls/stream999";
    
    CGFloat lineWidth = playbackButton.frame.size.width * 0.12f;
    
    //播放按钮
    playbackButton = [UIButton buttonWithType:UIButtonTypeCustom];
    playbackButton.frame = CGRectMake(45, screen_height_/2, 120, 80);
    playbackButton.center = CGPointMake(self.view.frame.size.width / 6, playbackButton.frame.origin.y + playbackButton.frame.size.height / 2);
    
    playbackButton.layer.cornerRadius = playbackButton.frame.size.width / 2;
    playbackButton.layer.borderColor = [UIColor greenColor].CGColor;
    playbackButton.layer.borderWidth = lineWidth;
    
    [playbackButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [playbackButton setTitle:@"开始播放" forState:UIControlStateNormal];
    
    [playbackButton addTarget:self action:@selector(playBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:playbackButton];
    
    //切换url按钮
    switchUrlButton = [UIButton buttonWithType:UIButtonTypeCustom];
    switchUrlButton.frame = CGRectMake(45, screen_height_/2 + 50, 120, 80);
    switchUrlButton.center = CGPointMake(self.view.frame.size.width / 6, switchUrlButton.frame.origin.y + switchUrlButton.frame.size.height / 2);
    
    switchUrlButton.layer.cornerRadius = switchUrlButton.frame.size.width / 2;
    switchUrlButton.layer.borderColor = [UIColor greenColor].CGColor;
    switchUrlButton.layer.borderWidth = lineWidth;
    
    [switchUrlButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [switchUrlButton setTitle:@"切换URL2" forState:UIControlStateNormal];
    
    [switchUrlButton addTarget:self action:@selector(SwitchUrlBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:switchUrlButton];
    
    //静音按钮
    muteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    muteButton.frame = CGRectMake(45, screen_height_/2 + 90, 120, 80);
    muteButton.center = CGPointMake(self.view.frame.size.width / 6, muteButton.frame.origin.y + muteButton.frame.size.height / 2);
    
    muteButton.layer.cornerRadius = muteButton.frame.size.width / 2;
    muteButton.layer.borderColor = [UIColor greenColor].CGColor;
    muteButton.layer.borderWidth = lineWidth;
    
    [muteButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [muteButton setTitle:@"静音" forState:UIControlStateNormal];
    
    [muteButton addTarget:self action:@selector(MuteBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:muteButton];
    
    //获取rtsp server当前的客户会话数
    getRtspSvrSessionNumButton = [UIButton buttonWithType:UIButtonTypeCustom];
    getRtspSvrSessionNumButton.frame = CGRectMake(45, screen_height_/2 + 90, 180, 60);
    getRtspSvrSessionNumButton.center = CGPointMake(self.view.frame.size.width / 2, getRtspSvrSessionNumButton.frame.origin.y + getRtspSvrSessionNumButton.frame.size.height / 2);
    
    getRtspSvrSessionNumButton.layer.cornerRadius = getRtspSvrSessionNumButton.frame.size.width / 2;
    getRtspSvrSessionNumButton.layer.borderColor = [UIColor greenColor].CGColor;
    getRtspSvrSessionNumButton.layer.borderWidth = lineWidth;
    
    [getRtspSvrSessionNumButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [getRtspSvrSessionNumButton setTitle:@"获取RTSP会话数" forState:UIControlStateNormal];
    
    [getRtspSvrSessionNumButton addTarget:self action:@selector(getRtspSvrSessionNumBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:getRtspSvrSessionNumButton];
    
    getRtspSvrSessionNumButton.hidden = YES;
    
    //录像按钮
    recButton = [UIButton buttonWithType:UIButtonTypeCustom];
    recButton.frame =  CGRectMake(45, screen_height_/2 + 130, 120, 80);
    recButton.center = CGPointMake(self.view.frame.size.width / 6, recButton.frame.origin.y + recButton.frame.size.height / 2);
    
    recButton.layer.cornerRadius = recButton.frame.size.width / 2;
    recButton.layer.borderColor = [UIColor greenColor].CGColor;
    recButton.layer.borderWidth = lineWidth;
    
    [recButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [recButton setTitle:@"开始录像" forState:UIControlStateNormal];
    
    [recButton addTarget:self action:@selector(recorderBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:recButton];
    
    //拉取RTMP/RTSP流 然后转发到RTMP/RTSP服务
    pullStreamButton = [UIButton buttonWithType:UIButtonTypeCustom];
    pullStreamButton.frame = CGRectMake(45, screen_height_/2 + 170, 200, 80);
    pullStreamButton.center = CGPointMake(self.view.frame.size.width / 6, pullStreamButton.frame.origin.y + pullStreamButton.frame.size.height / 2);
    
    pullStreamButton.layer.cornerRadius = pullStreamButton.frame.size.width / 2;
    pullStreamButton.layer.borderColor = [UIColor greenColor].CGColor;
    pullStreamButton.layer.borderWidth = lineWidth;
    
    [pullStreamButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [pullStreamButton setTitle:@"转推RTMP/RTSP" forState:UIControlStateNormal];
    
    [pullStreamButton addTarget:self action:@selector(pullStreamBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:pullStreamButton];
    
    //启动、停止RTSP服务
    rtspServiceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rtspServiceButton.frame = CGRectMake(45, screen_height_/2 + 220, 120, 60);
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
    rtspPublisherButton.frame = CGRectMake(45, screen_height_/2 + 220, 120, 60);
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
    
    //退出按钮
    quitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    quitButton.frame = CGRectMake(45, screen_height_/2 + 260, 120, 80);
    quitButton.center = CGPointMake(self.view.frame.size.width / 6, quitButton.frame.origin.y + quitButton.frame.size.height / 2);
    
    quitButton.layer.cornerRadius = quitButton.frame.size.width / 2;
    quitButton.layer.borderColor = [UIColor greenColor].CGColor;
    quitButton.layer.borderWidth = lineWidth;
    
    [quitButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [quitButton setTitle:@"退出进入录像" forState:UIControlStateNormal];
    
    [quitButton addTarget:self action:@selector(quitBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:quitButton];
    
    // 创建文字提示 UILable
    textModeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, screen_height_/2 + 300, self.view.frame.size.width, 50)];
    // 设置UILabel的背景色
    textModeLabel.backgroundColor = [UIColor clearColor];
    // 设置UILabel的文本颜色
    textModeLabel.textColor = [UIColor colorWithRed:1.0 green:0.0
                                               blue:1.0 alpha:1.0];
    
    textModeLabel.adjustsFontSizeToFitWidth = YES;
    
    NSString *str = @"转发url: ";
    
    textModeLabel.text =  [str stringByAppendingString:relay_url_];
    [self.view addSubview:textModeLabel];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.navigationController.view sendSubviewToBack:self.navigationController.navigationBar];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController.view bringSubviewToFront:self.navigationController.navigationBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//播放端接口封装
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
        f.origin.x = 0;
        f.origin.y = 50;
        f.size.width = screen_width_;
        f.size.height = screen_width_*stream_height_/stream_width_;
    }
    else
    {
        f.origin.x = 0;
        f.origin.y = 0;
        f.size.width = screen_height_;
        f.size.height = screen_width_;
    }
    
    _glView.frame = f;
}

- (void)SwitchUrlBtn:(id)sender {
    if ( _smart_player_sdk != nil )
    {
        is_switch_url_ = !is_switch_url_;
        
        NSString* switchUrl = @"";
        
        if ( is_switch_url_ )
        {
            switchUrl = @"rtmp://live.hkstv.hk.lxdns.com/live/hks2";
            //switchUrl = @"rtmp://player.daniulive.com:1935/hls/stream2";
            [switchUrlButton setTitle:@"切换URL2" forState:UIControlStateNormal];
        }
        else
        {
            switchUrl = playback_url_;
            [switchUrlButton setTitle:@"切换URL1" forState:UIControlStateNormal];
        }
        
        [_smart_player_sdk SmartPlayerSwitchPlaybackUrl:switchUrl];
    }
}

- (void)MuteBtn:(id)sender {
    if ( _smart_player_sdk != nil )
    {
        is_mute_ = !is_mute_;
        
        if ( is_mute_ )
        {
            [muteButton setTitle:@"取消静音" forState:UIControlStateNormal];
        }
        else
        {
            [muteButton setTitle:@"静音" forState:UIControlStateNormal];
        }
        
        [_smart_player_sdk SmartPlayerSetMute:is_mute_];
    }
}

- (void)playBtn:(UIButton *)button {
    
    NSLog(@"playBtn only++");
    
    button.selected = !button.selected;
    
    if (button.selected)
    {
        if(is_playing_)
            return;
        
        [self InitPlayer];
        
        if(![self StartPlayer])
        {
            NSLog(@"Call StartPlayer failed..");
        }
        
        [playbackButton setTitle:@"停止播放" forState:UIControlStateNormal];
        
        is_playing_ = YES;
    }
    else
    {
        if ( !is_playing_ )
            return;
        
        [self StopPlayer];
        
        if(!is_pulling_ && !is_recording_ && !isRTSPPublisherRunning)
        {
            [self UnInitPlayer];
        }
        
        [playbackButton setTitle:@"开始播放" forState:UIControlStateNormal];
        
        is_mute_ = NO;
        [muteButton setTitle:@"静音" forState:UIControlStateNormal];
        
        is_playing_ = NO;
    }
}

- (void)recorderBtn:(UIButton *)button {
    
    NSLog(@"record Stream only++");
    
    button.selected = !button.selected;
    
    if (button.selected)
    {
        if(is_recording_)
            return;
        
        [self InitPlayer];
        
        //设置录像目录
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *recorderDir = [paths objectAtIndex:0];
        
        if([_smart_player_sdk SmartPlayerSetRecorderDirectory:recorderDir] != DANIULIVE_RETURN_OK)
        {
            NSLog(@"Call SmartPlayerSetRecorderDirectory failed..");
        }
        
        //每个录像文件大小
        NSInteger size = 200;
        if([_smart_player_sdk SmartPlayerSetRecorderFileMaxSize:size] != DANIULIVE_RETURN_OK)
        {
            NSLog(@"Call SmartPlayerSetRecorderFileMaxSize failed..");
        }
        
        [_smart_player_sdk SmartPlayerStartRecorder];
        [recButton setTitle:@"停止录像" forState:UIControlStateNormal];
        
        is_recording_ = YES;
    }
    else
    {
        if(!is_recording_)
            return;
        
        [_smart_player_sdk SmartPlayerStopRecorder];
        [recButton setTitle:@"开始录像" forState:UIControlStateNormal];
        
        if(!is_playing_ && !is_pulling_ && !isRTSPPublisherRunning)
        {
            [self UnInitPlayer];
        }
        
        is_recording_ = NO;
    }
}

//如需转发video数据
- (void)OnPostVideoEncodedData:(NSInteger)codec_id data:(unsigned char*)data size:(NSInteger)size is_key_frame:(NSInteger)is_key_frame timestamp:(unsigned long long)timestamp pts:(unsigned long long)pts
{
    if((is_pulling_ || isRTSPPublisherRunning) && _smart_publisher_sdk != nil )
    {
        [_smart_publisher_sdk SmartPublisherPostVideoEncodedData:codec_id data:data size:size is_key_frame:is_key_frame timestamp:timestamp pts:pts];
    }
}

//如需转发audio数据
- (void)OnPostAudioEncodedData:(NSInteger)codec_id data:(unsigned char*)data size:(NSInteger)size is_key_frame:(NSInteger)is_key_frame timestamp:(unsigned long long)timestamp parameter_info:(unsigned char*)parameter_info parameter_info_size:(NSInteger)parameter_info_size
{
    if((is_pulling_ || isRTSPPublisherRunning) && _smart_publisher_sdk != nil )
    {
        [_smart_publisher_sdk SmartPublisherPostAudioEncodedData:codec_id data:data size:size is_key_frame:is_key_frame timestamp:timestamp parameter_info:parameter_info parameter_info_size:parameter_info_size];
    }
}

- (void)pullStreamBtn:(UIButton *)button {
    
    NSLog(@"pullStreamBtn only++");
    
    button.selected = !button.selected;
    
    if (button.selected)
    {
        if(is_pulling_)
            return;
        
        [self InitPlayer];
        
        [self StartStreamDataCallback];
        
        [self InitPublisher];
        
        [self StartPushRTMP];
        
        //[self StartPushRTSP];   //如需转推RTSP 这里打开即可
        
        [pullStreamButton setTitle:@"停止转推" forState:UIControlStateNormal];
        
        is_pulling_ = YES;
    }
    else
    {
        if (!is_pulling_ )
            return;
        
        [self StopPushRTMP];
        
        //[self StopPushRTSP];   //如需转推RTSP 这里打开即可
        
        if(!isRTSPPublisherRunning)
        {
            [self UnInitPublisher];
            [_smart_player_sdk SmartPlayerStopPullStream];
            is_stream_data_callback_started = false;
        }
        
        if(!is_playing_ && !is_recording_ && !isRTSPPublisherRunning)
        {
            [self UnInitPlayer];
        }
        
        [pullStreamButton setTitle:@"转推RTMP/RTSP" forState:UIControlStateNormal];
        
        is_pulling_ = NO;
    }
}

- (void)rtspServiceBtn:(UIButton *)button{
    NSLog(@"rtsp service++");
    
    button.selected = !button.selected;
    
    if (button.selected)
    {
        if(isRTSPServiceRunning)
            return;
        
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
        
        isRTSPServiceRunning = YES;    //RTSP服务状态
        
        [rtspServiceButton setTitle:@"停止RTSP服务" forState:UIControlStateNormal];
        
        rtspPublisherButton.hidden = NO;
    }
    else
    {
        if(!isRTSPServiceRunning)
            return;
        
        [_smart_rtsp_server_sdk StopRtspServer:rtsp_handle_];
        
        [_smart_rtsp_server_sdk CloseRtspServer:rtsp_handle_];
        
        rtsp_handle_ = NULL;
        
        _smart_rtsp_server_sdk = NULL;
        
        [rtspServiceButton setTitle:@"启动RTSP服务" forState:UIControlStateNormal];
        
        isRTSPServiceRunning = NO;    //RTSP服务状态
        
        rtspPublisherButton.hidden = YES;
    }
}

- (void)rtspPublisherBtn:(UIButton *)button{
    NSLog(@"rtsp publisher++");
    
    button.selected = !button.selected;
    
    if (button.selected)
    {
        if(isRTSPPublisherRunning)
            return;
        
        if(rtsp_handle_ == nil)
        {
            NSLog(@"请先启动RTSP服务..");
            return;
        }

        [self InitPlayer];
        
        [self StartStreamDataCallback];
        
        [self InitPublisher];
        
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
        getRtspSvrSessionNumButton.hidden = NO;
        
        isRTSPPublisherRunning = YES;
    }
    else
    {
        if(!isRTSPPublisherRunning)
            return;
        
        [_smart_publisher_sdk StopRtspStream];
        
        if(!is_pulling_)
        {
            [self UnInitPublisher];
            [_smart_player_sdk SmartPlayerStopPullStream];
            is_stream_data_callback_started = false;
        }
        
        if(!is_playing_ && !is_recording_ && !is_pulling_)
        {
            [self UnInitPlayer];
        }
        
        [rtspPublisherButton setTitle:@"发布RTSP流" forState:UIControlStateNormal];
        
        rtspServiceButton.hidden = NO;
        getRtspSvrSessionNumButton.hidden = YES;
        
        isRTSPPublisherRunning = NO;
        
        //_textPublisherEventLabel.text = @"";
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

- (void)quitBtn:(UIButton *)button {
    
    NSLog(@"quitBtn++");
    
    if(is_pulling_)
    {
        [self StopPushRTMP];
        [pullStreamButton setTitle:@"开始拉流" forState:UIControlStateNormal];
    }
    
    if(isRTSPPublisherRunning)
    {
        [_smart_publisher_sdk StopRtspStream];
        [rtspPublisherButton setTitle:@"发布RTSP流" forState:UIControlStateNormal];
    }
    
    if(isRTSPServiceRunning && rtsp_handle_ != nil)
    {
        [_smart_rtsp_server_sdk StopRtspServer:rtsp_handle_];
        [_smart_rtsp_server_sdk CloseRtspServer:rtsp_handle_];
        
        rtsp_handle_ = NULL;
        _smart_rtsp_server_sdk = NULL;
    }
    
    if(is_recording_)
    {
        [_smart_player_sdk SmartPlayerStopRecorder];
        [recButton setTitle:@"开始录像" forState:UIControlStateNormal];
    }
    
    if(is_playing_)
    {
        [self StopPlayer];
        [playbackButton setTitle:@"开始播放" forState:UIControlStateNormal];
    }
    
    if(is_pulling_ || isRTSPPublisherRunning)
    {
        [self UnInitPublisher];
        
        [_smart_player_sdk SmartPlayerStopPullStream];
    }
    
    if(is_playing_ || is_recording_ || is_pulling_ || isRTSPPublisherRunning)
    {
         [self UnInitPlayer];
    }
    
    is_mute_ = NO;
    is_playing_ = NO;
    is_recording_ = NO;
    is_pulling_ = NO;
    isRTSPServiceRunning = NO;    //RTSP服务状态
    isRTSPPublisherRunning = NO;  //RTSP流发布状态
    is_stream_data_callback_started = NO;
    
    RecorderView * recorderView =[[RecorderView alloc] init];
    [self presentViewController:recorderView animated:YES completion:nil];
    
    NSLog(@"quitBtn--");
}

-(bool)InitPlayer
{
    NSLog(@"InitPlayer++");
    
    if(is_inited_player_)
    {
        NSLog(@"InitPlayer: has inited before..");
        return true;
    }
    
    _smart_player_sdk = [[SmartPlayerSDK alloc] init];
    
    if (_smart_player_sdk ==nil ) {
        NSLog(@"SmartPlayerSDK init failed..");
        return false;
    }
    
    if (playback_url_.length == 0) {
        NSLog(@"_streamUrl with nil..");
        return false;
    }
    
    if (_smart_player_sdk.delegate == nil)
    {
        _smart_player_sdk.delegate = self;
        NSLog(@"SmartPlayerSDK _player.delegate:%@", _smart_player_sdk);
    }
    
    NSInteger initRet = [_smart_player_sdk SmartPlayerInitPlayer];
    if ( initRet != DANIULIVE_RETURN_OK )
    {
        NSLog(@"SmartPlayerSDK call SmartPlayerInitPlayer failed, ret=%ld", (long)initRet);
        return false;
    }
    
    [_smart_player_sdk SmartPlayerSetPlayURL:playback_url_];
    
    //超低延迟模式
    is_low_latency_mode_ = YES;
    [_smart_player_sdk SmartPlayerSetLowLatencyMode:(NSInteger)is_low_latency_mode_];
    
    buffer_time_ = 0;
    if(buffer_time_ >= 0)
    {
        [_smart_player_sdk SmartPlayerSetBuffer:buffer_time_];
    }
    
    is_fast_startup_ = YES;
    [_smart_player_sdk SmartPlayerSetFastStartup:(NSInteger)is_fast_startup_];
    
    NSLog(@"[relayDemo]is_fast_startup_:%d, buffer_time_:%ld", is_fast_startup_, (long)buffer_time_);
    
    [_smart_player_sdk SmartPlayerSetRTSPTcpMode:is_rtsp_tcp_mode_];
    
    NSInteger rtsp_timeout = 10;    //RTSP超时时间设置
    [_smart_player_sdk SmartPlayerSetRTSPTimeout:rtsp_timeout];
    
    NSInteger is_auto_switch_tcp_udp = 1;       //RTSP TCP/UDP模式自动切换设置
    [_smart_player_sdk SmartPlayerSetRTSPAutoSwitchTcpUdp:is_auto_switch_tcp_udp];
    
    NSInteger image_flag = 1;
    [_smart_player_sdk SmartPlayerSaveImageFlag:image_flag];
    
    //如需查看实时流量信息，可打开以下接口
    //NSInteger is_report = 1;
    //NSInteger report_interval = 1;
    //[_player SmartPlayerSetReportDownloadSpeed:is_report report_interval:report_interval];
    
    NSInteger is_rec_trans_code = 1;
    [_smart_player_sdk SmartPlayerSetRecorderAudioTranscodeAAC:is_rec_trans_code];
    
    NSInteger is_pull_trans_code = 1;
    [_smart_player_sdk SmartPlayerSetPullStreamAudioTranscodeAAC:is_pull_trans_code];
    
    is_inited_player_ = YES;
    
    NSLog(@"InitPlayer--");
    return true;
}

-(bool)StartPlayer
{
    NSLog(@"StartPlayer++");
    
    if ( _smart_player_sdk == nil )
    {
        NSLog(@"StartPlayer, player SDK with nil");
        return false;
    }
    
    //_smart_player_sdk.yuvDataBlock = nil; //如不需要回调YUV数据
    
    /*
     _smart_player_sdk.yuvDataBlock = ^void(int width, int height, unsigned long long time_stamp,
     unsigned char*yData, unsigned char* uData, unsigned char*vData,
     int yStride, int uStride, int vStride)
     {
     //NSLog(@"[PlaySideYuvCallback] width:%d, height:%d, ts:%lld, y:%d, u:%d, v:%d", width, height, time_stamp, yStride, uStride, vStride);
     //这里接收底层回调的YUV数据
     };
     */
    
    //设置YUV数据回调输出
    //[_smart_player_sdk SmartPlayerSetYuvBlock:true];
    
    //设置视频view旋转角度
    [_smart_player_sdk SmartPlayerSetRotation:rotate_degrees_];
    
    NSInteger videoDecoderMode = 0; //默认软解码
    [_smart_player_sdk SmartPlayerSetVideoDecoderMode:videoDecoderMode];
    
    if (is_audio_only_) {
        [_smart_player_sdk SmartPlayerSetPlayView:nil];
    }
    else
    {
        //如果只需外部回调YUV数据，自己绘制，无需创建view和设置view到SDK
        _glView = (__bridge UIView *)([SmartPlayerSDK SmartPlayerCreatePlayView:0 y:50 width:player_view_width_ height:player_view_height_]);
        
        if (_glView == nil ) {
            NSLog(@"createPlayView failed..");
            return false;
        }
        
        [self.view addSubview:_glView];
        
        [_smart_player_sdk SmartPlayerSetPlayView:(__bridge void *)(_glView)];
    }
    
    
    NSInteger ret = [_smart_player_sdk SmartPlayerStart];
    
    if(ret != DANIULIVE_RETURN_OK)
    {
        NSLog(@"Call SmartPlayerStart failed..ret:%ld", (long)ret);
        return false;
    }
    
    NSLog(@"StartPlayer--");
    return true;
}

-(bool)StopPlayer
{
    NSLog(@"StopPlayer++");
    
    if (_smart_player_sdk != nil)
    {
        [_smart_player_sdk SmartPlayerStop];
    }
    
    if (!is_audio_only_) {
        if (_glView != nil) {
            [_glView removeFromSuperview];
            [SmartPlayerSDK SmartPlayeReleasePlayView:(__bridge void *)(_glView)];
            _glView = nil;
        }
    }
    
    NSLog(@"StopPlayer--");
    return true;
}

-(bool)UnInitPlayer
{
    NSLog(@"UnInitPlayer++");
    
    if (_smart_player_sdk != nil)
    {
        [_smart_player_sdk SmartPlayerUnInitPlayer];
        
        if(_smart_player_sdk.delegate != nil)
        {
            _smart_player_sdk.delegate = nil;
        }
        
        _smart_player_sdk = nil;
    }
    
    is_inited_player_ = NO;
    
    NSLog(@"UnInitPlayer--");
    return true;
}

//推送端接口封装
-(bool)InitPublisher
{
    NSLog(@"InitPublisher++");
    
    if(is_inited_publisher_)
    {
        NSLog(@"InitPublisher: has inited before..");
        return true;
    }
    
    if(_smart_publisher_sdk != nil)
    {
        NSLog(@"InitPublisher, publisher() has inited before..");
        return true;
    }
    
    _smart_publisher_sdk = [[SmartPublisherSDK alloc] init];
    
    if (_smart_publisher_sdk == nil )
    {
        NSLog(@"_smart_publisher_sdk with nil..");
        return false;
    }
    
    if(_smart_publisher_sdk.delegate == nil)
    {
        _smart_publisher_sdk.delegate = self;
    }
    
    NSInteger audio_opt = 2;
    NSInteger video_opt = 2;
    
    if([_smart_publisher_sdk SmartPublisherInit:audio_opt video_opt:video_opt] != DANIULIVE_RETURN_OK)
    {
        NSLog(@"Call SmartPublisherInit failed..");
        
        _smart_publisher_sdk = nil;
        return false;
    }
    
    is_inited_publisher_ = YES;
    
    NSLog(@"InitPublisher--");
    return true;
}

-(bool)StartPushRTMP
{
    NSLog(@"StartPushRTMP++");
    if ( _smart_publisher_sdk == nil )
    {
        NSLog(@"StartPushRTMP, publisher SDK with nil");
        return false;
    }
    
    NSInteger errorCode = [_smart_publisher_sdk SmartPublisherStartPublisher:relay_url_];
    
    NSLog(@"rtmp pusher url: %@", relay_url_);
    
    if(errorCode != DANIULIVE_RETURN_OK)
    {
        NSLog(@"Call SmartPublisherStartPublisher failed..ret:%ld", (long)errorCode);
        return false;
    }
    
    NSLog(@"StartPushRTMP--");
    return true;
}

-(bool)StopPushRTMP
{
    NSLog(@"StopPushRTMP++");
    if ( _smart_publisher_sdk == nil )
    {
        NSLog(@"StopPushRTMP, publiher SDK with nil");
        return false;
    }
    
    [_smart_publisher_sdk SmartPublisherStopPublisher];
    
    NSLog(@"StopPushRTMP--");
    return true;
}

-(bool)StartPushRTSP
{
    NSLog(@"StartPushRTSP++");
    if ( _smart_publisher_sdk == nil )
    {
        NSLog(@"StartPushRTSP, publisher SDK with nil");
        return false;
    }
    
    NSString* rtsp_push_url = @"rtsp://player.daniulive.com:554/live123.sdp";   //推送到自己的RTSP服务器即可
    
    NSLog(@"rtsp pusher url: %@",rtsp_push_url);
    
    NSInteger transport_protocol = 1;
    [_smart_publisher_sdk SetPushRtspTransportProtocol:transport_protocol];
    
    NSInteger errorCode = [_smart_publisher_sdk SetPushRtspURL:rtsp_push_url];
    
    if(errorCode != DANIULIVE_RETURN_OK)
    {
        NSLog(@"Call SetPushRtspURL failed..ret:%ld", (long)errorCode);
        return false;
    }
    
    NSInteger reserve = 0;
    errorCode = [_smart_publisher_sdk StartPushRtsp:reserve];
    
    if(errorCode != DANIULIVE_RETURN_OK)
    {
        NSLog(@"Call StartPushRtsp failed..ret:%ld", (long)errorCode);
        return false;
    }
    NSLog(@"StartPushRTSP--");
    return true;
}

-(bool)StopPushRTSP
{
    NSLog(@"StopPushRTSP++");
    if ( _smart_publisher_sdk == nil )
    {
        NSLog(@"StopPushRTSP, publisher SDK with nil");
        return false;
    }
    
    [_smart_publisher_sdk StopPushRtsp];
    
    NSLog(@"StopPushRTSP--");
    return true;
}

-(bool)UnInitPublisher
{
    NSLog(@"UnInitPublisher++");
    if (_smart_publisher_sdk != nil)
    {
        [_smart_publisher_sdk SmartPublisherUnInit];
        
        if(_smart_publisher_sdk.delegate != nil)
        {
            _smart_publisher_sdk.delegate = nil;
        }
        
        _smart_publisher_sdk = nil;
    }
    
    is_inited_publisher_ = NO;
    
    NSLog(@"UnInitPublisher--");
    return true;
}

-(void)StartStreamDataCallback
{
    //_smart_player_sdk.pullStreamVideoDataBlock = nil; //如不需要回调视频数据
   
    if(is_stream_data_callback_started)
    {
        NSLog(@"StartStreamDataCallback: has inited before..");
        return;
    }
    
    if(_smart_player_sdk == nil)
    {
        NSLog(@"StartStreamDataCallback failed, _smart_player_sdk is null..");
        return;
    }
    
    __weak __typeof(self) weakSelf = self;
    
    _smart_player_sdk.pullStreamVideoDataBlock = ^(int video_codec_id, unsigned char *data, int size, int is_key_frame, unsigned long long timestamp, int width, int height, unsigned char *parameter_info, int parameter_info_size, unsigned long long presentation_timestamp)
    {
        //NSLog(@"[pullStreamVideoDataBlock]videoCodecID:%d, is_key_frame:%d, size:%d, width:%d, height:%d, ts:%lld",
        //      video_codec_id, is_key_frame, size, width, height, timestamp);
        
        [weakSelf OnPostVideoEncodedData:video_codec_id data:data size:size is_key_frame:is_key_frame timestamp:timestamp pts:presentation_timestamp];
    };
    
    //_smart_player_sdk.pullStreamAudioDataBlock = nil; //如不需要回调音频数据
    
    _smart_player_sdk.pullStreamAudioDataBlock = ^(int audio_codec_id, unsigned char *data, int size, int is_key_frame, unsigned long long timestamp, int sample_rate, int channel, unsigned char *parameter_info, int parameter_info_size, unsigned long long reserve)
    {
        //NSLog(@"[pullStreamAudioDataBlock]audioCodecID:%x, is_key_frame:%d, size:%d, parameter_info_size:%d",
        //      audio_codec_id, is_key_frame, size, parameter_info_size);
        
        [weakSelf OnPostAudioEncodedData:audio_codec_id data:data size:size is_key_frame:is_key_frame timestamp:timestamp parameter_info:parameter_info parameter_info_size:parameter_info_size];
    };
    
    //设置拉流视频数据回调
    bool isEnablePSVideoDataBlock = true;
    [_smart_player_sdk SmartPlayerSetPullStreamVideoDataBlock:isEnablePSVideoDataBlock];
    
    //设置拉流音频数据回调
    bool isEnablePSAudioDataBlock = true;
    [_smart_player_sdk SmartPlayerSetPullStreamAudioDataBlock:isEnablePSAudioDataBlock];
    
    if([_smart_player_sdk SmartPlayerStartPullStream] != DANIULIVE_RETURN_OK)
    {
        NSLog(@"Call SmartPlayerStartPullStream failed..");
    }
    
    is_stream_data_callback_started = YES;
}

//event相关处理
//(本demo快照最终拷贝保存到iOS设备“照片”目录，实际保存位置可自行设置，或以应用场景为准)
/*
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
 */

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
        stream_width_ = (NSInteger)param1;
        stream_height_ = (NSInteger)param2;
        NSLog(@"[event]视频解码分辨率信息..width:%ld, height:%ld", (long)stream_width_, (long)stream_height_);
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
            
            //tmp_path = param3;
            
            //image_path = [ UIImage imageNamed:param3];
            
            //UIImageWriteToSavedPhotosAlbum(image_path, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
        }
        else
        {
            NSLog(@"[event]快照失败: %@", param3);
        }
    }
    else if (nID == EVENT_DANIULIVE_ERC_PLAYER_RECORDER_START_NEW_FILE)
    {
        NSLog(@"[event]录像写入新文件..文件名: %@", param3);
    }
    else if (nID == EVENT_DANIULIVE_ERC_PLAYER_ONE_RECORDER_FILE_FINISHED)
    {
        NSLog(@"[event]一个录像文件完成..文件名: %@", param3);
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
    else if(nID == EVENT_DANIULIVE_ERC_PLAYER_RTSP_STATUS_CODE)
    {
        NSString* lable = @"[event]RTSP status code received:";
        NSString* player_event = [lable stringByAppendingFormat:@"%ld", (long)param1];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertController *aleView=[UIAlertController alertControllerWithTitle:@"RTSP错误状态" message:player_event preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *action_ok=[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
                [aleView addAction:action_ok];
                
                [self presentViewController:aleView animated:YES completion:nil];
            });
        });
    }
    else
        NSLog(@"[event]nID:%lx", (long)nID);
    
    return 0;
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
        NSLog(@"[event]推送快照..");
    }
    else if (nID == EVENT_DANIULIVE_ERC_PUBLISHER_RTSP_URL)
    {
        NSLog(@"[event]RTSP服务URL: %@", param3);
    }
    else
        NSLog(@"[event]nID:%lx", (long)nID);
    
    return 0;
}
@end
