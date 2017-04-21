//
//  ViewController.h
//  SmartiOSPublisher
//
//  GitHub: https://github.com/daniulive/SmarterStreaming
//  website: http://www.daniulive.com
//
//  Created by daniulive on 16/3/24.
//  Copyright © 2015~2017 daniulive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "SmartPublisherSDK.h"

@interface ViewController : UIViewController<SmartPublisherDelegate>

- (instancetype)initParameter:(NSString*)url
                streamQuality:(DNVideoStreamingQuality)streamQuality
                     audioOpt:(NSInteger)audioOpt
                     videoOpt:(NSInteger)videoOpt
                   isRecorder:(Boolean)isRecorder
                     isBeauty:(Boolean)isBeauty;

@end

