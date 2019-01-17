//
//  ViewController.h
//  SmartiOSPublisher
//
//  GitHub: https://github.com/daniulive/SmarterStreaming
//  website: https://www.daniulive.com
//
//  Created by daniulive on 16/3/24.
//  Copyright © 2014~2019 daniulive. All rights reserved.
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
                     isBeauty:(Boolean)isBeauty;

@end

