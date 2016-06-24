//
//  PlayVideoView.h
//  SmartPublisherSDK
//
//  GitHub: https://github.com/daniulive/SmarterStreaming
//
//  Created by daniulive on 16/3/24.
//  Copyright © 2016年 daniulive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface PlayVideoView : UIView

@property(nonatomic)AVPlayer * player;
@property(nonatomic,readonly)AVPlayerLayer * playerLayer;

@end
