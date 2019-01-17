//
//  SettingView.m
//  SmartPublisherSDK
//
//  GitHub: https://github.com/daniulive/SmarterStreaming
//  website: https://www.daniulive.com
//
//  Created by daniulive on 16/3/24.
//  Copyright © 2014~2019 daniulive. All rights reserved.
//

#import "SettingView.h"
#import "ViewController.h"
#import "RecorderView.h"


#define kBtnHeight     50
#define kHorMargin     10
#define kVerMargin     80


@interface SettingView ()
{
    DNVideoStreamingQuality streamQuality;
    NSInteger               audio_opt_;
    NSInteger               video_opt_;
    Boolean                 is_beauty_;
}

@property (nonatomic, strong) UINavigationBar *nvgBar;
@property (nonatomic, strong) UINavigationItem *nvgItem;

@property (nonatomic, strong) UITextField *inputUrlText; //url输入框，请输入rtmp推送url

@property (nonatomic, strong) UIButton *highQualityBtn;
@property (nonatomic, strong) UIButton *mediumQualityBtn;
@property (nonatomic, strong) UIButton *lowQualityBtn;

@property (nonatomic, strong) UIButton *avBtn;
@property (nonatomic, strong) UIButton *audioBtn;
@property (nonatomic, strong) UIButton *videoBtn;

@property (nonatomic, strong) UIButton *beautyBtn;
@property (nonatomic, strong) UIButton *noBeautyBtn;

@property (nonatomic, strong) UIButton *interPublisherView;
@property (nonatomic, strong) UIButton *interRecorderView;

@property (nonatomic, strong) UILabel *highQualityLable;
@property (nonatomic, strong) UILabel *mediumQualityLable;
@property (nonatomic, strong) UILabel *lowQualityLable;

@property (nonatomic, strong) UILabel *avLable;
@property (nonatomic, strong) UILabel *audioLable;
@property (nonatomic, strong) UILabel *videoLable;

@property (nonatomic, strong) UILabel *beautyLable;
@property (nonatomic, strong) UILabel *noBeautyLable;

- (void)qualityButtonClicked:(id)sender;
- (void)interPublisherViewBtnPressed:(id)sender;

@end

@implementation SettingView

