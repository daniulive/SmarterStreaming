//
//  SettingView.m
//  SmartiOSPlayer
//
//  GitHub: https://github.com/daniulive/SmarterStreaming
//  website: http://www.daniulive.com
//
//  Created by daniulive on 2016/01/03.
//  Copyright © 2015~2017 daniulive. All rights reserved.

#import "SettingView.h"
#import "ViewController.h"

#define kBtnHeight     50
#define kHorMargin     10
#define kVerMargin     80

@interface SettingView ()
{
    NSString* playback_url_;
    NSInteger   buffer_time_;
    Boolean is_fast_startup_;
    Boolean is_low_latency_mode_;
    Boolean is_hardware_decoder_;
    Boolean is_rtsp_tcp_mode_;
}

@property (nonatomic, strong) UINavigationBar *nvgBar;

@property (nonatomic, strong) UITextField *inputUrlText; //url输入框，请输入rtmp/rtsp link

@property (nonatomic, strong) UITextField *inputBufferText; //Buffer设置，单位: 毫秒
@property (nonatomic, strong) UILabel *bufferTimeLable; //Buffer设置lable

@property (nonatomic, strong) UISwitch *fastStartupSwitch;  //快速启动
@property (nonatomic, strong) UILabel *fastStartupSwitchLable;

@property (nonatomic, strong) UISwitch *lowLatencyModeSwitch;  //极速延迟模式，特别适用于类似于直播娃娃机方案
@property (nonatomic, strong) UILabel *lowLatencyModeSwitchLable;

@property (nonatomic, strong) UIButton *swDecoderBtn;
@property (nonatomic, strong) UIButton *hwDecoderBtn;

@property (nonatomic, strong) UIButton *udpBtn;
@property (nonatomic, strong) UIButton *tcpBtn;

@property (nonatomic, strong) UILabel *swDecoderLable;
@property (nonatomic, strong) UILabel *hwDecoderLable;

@property (nonatomic, strong) UILabel *udpLable;
@property (nonatomic, strong) UILabel *tcpLable;

@property (nonatomic, strong) UIButton *interPlaybackViewBtn;

@end

@implementation SettingView

