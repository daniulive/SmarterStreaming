//
//  SettingView.m
//  SmartiOSPlayer
//
//  GitHub: https://github.com/daniulive/SmarterStreaming
//
//  Created by daniulive on 16/3/24.
//  Copyright © 2016年 daniulive. All rights reserved.

#import "SettingView.h"
#import "ViewController.h"

#define kBtnHeight     50
#define kHorMargin     10
#define kVerMargin     80

@interface SettingView ()
{
    NSString *baseURL;
    Boolean is_audio_only_;
    Boolean is_hardware_decoder_;
    Boolean is_rtsp_tcp_mode_;
}

@property (nonatomic, strong) UINavigationBar *nvgBar;

@property (nonatomic, strong) UIButton *daniuServerBtn;
@property (nonatomic, strong) UIButton *cdnServerBtn;
@property (nonatomic, strong) UIButton *audioOnlyBtn;

@property (nonatomic, strong) UIButton *swDecoderBtn;
@property (nonatomic, strong) UIButton *hwDecoderBtn;

@property (nonatomic, strong) UIButton *udpBtn;
@property (nonatomic, strong) UIButton *tcpBtn;

@property (nonatomic, strong) UIButton *interPlaybackView;

@property (nonatomic, strong) UILabel *cdnServerLable;
@property (nonatomic, strong) UILabel *daniuServerLable;
@property (nonatomic, strong) UILabel *audioOnlyLable;

@property (nonatomic, strong) UILabel *swDecoderLable;
@property (nonatomic, strong) UILabel *hwDecoderLable;

@property (nonatomic, strong) UILabel *udpLable;
@property (nonatomic, strong) UILabel *tcpLable;

@property (nonatomic, strong) UITextField *urlID;

- (void)qualityButtonClicked:(id)sender;

@end

@implementation SettingView

@synthesize nvgBar;
@synthesize daniuServerBtn;
@synthesize cdnServerBtn;
@synthesize cdnServerLable;
@synthesize daniuServerLable;
@synthesize interPlaybackView;