@synthesize nvgBar;
@synthesize nvgItem;
@synthesize lowQualityBtn;
@synthesize mediumQualityBtn;
@synthesize highQualityBtn;
@synthesize avBtn;
@synthesize audioBtn;
@synthesize videoBtn;
@synthesize beautyBtn;
@synthesize noBeautyBtn;
@synthesize lowQualityLable;
@synthesize mediumQualityLable;
@synthesize highQualityLable;
@synthesize avLable;
@synthesize audioLable;
@synthesize videoLable;
@synthesize beautyLable;
@synthesize noBeautyLable;
@synthesize interPublisherView;
@synthesize interRecorderView;


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
    
    //默认标清分辨率
    streamQuality = DN_VIDEO_QUALITY_MEDIUM;
    //默认采集音视频
    audio_opt_ = 1;
    video_opt_ = 1;
    //默认不美颜
    is_beauty_ = false;
    
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    self.view.backgroundColor = [UIColor whiteColor];
    
    //当前屏幕宽高
    CGFloat screenWidth  = CGRectGetWidth([UIScreen mainScreen].bounds);
    
    //导航栏:直播设置
    
    [self.navigationItem setTitle:@"Daniulive RTMP/RTSP推送SDK"];
    
    [self.navigationController.navigationBar setBackgroundColor:[UIColor blackColor]];

    CGFloat buttonWidth = screenWidth - kHorMargin*2;
    
    CGFloat buttonSpace = (screenWidth - 2*kHorMargin-160)/6;
    
    //直播视频质量
    self.lowQualityBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.lowQualityBtn.tag = 1;
    self.lowQualityBtn.frame = CGRectMake(kHorMargin+buttonSpace, kVerMargin+kBtnHeight, 20, 20);
    [self.lowQualityBtn setImage:[UIImage imageNamed:@"btn_unselected"] forState:UIControlStateNormal];
    [self.lowQualityBtn addTarget:self action:@selector(qualityButtonClicked:) forControlEvents:UIControlEventTouchDown];
    
    self.lowQualityLable = [[UILabel alloc] initWithFrame:CGRectMake(kHorMargin+buttonSpace+20, kVerMargin+kBtnHeight, 60, 20)];
    self.lowQualityLable.text = @"流畅";
    self.lowQualityLable.textColor = [[UIColor alloc] initWithRed:51.0/255 green:51.0/255 blue:51.0/255 alpha:1.0];
   
    self.mediumQualityBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.mediumQualityBtn.tag = 2;

    self.mediumQualityBtn.frame = CGRectMake(kHorMargin+3*buttonSpace+60, kVerMargin+kBtnHeight, 20, 20);
    [self.mediumQualityBtn setImage:[UIImage imageNamed:@"btn_selected"] forState:UIControlStateNormal];
    [self.mediumQualityBtn addTarget:self action:@selector(qualityButtonClicked:) forControlEvents:UIControlEventTouchDown];
    self.mediumQualityLable = [[UILabel alloc] initWithFrame:CGRectMake(kHorMargin+3*buttonSpace+80, kVerMargin+kBtnHeight, 40, 20)];
    self.mediumQualityLable.text = @"标清";
    self.mediumQualityLable.textColor = [[UIColor alloc] initWithRed:51.0/255 green:51.0/255 blue:51.0/255 alpha:1.0];
    
    self.highQualityBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.highQualityBtn.tag = 3;
    
    self.highQualityBtn.frame = CGRectMake(screenWidth-kHorMargin-buttonSpace-60,kVerMargin+kBtnHeight,20,20);
    [self.highQualityBtn setImage:[UIImage imageNamed:@"btn_unselected"] forState:UIControlStateNormal];
    [self.highQualityBtn addTarget:self action:@selector(qualityButtonClicked:) forControlEvents:UIControlEventTouchDown];
    self.highQualityLable = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth-kHorMargin-buttonSpace-40,kVerMargin+kBtnHeight,40,20)];
    self.highQualityLable.text = @"高清";
    self.highQualityLable.textColor = [[UIColor alloc] initWithRed:51.0/255 green:51.0/255 blue:51.0/255 alpha:1.0];
    
    //推送音视频还是纯音频
    self.avBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.avBtn.tag = 1;
    self.avBtn.frame = CGRectMake(kHorMargin+buttonSpace, kVerMargin+kBtnHeight+80, 20, 20);
    [self.avBtn setImage:[UIImage imageNamed:@"btn_selected"] forState:UIControlStateNormal];
    [self.avBtn addTarget:self action:@selector(pushTypeButtonClicked:) forControlEvents:UIControlEventTouchDown];
    
    self.avLable = [[UILabel alloc] initWithFrame:CGRectMake(kHorMargin+buttonSpace+20, kVerMargin+kBtnHeight+80, 60, 20)];
    self.avLable.text = @"音视频";
    self.avLable.textColor = [[UIColor alloc] initWithRed:51.0/255 green:51.0/255 blue:51.0/255 alpha:1.0];
    
    self.audioBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.audioBtn.tag = 2;
    
    self.audioBtn.frame = CGRectMake(kHorMargin+3*buttonSpace+60, kVerMargin+kBtnHeight+80, 20, 20);
    [self.audioBtn setImage:[UIImage imageNamed:@"btn_unselected"] forState:UIControlStateNormal];
    [self.audioBtn addTarget:self action:@selector(pushTypeButtonClicked:) forControlEvents:UIControlEventTouchDown];
    self.audioLable = [[UILabel alloc] initWithFrame:CGRectMake(kHorMargin+3*buttonSpace+80, kVerMargin+kBtnHeight+80, 60, 20)];
    self.audioLable.text = @"纯音频";
    self.audioLable.textColor = [[UIColor alloc] initWithRed:51.0/255 green:51.0/255 blue:51.0/255 alpha:1.0];
    
    self.videoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.videoBtn.tag = 3;
    
    self.videoBtn.frame = CGRectMake(screenWidth-kHorMargin-buttonSpace-60, kVerMargin+kBtnHeight+80, 20, 20);
    [self.videoBtn setImage:[UIImage imageNamed:@"btn_unselected"] forState:UIControlStateNormal];
    [self.videoBtn addTarget:self action:@selector(pushTypeButtonClicked:) forControlEvents:UIControlEventTouchDown];
    self.videoLable = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth-kHorMargin-buttonSpace-40, kVerMargin+kBtnHeight+80, 60, 20)];
    self.videoLable.text = @"纯视频";
    self.videoLable.textColor = [[UIColor alloc] initWithRed:51.0/255 green:51.0/255 blue:51.0/255 alpha:1.0];

    //是否美颜
    self.beautyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.beautyBtn.tag = 1;
    self.beautyBtn.frame = CGRectMake(kHorMargin+buttonSpace, kVerMargin+kBtnHeight+80+80, 20, 20);
    [self.beautyBtn setImage:[UIImage imageNamed:@"btn_unselected"] forState:UIControlStateNormal];
    [self.beautyBtn addTarget:self action:@selector(beautyButtonClicked:) forControlEvents:UIControlEventTouchDown];
    
    self.beautyLable = [[UILabel alloc] initWithFrame:CGRectMake(kHorMargin+buttonSpace+20, kVerMargin+kBtnHeight+80+80, 60, 20)];
    self.beautyLable.text = @"美颜";
    self.beautyLable.textColor = [[UIColor alloc] initWithRed:51.0/255 green:51.0/255 blue:51.0/255 alpha:1.0];
    
    
    self.noBeautyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.noBeautyBtn.tag = 2;
    self.noBeautyBtn.frame = CGRectMake(kHorMargin+3*buttonSpace+60, kVerMargin+kBtnHeight+80+80, 20, 20);
    [self.noBeautyBtn setImage:[UIImage imageNamed:@"btn_selected"] forState:UIControlStateNormal];
    [self.noBeautyBtn addTarget:self action:@selector(beautyButtonClicked:) forControlEvents:UIControlEventTouchDown];
    self.noBeautyLable = [[UILabel alloc] initWithFrame:CGRectMake(kHorMargin+3*buttonSpace+80, kVerMargin+kBtnHeight+80+80, 80, 20)];
    self.noBeautyLable.text = @"不美颜";
    self.noBeautyLable.textColor = [[UIColor alloc] initWithRed:51.0/255 green:51.0/255 blue:51.0/255 alpha:1.0];
    
    //设置推流地址
    self.inputUrlText = [[UITextField alloc] initWithFrame:CGRectMake(kHorMargin, kVerMargin+kBtnHeight+80+80+60, buttonWidth, kBtnHeight)];
    [self.inputUrlText setBackgroundColor:[UIColor whiteColor]];
    self.inputUrlText.placeholder = @"输入推流的rtmp url,如不输入用默认url";
    self.inputUrlText.textColor = [[UIColor alloc] initWithRed:51.0/255 green:51.0/255 blue:51.0/255 alpha:1.0];
    self.inputUrlText.borderStyle = UITextBorderStyleRoundedRect;
    self.inputUrlText.autocorrectionType = UITextAutocorrectionTypeNo;
    self.inputUrlText.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.inputUrlText addTarget:self action:@selector(textFieldDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
    self.inputUrlText.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    //[self.inputUrlText setText:[NSString stringWithFormat:@"rtmp://player.daniulive.com:1935/hls/stream0"]];
    
    //进入推流页面
    self.interPublisherView = [UIButton buttonWithType:UIButtonTypeCustom];
    self.interPublisherView.tag = 3;
    self.interPublisherView.frame = CGRectMake(kHorMargin, kVerMargin+kBtnHeight+80+80+80+60, buttonWidth, kBtnHeight);
    [self.interPublisherView setTitle:@"进入推流页面" forState:UIControlStateNormal];
    [self.interPublisherView setBackgroundImage:[UIImage imageNamed:@"back_color"] forState:UIControlStateNormal];
    self.interPublisherView.titleLabel.textColor = [[UIColor alloc] initWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    [self.interPublisherView addTarget:self action:@selector(interPublisherViewBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    //进入回放页面
    self.interRecorderView = [UIButton buttonWithType:UIButtonTypeCustom];
    self.interRecorderView.tag = 4;
    self.interRecorderView.frame = CGRectMake(kHorMargin, kVerMargin+kBtnHeight+80+80+80+80+60, buttonWidth, kBtnHeight);
    [self.interRecorderView setTitle:@"进入回放页面" forState:UIControlStateNormal];
    [self.interRecorderView setBackgroundImage:[UIImage imageNamed:@"back_color"] forState:UIControlStateNormal];
    self.interRecorderView.titleLabel.textColor = [[UIColor alloc] initWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    [self.interRecorderView addTarget:self action:@selector(interRecorderViewBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.nvgBar];
    
    [self.view addSubview:self.inputUrlText];
    
    [self.view addSubview:self.highQualityBtn];
    [self.view addSubview:self.mediumQualityBtn];
    [self.view addSubview:self.lowQualityBtn];
    
    [self.view addSubview:self.avBtn];
    [self.view addSubview:self.audioBtn];
    [self.view addSubview:self.videoBtn];

    [self.view addSubview:self.beautyBtn];
    [self.view addSubview:self.noBeautyBtn];
    
    [self.view addSubview:self.interPublisherView];
    [self.view addSubview:self.interRecorderView];
    [self.view addSubview:self.highQualityLable];
    [self.view addSubview:self.mediumQualityLable];
    [self.view addSubview:self.lowQualityLable];
    
    [self.view addSubview:self.avLable];
    [self.view addSubview:self.audioLable];
    [self.view addSubview:self.videoLable];
    
    [self.view addSubview:self.beautyLable];
    [self.view addSubview:self.noBeautyLable];
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
- (void)qualityButtonClicked:(id)sender {
    
    UIButton *qualityBtn = (UIButton *)sender;

    switch (qualityBtn.tag) {
        case 1: {
            streamQuality = DN_VIDEO_QUALITY_LOW;
            [self.mediumQualityBtn setImage:[UIImage imageNamed:@"btn_unselected"] forState:UIControlStateNormal];
            [self.highQualityBtn setImage:[UIImage imageNamed:@"btn_unselected"] forState:UIControlStateNormal];
            [self.lowQualityBtn setImage:[UIImage imageNamed:@"btn_selected"] forState:UIControlStateNormal];
            break;
        }
        case 2: {
            streamQuality = DN_VIDEO_QUALITY_MEDIUM;
            [self.mediumQualityBtn setImage:[UIImage imageNamed:@"btn_selected"] forState:UIControlStateNormal];
            [self.highQualityBtn setImage:[UIImage imageNamed:@"btn_unselected"] forState:UIControlStateNormal];
            [self.lowQualityBtn setImage:[UIImage imageNamed:@"btn_unselected"] forState:UIControlStateNormal];
            break;
        }
        case 3: {
            streamQuality = DN_VIDEO_QUALITY_HIGH;
            [self.mediumQualityBtn setImage:[UIImage imageNamed:@"btn_unselected"] forState:UIControlStateNormal];
            [self.highQualityBtn setImage:[UIImage imageNamed:@"btn_selected"] forState:UIControlStateNormal];
            [self.lowQualityBtn setImage:[UIImage imageNamed:@"btn_unselected"] forState:UIControlStateNormal];
            break;
        }
        default:
            break;
    }
}

- (void)pushTypeButtonClicked:(id)sender {
    
    UIButton *pushTypeBtn = (UIButton *)sender;
    
    switch (pushTypeBtn.tag) {
        case 1: {
            [self.avBtn setImage:[UIImage imageNamed:@"btn_selected"] forState:UIControlStateNormal];
            [self.audioBtn setImage:[UIImage imageNamed:@"btn_unselected"] forState:UIControlStateNormal];
            [self.videoBtn setImage:[UIImage imageNamed:@"btn_unselected"] forState:UIControlStateNormal];
            audio_opt_ = 1;
            video_opt_ = 1;
            break;
        }
        case 2: {
            [self.avBtn setImage:[UIImage imageNamed:@"btn_unselected"] forState:UIControlStateNormal];
            [self.audioBtn setImage:[UIImage imageNamed:@"btn_selected"] forState:UIControlStateNormal];
            [self.videoBtn setImage:[UIImage imageNamed:@"btn_unselected"] forState:UIControlStateNormal];
            audio_opt_ = 1;
            video_opt_ = 0;
            break;
        }
        case 3: {
            [self.avBtn setImage:[UIImage imageNamed:@"btn_unselected"] forState:UIControlStateNormal];
            [self.audioBtn setImage:[UIImage imageNamed:@"btn_unselected"] forState:UIControlStateNormal];
            [self.videoBtn setImage:[UIImage imageNamed:@"btn_selected"] forState:UIControlStateNormal];
            audio_opt_ = 0;
            video_opt_ = 1;
            break;
        }
        default:
            break;
    }
}

- (void)beautyButtonClicked:(id)sender {
    
    UIButton *beautyTypeBtn = (UIButton *)sender;
    
    switch (beautyTypeBtn.tag) {
        case 1: {
            [self.beautyBtn setImage:[UIImage imageNamed:@"btn_selected"] forState:UIControlStateNormal];
            [self.noBeautyBtn setImage:[UIImage imageNamed:@"btn_unselected"] forState:UIControlStateNormal];
            is_beauty_ = true;
            break;
        }
        case 2: {
            [self.beautyBtn setImage:[UIImage imageNamed:@"btn_unselected"] forState:UIControlStateNormal];
            [self.noBeautyBtn setImage:[UIImage imageNamed:@"btn_selected"] forState:UIControlStateNormal];
            is_beauty_ = false;
            break;
        }
        default:
            break;
    }
}

- (void)textFieldDone:(UITextField *)textField {
    [textField resignFirstResponder];
}

- (void)interPublisherViewBtnPressed:(id)sender {
    
    NSString* push_url;     //考虑到好多开发者没有自建rtsp服务器 rtsp url可在ViewController单独设置
    
    NSString* inputVal = [[self inputUrlText] text];
    
    if ( inputVal.length < 7 || ([inputVal hasPrefix:@"rtmp://"] == NO))
    {
        NSLog(@"incorrect rtmp publish url, use default url..");
        
        NSInteger randNumber = arc4random()%(1000000);
        
        NSString *strNumber = [NSString stringWithFormat:@"%ld", (long)randNumber];
        
        NSString *baseURL = @"rtmp://player.daniulive.com:1935/hls/stream";
        
        push_url = [ baseURL stringByAppendingString:strNumber];

    }
    else
    {
        push_url = inputVal;
    }
    
    NSLog(@"publishURL:%@", push_url);
   
    ViewController * coreView =[[ViewController alloc] initParameter:push_url
                                                       streamQuality:streamQuality audioOpt:audio_opt_ videoOpt:video_opt_ isBeauty:is_beauty_];
    [self presentViewController:coreView animated:YES completion:nil];
}

- (void)interRecorderViewBtnPressed:(id)sender {
    RecorderView * recorderView =[[RecorderView alloc] init];
    [self presentViewController:recorderView animated:YES completion:nil];
}

@end