@synthesize nvgBar;
@synthesize bufferTimeLable;
@synthesize fastStartupSwitch;
@synthesize fastStartupSwitchLable;
@synthesize interPlaybackViewBtn;

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
    // If you create your views manually, you MUST override this method and use it to create your views.
    // If you use Interface Builder to create your views, then you must NOT override this method.
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    self.view.backgroundColor = [UIColor whiteColor];
    
    is_fast_startup_ = YES;
    
    CGFloat screenWidth  = CGRectGetWidth([UIScreen mainScreen].bounds);
    
    //导航栏:直播设置
    [self.navigationItem setTitle:@"大牛直播播放端V1.0.17.05.03"];
    [self.navigationController.navigationBar setBackgroundColor:[UIColor blackColor]];
    
    
    CGFloat buttonWidth = screenWidth - kHorMargin*2;
    CGFloat buttonSpace = (screenWidth - 2*kHorMargin-160)/6;
    
    //直播地址
    self.inputUrlText = [[UITextField alloc] initWithFrame:CGRectMake(kHorMargin, kVerMargin, buttonWidth, kBtnHeight)];
    [self.inputUrlText setBackgroundColor:[UIColor whiteColor]];
    self.inputUrlText.placeholder = @"请输入完整rtmp/rtsp播放url";
    self.inputUrlText.textColor = [[UIColor alloc] initWithRed:51.0/255 green:51.0/255 blue:51.0/255 alpha:1.0];
    self.inputUrlText.borderStyle = UITextBorderStyleRoundedRect;
    self.inputUrlText.autocorrectionType = UITextAutocorrectionTypeNo;
    self.inputUrlText.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.inputUrlText addTarget:self action:@selector(textFieldDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
    self.inputUrlText.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.inputUrlText setText:[NSString stringWithFormat:@"hks"]];
    //[self.inputUrlText setText:[NSString stringWithFormat:@"rtsp"]];
    
    //Buffer设置
    self.bufferTimeLable = [[UILabel alloc] initWithFrame:CGRectMake(kHorMargin+buttonSpace, kVerMargin+kBtnHeight+20, 130, kBtnHeight)];
    self.bufferTimeLable.text = @"Buffer设置(ms):";
    self.bufferTimeLable.lineBreakMode = NSLineBreakByCharWrapping;
    self.bufferTimeLable.textColor = [[UIColor alloc] initWithRed:51.0/255 green:51.0/255 blue:51.0/255 alpha:1.0];
    
    self.inputBufferText = [[UITextField alloc] initWithFrame:CGRectMake(kHorMargin + buttonSpace + 130, kVerMargin+kBtnHeight+20, buttonWidth-buttonSpace - 130, kBtnHeight)];
    
    [self.inputBufferText setBackgroundColor:[UIColor whiteColor]];
    self.inputBufferText.placeholder = @"请输入buffer时间(单位:毫秒)";
    self.inputBufferText.textColor = [[UIColor alloc] initWithRed:51.0/255 green:51.0/255 blue:51.0/255 alpha:1.0];
    self.inputBufferText.borderStyle = UITextBorderStyleRoundedRect;
    self.inputBufferText.autocorrectionType = UITextAutocorrectionTypeNo;
    self.inputBufferText.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.inputBufferText addTarget:self action:@selector(textFieldDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
    self.inputBufferText.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.inputBufferText setText:[NSString stringWithFormat:@"100"]];
    
    //快速启动开关
    self.fastStartupSwitchLable = [[UILabel alloc] initWithFrame:CGRectMake(kHorMargin+buttonSpace, kVerMargin+kBtnHeight+100, 80, 20)];
    self.fastStartupSwitchLable.text = @"快速启动";
    self.fastStartupSwitchLable.lineBreakMode = NSLineBreakByCharWrapping;
    self.fastStartupSwitchLable.textColor = [[UIColor alloc] initWithRed:51.0/255 green:51.0/255 blue:51.0/255 alpha:1.0];
    
    self.fastStartupSwitch = [[UISwitch alloc]init];
    self.fastStartupSwitch.tag = 1;
    self.fastStartupSwitch.frame = CGRectMake(kHorMargin+buttonSpace+80, kVerMargin+kBtnHeight+95, 50, 20);
    [self.fastStartupSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    self.fastStartupSwitch.on = YES;
    
    //超低延迟模式
    self.lowLatencyModeSwitchLable = [[UILabel alloc] initWithFrame:CGRectMake(kHorMargin+3*buttonSpace+60, kVerMargin+kBtnHeight+100, 80, 20)];
    self.lowLatencyModeSwitchLable.text = @"超低延迟";
    self.lowLatencyModeSwitchLable.lineBreakMode = NSLineBreakByCharWrapping;
    self.lowLatencyModeSwitchLable.textColor = [[UIColor alloc] initWithRed:51.0/255 green:51.0/255 blue:51.0/255 alpha:1.0];
    
    self.lowLatencyModeSwitch = [[UISwitch alloc]init];
    self.lowLatencyModeSwitch.tag = 1;
    self.lowLatencyModeSwitch.frame = CGRectMake(kHorMargin+3*buttonSpace+80+60, kVerMargin+kBtnHeight+95, 50, 20);
    [self.lowLatencyModeSwitch addTarget:self action:@selector(lowLantecySwitchAction:) forControlEvents:UIControlEventValueChanged];
    self.lowLatencyModeSwitch.on = NO;
    
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
    self.interPlaybackViewBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.interPlaybackViewBtn.tag = 4;
    self.interPlaybackViewBtn.frame = CGRectMake(kHorMargin, kVerMargin+kBtnHeight+80+80+80+80+20, buttonWidth, kBtnHeight);
    [self.interPlaybackViewBtn setTitle:@"进入播放页面" forState:UIControlStateNormal];
    [self.interPlaybackViewBtn setBackgroundImage:[UIImage imageNamed:@"start_playback"] forState:UIControlStateNormal];
    self.interPlaybackViewBtn.titleLabel.textColor = [[UIColor alloc] initWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    [self.interPlaybackViewBtn addTarget:self action:@selector(interPlaybackViewBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.nvgBar];
    
    [self.view addSubview:self.inputUrlText];
    [self.view addSubview:self.inputBufferText];
    
    [self.view addSubview:self.bufferTimeLable];
    
    [self.view addSubview:self.fastStartupSwitchLable];
    [self.view addSubview:self.fastStartupSwitch];
    
    [self.view addSubview:self.lowLatencyModeSwitchLable];
    [self.view addSubview:self.lowLatencyModeSwitch];
    
    [self.view addSubview:self.swDecoderBtn];
    [self.view addSubview:self.hwDecoderBtn];
    
    [self.view addSubview:self.udpBtn];
    [self.view addSubview:self.tcpBtn];
    
    [self.view addSubview:self.interPlaybackViewBtn];
    
    [self.view addSubview:self.swDecoderLable];
    [self.view addSubview:self.hwDecoderLable];
    
    [self.view addSubview:self.udpLable];
    [self.view addSubview:self.tcpLable];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
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

-(void)switchAction:(id)sender
{
    UISwitch *switchButton = (UISwitch*)sender;
    BOOL isButtonOn = [switchButton isOn];
    if (isButtonOn) {
        is_fast_startup_ = YES;
    }else {
        is_fast_startup_ = NO;
    }
    
    NSLog(@"is_fast_startup_:%d", is_fast_startup_);
}

-(void)lowLantecySwitchAction:(id)sender
{
    UISwitch *lowLantecySwitchButton = (UISwitch*)sender;
    BOOL isButtonOn = [lowLantecySwitchButton isOn];
    if (isButtonOn) {
        [self.inputBufferText setText:[NSString stringWithFormat:@"0"]];
        is_low_latency_mode_ = YES;
    }else {
        is_low_latency_mode_ = NO;
    }
    
    NSLog(@"is_low_latency_mode_:%d", is_low_latency_mode_);
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
    
    NSString* inputVal = [[self inputUrlText] text];
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
    
    if ( [inputVal isEqualToString:@"hks" ] )
    {
        is_half_screen = TRUE;
        
        playback_url_ = @"rtmp://live.hkstv.hk.lxdns.com/live/hks1";
        
    }
    else if( [inputVal isEqualToString:@"rtsp" ] )
    {
        is_half_screen = TRUE;
        
        // playback_url_ = @"rtsp://184.72.239.149/vod/mp4://BigBuckBunny_175k.mov";
        
        //playback_url_ = @"rtsp://rtsp-v3-spbtv.msk.spbtv.com/spbtv_v3_1/214_110.sdp";
    }
    else
    {
        playback_url_ = self.inputUrlText.text;
    }
    
    buffer_time_ = [self.inputBufferText.text intValue];
    
    NSLog(@"playbackURL:%@, buffer time:%ld, isFastStartup:%d", playback_url_, (long)buffer_time_, is_fast_startup_);
    
    ViewController * coreView =[[ViewController alloc] initParameter:playback_url_
                                                        isHalfScreen:is_half_screen
                                                          bufferTime:buffer_time_
                                                          isFastStartup:is_fast_startup_
                                                          isLowLantecy:is_low_latency_mode_
                                                          isHWDecoder:is_hardware_decoder_
                                                          isRTSPTcpMode:is_rtsp_tcp_mode_];
    [self presentViewController:coreView animated:YES completion:nil];
}

@end
