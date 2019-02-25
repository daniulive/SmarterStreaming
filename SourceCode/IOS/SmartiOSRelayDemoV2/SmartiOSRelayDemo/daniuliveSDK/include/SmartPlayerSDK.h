//
//  SmartPlayerSDK.h
//  SmartPlayerSDK
//
//  GitHub: https://github.com/daniulive/SmarterStreaming
//  website: https://www.daniulive.com
//
//  Created by daniulive on 16/01/03.
//  Copyright © 2014~2019 daniulive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "nt_event_define.h"

//设置协议
@protocol SmartPlayerDelegate;

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
 * 设置音频回音消除模式(如不设置 则用正常播放模式)
 *
 * @param mode
 * if 0: 正常播放模式
 * if 1: 回音消除模式
 *
 * @return {0} if successful
 */
- (NSInteger)SmartPlayerSetEchoCancellationMode:(NSInteger)mode;

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
 * 设置拉流时，用户数据回调(目前是推送的发过来的)
 *
 * @param isEnableUserDataCallback 默认false，如需回调用户数据(通过扩展SEI信息传递的数据)，设置为true
 *
 * @return {0} if successful
 */
- (NSInteger) SmartPlayerSetUserDataCallback:(Boolean)isEnableUserDataCallback;

/**
 * 设置拉流时，视频的SEI数据回调
 *
 * @param isEnableSEIDataCallback 默认false，如需回调SEI数据(通过扩展SEI信息传递的数据)，设置为true
 *
 * @return {0} if successful
 */
- (NSInteger) SmartPlayerSetSEIDataBlock:(Boolean)isEnableSEIDataCallback;

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
 * 设置RTSP超时时间, timeout单位为秒，必须大于0
 *
 * @param timeout 超时时间
 *
 * @return {0} if successful
 */
- (NSInteger)SmartPlayerSetRTSPTimeout:(NSInteger)timeout;

/**
 * 设置RTSP TCP/UDP自动切换
 *
 * NOTE: 对于RTSP来说，有些可能支持rtp over udp方式，有些可能支持使用rtp over tcp方式.
 * 为了方便使用，有些场景下可以开启自动尝试切换开关, 打开后如果udp无法播放，sdk会自动尝试tcp, 如果tcp方式播放不了,sdk会自动尝试udp.
 *
 * @param is_auto_switch_tcp_udp 如果设置1的话, sdk将在tcp和udp之间尝试切换播放，如果设置为0，则不尝试切换.
 *
 * @return {0} if successful
 */
- (NSInteger)SmartPlayerSetRTSPAutoSwitchTcpUdp:(NSInteger)is_auto_switch_tcp_udp;

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
 * 设置视频垂直反转
 *
 * @param is_flip 0: 不反转, 1: 反转
 *
 * @return {0} if successful
 */
- (NSInteger)SmartPlayerSetFlipVertical:(NSInteger)is_flip;

/**
 * 设置视频水平反转
 *
 * @param is_flip 0: 不反转, 1: 反转
 *
 * @return {0} if successful
 */
- (NSInteger)SmartPlayerSetFlipHorizontal:(NSInteger)is_flip;

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

/*
 * 设置录像时音频转AAC编码的开关
 *
 * aac比较通用，sdk增加其他音频编码(比如speex, pcmu, pcma等)转aac的功能.
 *
 * @param is_transcode: 设置为1的话，如果音频编码不是aac，则转成aac, 如果是aac，则不做转换. 设置为0的话，则不做任何转换. 默认是0.
 *
 * 注意: 转码会增加性能消耗
 */
- (NSInteger)SmartPlayerSetRecorderAudioTranscodeAAC:(NSInteger)is_transcode;

/**
 * 设置是否录视频，默认的话，如果视频源有视频就录，没有就不录, 但有些场景下可能不想录制视频，只想录音频，所以增加个开关
 *
 * @param is_record_video 1 表示录制视频, 0 表示不录制视频, 默认是1
 *
 * @return {0} if successful
 */
- (NSInteger)SmartPlayerSetRecorderVideo:(NSInteger)is_record_video;

/**
 * 设置是否录音频，默认的话，如果视频源有音频就录，没有就不录, 但有些场景下可能不想录制音频，只想录视频，所以增加个开关
 *
 * @param is_record_audio 1 表示录制音频, 0 表示不录制音频, 默认是1
 *
 * @return {0} if successful
 */
- (NSInteger)SmartPlayerSetRecorderAudio:(NSInteger)is_record_audio;

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
 * 设置拉流时音频转AAC编码的开关
 *
 * aac比较通用，sdk增加其他音频编码(比如speex, pcmu, pcma等)转aac的功能.
 *
 * @param is_transcode: 设置为1的话，如果音频编码不是aac，则转成aac, 如果是aac，则不做转换. 设置为0的话，则不做任何转换. 默认是0.
 
 * 注意: 转码会增加性能消耗
 *
 * @return {0} if successful
 */
- (NSInteger)SmartPlayerSetPullStreamAudioTranscodeAAC:(NSInteger)is_transcode;

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

/*
 * 用户数据回调，目前是推送端发送过来的
 * data_type: 数据类型，1:表示二进制字节类型. 2:表示utf8字符串
 * data：实际数据， 如果data_type是1的话，data类型是const NT_BYTE*, 如果data_type是2的话，data类型是 const NT_CHAR*
 * size: 数据大小
 * timestamp: 视频时间戳
 * reserve1: 保留
 * reserve2: 保留
 * reserve3: 保留
 */
typedef void (^SP_SDKUserDataCallBack)(int data_type, unsigned char* data, unsigned int size,
                                       unsigned long long timestamp, unsigned long long reserve1,
                                       long long reserve2, unsigned char* reserve3);

/**
 * 拉流时，用户数据回调
 */
@property (nonatomic, copy)SP_SDKUserDataCallBack spUserDataCallBack;

/*
 * 视频的sei数据回调
 * data: sei 数据
 * size: sei 数据大小
 * timestamp：视频时间戳
 * reserve1: 保留
 * reserve2: 保留
 * reserve3: 保留
 * 注意: 目前测试发现有些视频有好几个sei nal, 为了方便用户处理，我们把解析到的所有sei都吐出来,sei nal之间还是用 00 00 00 01 分隔, 这样方便解析
 * 吐出来的sei数据目前加了 00 00 00 01 前缀
 */
typedef void (^SP_SDKSEIDataCallBack)(unsigned char* data, unsigned int size,
                                      unsigned long long timestamp, unsigned long long reserve1,
                                      long long reserve2, unsigned char* reserve3);

/**
 * 拉流时，视频的sei数据回调
 */
@property (nonatomic, copy)SP_SDKSEIDataCallBack spSEIDataCallBack;

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
