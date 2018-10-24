//
//  ViewController.m
//  SmartiOSRelayDemo
//
//  GitHub: https://github.com/daniulive/SmarterStreaming
//
//  Created by daniulive on 2017/12/28.
//  Copyright © 2014~2018年 daniulive. All rights reserved.
//

#import "ViewController.h"

#import "RecorderView.h"

@interface ViewController ()

@end

@implementation ViewController
{
    SmartPlayerSDK  *_smart_player_sdk;
    SmartPublisherSDK *_smart_publisher_sdk;    //推流SDK API
    
    UIView          * _glView;
    
    Boolean         is_inited_player_;
    
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
    
    is_playing_ = NO;
    is_recording_ = NO;
    is_pulling_ = NO;
    
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
    //playback_url_ = @"rtmp://live.hkstv.hk.lxdns.com/live/hks";
    //playback_url_ = @"rtmp://player.daniulive.com:1935/hls/stream1";
    
    //转发url可以自定义
    NSInteger randNumber = arc4random()%(1000000);
    NSString *strNumber = [NSString stringWithFormat:@"%ld", (long)randNumber];
    NSString *baseURL = @"rtmp://player.daniulive.com:1935/hls/stream";
    
    relay_url_ = [ baseURL stringByAppendingString:strNumber];
    
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
    muteButton.frame = CGRectMake(45, screen_height_/2 + 100, 120, 80);
    muteButton.center = CGPointMake(self.view.frame.size.width / 6, muteButton.frame.origin.y + muteButton.frame.size.height / 2);
    
    muteButton.layer.cornerRadius = muteButton.frame.size.width / 2;
    muteButton.layer.borderColor = [UIColor greenColor].CGColor;
    muteButton.layer.borderWidth = lineWidth;
    
    [muteButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [muteButton setTitle:@"静音" forState:UIControlStateNormal];
    
    [muteButton addTarget:self action:@selector(MuteBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:muteButton];
    
    //录像按钮
    recButton = [UIButton buttonWithType:UIButtonTypeCustom];
    recButton.frame =  CGRectMake(45, screen_height_/2 + 150, 120, 80);
    recButton.center = CGPointMake(self.view.frame.size.width / 6, recButton.frame.origin.y + recButton.frame.size.height / 2);
    
    recButton.layer.cornerRadius = recButton.frame.size.width / 2;
    recButton.layer.borderColor = [UIColor greenColor].CGColor;
    recButton.layer.borderWidth = lineWidth;
    
    [recButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [recButton setTitle:@"开始录像" forState:UIControlStateNormal];
    
    [recButton addTarget:self action:@selector(recorderBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:recButton];
    
    //拉流按钮
    pullStreamButton = [UIButton buttonWithType:UIButtonTypeCustom];
    pullStreamButton.frame = CGRectMake(45, screen_height_/2 + 200, 120, 80);
    pullStreamButton.center = CGPointMake(self.view.frame.size.width / 6, pullStreamButton.frame.origin.y + pullStreamButton.frame.size.height / 2);
    
    pullStreamButton.layer.cornerRadius = pullStreamButton.frame.size.width / 2;
    pullStreamButton.layer.borderColor = [UIColor greenColor].CGColor;
    pullStreamButton.layer.borderWidth = lineWidth;
    
    [pullStreamButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [pullStreamButton setTitle:@"开始拉流" forState:UIControlStateNormal];
    
    [pullStreamButton addTarget:self action:@selector(pullStreamBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:pullStreamButton];
    
    //退出按钮
    quitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    quitButton.frame = CGRectMake(45, screen_height_/2 + 250, 120, 80);
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
            switchUrl = @"rtmp://live.hkstv.hk.lxdns.com/live/hks";
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
        
        if(!is_pulling_ && !is_recording_)
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
        [_smart_player_sdk SmartPlayerStopRecorder];
        [recButton setTitle:@"开始录像" forState:UIControlStateNormal];
        
        if(!is_playing_ && !is_pulling_)
        {
            [self UnInitPlayer];
        }
        
        is_recording_ = NO;
    }
}

//如需转发video数据
- (void)OnPostVideoEncodedData:(NSInteger)codec_id data:(unsigned char*)data size:(NSInteger)size is_key_frame:(NSInteger)is_key_frame timestamp:(unsigned long long)timestamp pts:(unsigned long long)pts
{
    if(is_pulling_ && _smart_publisher_sdk != nil )
    {
        [_smart_publisher_sdk SmartPublisherPostVideoEncodedData:codec_id data:data size:size is_key_frame:is_key_frame timestamp:timestamp pts:pts];
    }
}

//如需转发audio数据
- (void)OnPostAudioEncodedData:(NSInteger)codec_id data:(unsigned char*)data size:(NSInteger)size is_key_frame:(NSInteger)is_key_frame timestamp:(unsigned long long)timestamp parameter_info:(unsigned char*)parameter_info parameter_info_size:(NSInteger)parameter_info_size
{
    if(is_pulling_ && _smart_publisher_sdk != nil )
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
        
        //_smart_player_sdk.pullStreamVideoDataBlock = nil; //如不需要回调视频数据
        
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
        
        [self InitPublisher];
        
        [self StartPublisher];
        
        if([_smart_player_sdk SmartPlayerStartPullStream] != DANIULIVE_RETURN_OK)
        {
            NSLog(@"Call SmartPlayerStartPullStream failed..");
        }
        
        [pullStreamButton setTitle:@"停止拉流" forState:UIControlStateNormal];
        
        is_pulling_ = YES;
    }
    else
    {
        if (!is_pulling_ )
            return;
        
        [self StopPublisher];
        [self UnInitPublisher];
        
        [_smart_player_sdk SmartPlayerStopPullStream];
        
        [pullStreamButton setTitle:@"开始拉流" forState:UIControlStateNormal];
        
        if(!is_playing_ && !is_recording_)
        {
            [self UnInitPlayer];
        }
        
        is_pulling_ = NO;
    }
}


- (void)quitBtn:(UIButton *)button {
    
    NSLog(@"quitBtn++");
    
    if(is_pulling_)
    {
        [self StopPublisher];
        [self UnInitPublisher];
        
        [_smart_player_sdk SmartPlayerStopPullStream];
        [pullStreamButton setTitle:@"开始拉流" forState:UIControlStateNormal];
        
        is_pulling_ = NO;
    }
    
    if(is_recording_)
    {
        [_smart_player_sdk SmartPlayerStopRecorder];
        [recButton setTitle:@"开始录像" forState:UIControlStateNormal];
        
        is_recording_ = NO;
    }
    
    if(is_playing_)
    {
        [self StopPlayer];
        
        [playbackButton setTitle:@"开始播放" forState:UIControlStateNormal];
        
        is_mute_ = NO;
        is_playing_ = NO;
    }
    
    [self UnInitPlayer];
    
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
    
    NSLog(@"InitPublisher--");
    return true;
}

-(bool)StartPublisher
{
    NSLog(@"StartPublisher++");
    if ( _smart_publisher_sdk == nil )
    {
        NSLog(@"StartPublisher, publiher SDK with nil");
        return false;
    }
    
    NSInteger ret = [_smart_publisher_sdk SmartPublisherStartPublisher:relay_url_];
    
    if(ret != DANIULIVE_RETURN_OK)
    {
        NSLog(@"Call SmartPublisherStartPublisher failed..ret:%ld", (long)ret);
        return false;
    }
    NSLog(@"StartPublisher--");
    return true;
}

-(bool)StopPublisher
{
    NSLog(@"StopPublisher++");
    if ( _smart_publisher_sdk == nil )
    {
        NSLog(@"StopPublisher, publiher SDK with nil");
        return false;
    }
    
    [_smart_publisher_sdk SmartPublisherStopPublisher];
    
    NSLog(@"StopPublisher--");
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
    
    NSLog(@"UnInitPublisher--");
    return true;
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
    else
        NSLog(@"[event]nID:%lx", (long)nID);
    
    return 0;
}
@end
