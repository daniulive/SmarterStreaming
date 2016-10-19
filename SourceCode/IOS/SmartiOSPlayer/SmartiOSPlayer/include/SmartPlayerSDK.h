//
//  SmartPlayerSDK.h
//  SmartPlayerSDK
//
//  GitHub: https://github.com/daniulive/SmarterStreaming
//
//  Created by daniuLive on 2016/01/03.
//  Copyright © 2016年 daniuLive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "nt_event_define.h"

//设置协议
@protocol SmartPlayerDelegate;

/**
 *  错误返回值
 */
typedef enum DNErrorCode{
    DANIULIVE_RETURN_OK = 0,        //!< 返回OK
    DANIULIVE_RETURN_ERROR,         //!< 返回错误
    DANIULIVE_RETURN_SDK_EXPIRED    //!< SDK过期
}DNErrorCode;

@interface SmartPlayerSDK : NSObject

//Event callback
@property(atomic, assign) id<SmartPlayerDelegate> delegate;

/**
 * 初始化，创建player实例
 * <pre>此接口请第一个调用</pre>
 *
 * @return {0} if successful
 */
- (NSInteger)SmartPlayerInitPlayer;

/**
 * 创建播放view
 *
 * @param [in] 指定播放位置（CGRect)
 */
+ (void*)SmartPlayerCreatePlayView:(NSInteger)x y:(NSInteger)y width:(NSInteger)width height:(NSInteger)height;

/**
 * 释放player view
 *
 * @param view  [in] SmartPlayerCreatePlayView创建的view
 */
+ (void) SmartPlayeReleasePlayView:(void*) playView;

/**
 * 设置player view
 *
 * @param view  [in] SmartPlayerCreatePlayView创建的view
 *
 * @return {0} if successful
 */
- (NSInteger) SmartPlayerSetPlayView:(void*) playView;


/**
 * 设置player buffer
 *
 * @param buffer: Unit is millisecond, range is 200-5000 ms
 *
 * @return {0} if successful
 */
- (NSInteger) SmartPlayerSetBuffer:(NSInteger) buffer;

/**
 * 此接口仅用于播放RTSP流时有效
 *
 * RTSP播放，默认采用UDP
 *
 * @param isUsingTCP: 设置为true, 走TCP模式，false为UDP模式
 *
 * @return {0} if successful
 */
- (NSInteger)SmartPlayerSetRTSPTcpMode:(Boolean)isUsingTCP;

/**
 * 设置播放URL
 *
 * @param url
 *
 * @return {0} if successful
 */
- (NSInteger)SmartPlayerSetPlayURL:(NSString *)url;


/**
 * 开始播放
 *
 * @return {0} if successful
 */
- (NSInteger)SmartPlayerStart;


/**
 * 停止播放
 *
 * @return {0} if successful
 */
- (NSInteger) SmartPlayerStop;


/**
 * 销毁player实例
 *
 * @return {0} if successful
 */
- (NSInteger) SmartPlayerUnInitPlayer;

/**
 *  获取当前sdk的版本号
 */
-(NSString*) SmartPlayerGetSDKVersionID;

@end

@protocol SmartPlayerDelegate <NSObject>

/**
 * Event callback handling.
 */

- (NSInteger) handleSmartPlayerEvent:(NSInteger)nID param1:(unsigned long long)param1 param2:(unsigned long long)param2 param3:(NSString*)param3 param4:(NSString*)param4 pObj:(void *)pObj;

@end
