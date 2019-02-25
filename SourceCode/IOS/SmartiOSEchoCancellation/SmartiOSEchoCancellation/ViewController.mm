//
//  ViewController.m
//  SmartiOSEchoCancellation
//
//  Created by daniulive on 2019/1/22.
//  Copyright © 2019年 daniulive. All rights reserved.
//

#import "ViewController.h"
#import "SmartPublisherSDK.h"
#import "SmartPlayerSDK.h"

@interface ViewController ()<SmartPublisherDelegate,SmartPlayerDelegate>
{
    CGFloat screen_width_;
    CGFloat screen_height_;
    
    UIButton *btn_publisher_controller_;
    UIButton *btn_switch_camera_;
    UIButton *btn_publisher_mute_;
    
    UIButton *btn_player_controller_;
    UIButton *btn_player_mute_;
    
    SmartPlayerSDK *smart_player_sdk;
    SmartPublisherSDK *smart_publisher_sdk;
    
    Boolean is_pushing_rtmp_;
    Boolean is_playing_;
    
    NSString* rtmp_push_url_;
    NSString* playback_url_;
    
    Boolean is_pusher_mute_;
    Boolean is_player_mute_;
}

@property (nonatomic, strong) UIView *publishView;
@property (nonatomic, strong) UIView *playView;

//推送端event状态显示
@property (strong, nonatomic) UILabel *textPublisherEventLabel;

//播放端event状态显示
@property (strong, nonatomic) UILabel *textPlayerEventLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //当前屏幕宽高
    screen_width_  = CGRectGetWidth([UIScreen mainScreen].bounds);
    screen_height_ = CGRectGetHeight([UIScreen mainScreen].bounds);
    
    is_pushing_rtmp_ = NO;
    is_playing_ = NO;
    
    //随机生成个RTMP推送url
    NSInteger randNumber = arc4random()%(1000000);
    NSString *strNumber = [NSString stringWithFormat:@"%ld", (long)randNumber];
    NSString *baseURL = @"rtmp://player.daniulive.com:1935/hls/stream";
    rtmp_push_url_ = [ baseURL stringByAppendingString:strNumber];

    playback_url_ = @"rtmp://live.hkstv.hk.lxdns.com/live/hks1";
    
    is_pusher_mute_ = NO;
    is_player_mute_ = NO;
    
    btn_publisher_controller_ = [UIButton buttonWithType:(UIButtonTypeCustom)];
    btn_publisher_controller_.frame = CGRectMake(0, 100, 100, 30);
    btn_publisher_controller_.backgroundColor = [UIColor redColor];
    
    [self.view addSubview:btn_publisher_controller_];
    [btn_publisher_controller_ setTitle:@"开始推流" forState:(UIControlStateNormal)];
    [btn_publisher_controller_ addTarget:self action:@selector(RtmpPusherController) forControlEvents:(UIControlEventTouchUpInside)];
    
    btn_switch_camera_ = [UIButton buttonWithType:(UIButtonTypeCustom)];
    btn_switch_camera_.frame = CGRectMake(0, 160, 100, 30);
    btn_switch_camera_.backgroundColor = [UIColor blueColor];
    
    [self.view addSubview:btn_switch_camera_];
    [btn_switch_camera_ setTitle:@"切摄像头" forState:(UIControlStateNormal)];
    [btn_switch_camera_ addTarget:self action:@selector(SwitchCamera:) forControlEvents:(UIControlEventTouchUpInside)];
    
    btn_publisher_mute_ = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_publisher_mute_.frame = CGRectMake(0, 220, 100, 30);
    btn_publisher_mute_.backgroundColor = [UIColor blueColor];
    [self.view addSubview:btn_publisher_mute_];
    [btn_publisher_mute_ setTitle:@"实时静音" forState:(UIControlStateNormal)];
    [btn_publisher_mute_ addTarget:self action:@selector(PushererMute:) forControlEvents:(UIControlEventTouchUpInside)];
    
    btn_player_controller_ = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_player_controller_.frame = CGRectMake(0, screen_height_/2, 100, 30);
    btn_player_controller_.backgroundColor = [UIColor redColor];
    [self.view addSubview:btn_player_controller_];
    [btn_player_controller_ setTitle:@"开始播放" forState:(UIControlStateNormal)];
    [btn_player_controller_ addTarget:self action:@selector(PlayerController) forControlEvents:(UIControlEventTouchUpInside)];
    
    btn_player_mute_ = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_player_mute_.frame = CGRectMake(0, screen_height_/2 + 60, 100, 30);
    btn_player_mute_.backgroundColor = [UIColor blueColor];
    [self.view addSubview:btn_player_mute_];
    [btn_player_mute_ setTitle:@"实时静音" forState:(UIControlStateNormal)];
    [btn_player_mute_ addTarget:self action:@selector(PlayerMute:) forControlEvents:(UIControlEventTouchUpInside)];
    
    // 创建推送端Event显示文本
    _textPublisherEventLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, screen_height_/2 - 50, self.view.frame.size.width, 50)];
    // 设置UILabel的背景色
    _textPublisherEventLabel.backgroundColor = [UIColor clearColor];
    // 设置UILabel的文本颜色
    _textPublisherEventLabel.textColor = [UIColor colorWithRed:1.0 green:0.0
                                                          blue:1.0 alpha:1.0];
    
    _textPublisherEventLabel.adjustsFontSizeToFitWidth = YES;
    
    NSString* pub_tag = @"推流URL:";
    
    _textPublisherEventLabel.text = [pub_tag stringByAppendingFormat:@"%@", rtmp_push_url_];
    
    [self.view addSubview:_textPublisherEventLabel];
    
    // 创建播放端Event显示文本
    _textPlayerEventLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, screen_height_ - 50, self.view.frame.size.width, 50)];
    // 设置UILabel的背景色
    _textPlayerEventLabel.backgroundColor = [UIColor clearColor];
    // 设置UILabel的文本颜色
    _textPlayerEventLabel.textColor = [UIColor colorWithRed:1.0 green:0.0
                                                          blue:1.0 alpha:1.0];
    
    _textPlayerEventLabel.adjustsFontSizeToFitWidth = YES;
    
    NSString* play_tag = @"播放URL:";
    
    _textPlayerEventLabel.text = [play_tag stringByAppendingFormat:@"%@", playback_url_];
    
    [self.view addSubview:_textPlayerEventLabel];
}

