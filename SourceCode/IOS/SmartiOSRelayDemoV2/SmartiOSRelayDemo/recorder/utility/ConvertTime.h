//
//  ConvertTime.h
//  SmartPublisherSDK
//
//  GitHub: https://github.com/daniulive/SmarterStreaming
//  website: https://www.daniulive.com
//
//  Created by daniulive on 16/3/24.
//  Copyright © 2014~2019年 daniulive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface NSString (time)

// 时间转换
+ (NSString *)convertTime:(CGFloat)second;

@end
