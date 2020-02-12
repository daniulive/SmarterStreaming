//
//  SettingView.m
//  SmartPublisherSDK
//
//  GitHub: https://github.com/daniulive/SmarterStreaming
//  website: https://www.daniulive.com
//
//  Created by daniulive on 16/3/24.
//  Copyright © 2014~2020 daniulive. All rights reserved.
//

#import "SettingView.h"
#import "ViewController.h"
#import "RecorderView.h"
#import "DropdownListView.h"

#define kBtnHeight     50
#define kHorMargin     10
#define kVerMargin     80


@interface SettingView ()
{
    DNVideoStreamingQuality streamQuality;
    NSInteger               audio_opt_;
    NSInteger               video_opt_;
    Boolean                 is_beauty_;
    NSString        *encrypt_key_;              //RTMP加密Key
    NSString        *encrypt_iv_;               //RTMP IV加密向量
    
    //设置编码前视频宽高比例缩放(用于屏幕或摄像头采集缩放)
    //为适配屏幕宽高比, 比如需要推送640*360分辨率, 可设置1280*720的采集, scale rate设置0.5 来实现等比例缩放
    CGFloat         video_scale_rate_;
}

@property (nonatomic, strong) UINavigationBar *nvgBar;
@property (nonatomic, strong) UINavigationItem *nvgItem;

@property (nonatomic, strong) UITextField *inputUrlText; //url输入框，请输入rtmp推送url

//如需音视频加密，可设置加密的Key(16/24/32字节)和IV(16字节)，IV如不输入，用默认值，播放端，需要输入推送端设置的加密Key和IV方可正常播放
@property (nonatomic, strong) UIButton *inputKeyIvView;
@property (nonatomic, strong) UIButton *interPublisherView;
@property (nonatomic, strong) UIButton *interRecorderView;

- (void)interPublisherViewBtnPressed:(id)sender;

@end

@implementation SettingView

