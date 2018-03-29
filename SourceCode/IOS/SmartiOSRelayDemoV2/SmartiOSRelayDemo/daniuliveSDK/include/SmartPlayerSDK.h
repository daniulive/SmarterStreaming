//
//  SmartPlayerSDK.h
//  SmartPlayerSDK
//
//  GitHub: https://github.com/daniulive/SmarterStreaming
//  website: http://www.daniulive.com
//
//  Created by daniulive on 16/01/03.
//  Copyright © 2015~2018 daniulive. All rights reserved.
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
 * @param mode
 * if 0: 软解码;
 * if 1: 硬解码.
 *
 * @return {0} if successful
 */
- (NSInteger)SmartPlayerSetVideoDecoderMode:(NSInteger)mode;

/**
 * 创建播放view
 *
 * @param x y width height 指定播放位置（CGRect)
 */
+ (void*)SmartPlayerCreatePlayView:(NSInteger)x y:(NSInteger)y width:(NSInteger)width height:(NSInteger)height;

/**
 * 释放播放view
 *
 * @param playView 对应SmartPlayerCreatePlayView创建的view
 */
+ (void) SmartPlayeReleasePlayView:(void*) playView;

/**
 * 设置播放view
 *
 * @param playView SmartPlayerCreatePlayView创建的view
 *
 * @return {0} if successful
 */
- (NSInteger) SmartPlayerSetPlayView:(void*) playView;

/**
 * 设置拉流时，视频YUV数据回调
 *
 * @param isEnableYuvBlock 默认false，如需回调YUV数据自己绘制，设置为true
 *
 * @return {0} if successful
 */
- (NSInteger) SmartPlayerSetYuvBlock:(Boolean)isEnableYuvBlock;

/**
 * 设置拉流时，视频数据回调
 *
 * @param isEnablePSVideoDataBlock 默认false，如需拉流时，视频数据回调(比如视频转发之用)，设置为true
 *
 * @return {0} if successful
 */
- (NSInteger) SmartPlayerSetPullStreamVideoDataBlock:(Boolean)isEnablePSVideoDataBlock;

/**
 * 设置拉流时，音频数据回调
 *
 * @param isEnablePSAudioDataBlock 默认false，如需拉流时，视频数据回调(比如视频转发之用)，设置为true
 *
 * @return {0} if successful
 */
- (NSInteger) SmartPlayerSetPullStreamAudioDataBlock:(Boolean)isEnablePSAudioDataBlock;

/**
 * 设置player buffer
 *
 * @param buffer Unit is millisecond, range is 200-5000 ms
 *
 * @return {0} if successful
 */
- (NSInteger) SmartPlayerSetBuffer:(NSInteger) buffer;

/**
 * 此接口仅用于播放RTSP流时有效
 *
 * RTSP播放，默认采用UDP
 *
 * @param isUsingTCP 设置为true, 走TCP模式，false为UDP模式
 *
 * @return {0} if successful
 */
- (NSInteger)SmartPlayerSetRTSPTcpMode:(Boolean)isUsingTCP;

/**
 * Set fast startup(快速启动)
 *
 * @param isFastStartup 1: 快速启动; 0: not.
 *
 * @return {0} if successful
 */
- (NSInteger)SmartPlayerSetFastStartup:(NSInteger)isFastStartup;

/**
 * Set low lantency mode(设置超低延迟模式)
 *
 * @param mode 1: 超低延迟模式; 0: not.
 *
 * @return {0} if successful
 */
- (NSInteger)SmartPlayerSetLowLatencyMode:(NSInteger)mode;

/**
 * 设置顺时针旋转, 注意除了0度之外， 其他角度都会额外消耗性能
 *
 * @param degress 当前支持 0度，90度, 180度, 270度 旋转
 *
 * @return {0} if successful
 */
- (NSInteger)SmartPlayerSetRotation:(NSInteger)degress;

/*
 * 设置下载速度上报, 默认不上报下载速度
 *
 * @param is_report: 上报开关, 1: 表上报. 0: 表示不上报. 其他值无效.
 *
 * @param report_interval 上报时间间隔（上报频率），单位是秒，最小值是1秒1次. 如果小于1且设置了上报，将调用失败
 *
 * 上报事件是：EVENT_DANIULIVE_ERC_PLAYER_DOWNLOAD_SPEED
 *
 * 此接口必须在Start之前调用
 *
 * @return {0} if successful
 */
- (NSInteger)SmartPlayerSetReportDownloadSpeed:(NSInteger)is_report report_interval:(NSInteger)report_interval;

/**
 * 设置播放URL
 *
 * @param url 需要播放的URL
 *
 * @return {0} if successful
 */
- (NSInteger)SmartPlayerSetPlayURL:(NSString *)url;

/**
 * Set if needs to save image during playback stream(设置是否启用快照功能)
 *
 * @param is_save_image 1 通过SmartPlayerSaveCurImage()保存当前image, 0: 不保存
 *
 * @return {0} if successful
 */