- (void)RtmpPusherController{
 
    if(is_pushing_rtmp_)
    {
        [self StopPublisher];
    }
    else
    {
        [self StartPublisher];
    }
}

- (void)SwitchCamera:(UIButton *)button
{
    NSLog(@"Run into SwitchCamera..");
    
    button.selected = !button.selected;
    
    if(smart_publisher_sdk)
    {
         [smart_publisher_sdk SmartPublisherSwitchCamera];
    }
}

- (void)PushererMute:(UIButton *)button
{
    NSLog(@"Run into PushererMute..");
    
    if ( smart_publisher_sdk != nil )
    {
        is_pusher_mute_ = !is_pusher_mute_;
        
        if ( is_pusher_mute_ )
        {
            [btn_publisher_mute_ setTitle:@"取消静音" forState:UIControlStateNormal];
        }
        else
        {
            [btn_publisher_mute_ setTitle:@"实时静音" forState:UIControlStateNormal];
        }
        
        [smart_publisher_sdk SmartPublisherSetMute:is_pusher_mute_];
    }
}

-(void)PlayerController{
    
    if(is_playing_)
    {
        [self StopPlayer];
    }
    else
    {
        [self StartPlayer];
    }
}

- (void)PlayerMute:(UIButton *)button
{
    NSLog(@"Run into PlayerMute..");
    
    if ( smart_player_sdk != nil )
    {
        is_player_mute_ = !is_player_mute_;
        
        if ( is_player_mute_ )
        {
            [btn_player_mute_ setTitle:@"取消静音" forState:UIControlStateNormal];
        }
        else
        {
            [btn_player_mute_ setTitle:@"实时静音" forState:UIControlStateNormal];
        }
        
        [smart_player_sdk SmartPlayerSetMute:is_player_mute_];
    }
}