#pragma mark - Init
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView
{
    is_audio_only_ = FALSE;
    
    // If you create your views manually, you MUST override this method and use it to create your views.
    // If you use Interface Builder to create your views, then you must NOT override this method.
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    self.view.backgroundColor = [UIColor whiteColor];
    
    //当前屏幕宽高
    CGFloat screenWidth  = CGRectGetWidth([UIScreen mainScreen].bounds);
    
    //导航栏:直播设置
    
    [self.navigationItem setTitle:@"大牛直播播放端V1.0.06.12.05"];
    
    [self.navigationController.navigationBar setBackgroundColor:[UIColor blackColor]];
    

    CGFloat buttonWidth = screenWidth - kHorMargin*2;
    
    CGFloat buttonSpace = (screenWidth - 2*kHorMargin-160)/6;
    
    //直播地址
    self.urlID = [[UITextField alloc] initWithFrame:CGRectMake(kHorMargin, kVerMargin, buttonWidth, kBtnHeight)];
    [self.urlID setBackgroundColor:[UIColor whiteColor]];
    self.urlID.placeholder = @"请输入播放urlID（推流url中，stream后的部分）";
    self.urlID.textColor = [[UIColor alloc] initWithRed:51.0/255 green:51.0/255 blue:51.0/255 alpha:1.0];
    self.urlID.borderStyle = UITextBorderStyleRoundedRect;
    self.urlID.autocorrectionType = UITextAutocorrectionTypeNo;
    self.urlID.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.urlID addTarget:self action:@selector(textFieldDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
    self.urlID.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.urlID setText:[NSString stringWithFormat:@"hks"]];
    //[self.urlID setText:[NSString stringWithFormat:@"rtsp"]];
    //[self.urlID setText:[NSString stringWithFormat:@"audio"]];
    
    //直播视频质量
    self.daniuServerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.daniuServerBtn.tag = 1;
    self.daniuServerBtn.frame = CGRectMake(kHorMargin+buttonSpace, kVerMargin+kBtnHeight+80, 20, 20);
    [self.daniuServerBtn setImage:[UIImage imageNamed:@"btn_selected"] forState:UIControlStateNormal];
    [self.daniuServerBtn addTarget:self action:@selector(qualityButtonClicked:) forControlEvents:UIControlEventTouchDown];
    
    self.daniuServerLable = [[UILabel alloc] initWithFrame:CGRectMake(kHorMargin+buttonSpace+20, kVerMargin+kBtnHeight+80, 50, 20)];
    self.daniuServerLable.text = @"大牛";
    self.cdnServerLable.lineBreakMode = NSLineBreakByCharWrapping;
    self.daniuServerLable.textColor = [[UIColor alloc] initWithRed:51.0/255 green:51.0/255 blue:51.0/255 alpha:1.0];

    self.cdnServerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cdnServerBtn.tag = 2;
    
    self.cdnServerBtn.frame = CGRectMake(kHorMargin+3*buttonSpace+60, kVerMargin+kBtnHeight+80, 20, 20);
    [self.cdnServerBtn setImage:[UIImage imageNamed:@"btn_unselected"] forState:UIControlStateNormal];
    [self.cdnServerBtn addTarget:self action:@selector(qualityButtonClicked:) forControlEvents:UIControlEventTouchDown];
    self.cdnServerLable = [[UILabel alloc] initWithFrame:CGRectMake(kHorMargin+3*buttonSpace+80, kVerMargin+kBtnHeight+80, 50, 20)];
    self.cdnServerLable.text = @"CDN";
    self.cdnServerLable.lineBreakMode = NSLineBreakByCharWrapping;
    self.cdnServerLable.textColor = [[UIColor alloc] initWithRed:51.0/255 green:51.0/255 blue:51.0/255 alpha:1.0];
    
    self.audioOnlyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.audioOnlyBtn.tag = 3;
    
    self.audioOnlyBtn.frame = CGRectMake(screenWidth-kHorMargin-buttonSpace-60,kVerMargin+kBtnHeight+80,20,20);
    [self.audioOnlyBtn setImage:[UIImage imageNamed:@"btn_unselected"] forState:UIControlStateNormal];
    [self.audioOnlyBtn addTarget:self action:@selector(qualityButtonClicked:) forControlEvents:UIControlEventTouchDown];
    self.audioOnlyLable = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth-kHorMargin-buttonSpace-40,kVerMargin+kBtnHeight+80,50,20)];
    self.audioOnlyLable.text = @"纯音频";
    self.audioOnlyLable.lineBreakMode = NSLineBreakByCharWrapping;
    self.audioOnlyLable.textColor = [[UIColor alloc] initWithRed:51.0/255 green:51.0/255 blue:51.0/255 alpha:1.0];
    
    //设置软解／硬解码
    self.swDecoderBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.swDecoderBtn.tag = 1;
    self.swDecoderBtn.frame = CGRectMake(kHorMargin+buttonSpace, kVerMargin+kBtnHeight+80+80, 20, 20);
    [self.swDecoderBtn setImage:[UIImage imageNamed:@"btn_selected"] forState:UIControlStateNormal];
    [self.swDecoderBtn addTarget:self action:@selector(decoderButtonClicked:) forControlEvents:UIControlEventTouchDown];
    
    self.swDecoderLable = [[UILabel alloc] initWithFrame:CGRectMake(kHorMargin+buttonSpace+20, kVerMargin+kBtnHeight+80+80, 90, 20)];
    self.swDecoderLable.text = @"软解码";
    self.swDecoderLable.lineBreakMode = NSLineBreakByCharWrapping;
    self.swDecoderLable.textColor = [[UIColor alloc] initWithRed:51.0/255 green:51.0/255 blue:51.0/255 alpha:1.0];
    
    self.hwDecoderBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.hwDecoderBtn.tag = 2;
    
    self.hwDecoderBtn.frame = CGRectMake(kHorMargin+3*buttonSpace+60, kVerMargin+kBtnHeight+80+80, 20, 20);
    [self.hwDecoderBtn setImage:[UIImage imageNamed:@"btn_unselected"] forState:UIControlStateNormal];
    [self.hwDecoderBtn addTarget:self action:@selector(decoderButtonClicked:) forControlEvents:UIControlEventTouchDown];
    
    self.hwDecoderLable = [[UILabel alloc] initWithFrame:CGRectMake(kHorMargin+3*buttonSpace+80, kVerMargin+kBtnHeight+80+80, 90, 20)];
    self.hwDecoderLable.text = @"硬解码";
    self.hwDecoderLable.lineBreakMode = NSLineBreakByCharWrapping;
    self.hwDecoderLable.textColor = [[UIColor alloc] initWithRed:51.0/255 green:51.0/255 blue:51.0/255 alpha:1.0];
    
    //RTSP only: 设置UDP或TCP传输
    self.udpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.udpBtn.tag = 1;
    self.udpBtn.frame = CGRectMake(kHorMargin+buttonSpace, kVerMargin+kBtnHeight+80+80+80, 20, 20);
    [self.udpBtn setImage:[UIImage imageNamed:@"btn_selected"] forState:UIControlStateNormal];
    [self.udpBtn addTarget:self action:@selector(transModeButtonClicked:) forControlEvents:UIControlEventTouchDown];
    
    self.udpLable = [[UILabel alloc] initWithFrame:CGRectMake(kHorMargin+buttonSpace+20, kVerMargin+kBtnHeight+80+80+80, 90, 20)];
    self.udpLable.text = @"UDP(RTSP)";
    self.udpLable.lineBreakMode = NSLineBreakByCharWrapping;
    self.udpLable.textColor = [[UIColor alloc] initWithRed:51.0/255 green:51.0/255 blue:51.0/255 alpha:1.0];
    
    self.tcpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.tcpBtn.tag = 2;
    
    self.tcpBtn.frame = CGRectMake(kHorMargin+3*buttonSpace+60, kVerMargin+kBtnHeight+80+80+80, 20, 20);
    [self.tcpBtn setImage:[UIImage imageNamed:@"btn_unselected"] forState:UIControlStateNormal];
    [self.tcpBtn addTarget:self action:@selector(transModeButtonClicked:) forControlEvents:UIControlEventTouchDown];
    
    self.tcpLable = [[UILabel alloc] initWithFrame:CGRectMake(kHorMargin+3*buttonSpace+80, kVerMargin+kBtnHeight+80+80+80, 90, 20)];
    self.tcpLable.text = @"TCP(RTSP)";
    self.tcpLable.lineBreakMode = NSLineBreakByCharWrapping;
    self.tcpLable.textColor = [[UIColor alloc] initWithRed:51.0/255 green:51.0/255 blue:51.0/255 alpha:1.0];

    
    //进入播放页面
    self.interPlaybackView = [UIButton buttonWithType:UIButtonTypeCustom];
    self.interPlaybackView.tag = 4;
    self.interPlaybackView.frame = CGRectMake(kHorMargin, kVerMargin+kBtnHeight+80+80+80+80+20, buttonWidth, kBtnHeight);
    [self.interPlaybackView setTitle:@"进入播放页面" forState:UIControlStateNormal];
    [self.interPlaybackView setBackgroundImage:[UIImage imageNamed:@"start_playback"] forState:UIControlStateNormal];
    self.interPlaybackView.titleLabel.textColor = [[UIColor alloc] initWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    [self.interPlaybackView addTarget:self action:@selector(interPlaybackViewBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.nvgBar];
    [self.view addSubview:self.daniuServerBtn];
    [self.view addSubview:self.cdnServerBtn];
    [self.view addSubview:self.audioOnlyBtn];

    [self.view addSubview:self.swDecoderBtn];
    [self.view addSubview:self.hwDecoderBtn];
    
    [self.view addSubview:self.udpBtn];
    [self.view addSubview:self.tcpBtn];
    
    [self.view addSubview:self.interPlaybackView];
    [self.view addSubview:self.daniuServerLable];
    [self.view addSubview:self.cdnServerLable];
    [self.view addSubview:self.audioOnlyLable];
    
    [self.view addSubview:self.swDecoderLable];
    [self.view addSubview:self.hwDecoderLable];
    
    [self.view addSubview:self.udpLable];
    [self.view addSubview:self.tcpLable];
    
    [self.view addSubview:self.urlID];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //默认baseURL
    baseURL = @"rtmp://player.daniulive.com:1935/hls/stream";

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Buttons methods
- (void)qualityButtonClicked:(id)sender {
    
    UIButton *functionSelBtn = (UIButton *)sender;

    switch (functionSelBtn.tag) {
        case 1: {
            [self.daniuServerBtn setImage:[UIImage imageNamed:@"btn_selected"] forState:UIControlStateNormal];
            [self.cdnServerBtn setImage:[UIImage imageNamed:@"btn_unselected"] forState:UIControlStateNormal];
            [self.audioOnlyBtn setImage:[UIImage imageNamed:@"btn_unselected"] forState:UIControlStateNormal];
            baseURL = @"rtmp://player.daniulive.com:1935/hls/stream";
            is_audio_only_ = false;
            break;
        }
        case 2: {
            
            [self.cdnServerBtn setImage:[UIImage imageNamed:@"btn_selected"] forState:UIControlStateNormal];
            [self.daniuServerBtn setImage:[UIImage imageNamed:@"btn_unselected"] forState:UIControlStateNormal];
            [self.audioOnlyBtn setImage:[UIImage imageNamed:@"btn_unselected"] forState:UIControlStateNormal];
             baseURL = @"rtmp://play.daniulive.8686c.com/live/stream";
            is_audio_only_ = false;
            break;
        }
        case 3: {
            [self.audioOnlyBtn setImage:[UIImage imageNamed:@"btn_selected"] forState:UIControlStateNormal];
            [self.cdnServerBtn setImage:[UIImage imageNamed:@"btn_unselected"] forState:UIControlStateNormal];
            [self.daniuServerBtn setImage:[UIImage imageNamed:@"btn_unselected"] forState:UIControlStateNormal];
            baseURL = @"rtmp://player.daniulive.com:1935/hls/stream";
            is_audio_only_ = true;
            break;
        }
        default:
            break;
    }
}

- (void)decoderButtonClicked:(id)sender {
    
    UIButton *functionSelBtn = (UIButton *)sender;
    
    switch (functionSelBtn.tag) {
        case 1: {
            [self.swDecoderBtn setImage:[UIImage imageNamed:@"btn_selected"] forState:UIControlStateNormal];
            [self.hwDecoderBtn setImage:[UIImage imageNamed:@"btn_unselected"] forState:UIControlStateNormal];
            
            is_hardware_decoder_ = false;
            break;
        }
        case 2: {
            
            [self.swDecoderBtn setImage:[UIImage imageNamed:@"btn_unselected"] forState:UIControlStateNormal];
            [self.hwDecoderBtn setImage:[UIImage imageNamed:@"btn_selected"] forState:UIControlStateNormal];
            
            is_hardware_decoder_ = true;
            break;
        }
            
        default:
            break;
    }
}

- (void)transModeButtonClicked:(id)sender {
    
    UIButton *functionSelBtn = (UIButton *)sender;
    
    switch (functionSelBtn.tag) {
        case 1: {
            [self.udpBtn setImage:[UIImage imageNamed:@"btn_selected"] forState:UIControlStateNormal];
            [self.tcpBtn setImage:[UIImage imageNamed:@"btn_unselected"] forState:UIControlStateNormal];
            
            is_rtsp_tcp_mode_ = false;
            break;
        }
        case 2: {
            [self.udpBtn setImage:[UIImage imageNamed:@"btn_unselected"] forState:UIControlStateNormal];
            [self.tcpBtn setImage:[UIImage imageNamed:@"btn_selected"] forState:UIControlStateNormal];
  
            is_rtsp_tcp_mode_ = true;
            break;
        }

        default:
            break;
    }
}


#pragma mark - textField method
- (void)textFieldDone:(UITextField *)textField {
    [textField resignFirstResponder];
}

- (void)interPlaybackViewBtnPressed:(id)sender {

    NSString* inputVal = [[self urlID] text];
    if ( inputVal == nil )
    {
        NSLog(@"pass playbackURL input value is nil");
        return;
    }
    
    if ( [inputVal length] < 1 )
    {
        NSLog(@"pass playbackURL input value is empty");
        return;
    }
    
    Boolean is_half_screen = FALSE;
    NSString* playbackURL = [baseURL stringByAppendingString:self.urlID.text];
    
    if ( [inputVal isEqualToString:@"hks" ] )
    {
        is_half_screen = TRUE;
        
        playbackURL = @"rtmp://live.hkstv.hk.lxdns.com/live/hks";
    }
    else if( [inputVal isEqualToString:@"rtsp" ] )
    {
        is_half_screen = TRUE;
        
        //playbackURL = @"rtsp://218.204.223.237:554/live/1/67A7572844E51A64/f68g2mj7wjua3la7";
    
        //playbackURL = @"rtsp://rtsp-v3-spbtv.msk.spbtv.com/spbtv_v3_1/214_110.sdp";
        
    }
    else if( [inputVal isEqualToString:@"audio" ] )
    {
        //playbackURL = @"rtmp://player.daniulive.com:1935/live/audio";
        
        is_audio_only_ = true;
    }
    
    NSLog(@"pass playbackURL:%@", playbackURL);
    
    ViewController * coreView =[[ViewController alloc] initParameter:playbackURL isHalfScreen:is_half_screen
                                                         isAudioOnly:is_audio_only_ isHWDecoder:is_hardware_decoder_ isRTSPTcpMode:is_rtsp_tcp_mode_];
    [self presentViewController:coreView animated:YES completion:nil];
}

@end