@synthesize nvgBar;
@synthesize nvgItem;
@synthesize inputKeyIvView;
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
    streamQuality = DN_VIDEO_QUALITY_HIGH;
    video_scale_rate_ = 0.5;
    
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
    
    //直播视频质量
    DropdownListItem *resSelItem1 = [[DropdownListItem alloc] initWithItem:@"0" itemName:@"流畅(352*288)"];
    DropdownListItem *resSelItem2 = [[DropdownListItem alloc] initWithItem:@"1" itemName:@"标清(640*480)"];
    DropdownListItem *resSelItem3 = [[DropdownListItem alloc] initWithItem:@"2" itemName:@"标清(640*368)"];
    DropdownListItem *resSelItem4 = [[DropdownListItem alloc] initWithItem:@"3" itemName:@"标清(960*544)"];
    DropdownListItem *resSelItem5 = [[DropdownListItem alloc] initWithItem:@"4" itemName:@"高清(1280*720)"];
    DropdownListItem *resSelItem6 = [[DropdownListItem alloc] initWithItem:@"5" itemName:@"超高清(1920*1080)"];
    
    // 弹出框向上
    DropdownListView *resSelDropdownListView = [[DropdownListView alloc] initWithDataSource:@[resSelItem1, resSelItem2, resSelItem3, resSelItem4, resSelItem5, resSelItem6]];
    resSelDropdownListView.frame = CGRectMake(kHorMargin, 100, 180, 30);
    resSelDropdownListView.selectedIndex = 2;
    [resSelDropdownListView setViewBorder:0.5 borderColor:[UIColor grayColor] cornerRadius:2];
    [self.view addSubview:resSelDropdownListView];
    
    [resSelDropdownListView setDropdownListViewSelectedBlock:^(DropdownListView *resSelDropdownListView) {
        NSString *msgString = [NSString stringWithFormat:
                               @"resolution selected name:%@  id:%@  index:%lu"
                               , resSelDropdownListView.selectedItem.itemName
                               , resSelDropdownListView.selectedItem.itemId
                               , (unsigned long)resSelDropdownListView.selectedIndex];
        
        NSLog(@"%@", msgString);
        
        switch (resSelDropdownListView.selectedIndex) {
            case 0:
                //流畅(352*288)
                streamQuality = DN_VIDEO_QUALITY_LOW;
                video_scale_rate_ = 1.0;
                break;
            case 1:
                //标清(640*480)
                streamQuality = DN_VIDEO_QUALITY_MEDIUM;
                video_scale_rate_ = 1.0;
                break;
            case 2:
                //标清(640*368), 1280*720采集分辨率 宽高缩放系数为0.5后得到
                streamQuality = DN_VIDEO_QUALITY_HIGH;
                video_scale_rate_ = 0.5;
                break;
            case 3:
                //标清(960*544), 1280*720采集分辨率 宽高缩放系数为0.75后得到
                streamQuality = DN_VIDEO_QUALITY_HIGH;
                video_scale_rate_ = 0.75;
                break;
            case 4:
                //高清(1280*720)
                streamQuality = DN_VIDEO_QUALITY_HIGH;
                video_scale_rate_ = 1.0;
                break;
            case 5:
                //超高清(1920*1080)
                streamQuality = DN_VIDEO_QUALITY_1080P;
                video_scale_rate_ = 1.0;
                break;
            default:
                break;
        }
    }];
     
    //推送音视频还是纯音频
    DropdownListItem *avSelItem1 = [[DropdownListItem alloc] initWithItem:@"0" itemName:@"推送音视频"];
    DropdownListItem *avSelItem2 = [[DropdownListItem alloc] initWithItem:@"1" itemName:@"推送纯音频"];
    DropdownListItem *avSelItem3 = [[DropdownListItem alloc] initWithItem:@"2" itemName:@"推送纯视频"];
    
    // 弹出框向上
    DropdownListView *avSelDropdownListView = [[DropdownListView alloc] initWithDataSource:@[avSelItem1, avSelItem2, avSelItem3]];
    avSelDropdownListView.frame = CGRectMake(kHorMargin, 150, 180, 30);
    avSelDropdownListView.selectedIndex = 0;
    [avSelDropdownListView setViewBorder:0.5 borderColor:[UIColor grayColor] cornerRadius:2];
    [self.view addSubview:avSelDropdownListView];
    
    [avSelDropdownListView setDropdownListViewSelectedBlock:^(DropdownListView *avSelDropdownListView) {
        NSString *msgString = [NSString stringWithFormat:
                               @"av pusher type selected name:%@  id:%@  index:%lu"
                               , avSelDropdownListView.selectedItem.itemName
                               , avSelDropdownListView.selectedItem.itemId
                               , (unsigned long)avSelDropdownListView.selectedIndex];
        
        //msgLabel.text = msgString;
        NSLog(@"%@", msgString);
        
        switch (avSelDropdownListView.selectedIndex) {
            case 0:
                //推送音视频
                audio_opt_ = 1;
                video_opt_ = 1;
                break;
            case 1:
                //推送纯音频
                audio_opt_ = 1;
                video_opt_ = 0;
                break;
            case 2:
                //推送纯视频
                audio_opt_ = 0;
                video_opt_ = 1;
                break;
            default:
                break;
        }
    }];
    
    //是否美颜
    DropdownListItem *beautySelItem1 = [[DropdownListItem alloc] initWithItem:@"0" itemName:@"当前不美颜"];
    DropdownListItem *beautySelItem2 = [[DropdownListItem alloc] initWithItem:@"1" itemName:@"基础美颜"];
    
    // 弹出框向上
    DropdownListView *beautySelDropdownListView = [[DropdownListView alloc] initWithDataSource:@[beautySelItem1, beautySelItem2]];
    beautySelDropdownListView.frame = CGRectMake(kHorMargin, 200, 180, 30);
    beautySelDropdownListView.selectedIndex = 0;
    [beautySelDropdownListView setViewBorder:0.5 borderColor:[UIColor grayColor] cornerRadius:2];
    [self.view addSubview:beautySelDropdownListView];
    
    [beautySelDropdownListView setDropdownListViewSelectedBlock:^(DropdownListView *beautySelDropdownListView) {
        NSString *msgString = [NSString stringWithFormat:
                               @"beauty mode selected name:%@  id:%@  index:%lu"
                               , beautySelDropdownListView.selectedItem.itemName
                               , beautySelDropdownListView.selectedItem.itemId
                               , (unsigned long)beautySelDropdownListView.selectedIndex];
        
        NSLog(@"%@", msgString);
        
        switch (beautySelDropdownListView.selectedIndex) {
            case 0:
                //推送音视频
                is_beauty_ = false;
                break;
            case 1:
                //基础美颜
                is_beauty_ = true;
                break;
            default:
                break;
        }
    }];
    
    //设置推流地址
    self.inputUrlText = [[UITextField alloc] initWithFrame:CGRectMake(kHorMargin, 250, buttonWidth, kBtnHeight)];
    [self.inputUrlText setBackgroundColor:[UIColor whiteColor]];
    self.inputUrlText.placeholder = @"输入推流的rtmp url,如不输入用默认url";
    self.inputUrlText.textColor = [[UIColor alloc] initWithRed:51.0/255 green:51.0/255 blue:51.0/255 alpha:1.0];
    self.inputUrlText.borderStyle = UITextBorderStyleRoundedRect;
    self.inputUrlText.autocorrectionType = UITextAutocorrectionTypeNo;
    self.inputUrlText.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.inputUrlText addTarget:self action:@selector(textFieldDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
    self.inputUrlText.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    //[self.inputUrlText setText:[NSString stringWithFormat:@"rtmp://player.daniulive.com:1935/hls/stream0"]];
    
    //设置RTMP加密Key和IV加密向量
    self.inputKeyIvView = [UIButton buttonWithType:UIButtonTypeCustom];
    self.inputKeyIvView.tag = 3;
    self.inputKeyIvView.frame = CGRectMake(kHorMargin, 330, buttonWidth, kBtnHeight);
    [self.inputKeyIvView setTitle:@"设置RTMP加密Key和IV" forState:UIControlStateNormal];
    [self.inputKeyIvView setBackgroundImage:[UIImage imageNamed:@"back_color"] forState:UIControlStateNormal];
    self.inputKeyIvView.titleLabel.textColor = [[UIColor alloc] initWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    [self.inputKeyIvView addTarget:self action:@selector(inputKeyIVViewBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    //进入推流页面
    self.interPublisherView = [UIButton buttonWithType:UIButtonTypeCustom];
    self.interPublisherView.tag = 4;
    self.interPublisherView.frame = CGRectMake(kHorMargin, 410, buttonWidth, kBtnHeight);
    [self.interPublisherView setTitle:@"进入推流|录像页面" forState:UIControlStateNormal];
    [self.interPublisherView setBackgroundImage:[UIImage imageNamed:@"back_color"] forState:UIControlStateNormal];
    self.interPublisherView.titleLabel.textColor = [[UIColor alloc] initWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    [self.interPublisherView addTarget:self action:@selector(interPublisherViewBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    //进入本地录像回放页面
    self.interRecorderView = [UIButton buttonWithType:UIButtonTypeCustom];
    self.interRecorderView.tag = 5;
    self.interRecorderView.frame = CGRectMake(kHorMargin, 490, buttonWidth, kBtnHeight);
    [self.interRecorderView setTitle:@"进入录制MP4回放页面" forState:UIControlStateNormal];
    [self.interRecorderView setBackgroundImage:[UIImage imageNamed:@"back_color"] forState:UIControlStateNormal];
    self.interRecorderView.titleLabel.textColor = [[UIColor alloc] initWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    [self.interRecorderView addTarget:self action:@selector(interRecorderViewBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.nvgBar];
    
    [self.view addSubview:self.inputUrlText];

    [self.view addSubview:self.inputKeyIvView];
    [self.view addSubview:self.interPublisherView];
    [self.view addSubview:self.interRecorderView];
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

- (void)textFieldDone:(UITextField *)textField {
    [textField resignFirstResponder];
}

- (void)inputKeyIVViewBtnPressed:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"如RTMP加密流，请输入加密Key和IV" preferredStyle:UIAlertControllerStyleAlert];

    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        UITextField *keyTextField = alertController.textFields.firstObject;
        encrypt_key_ = keyTextField.text;
        
        UITextField *ivTextField = alertController.textFields.lastObject;
        encrypt_iv_ = ivTextField.text;
        
        NSLog(@"key: %@，iv: %@",encrypt_key_, encrypt_iv_);
        
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil]];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入RTMP加密Key(16/24/32字节)";
    }];

    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入RTMP IV加密向量(可选，如不输入用默认值)";
    }];
    
    [self presentViewController:alertController animated:true completion:nil];
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
                                                       streamQuality:streamQuality audioOpt:audio_opt_ videoOpt:video_opt_ isBeauty:is_beauty_ scale_rate:video_scale_rate_];
    
    [coreView setRTMPKeyIV:encrypt_key_ iv:encrypt_iv_];
    
    [self presentViewController:coreView animated:YES completion:nil];
}

- (void)interRecorderViewBtnPressed:(id)sender {
    RecorderView * recorderView =[[RecorderView alloc] init];
    [self presentViewController:recorderView animated:YES completion:nil];
}

@end