- (void)StartPublisher{
    
    smart_publisher_sdk = [[SmartPublisherSDK alloc]init];
    
    if (smart_publisher_sdk == nil)
    {
        NSLog(@"publisher创建失败");
        return;
    }
    
    if (smart_publisher_sdk.delegate == nil)
    {
        smart_publisher_sdk.delegate = self;
    }

    if([smart_publisher_sdk SmartPublisherInit:1 video_opt:1] != 0)
    {
        smart_publisher_sdk = nil;
        NSLog(@"publisher初始化失败");
        return;
    }
    
    _publishView = [[UIView alloc]initWithFrame:CGRectMake(screen_width_ - 300, 50, 225, 300)];
    _publishView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_publishView];
    
    if ([smart_publisher_sdk SmartPublisherSetVideoPreview:_publishView] != 0)
    {
        [smart_publisher_sdk SmartPublisherUnInit];
        //设置回显失败
        smart_publisher_sdk = nil;
        return;
    }
    
    //调用横屏方法
    /*
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        if([smart_publisher_sdk SmartPublisherSetPublishOrientation:2]!=0)
        {
            NSLog(@"设置横屏失败");
        }
    }else
    {
        if([smart_publisher_sdk SmartPublisherSetPublishOrientation:1]!=0)
        {
            NSLog(@"设置竖屏失败");
        }
    }
     */
    
    Boolean is_enable_echo_cancellation = YES;
    [smart_publisher_sdk SmartPublisherSetEchoCancellation:is_enable_echo_cancellation];
    
    DNVideoStreamingQuality video_stream_quality = DN_VIDEO_QUALITY_MEDIUM;
    if ([smart_publisher_sdk SmartPublisherStartCapture:video_stream_quality]!=0) {
        [smart_publisher_sdk SmartPublisherUnInit];
        smart_publisher_sdk = nil;
        return;
    }
    
    NSInteger video_encoder_type = 1;    //1: H.264, 2: H.265编码
    Boolean is_video_hardware_encoder = YES;
    [smart_publisher_sdk SmartPublisherSetVideoEncoderType:video_encoder_type isHwEncoder:is_video_hardware_encoder];
    
    NSInteger audio_encoder_type = 1;    //1: AAC
    Boolean is_audio_hardware_encoder = NO;
    [smart_publisher_sdk SmartPublisherSetAudioEncoderType:audio_encoder_type isHwEncoder:is_audio_hardware_encoder];
    
    NSInteger gop_interval = 40;
    [smart_publisher_sdk SmartPublisherSetGopInterval:gop_interval];
    
    NSInteger fps = 20;
    [smart_publisher_sdk SmartPublisherSetFPS:fps];
    
    //NSInteger sw_video_encoder_profile = 1;
    //[smart_publisher_sdk SmartPublisherSetSWVideoEncoderProfile:sw_video_encoder_profile];
    
    //NSInteger sw_video_encoder_speed = 2;
    //[smart_publisher_sdk SmartPublisherSetSWVideoEncoderSpeed:sw_video_encoder_speed];
    
    Boolean clip_mode = false;
    [smart_publisher_sdk SmartPublisherSetClippingMode:clip_mode];
    
    if ( !is_video_hardware_encoder )
    {
        NSInteger is_enable_vbr = 1;
        
        if(is_enable_vbr)
        {
            NSInteger video_quality = [self CalVideoQuality:video_stream_quality is_h264:YES];
            NSInteger vbr_max_kbitrate = [self CalVbrMaxKBitRate:video_stream_quality];
            [smart_publisher_sdk SmartPublisherSetSwVBRMode:is_enable_vbr video_quality:video_quality vbr_max_kbitrate:vbr_max_kbitrate];
        }
        else
        {
            //NSInteger avg_bit_rate = 500;
            //NSInteger max_bit_rate = 1000;
            
            //[smart_publisher_sdk SmartPublisherSetVideoBitRate:avg_bit_rate maxBitRate:max_bit_rate];
        }
    }
    else
    {
        //码率可根据实际场景使用情况酌情设置
        if(video_stream_quality == DN_VIDEO_QUALITY_MEDIUM)
        {
            NSInteger avg_bit_rate = 800;
            NSInteger max_bit_rate = 1600;
            
            [smart_publisher_sdk SmartPublisherSetVideoBitRate:avg_bit_rate maxBitRate:max_bit_rate];
        }
    }
    
    NSInteger ret = [smart_publisher_sdk SmartPublisherStartPublisher:rtmp_push_url_];
    
    if(ret != 0)
    {
        if (ret == 2)
        {
            NSLog(@"推流失败");
        }
        else
        {
            NSLog(@"推流失败，返回 DANIULIVE_RETURN_ERROR");
        }
        
        return;
    }
    
    is_pushing_rtmp_ = YES;
    
    [btn_publisher_controller_ setTitle:@"停止推流" forState:(UIControlStateNormal)];
}

