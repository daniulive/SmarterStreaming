//
//  SmartPlayerSDK.h
//  SmartPlayerSDK
//
//  GitHub: https://github.com/daniulive/SmarterStreaming
//  website: http://www.daniulive.com
//
//  Created by daniulive on 2016/01/03.
//  Copyright © 2015~2017 daniulive. All rights reserved.
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
 * 设置视频解码模式
 *
 * @param mode:
 * if 0: 软解码;
 * if 1: 硬解码.
 *
 * @return {0} if successful
 */
- (NSInteger)SmartPlayerSetVideoDecoderMode:(NSInteger)mode;

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
 * Set fast startup(快速启动)
 *
 * @param is_fast_startup: 1: 快速启动; 0: not.
 *
 * @return {0} if successful
 */
- (NSInteger)SmartPlayerSetFastStartup:(NSInteger)isFastStartup;

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
 * 快速切换播放url
 *
 * @param url: 需要切换的新的url
 *
 * @return {0} if successful
 */
- (NSInteger)SmartPlayerSwitchPlaybackUrl:(NSString *)url;

/**
 * 设置播放过程中静音/取消静音
 *
 * @param mute: 设置为1，则静音，设置为0，取消静音
 *
 * @return {0} if successful
 */
- (NSInteger) SmartPlayerSetMute:(NSInteger) mute;


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
