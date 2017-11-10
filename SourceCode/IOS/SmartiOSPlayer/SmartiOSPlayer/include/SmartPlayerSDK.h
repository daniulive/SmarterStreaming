//
//  SmartPlayerSDK.h
//  SmartPlayerSDK
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
 * 设置player external yuv block callback
 *
 * @param isEnableYuvBlock: 默认false，如需回调YUV数据自己绘制，设置为true
 *
 * @return {0} if successful
 */
- (NSInteger) SmartPlayerSetYuvBlock:(Boolean)isEnableYuvBlock;

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
 * Set low lantency mode(设置超低延迟模式)
 *
 * @param mode: 1: 超低延迟模式; 0: not.
 *
 * @return {0} if successful
 */
- (NSInteger)SmartPlayerSetLowLatencyMode:(NSInteger)mode;

/*
 * 设置下载速度上报, 默认不上报下载速度
 *
 * is_report: 上报开关, 1: 表上报. 0: 表示不上报. 其他值无效.
 *
 * report_interval： 上报时间间隔（上报频率），单位是秒，最小值是1秒1次. 如果小于1且设置了上报，将调用失败
 *
 * 上报事件是：EVENT_DANIULIVE_ERC_PLAYER_DOWNLOAD_SPEED
 *
 * 这个接口必须在Start之前调用
 *
 * @return {0} if successful
 */
- (NSInteger)SmartPlayerSetReportDownloadSpeed:(NSInteger)is_report report_interval:(NSInteger)report_interval;

/**
 * 设置播放URL
 *
 * @param url
 *
 * @return {0} if successful
 */
- (NSInteger)SmartPlayerSetPlayURL:(NSString *)url;

/**
 * Set if needs to save image during playback stream(设置是否启用快照功能)
 *
 * @param handle: return value from SmartPlayerInit()
 *
 * @param is_save_image: if with 1, it will save current image via the interface of SmartPlayerSaveCurImage(), if with 0: does not it
 *
 * @return {0} if successful
 */
- (NSInteger)SmartPlayerSaveImageFlag:(NSInteger) is_save_image;

/**
 * Save current image during playback stream(快照)
 *
 * @param handle: return value from SmartPlayerInit()
 *
 * @param imageName: image name, which including fully path, "/sdcard/daniuliveimage/daniu.png", etc.
 *
 * @return {0} if successful
 */
- (NSInteger)SmartPlayerSaveCurImage:(NSString*) imageName;

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

/**
 * YUV数据回调
 */
typedef void (^PlayerYuvDataBlock)(int width, int height, unsigned long long time_stamp,
unsigned char*yData, unsigned char* uData, unsigned char*vData,
int yStride, int uStride, int vStride);

/**
 * YUV数据回调
 */
@property (nonatomic, copy)PlayerYuvDataBlock yuvDataBlock;

@end

@protocol SmartPlayerDelegate <NSObject>

/**
 * Event callback handling.
 */

- (NSInteger) handleSmartPlayerEvent:(NSInteger)nID param1:(unsigned long long)param1 param2:(unsigned long long)param2 param3:(NSString*)param3 param4:(NSString*)param4 pObj:(void *)pObj;

@end
