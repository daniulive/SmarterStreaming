//
//  AppDelegate.h
//  EasyiOSPlayer
//
//  Created by Xinsheng & Yanjie on 16/3/3.
//  Copyright © 2016年 daniulive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SmartPlayerSDK.h"

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    UIView * _glView;
    ViewController *_viewController;
    SmartPlayerSDK * _player;
    CGRect rScreenBounds;
    NSInteger screenWidth;
    NSInteger screenHeight;
    NSInteger copyRightHeight;
    NSString* _strPlaybackUrl;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIView *glView;
@property (strong, nonatomic) ViewController *viewController;
@property (strong, nonatomic) NSString *strPlaybackUrl;

@end