- (NSInteger)SmartPlayerSaveImageFlag:(NSInteger) is_save_image;

/**
 * Save current image during playback stream(快照)
 *
 * @param imageName 设置包含全路径的名字
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
 * @param url 需要快速切换的新的url, 比如高低分辨率切换/双摄像头URL切换等
 *
 * @return {0} if successful
 */
- (NSInteger)SmartPlayerSwitchPlaybackUrl:(NSString *)url;

/**
 * 设置播放过程中静音/取消静音
 *
 * @param mute 1: 静音 0: not
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
 * 录像相关：
 *
 * @param path 录像文件存放目录
 *
 * @return {0} if successful
 */
- (NSInteger)SmartPlayerSetRecorderDirectory:(NSString*)path;

/**
 * 录像相关：
 *
 * @param size 每个录像文件的大小 (5~500M), 默认200M
 *
 * @return {0} if successful
 */
- (NSInteger)SmartPlayerSetRecorderFileMaxSize:(NSInteger)size;

/**
 * 录像相关：
 *
 * Start recorder(开始录像)
 *
 * @return {0} if successful
 */
- (NSInteger)SmartPlayerStartRecorder;

/**
 * 录像相关：
 *
 * Stop recorder(停止录像)
 *
 * @return {0} if successful
 */
- (NSInteger)SmartPlayerStopRecorder;

/*
 * 启动拉流
 *
 * Start pull stream(开始拉流)
 */
- (NSInteger)SmartPlayerStartPullStream;

/*
 * 停止拉流
 *
 * Stop pull stream(停止拉流)
 */
- (NSInteger)SmartPlayerStopPullStream;

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
 * 拉流时YUV数据回调
 *
 * @param width 视频宽
 *
 * @param height 视频高
 *
 * @param time_stamp 解码时间戳, 单位是毫秒
 *
 * @param yData Y分量数据
 *
 * @param uData U分量数据
 *
 * @param vData V分量数据
 *
 * @param yStride Y分量stride
 *
 * @param uStride U分量stride
 *
 * @param vStride V分量stride
 */
typedef void (^PlayerYuvDataBlock)(int width, int height, unsigned long long time_stamp,
                unsigned char*yData, unsigned char* uData, unsigned char*vData,
                int yStride, int uStride, int vStride);

/**
 * 拉流时，YUV数据回调
 */
@property (nonatomic, copy)PlayerYuvDataBlock yuvDataBlock;

/**
 * 拉流时，视频数据回调
 *
 * @param video_codec_id 8代表 H.264
 *
 * @param is_key_frame 1:表示关键帧, 0：表示非关键帧
 *
 * @param timestamp 解码时间戳, 单位是毫秒
 *
 * @param width 一般是0
 *
 * @param height 一般也是0
 *
 * @param parameter_info 一般是nil
 *
 * @param parameter_info_size 一般是0
 *
 * @param presentation_timestamp 显示时间戳, 这个值要大于或等于timestamp, 单位是毫秒
 */
typedef void (^PullStreamVideoDataBlock)(int video_codec_id, unsigned char* data, int size, int is_key_frame,
                                         unsigned long long timestamp, int width, int height,
                                         unsigned char* parameter_info, int parameter_info_size, unsigned long long presentation_timestamp);

/**
 * 拉流时，视频数据回调
 */
@property (nonatomic, copy)PullStreamVideoDataBlock pullStreamVideoDataBlock;

/**
 * 拉流时，音频数据回调
 *
 * @param audio_codec_id 8代表 AAC
 *
 * @param is_key_frame 1:表示关键帧, 0:表示非关键帧
 *
 * @param timestamp 单位是毫秒
 *
 * @param sample_rate 一般是0
 *
 * @param channel 一般也是0
 *
 * @param parameter_info 如果是AAC的话，这个是有值的, 其他编码一般忽略
 *
 * @param parameter_info_size 如果是AAC的话，这个是有值的, 其他编码一般忽略
 *
 * @param reserve 保留字段
 */
typedef void (^PullStreamAudioDataBlock)(int audio_codec_id, unsigned char* data, int size, int is_key_frame,
                                         unsigned long long timestamp, int sample_rate, int channel,
                                         unsigned char* parameter_info, int parameter_info_size, unsigned long long reserve);

/**
 * 拉流时，音频数据回调
 */
@property (nonatomic, copy)PullStreamAudioDataBlock pullStreamAudioDataBlock;

@end

@protocol SmartPlayerDelegate <NSObject>

/**
 * Event callback handling.
 */

- (NSInteger) handleSmartPlayerEvent:(NSInteger)nID param1:(unsigned long long)param1 param2:(unsigned long long)param2 param3:(NSString*)param3 param4:(NSString*)param4 pObj:(void *)pObj;

@end
