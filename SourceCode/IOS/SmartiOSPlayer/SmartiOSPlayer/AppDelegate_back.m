//
//  AppDelegate.m
//  SmartiOSPlayer
//
//  Created by daniulive on 16/3/3.
//  Copyright © 2016年 daniulive. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


@synthesize window = _window;
@synthesize glView = _glView;

@synthesize viewController = _viewController;
@synthesize strPlaybackUrl = _strPlaybackUrl;


- (void)dealloc
{
    //[_window release];
    //[_viewController release];
    //[_strPlaybackUrl release];
    //[super dealloc];
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    
    CGRect rect=[[UIScreen mainScreen] bounds];
    
    NSLog(@"height:%f",rect.size.height);
    NSLog(@"width:%f",rect.size.width);
    
    NSInteger btnWidth = 0;
    
    if(rect.size.height > rect.size.width)
    {
        btnWidth = rect.size.width/4;
        screenHeight = rect.size.height;
        screenWidth = rect.size.width;
        copyRightHeight = rect.size.height;
    }
    else
    {
        btnWidth = rect.size.height/4;
        screenWidth = rect.size.width;
        screenHeight = rect.size.height;
        copyRightHeight = rect.size.height;
    }
    
    NSArray *windows = [[UIApplication sharedApplication] windows];
    for(UIWindow *window in windows)
    {
        NSLog(@"window: %@",window.description);
        if(window.rootViewController == nil)
        {
            UIViewController *vc = [[UIViewController alloc]initWithNibName:nil bundle:nil];
            self.window.rootViewController = vc;
        }
    }
    
    //Create 3 buttons for IuputID/ButtonStart/ButtonStop
    UIButton* btnInputID = [UIButton buttonWithType:UIButtonTypeSystem];
    btnInputID.frame = CGRectMake(0, 20, btnWidth, 30);
    
    [btnInputID setTitle:@"输入urlID" forState:UIControlStateNormal];
    
    btnInputID.backgroundColor = [UIColor blueColor];
    
    [btnInputID addTarget:self action:@selector(buttonInputID:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.window.rootViewController.view addSubview:btnInputID];
    
    UIButton* btnStart = [UIButton buttonWithType:UIButtonTypeSystem];
    btnStart.frame = CGRectMake(btnWidth, 20, btnWidth, 30);
    
    [btnStart setTitle:@"播放" forState:UIControlStateNormal];
    
    btnStart.backgroundColor = [UIColor redColor];
    
    [btnStart addTarget:self action:@selector(buttonStart:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.window.rootViewController.view addSubview:btnStart];
    
    UIButton* btnStop = [UIButton buttonWithType:UIButtonTypeSystem];
    btnStop.frame = CGRectMake(btnWidth*2, 20, btnWidth, 30);
    [btnStop setTitle:@"停止" forState:UIControlStateNormal];
    
    btnStop.backgroundColor = [UIColor blueColor];
    
    [btnStop addTarget:self action:@selector(buttonStop:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.window.rootViewController.view addSubview:btnStop];
    
    [self.window makeKeyAndVisible];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    NSLog(@"Run into applicationWillResignActive..");
    if (_player) {
        [_player stop];
        [_player unInitPlayer];
        //[_player release];
        _player = nil;
        if (self.glView!=nil) {
            [SmartPlayerSDK releasePlayView:(__bridge void *)(self.glView)];
            self.glView = nil;
        }
    }
    
    NSLog(@"Run out of applicationWillResignActive..");
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSLog(@"Run into applicationWillTerminate..");
    
    if (_player) {
        [_player stop];
        [_player unInitPlayer];
        //[_player release];
        _player = nil;
        if (self.glView!=nil) {
            [SmartPlayerSDK releasePlayView:(__bridge void *)(self.glView)];
            self.glView = nil;
        }
    }
    NSLog(@"Run out of applicationWillTerminate..");
}

-(void)buttonInputID:(id)sender{
    
    NSLog(@"Run into input ID..");
    
    UIAlertView *alertInputID= [[UIAlertView alloc] initWithTitle:@"如rtmp://daniulive.com:1935/hls/stream123456, 请输入123456" message:@"" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil,nil];
    
    [alertInputID setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [alertInputID show];
    
    NSLog(@"Run out of input ID..");
}

-(void)buttonStart:(id)sender{
    NSLog(@"Run into startup player..");
    
    _player = [[SmartPlayerSDK alloc] init];
    
    if (!_player) {
        return;
    }
    
    [_player initPlayer];
    
    self.glView = (__bridge UIView *)([SmartPlayerSDK createPlayView:0 y:50 width:screenWidth height:screenHeight ]);
    
    [self.window addSubview:self.glView];
    
    //Add copyright information
    UILabel *copyRightLable = [[UILabel alloc]initWithFrame:CGRectMake(0, screenHeight - 50, screenWidth - 50, 50)];
    copyRightLable.text = @"Copyright 2014~2016 www.daniulive.com v1.0.16.0321";

    copyRightLable.textColor = [UIColor orangeColor];
    copyRightLable.adjustsFontSizeToFitWidth = YES;
    
    [self.window addSubview:copyRightLable];

    //[self.glView addSubview:copyRightLable];
    
    [_player setPlayView:(__bridge void *)(self.glView)];

    if (_strPlaybackUrl.length == 0) {
        NSLog(@"Please input url..");
        return;
    }

    NSLog(@"playbackURL: %@",_strPlaybackUrl);
    
    [_player setPlayURL:_strPlaybackUrl];
    
    [_player start];
    
    NSLog(@"Run out of startup player..");
}


-(void)buttonStop:(id)sender{

    NSLog(@"Run into stop player..");
    if (_player) {
        [_player stop];
    }
    
    NSLog(@"Run out of stop player..");
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UITextField *txt = [alertView textFieldAtIndex:0];
    
    NSString* strID = txt.text;
    NSLog(@"strID: %@",strID);
    
    NSString *baseURL = @"rtmp://daniulive.com:1935/hls/stream";
    
    NSString *url;
    
    url = [baseURL stringByAppendingString:strID];
    
    _strPlaybackUrl = [[NSString alloc]initWithString:url];
    
    NSLog(@"_strPlaybackUrl: %@",_strPlaybackUrl);
    
}

@end
