//
//  SettingView.m
//  SmartPublisherSDK
//
//  GitHub: https://github.com/daniulive/SmarterStreaming
//
//  Created by daniulive on 16/3/24.
//  Copyright © 2016年 daniulive. All rights reserved.
//

#import "SettingView.h"
#import "ViewController.h"


#define kBtnHeight     50
#define kHorMargin     10
#define kVerMargin     80


@interface SettingView ()
{
    DNVideoStreamingQuality streamQuality;
}

@property (nonatomic, strong) UINavigationBar *nvgBar;

@property (nonatomic, strong) UIButton *highQualityBtn;
@property (nonatomic, strong) UIButton *mediumQualityBtn;
@property (nonatomic, strong) UIButton *lowQualityBtn;

@property (nonatomic, strong) UIButton *interPublisherView;

@property (nonatomic,strong) UILabel *highQualityLable;
@property (nonatomic,strong) UILabel *mediumQualityLable;
@property (nonatomic,strong) UILabel *lowQualityLable;

- (void)qualityButtonClicked:(id)sender;
- (void)interPublisherViewBtnPressed:(id)sender;

@end

@implementation SettingView

@synthesize nvgBar;
@synthesize highQualityBtn;
@synthesize mediumQualityBtn;
@synthesize lowQualityBtn;
@synthesize highQualityLable;
@synthesize mediumQualityLable;
@synthesize lowQualityLable;
@synthesize interPublisherView;


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
    
    //当前屏幕宽高
    CGFloat screenWidth  = CGRectGetWidth([UIScreen mainScreen].bounds);
    
    //导航栏:直播设置
    
    [self.navigationItem setTitle:@"大牛直播推流端V1.0.06.05.21"];
    
    [self.navigationController.navigationBar setBackgroundColor:[UIColor blackColor]];
    

    CGFloat buttonWidth = screenWidth - kHorMargin*2;
    
    CGFloat buttonSpace = (screenWidth - 2*kHorMargin-160)/6;
    //直播视频质量
    self.lowQualityBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.lowQualityBtn.tag = 1;
    self.lowQualityBtn.frame = CGRectMake(kHorMargin+buttonSpace, kVerMargin+kBtnHeight+80, 20, 20);
    [self.lowQualityBtn setImage:[UIImage imageNamed:@"btn_unselected"] forState:UIControlStateNormal];
    [self.lowQualityBtn addTarget:self action:@selector(qualityButtonClicked:) forControlEvents:UIControlEventTouchDown];
    
    self.lowQualityLable = [[UILabel alloc] initWithFrame:CGRectMake(kHorMargin+buttonSpace+20, kVerMargin+kBtnHeight+80, 40, 20)];
    self.lowQualityLable.text = @"流畅";
    self.lowQualityLable.textColor = [[UIColor alloc] initWithRed:51.0/255 green:51.0/255 blue:51.0/255 alpha:1.0];
   
    self.mediumQualityBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.mediumQualityBtn.tag = 2;

    self.mediumQualityBtn.frame = CGRectMake(kHorMargin+3*buttonSpace+60, kVerMargin+kBtnHeight+80, 20, 20);
    [self.mediumQualityBtn setImage:[UIImage imageNamed:@"btn_selected"] forState:UIControlStateNormal];
    [self.mediumQualityBtn addTarget:self action:@selector(qualityButtonClicked:) forControlEvents:UIControlEventTouchDown];
    self.mediumQualityLable = [[UILabel alloc] initWithFrame:CGRectMake(kHorMargin+3*buttonSpace+80, kVerMargin+kBtnHeight+80, 40, 20)];
    self.mediumQualityLable.text = @"标清";
    self.mediumQualityLable.textColor = [[UIColor alloc] initWithRed:51.0/255 green:51.0/255 blue:51.0/255 alpha:1.0];
    

    self.highQualityBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.highQualityBtn.tag = 3;
    
    self.highQualityBtn.frame = CGRectMake(screenWidth-kHorMargin-buttonSpace-60,kVerMargin+kBtnHeight+80,20,20);
    [self.highQualityBtn setImage:[UIImage imageNamed:@"btn_unselected"] forState:UIControlStateNormal];
    [self.highQualityBtn addTarget:self action:@selector(qualityButtonClicked:) forControlEvents:UIControlEventTouchDown];
    self.highQualityLable = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth-kHorMargin-buttonSpace-40,kVerMargin+kBtnHeight+80,40,20)];
    self.highQualityLable.text = @"高清";
    self.highQualityLable.textColor = [[UIColor alloc] initWithRed:51.0/255 green:51.0/255 blue:51.0/255 alpha:1.0];
    
    //进入推流页面
    self.interPublisherView = [UIButton buttonWithType:UIButtonTypeCustom];
    self.interPublisherView.tag = 4;
    self.interPublisherView.frame = CGRectMake(kHorMargin, kVerMargin+kBtnHeight+80+80+20, buttonWidth, kBtnHeight);
    [self.interPublisherView setTitle:@"进入推流页面" forState:UIControlStateNormal];
    [self.interPublisherView setBackgroundImage:[UIImage imageNamed:@"start_publish"] forState:UIControlStateNormal];
    self.interPublisherView.titleLabel.textColor = [[UIColor alloc] initWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    [self.interPublisherView addTarget:self action:@selector(interPublisherViewBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.nvgBar];
    [self.view addSubview:self.highQualityBtn];
    [self.view addSubview:self.mediumQualityBtn];
    [self.view addSubview:self.lowQualityBtn];
    [self.view addSubview:self.interPublisherView];
    [self.view addSubview:self.highQualityLable];
    [self.view addSubview:self.mediumQualityLable];
    [self.view addSubview:self.lowQualityLable];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //默认标清分辨率
    streamQuality = DN_VIDEO_QUALITY_MEDIUM;
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

- (void)interPublisherViewBtnPressed:(id)sender {
    ViewController * coreView =[[ViewController alloc] initParameter:streamQuality];
    [self presentViewController:coreView animated:YES completion:nil];
}

@end
