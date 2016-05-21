//
//  ViewController.m
//  SmartiOSPlayer
//
//  GitHub: https://github.com/daniulive/SmarterStreaming
//
//  Created by daniulive on 16/01/03.
//  Copyright © 2016年 daniulive. All rights reserved.

#import "ViewController.h"
#import "SmartPlayerSDK.h"
#import "SettingView.h"

@interface ViewController ()

@end

@implementation ViewController
{
    NSString        *_streamUrl;
    SmartPlayerSDK  * _player;
    UIView          * _glView;
    NSString        *copyRights;
    UILabel         *textModeLabel;             //文字提示
    UIButton        *backSettingsButton;        //返回按钮
}

- (instancetype)initParameter:(NSString*)url
{
    self = [super init];
    if (!self) {
        return nil;
    }
    else if(self) {
        _streamUrl = url;
    }
    
    return self;
}

- (void)loadView
{
    copyRights = @"Copyright 2014~2016 www.daniulive.com v1.0.16.0502";
    //当前屏幕宽高
    NSInteger screenWidth  = CGRectGetWidth([UIScreen mainScreen].bounds);
    NSInteger screenHeight = CGRectGetHeight([UIScreen mainScreen].bounds);
    
    NSLog(@"screenWidth:%ld, screenHeight:%ld",(long)screenWidth, (long)screenHeight);
    
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    
    _player = [[SmartPlayerSDK alloc] init];
    
    if (_player ==nil ) {
        NSLog(@"SmartPlayerSDK init failed..");
        return;
    }
    
    NSString* sdkVersion = [_player SmartPlayerGetSDKVersionID];
    NSLog(@"sdk version:%@",sdkVersion);
    
    NSInteger initRet = [_player SmartPlayerInitPlayer];
    if ( initRet != DANIULIVE_RETURN_OK )
    {
        NSLog(@"SmartPlayerSDK call SmartPlayerInitPlayer failed, ret=%ld", (long)initRet);
        return;
    }
    
    _glView = (__bridge UIView *)([SmartPlayerSDK SmartPlayerCreatePlayView:0 y:0 width:screenWidth height:screenHeight]);
    
    if (_glView == nil ) {
        NSLog(@"createPlayView failed..");
        return;
    }
    
    [self.view addSubview:_glView];
    
    [_player SmartPlayerSetPlayView:(__bridge void *)(_glView)];
    
    if (_streamUrl.length == 0) {
        NSLog(@"_streamUrl with nil..");
        return;
    }
    
    NSLog(@"playback URL: %@", _streamUrl);
    
    [_player SmartPlayerSetPlayURL:_streamUrl];
    
    [_player SmartPlayerStart];
    
    backSettingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backSettingsButton.frame = CGRectMake(45, self.view.frame.size.height - 80, 60, 60);
    backSettingsButton.center = CGPointMake(self.view.frame.size.width / 2, backSettingsButton.frame.origin.y + backSettingsButton.frame.size.height / 2);
    
    CGFloat lineWidth = backSettingsButton.frame.size.width * 0.12f;
    
    backSettingsButton.layer.cornerRadius = backSettingsButton.frame.size.width / 2;
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
    
    if (_glView != nil) {
        [_glView removeFromSuperview];
        [SmartPlayerSDK SmartPlayeReleasePlayView:(__bridge void *)(_glView)];
        _glView = nil;
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

@end
