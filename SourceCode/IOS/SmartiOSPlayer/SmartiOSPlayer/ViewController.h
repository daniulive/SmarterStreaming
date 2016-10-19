//
//  ViewController.h
//  SmartiOSPlayer
//
//  GitHub: https://github.com/daniulive/SmarterStreaming
//
//  Created by daniulive on 16/01/03.
//  Copyright © 2016年 daniulive. All rights reserved.

#import <UIKit/UIKit.h>
#import "SmartPlayerSDK.h"

@interface ViewController : UIViewController<SmartPlayerDelegate>

- (instancetype)initParameter:(NSString*)url isHalfScreen:(Boolean)isHalfScreenVal isAudioOnly:(Boolean)isAudioOnly isRTSPTcpMode:(Boolean)isRTSPTcpMode;

@end

