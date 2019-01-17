//
//  ViewController.m
//  SmartiOSPlayerV2
//
//  GitHub: https://github.com/daniulive/SmarterStreaming
//  website: https://www.daniulive.com
//
//  Created by daniulive on 2016/01/03.
//  Copyright © 2014~2019 daniulive. All rights reserved.
//

#import "ViewController.h"
#import "RecorderView.h"

@interface ViewController ()

@property (strong, nonatomic) UILabel *textPlayerEventLabel;
@property (strong, nonatomic) UILabel *textPlayerUserDataLabel;
@property NSTimer *timer;

/**
 * 这个说明自定义传输的数据类型，目前传两种格式,第一种是二进制数据，第二种是utf8字符串
 */
typedef enum NT_SDK_E_H264_SEI_USER_DATA_TYPE{
    NT_SDK_E_H264_SEI_USER_DATA_TYPE_BYTE_DATA = 1,        // 二进制数据
    NT_SDK_E_H264_SEI_USER_DATA_TYPE_UTF8_STRING = 2	   // utf8字符串
}NT_SDK_E_H264_SEI_USER_DATA_TYPE;

@end

@implementation ViewController
{
    SmartPlayerSDK  *_smart_player_sdk;
    
    UIView          * _glView;
    Boolean         is_inited_player_;
    NSString        *playback_url_;             //拉流url
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
    NSInteger       stream_width_;              //视频宽
    NSInteger       stream_height_;             //视频高
    
    Boolean         is_switch_url_;             //切换url flag
    Boolean         is_mute_;                   //静音flag
    NSInteger       save_image_flag_;           //实时快照
    
    UIButton        *muteButton;                //静音 取消静音
    UIButton        *switchUrlButton;           //切换url按钮
    UIButton        *playbackButton;            //播放按钮
    UIButton        *flipVerticalButton;        //垂直反转
    UIButton        *flipHorizontalButton;      //水平反转
    UIButton        *rotationButton;            //view旋转按钮
    UIButton        *recButton;                 //录像按钮
    UIButton        *saveImageButton;           //快照按钮
    UIButton        *quitButton;                //退出按钮
    
    UIImage         *image_path_;
    NSString        *tmp_path_;
    
    Boolean         is_flip_vertical_;          //垂直反转
    Boolean         is_flip_horizontal_;        //水平反转
    NSInteger       rotate_degrees_;            //view旋转角度 如设置为0则不旋转 参考设置值 0 90 180 270
    
    Boolean         is_playing_;                //是否播放状态
    Boolean         is_recording_;              //是否录像状态
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientChange:)name:UIDeviceOrientationDidChangeNotification object:nil];
    
    is_inited_player_ = NO;
    
    //当前屏幕宽高
    screen_width_  = CGRectGetWidth([UIScreen mainScreen].bounds);
    screen_height_ = CGRectGetHeight([UIScreen mainScreen].bounds);
    
    player_view_width_ = screen_width_;
    player_view_height_ = screen_height_;
    
    stream_width_ = 480;
    stream_height_ = 288;
    
    //拉流url可以自定义
    playback_url_ = @"rtmp://live.hkstv.hk.lxdns.com/live/hks1";
    
    //playback_url_ = @"rtsp://184.72.239.149/vod/mp4://BigBuckBunny_175k.mov";   //公网rtsp流，TCP模式的有audio
    
    //playback_url_ = @"rtmp://player.daniulive.com:1935/hls/stream123";
    
    is_audio_only_ = NO;
    is_half_screen_ = YES;            //半屏播放, 只是为了效果展示
    
    is_fast_startup_ = YES;           //是否快速启动模式
    is_low_latency_mode_ = NO;        //是否开启极速模式
    buffer_time_ = 100;               //buffer时间
    is_hardware_decoder_ = NO;        //默认软解码
    is_rtsp_tcp_mode_ = NO;           //仅用于rtsp流 设置TCP传输模式 默认UDP模式
    
    is_flip_vertical_ = NO;           //垂直反转
    is_flip_horizontal_ = NO;         //水平反转
    rotate_degrees_ = 0;              //视频view旋转 0度 90度 180度 270度
    
    is_switch_url_ = NO;              //URL快速切换
    is_mute_ = NO;                    //是否静音
    save_image_flag_ = 1;             //是否启用实时快照
    
    is_playing_ = NO;
    is_recording_ = NO;
    
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
    switchUrlButton.frame = CGRectMake(45, screen_height_/2, 120, 80);
    switchUrlButton.center = CGPointMake(self.view.frame.size.width / 2, switchUrlButton.frame.origin.y + switchUrlButton.frame.size.height / 2);
    
    switchUrlButton.layer.cornerRadius = switchUrlButton.frame.size.width / 2;
    switchUrlButton.layer.borderColor = [UIColor greenColor].CGColor;
    switchUrlButton.layer.borderWidth = lineWidth;
    
    [switchUrlButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [switchUrlButton setTitle:@"切换URL2" forState:UIControlStateNormal];
    
    [switchUrlButton addTarget:self action:@selector(SwitchUrlBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:switchUrlButton];
    
    //静音按钮
    muteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    muteButton.frame = CGRectMake(45, screen_height_/2 + 50, 120, 80);
    muteButton.center = CGPointMake(self.view.frame.size.width / 6, muteButton.frame.origin.y + muteButton.frame.size.height / 2);
    
    muteButton.layer.cornerRadius = muteButton.frame.size.width / 2;
    muteButton.layer.borderColor = [UIColor greenColor].CGColor;
    muteButton.layer.borderWidth = lineWidth;
    
    [muteButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [muteButton setTitle:@"实时静音" forState:UIControlStateNormal];
    
    [muteButton addTarget:self action:@selector(MuteBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:muteButton];
    
    //实时视频view旋转按钮
    rotationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rotationButton.frame = CGRectMake(45, screen_height_/2 + 50, 120, 80);
    rotationButton.center = CGPointMake(self.view.frame.size.width / 2, rotationButton.frame.origin.y + muteButton.frame.size.height / 2);
    
    rotationButton.layer.cornerRadius = rotationButton.frame.size.width / 2;
    rotationButton.layer.borderColor = [UIColor greenColor].CGColor;
    rotationButton.layer.borderWidth = lineWidth;
    
    [rotationButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    
    NSString* rotation_text;
    
    if ( 0 == rotate_degrees_ )
    {
        rotation_text = @"旋转90度";
    }
    else if ( 90 == rotate_degrees_)
    {
        rotation_text = @"旋转180度";
    }
    else if ( 180 == rotate_degrees_)
    {
        rotation_text = @"旋转270度";
    }
    else if ( 270 == rotate_degrees_)
    {
        rotation_text = @"不旋转";
    }
    
    [rotationButton setTitle:rotation_text forState:UIControlStateNormal];
    
    [rotationButton addTarget:self action:@selector(RotationBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:rotationButton];
    
    //垂直反转
    flipVerticalButton = [UIButton buttonWithType:UIButtonTypeCustom];
    flipVerticalButton.frame =  CGRectMake(45, screen_height_/2 + 100, 120, 80);
    flipVerticalButton.center = CGPointMake(self.view.frame.size.width / 6, flipVerticalButton.frame.origin.y + flipVerticalButton.frame.size.height / 2);
    
    flipVerticalButton.layer.cornerRadius = flipVerticalButton.frame.size.width / 2;
    flipVerticalButton.layer.borderColor = [UIColor greenColor].CGColor;
    flipVerticalButton.layer.borderWidth = lineWidth;
    
    [flipVerticalButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [flipVerticalButton setTitle:@"垂直反转" forState:UIControlStateNormal];
    
    [flipVerticalButton addTarget:self action:@selector(FlipVerticalBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:flipVerticalButton];
    
    //水平反转
    flipHorizontalButton = [UIButton buttonWithType:UIButtonTypeCustom];
    flipHorizontalButton.frame =  CGRectMake(45, screen_height_/2 + 100, 120, 80);
    flipHorizontalButton.center = CGPointMake(self.view.frame.size.width / 2, flipVerticalButton.frame.origin.y + flipHorizontalButton.frame.size.height / 2);
    
    flipHorizontalButton.layer.cornerRadius = flipHorizontalButton.frame.size.width / 2;
    flipHorizontalButton.layer.borderColor = [UIColor greenColor].CGColor;
    flipHorizontalButton.layer.borderWidth = lineWidth;
    
    [flipHorizontalButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [flipHorizontalButton setTitle:@"水平反转" forState:UIControlStateNormal];
    
    [flipHorizontalButton addTarget:self action:@selector(FlipHorizontalBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:flipHorizontalButton];

    //实时录像按钮
    recButton = [UIButton buttonWithType:UIButtonTypeCustom];
    recButton.frame =  CGRectMake(45, screen_height_/2 + 150, 120, 80);
    recButton.center = CGPointMake(self.view.frame.size.width / 6, recButton.frame.origin.y + recButton.frame.size.height / 2);
    
    recButton.layer.cornerRadius = recButton.frame.size.width / 2;
    recButton.layer.borderColor = [UIColor greenColor].CGColor;
    recButton.layer.borderWidth = lineWidth;
    
    [recButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [recButton setTitle:@"开始录像" forState:UIControlStateNormal];
    
    [recButton addTarget:self action:@selector(RecorderBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:recButton];
    
    //实时快照按钮
    saveImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    saveImageButton.frame =  CGRectMake(45, screen_height_/2 + 150, 120, 80);
    saveImageButton.center = CGPointMake(self.view.frame.size.width / 2, saveImageButton.frame.origin.y + saveImageButton.frame.size.height / 2);
    
    saveImageButton.layer.cornerRadius = recButton.frame.size.width / 2;
    saveImageButton.layer.borderColor = [UIColor greenColor].CGColor;
    saveImageButton.layer.borderWidth = lineWidth;
    
    [saveImageButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [saveImageButton setTitle:@"实时快照" forState:UIControlStateNormal];
    
    [saveImageButton addTarget:self action:@selector(SaveImageBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:saveImageButton];
    
    //退出按钮
    quitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    quitButton.frame = CGRectMake(45, screen_height_/2 + 200, 120, 80);
    quitButton.center = CGPointMake(self.view.frame.size.width / 6, quitButton.frame.origin.y + quitButton.frame.size.height / 2);
    
    quitButton.layer.cornerRadius = quitButton.frame.size.width / 2;
    quitButton.layer.borderColor = [UIColor greenColor].CGColor;
    quitButton.layer.borderWidth = lineWidth;
    
    [quitButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [quitButton setTitle:@"退出进入录像" forState:UIControlStateNormal];
    
    [quitButton addTarget:self action:@selector(quitBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:quitButton];
    
    // 创建Event状态显示文本
    _textPlayerEventLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, screen_height_/2 + 250, self.view.frame.size.width, 50)];
    // 设置UILabel的背景色
    _textPlayerEventLabel.backgroundColor = [UIColor clearColor];
    // 设置UILabel的文本颜色
    _textPlayerEventLabel.textColor = [UIColor colorWithRed:1.0 green:0.0
                                               blue:1.0 alpha:1.0];
    
    _textPlayerEventLabel.adjustsFontSizeToFitWidth = YES;
    
    _textPlayerEventLabel.text = @"当前状态:";
    [self.view addSubview:_textPlayerEventLabel];
    
    // 创建用户信息显示文本
    _textPlayerUserDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, screen_height_/2 + 300, self.view.frame.size.width, 50)];
    // 设置UILabel的背景色
    _textPlayerUserDataLabel.backgroundColor = [UIColor clearColor];
    // 设置UILabel的文本颜色
    _textPlayerUserDataLabel.textColor = [UIColor colorWithRed:1.0 green:0.0
                                                       blue:1.0 alpha:1.0];
    
    _textPlayerUserDataLabel.adjustsFontSizeToFitWidth = YES;
    
    //如果没有用户信息, 默认显示播放的url
    NSString *str = @"播放url: ";
    
    _textPlayerUserDataLabel.text =  [str stringByAppendingString:playback_url_];
    [self.view addSubview:_textPlayerUserDataLabel];
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
        f.origin.y = 100;
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
            switchUrl = @"rtsp://184.72.239.149/vod/mp4://BigBuckBunny_175k.mov";     //切换url可自定义
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
            [muteButton setTitle:@"实时静音" forState:UIControlStateNormal];
        }
        
        [_smart_player_sdk SmartPlayerSetMute:is_mute_];
    }
}

- (void)RotationBtn:(id)sender {
    if ( _smart_player_sdk != nil )
    {
        rotate_degrees_ += 90;
        rotate_degrees_ = rotate_degrees_ % 360;
        
        NSString* rotation_text;
        
        if ( 0 == rotate_degrees_ )
        {
            rotation_text = @"旋转90度";
        }
        else if ( 90 == rotate_degrees_)
        {
            rotation_text = @"旋转180度";
        }
        else if ( 180 == rotate_degrees_)
        {
            rotation_text = @"旋转270度";
        }
        else if ( 270 == rotate_degrees_)
        {
            rotation_text = @"不旋转";
        }
        
        [rotationButton setTitle:rotation_text forState:UIControlStateNormal];
        
        [_smart_player_sdk SmartPlayerSetRotation:rotate_degrees_];
    }
}

- (void)FlipVerticalBtn:(id)sender {
    if ( _smart_player_sdk != nil )
    {
        is_flip_vertical_ = !is_flip_vertical_;
        
        if ( is_flip_vertical_ )
        {
            [flipVerticalButton setTitle:@"取消反转" forState:UIControlStateNormal];
        }
        else
        {
            [flipVerticalButton setTitle:@"垂直反转" forState:UIControlStateNormal];
        }
        
        [_smart_player_sdk SmartPlayerSetFlipVertical:(is_flip_vertical_?1:0)];
    }
}

- (void)FlipHorizontalBtn:(id)sender {
    if ( _smart_player_sdk != nil )
    {
        is_flip_horizontal_ = !is_flip_horizontal_;
        
        if ( is_flip_horizontal_ )
        {
            [flipHorizontalButton setTitle:@"取消反转" forState:UIControlStateNormal];
        }
        else
        {
            [flipHorizontalButton setTitle:@"水平反转" forState:UIControlStateNormal];
        }
        
        [_smart_player_sdk SmartPlayerSetFlipHorizontal:(is_flip_horizontal_?1:0)];
    }
}

-(void)OnUserDataCallBack:(NSInteger)data_type data:(unsigned char*)data
            size:(NSInteger)size timestamp:(unsigned long long)timestamp
            reserve1:(unsigned long long)reserve1 reserve2:(long long)reserve2 reserve3:(unsigned char*)reserve3
{
    //NSLog(@"OnUserDataCallBack, type:%d, data:%s, size:%d, ts:%lld", (int)data_type, data, (int)size, timestamp);
    
	//功能展示之用, 其他回调参数 开发者可自行处理
	if(data_type == NT_SDK_E_H264_SEI_USER_DATA_TYPE_UTF8_STRING)
	{
	    NSString* user_data = [[NSString alloc]initWithUTF8String:(char*)data];
    
	    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
	        dispatch_async(dispatch_get_main_queue(), ^{
	            self.textPlayerUserDataLabel.text = user_data;
	        });
	    });
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
        
        //如需处理回调的用户数据+++++++++
        __weak __typeof(self) weakSelf = self;
        
        _smart_player_sdk.spUserDataCallBack = ^(int data_type, unsigned char *data, unsigned int size, unsigned long long timestamp, unsigned long long reserve1, long long reserve2, unsigned char *reserve3)
        {
            [weakSelf OnUserDataCallBack:data_type data:data size:size timestamp:timestamp reserve1:reserve1 reserve2:reserve2 reserve3:reserve3];
        };
        
        Boolean enableUserDataCallback = YES;
        [_smart_player_sdk SmartPlayerSetUserDataCallback:enableUserDataCallback];
         //如需处理回调的用户数据---------
        
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
        
        if(!is_recording_)
        {
            [self UnInitPlayer];
        }
        
        [playbackButton setTitle:@"开始播放" forState:UIControlStateNormal];
        
        is_mute_ = NO;
        [muteButton setTitle:@"实时静音" forState:UIControlStateNormal];
        
        is_playing_ = NO;
    }
}

- (void)RecorderBtn:(UIButton *)button {
    
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
        
        if(!is_playing_)
        {
            [self UnInitPlayer];
        }
        
        is_recording_ = NO;
    }
}

- (void)SaveImageBtn:(id)sender {
    if ( _smart_player_sdk != nil )
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
        
        [_smart_player_sdk SmartPlayerSaveCurImage:image_name];
    }
}

- (void)quitBtn:(UIButton *)button {
    
    NSLog(@"quitBtn++");
    
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
    
    //超低延迟模式设置
    [_smart_player_sdk SmartPlayerSetLowLatencyMode:(NSInteger)is_low_latency_mode_];
    
    //buffer time设置
    if(buffer_time_ >= 0)
    {
        [_smart_player_sdk SmartPlayerSetBuffer:buffer_time_];
    }
    
    //快速启动模式设置
    [_smart_player_sdk SmartPlayerSetFastStartup:(NSInteger)is_fast_startup_];
    
    NSLog(@"[SmartPlayerV2]is_fast_startup_:%d, buffer_time_:%ld", is_fast_startup_, (long)buffer_time_);
    
    //RTSP TCP还是UDP模式
    [_smart_player_sdk SmartPlayerSetRTSPTcpMode:is_rtsp_tcp_mode_];
 
    //设置RTSP超时时间
    NSInteger rtsp_timeout = 10;
    [_smart_player_sdk SmartPlayerSetRTSPTimeout:rtsp_timeout];
    
    //设置RTSP TCP/UDP自动切换
    NSInteger is_tcp_udp_auto_switch = 1;
    [_smart_player_sdk SmartPlayerSetRTSPAutoSwitchTcpUdp:is_tcp_udp_auto_switch];
    
    //快照设置 如需快照 参数传1
    [_smart_player_sdk SmartPlayerSaveImageFlag:save_image_flag_];
    
    //如需查看实时流量信息，可打开以下接口
    NSInteger is_report = 1;
    NSInteger report_interval = 5;
    [_smart_player_sdk SmartPlayerSetReportDownloadSpeed:is_report report_interval:report_interval];
    
    //录像端音频，是否转AAC后保存
    NSInteger is_transcode = 1;
    [_smart_player_sdk SmartPlayerSetRecorderAudioTranscodeAAC:is_transcode];
    
    //录制MP4文件 是否录制视频
    NSInteger is_record_video = 1;
    [_smart_player_sdk SmartPlayerSetRecorderVideo:is_record_video];
    
    //录制MP4文件 是否录制音频
    NSInteger is_record_audio = 1;
    [_smart_player_sdk SmartPlayerSetRecorderAudio:is_record_audio];
    
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

    //设置视频view旋转角度
    [_smart_player_sdk SmartPlayerSetRotation:rotate_degrees_];
    
    //软/硬解码模式设置
    [_smart_player_sdk SmartPlayerSetVideoDecoderMode:is_hardware_decoder_];
    
    if (is_audio_only_) {
        [_smart_player_sdk SmartPlayerSetPlayView:nil];
    }
    else
    {
        //如果只需外部回调YUV数据，自己绘制，无需创建view和设置view到SDK
        _glView = (__bridge UIView *)([SmartPlayerSDK SmartPlayerCreatePlayView:0 y:100 width:player_view_width_ height:player_view_height_]);
        
        if (_glView == nil ) {
            NSLog(@"CreatePlayView failed..");
            return false;
        }
        
        [self.view addSubview:_glView];
        
        [_smart_player_sdk SmartPlayerSetPlayView:(__bridge void *)(_glView)];
    }
    
    /*
     _smart_player_sdk.yuvDataBlock = ^void(int width, int height, unsigned long long time_stamp,
     unsigned char*yData, unsigned char* uData, unsigned char*vData,
     int yStride, int uStride, int vStride)
     {
     NSLog(@"[PlaySideYuvCallback] width:%d, height:%d, ts:%lld, y:%d, u:%d, v:%d", width, height, time_stamp, yStride, uStride, vStride);
     //这里接收底层回调的YUV数据
     };
    
    //设置YUV数据回调输出
    [_smart_player_sdk SmartPlayerSetYuvBlock:true];
    */
    
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
        
        if (_smart_player_sdk.delegate != nil)
        {
            _smart_player_sdk.delegate = nil;
        }
        
        _smart_player_sdk = nil;
    }
    
    is_inited_player_ = NO;
    
    NSLog(@"UnInitPlayer--");
    return true;
}

//event相关处理
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
    BOOL isDelete=[fileManager removeItemAtPath:tmp_path_ error:nil];
    NSLog(@"old file deleted: %d",isDelete);
}

- (NSInteger) handleSmartPlayerEvent:(NSInteger)nID param1:(unsigned long long)param1 param2:(unsigned long long)param2 param3:(NSString*)param3 param4:(NSString*)param4 pObj:(void *)pObj;
{
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
        stream_width_ = (NSInteger)param1;
        stream_height_ = (NSInteger)param2;
        
        NSString *str_w = [NSString stringWithFormat:@"%ld", (long)stream_width_];
        NSString *str_h = [NSString stringWithFormat:@"%ld", (long)stream_height_];
        
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
            
            tmp_path_ = param3;
            
            image_path_ = [ UIImage imageNamed:param3];
            
            UIImageWriteToSavedPhotosAlbum(image_path_, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
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

@end