- (void)StopPublisher{
    
    if([smart_publisher_sdk SmartPublisherStopPublisher] != 0)
    {
        //停止推流失败
         NSLog(@"rtmp pusher StopPublisher failed..");
    }
    if([smart_publisher_sdk SmartPublisherStopCaputure] != 0)
    {
        //停止捕获失败
        NSLog(@"rtmp pusher StopCaputure failed..");
    }
    if ([smart_publisher_sdk SmartPublisherUnInit] != 0)
    {
        //uninit推流SDK失败
        NSLog(@"rtmp pusher UnInit failed..");
    }
    
    if (_publishView != nil)
    {
        [_publishView removeFromSuperview];
        _publishView = nil;
    }
    
    smart_publisher_sdk.delegate = nil;
    smart_publisher_sdk = nil;
    
    is_pushing_rtmp_ = NO;
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];
    
    [btn_publisher_controller_ setTitle:@"开始推流" forState:(UIControlStateNormal)];
    [btn_publisher_mute_ setTitle:@"实时静音" forState:UIControlStateNormal];
}

- (void)StartPlayer{
    
    _playView = (__bridge UIView *)[SmartPlayerSDK SmartPlayerCreatePlayView:(screen_width_ - 300) y:screen_height_/2 width:300 height:200];
    
    [self.view addSubview:_playView];
    
    smart_player_sdk = [[SmartPlayerSDK alloc]init];//创建对象
    
    if (smart_player_sdk ==nil)
    {
        return;
    }
    
    if (smart_player_sdk.delegate == nil)
    {
        smart_player_sdk.delegate = self;//设置代理
    }
    
    NSInteger initRet = [smart_player_sdk SmartPlayerInitPlayer];//初始化，创建player实例
    
    if ( initRet != 0 )
    {
        return;
    }
    NSInteger videoDecoder = [smart_player_sdk SmartPlayerSetVideoDecoderMode:0];//设置视频解码模式 0软 1硬
    
    if (videoDecoder != 0)
    {
        return;
    }
    
    NSInteger isEchoCancellationMode = 1;   //设置回音消除模式
    [smart_player_sdk SmartPlayerSetEchoCancellationMode:isEchoCancellationMode];
    
    if( [smart_player_sdk SmartPlayerSetPlayView:(__bridge void *)(_playView)]!= 0)
    {
        return;
    }
    
    NSInteger bufferTime = 0;
    
    if( [smart_player_sdk SmartPlayerSetBuffer:bufferTime] != 0 )
    {
        return;
    }
    
    if([smart_player_sdk SmartPlayerSetPlayURL:playback_url_] != 0)
    {
        return;
    }
    
    if([smart_player_sdk SmartPlayerStart] != 0)
    {
        NSLog(@"播放失败");
        return;
    }
    
    is_playing_ = YES;
    [btn_player_controller_ setTitle:@"停止播放" forState:(UIControlStateNormal)];
}
- (void)StopPlayer{
    
    NSLog(@"StopPlayer++");
    
    if (smart_player_sdk != nil)
    {
        [smart_player_sdk SmartPlayerStop];
    }
    
    if (_playView != nil) {
        [_playView removeFromSuperview];
        [SmartPlayerSDK SmartPlayeReleasePlayView:(__bridge void *)(_playView)];
        _playView = nil;
    }
    
    [smart_player_sdk SmartPlayerUnInitPlayer];
    
    if (smart_player_sdk.delegate != nil)
    {
        smart_player_sdk.delegate = nil;
    }
    
    smart_player_sdk = nil;
    
    is_playing_ = NO;
    
    [btn_player_controller_ setTitle:@"开始播放" forState:(UIControlStateNormal)];
    [btn_player_mute_ setTitle:@"实时静音" forState:(UIControlStateNormal)];
}

- (NSInteger) handleSmartPublisherEvent:(NSInteger)nID param1:(unsigned long long)param1 param2:(unsigned long long)param2 param3:(NSString*)param3 param4:(NSString*)param4 pObj:(void *)pObj{
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
    
    NSString* publisher_event_tag = @"推流状态:";
    
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

- (NSInteger)handleSmartPlayerEvent:(NSInteger)nID param1:(unsigned long long)param1 param2:(unsigned long long)param2 param3:(NSString *)param3 param4:(NSString *)param4 pObj:(void *)pObj{
    NSString* player_event = @"";
    NSString* lable = @"";
    
    if (nID == EVENT_DANIULIVE_ERC_PLAYER_STARTED) {
        player_event = @"[event]开始播放..";
    }
    else if (nID == EVENT_DANIULIVE_ERC_PLAYER_CONNECTING)
    {
        player_event = @"[event]连接中..";
    }
    else if (nID == EVENT_DANIULIVE_ERC_PLAYER_CONNECTION_FAILED)
    {
        player_event = @"[event]连接失败..";
    }
    else if (nID == EVENT_DANIULIVE_ERC_PLAYER_CONNECTED)
    {
        player_event = @"[event]已连接..";
    }
    else if (nID == EVENT_DANIULIVE_ERC_PLAYER_DISCONNECTED)
    {
        player_event = @"[event]断开连接..";
    }
    else if (nID == EVENT_DANIULIVE_ERC_PLAYER_STOP)
    {
        player_event = @"[event]停止播放..";
    }
    else if (nID == EVENT_DANIULIVE_ERC_PLAYER_RESOLUTION_INFO)
    {
        NSString *str_w = [NSString stringWithFormat:@"%ld", (NSInteger)param1];
        NSString *str_h = [NSString stringWithFormat:@"%ld", (NSInteger)param2];
        
        lable = @"[event]视频解码分辨率信息: ";
        player_event = [lable stringByAppendingFormat:@"%@*%@", str_w, str_h];
    }
    else if (nID == EVENT_DANIULIVE_ERC_PLAYER_NO_MEDIADATA_RECEIVED)
    {
        player_event = @"[event]收不到RTMP数据..";
    }
    else if (nID == EVENT_DANIULIVE_ERC_PLAYER_SWITCH_URL)
    {
        player_event = @"[event]快速切换url..";
    }
    else if (nID == EVENT_DANIULIVE_ERC_PLAYER_CAPTURE_IMAGE)
    {
        if ((int)param1 == 0)
        {
            NSLog(@"[event]快照成功: %@", param3);
            lable = @"[event]快照成功:";
            player_event = [lable stringByAppendingFormat:@"%@", param3];
        }
        else
        {
            lable = @"[event]快照失败";
            player_event = [lable stringByAppendingFormat:@"%@", param3];
        }
    }
    else if (nID == EVENT_DANIULIVE_ERC_PLAYER_RECORDER_START_NEW_FILE)
    {
        lable = @"[event]录像写入新文件..文件名:";
        player_event = [lable stringByAppendingFormat:@"%@", param3];
    }
    else if (nID == EVENT_DANIULIVE_ERC_PLAYER_ONE_RECORDER_FILE_FINISHED)
    {
        lable = @"一个录像文件完成..文件名:";
        player_event = [lable stringByAppendingFormat:@"%@", param3];
    }
    else if (nID == EVENT_DANIULIVE_ERC_PLAYER_START_BUFFERING)
    {
        NSLog(@"[event]开始buffer..");
    }
    else if (nID == EVENT_DANIULIVE_ERC_PLAYER_BUFFERING)
    {
        NSLog(@"[event]buffer百分比: %lld", param1);
    }
    else if (nID == EVENT_DANIULIVE_ERC_PLAYER_STOP_BUFFERING)
    {
        NSLog(@"[event]停止buffer..");
    }
    else if (nID == EVENT_DANIULIVE_ERC_PLAYER_DOWNLOAD_SPEED)
    {
        NSInteger speed_kbps = (NSInteger)param1*8/1000;
        NSInteger speed_KBs = (NSInteger)param1/1024;
        
        lable = @"[event]download speed :";
        player_event = [lable stringByAppendingFormat:@"%ld kbps - %ld KB/s", (long)speed_kbps, (long)speed_KBs];
    }
    else if(nID == EVENT_DANIULIVE_ERC_PLAYER_RTSP_STATUS_CODE)
    {
        lable = @"[event]RTSP status code received:";
        player_event = [lable stringByAppendingFormat:@"%ld", (long)param1];
        
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
    
    NSString* player_event_tag = @"当前状态:";
    NSString* event = [player_event_tag stringByAppendingFormat:@"%@", player_event];
    
    NSLog(@"%@", event);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            self.textPlayerEventLabel.text = event;
        });
    });
    
    return 0;
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

@end
