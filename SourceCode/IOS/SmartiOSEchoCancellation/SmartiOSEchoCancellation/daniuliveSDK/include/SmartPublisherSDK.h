//
//  SmartPublisherSDK.h
//  SmartPublisherSDK
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

#import "nt_event_define.h"

//设置delegate
@protocol SmartPublisherDelegate;

/**
 * 美颜类型
 */
typedef NS_ENUM(NSInteger, DN_BEAUTY_TYPE) {
    DN_BEAUTY_NONE = 0,             //!< 不加美颜
    DN_BEAUTY_INTERNAL_BEAUTY = 1,  //!< 内部daniulive基础美颜
};

/**
 * 推流分辨率选择
 *
 *  此类型仅用于daniulive做视频采集时使用，如视频数据来自美颜或第三方接口，无需使用
 */
typedef enum DNVideoStreamingQuality{
    DN_VIDEO_QUALITY_LOW,           //!< 视频分辨率：低清.
    DN_VIDEO_QUALITY_MEDIUM,        //!< 视频分辨率：标清.
    DN_VIDEO_QUALITY_HIGH           //!< 视频分辨率：高清.
}DNVideoStreamingQuality;

/**
 * 前后置摄像头
 */
typedef enum DNCameraPosition{
    DN_CAMERA_POSITION_BACK,         //!< 后置摄像头.
    DN_CAMERA_POSITION_FRONT         //!< 前置摄像头.
} DNCameraPosition;

@interface SmartPublisherSDK : NSObject

//Event callback
@property(atomic, assign) id<SmartPublisherDelegate> delegate;

/**
 * 初始化Publisher
 *
 * <pre>此接口请第一个调用</pre>
 *
 * audio_opt和video_opt组合推送类型，如 audio_opt为1，video_opt为1，则代表推送音频和视频
 *
 * @param audio_opt
 if with 0: 不推送音频
 if with 1: 推送SDK内部采集的音频
 if with 2: 推送外部编码后音频(目前支持AAC/PCMA/PCMU/SPEEX宽带)
 if with 3: 推送外部编码前音频数据(CMSampleBufferRef类型), 数据传递对应接口: SmartPublisherPostAudioSampleBuffer
 if with 4: 推送外部采集的PCM音频
 *
 * @param video_opt
 if with 0: 不推送视频
 if with 1: 推送SDK内部采集的视频
 if with 2: 推送外部编码后视频(目前支持H.264),数据格式: 0000000167....
 if with 3: 推送外部编码前视频数据(CMSampleBufferRef类型), 数据传递对应接口: SmartPublisherPostVideoSampleBuffer
 if with 4: 推送外部编码前yuv420视频数据, 数据传递对应接口: SmartPublisherSetExternalYuvData
 if with 5: 推送外部编码前BGRA视频数据(alpha通道不使用), 数据传递对应接口: SmartPublisherSetExternalBGRAData
 if with 6: 推送外部编码前ARGB视频数据(alpha通道不使用), 数据传递对应接口: SmartPublisherSetExternalARGBData
 *
 * @return {0} if successful
 */
- (NSInteger)SmartPublisherInit:(NSInteger)audio_opt video_opt:(NSInteger)video_opt;

/**
 * 设置横竖屏推送模式(仅适用于内置非美颜模式)
 *
 * <pre>SmartPublisherInit之后，SmartPublisherStartCapture之前调用</pre>
 *
 * orientation: 竖屏推送:1, 横屏推送:2
 *
 * @return {0} if successful
 */
-(NSInteger)SmartPublisherSetPublishOrientation:(NSInteger)orientation;

/**
 * 设置视频编码类型(H.264/H.265,软编码还是硬编码)
 *
 * <pre>SmartPublisherInit之后，SmartPublisherStartCapture之前调用</pre>
 *
 * @param encoderType 1: H.264, 2: H.265编码
 *
 * @param isHwEncoder YES: 硬编码 NO: 软编码
 *
 * @return {0} if successful
 */
-(NSInteger)SmartPublisherSetVideoEncoderType:(NSInteger)encoderType isHwEncoder:(Boolean)isHwEncoder;

/**
 * 设置音频编码类型(目前仅支持AAC)
 *
 * <pre>SmartPublisherInit之后，SmartPublisherStartCapture之前调用</pre>
 *
 * @param encoderType 1: AAC
 *
 * @param isHwEncoder YES: 硬编码 NO: 软编码
 *
 * @return {0} if successful
 */
-(NSInteger)SmartPublisherSetAudioEncoderType:(NSInteger)encoderType isHwEncoder:(Boolean)isHwEncoder;

/**
 * 设置是否启用回音消除
 *
 * <pre>SmartPublisherInit之后，SmartPublisherStartCapture之前调用</pre>
 *
 * @param isEnableEchoCancellation YES: 打开 NO: 关闭
 *
 * @return {0} if successful
 */
-(NSInteger)SmartPublisherSetEchoCancellation:(Boolean)isEnableEchoCancellation;

/**
 * Set software encode vbr mode(软编码可变码率).
 *
 * <pre>SmartPublisherInit之后，SmartPublisherStartCapture之前调用</pre>
 *
 * is_enable_vbr: if 0: NOT enable vbr mode, 1: enable vbr
 *
 * video_quality: vbr video quality, range with (1,50), default 23
 *
 * vbr_max_kbitrate: vbr max encode bit-rate(kbps)
 *
 * @return {0} if successful
 */
-(NSInteger)SmartPublisherSetSwVBRMode:(Boolean)is_enable_vbr video_quality:(NSInteger)video_quality vbr_max_kbitrate:(NSInteger)vbr_max_kbitrate;

/**
 * 设置GOP间隔
 *
 * <pre>SmartPublisherInit之后，SmartPublisherStartCapture之前调用</pre>
 *
 * @param gopInterval 编码I帧间隔, gopInterval>0
 *
 * @return {0} if successful
 */
-(NSInteger)SmartPublisherSetGopInterval:(NSInteger)gopInterval;

/**
 * 设置software/harderware encode video bit-rate.
 *
 * <pre>SmartPublisherInit之后，SmartPublisherStartCapture之前调用</pre>
 *
 * @param avgBitRate average encode bit-rate(kbps)
 *
 * @param maxBitRate max encode bit-rate(kbps)
 *
 * @return {0} if successful
 */
-(NSInteger)SmartPublisherSetVideoBitRate:(NSInteger)avgBitRate maxBitRate:(NSInteger)maxBitRate;

/**
 * Set software video encoder profile(设置视频软编码profile).
 *
 * <pre>SmartPublisherInit之后，SmartPublisherStartCapture之前调用</pre>
 *
 * profile: the software video encoder profile, range with (1,3).
 *
 * 1: baseline profile
 * 2: main profile
 * 3: high profile
 *
 * @return {0} if successful
 */
-(NSInteger)SmartPublisherSetSWVideoEncoderProfile:(NSInteger)profile;

/**
 *
 * Set software video encoder speed(设置视频软编码speed).
 *
 * <pre>SmartPublisherInit之后，SmartPublisherStartCapture之前调用</pre>
 *
 * @param speed range with(1, 6), the default speed is 6.
 *
 * if with 1, CPU is lowest.
 * if with 6, CPU is highest.
 *
 * @return {0} if successful
 */
-(NSInteger)SmartPublisherSetSWVideoEncoderSpeed:(NSInteger)speed;

/**
 * 设置fps.
 *
 * <pre>SmartPublisherInit之后，SmartPublisherStartCapture之前调用</pre>
 *
 * @param fps 视频帧率, range (1,25).
 *
 * @return {0} if successful
 */
-(NSInteger)SmartPublisherSetFPS:(NSInteger)fps;

/**
 * 设置裁剪模式(仅用于640*480分辨率, 裁剪主要用于移动端宽高适配)
 *
 * <pre>SmartPublisherInit之后，SmartPublisherStartCapture之前调用</pre>
 *
 * @param mode 0: 非裁剪模式 1:裁剪模式(如不设置, 默认裁剪模式)
 *
 * @return {0} if successful
 */
-(NSInteger)SmartPublisherSetClippingMode:(Boolean)mode;

/**
 * 设置镜像(mirror)
 *
 * <pre>SmartPublisherInit之后调用</pre>
 *
 * mirror true: 镜像模式, false: 非镜像模式
 *
 * 镜像模式: 播放端和推送端本地回显方向显示一致
 *
 * @return {0} if successful
 */
-(NSInteger)SmartPublisherSetMirror:(Boolean)mirror;

/**
 * 美颜相关
 *
 * 是否使用美颜
 *
 * beautyTpye:
 DN_BEAUTY_NONE = 0,             //!< 不加美颜
 DN_BEAUTY_INTERNAL_BEAUTY = 1,  //!< 内部daniulive基础美颜
 DN_BEAUTY_ADDITIONAL_BEAUTY = 2 //!< 第三方美颜对接
 *
 * <pre>beautyTpye为2(DN_BEAUTY_ADDITIONAL_BEAUTY)时，
 * 请调用SmartPublisherSetExternalResolution和SmartPublisherSetExternalYuvData给数据</pre>
 *
 * @return {0} if successful
 */
- (NSInteger)SmartPublisherSetBeauty:(DN_BEAUTY_TYPE)beautyTpye;

/**
 * 内部美颜时使用,亮度调节
 *
 * <pre>SmartPublisherInit之后调用</pre>
 *
 * <NOTE> 此接口仅在使用daniulive基础美颜(DN_BEAUTY_INTERNAL_BEAUTY)时设置
 *
 * level范围: (0~1)
 *
 * @return {0} if successful
 */
-(NSInteger)SmartPublisherSetBeautyBrightness:(CGFloat)level;

/**
 * 美颜或外部视频采集时使用
 *
 * 设置采集分辨率
 *
 * <pre>width: 宽， height: 高)</pre>
 *
 * @return {0} if successful
 */
- (NSInteger)SmartPublisherSetExternalResolution:(NSInteger)width height:(NSInteger)height;

/**
 * 美颜或外部视频采集时使用
 *
 * 传递YUV数据
 *
 * <pre>yData: Y平面， uData: U平面 vData: V平面</pre>
 *
 * @return {0} if successful
 */
- (NSInteger)SmartPublisherSetExternalYuvData:(unsigned char*)yData uData:(unsigned char*)uData vData:(unsigned char*)vData yStride:(NSInteger)yStride uStride:(NSInteger)uStride vStride:(NSInteger)vStride;

/**
 * 美颜或外部视频采集时使用
 *
 * 传递BGRA数据
 *
 * <pre>data: bgra data</pre>
 *
 * @return {0} if successful
 */
-(NSInteger)SmartPublisherSetExternalBGRAData:(unsigned char*)data stride:(NSInteger)stride;

/**
 * 美颜或外部视频采集时使用
 *
 * 传递ARGB数据
 *
 * <pre>data: argb data</pre>
 *
 * @return {0} if successful
 */
-(NSInteger)SmartPublisherSetExternalARGBData:(unsigned char*)data stride:(NSInteger)stride;

/*
 * 投递PCM音频数据给SDK, 每10ms音频数据传入一次
 *
 * SmartPublisherInit接口设置audio_opt为4时, 调用此接口传递外部编码前PCM数据
 *
 * data: pcm数据, 注意每个采样必须是16位的, 其他格式不支持, 注意双通道的话数据是交错的
 *
 * size: pcm数据大小
 *
 * timestamp：时间戳单位是毫秒，必须是递增的
 *
 * sample_rate: 采样率
 *
 * channels: 通道, 当前通道只支持1和2，也就是单通道和双通道
 *
 * per_channel_sample_number: 这个请传入的是 sampleRate/100， 也就是单个通道的10毫秒的采样数
 */
-(NSInteger)SmartPublisherPostAudioPCMData:(unsigned char*)data size:(NSInteger)size
                                 timestamp:(unsigned long long)timestamp sample_rate:(NSInteger)sample_rate
                                  channels:(NSInteger)channels per_channel_sample_number:(NSInteger)per_channel_sample_number;

/**
 * 设置编码后视频数据(H.264)
 *
 * !!!NOTE: 最新版(2018年1月release), 可以用 SmartPublisherPostVideoEncodedData 接口代替
 *
 * @param buffer encoded video data
 *
 * @param len data length
 *
 * @param isKeyFrame if with key frame, please set 1, otherwise, set 0.
 *
 * @param timeStamp video timestamp
 *
 * @return {0} if successful
 */
//-(NSInteger) SmartPublisherOnReceivingVideoEncodedData:(unsigned char*)buffer len:(NSInteger)len isKeyFrame:(NSInteger)isKeyFrame timeStamp:(unsigned long long)timeStamp;

/**
 * 设置 audio specific configure.
 *
 * !!!NOTE: 最新版(2018年1月release), 可以用 SmartPublisherPostAudioEncodedData 接口代替
 *
 * @param buffer audio specific settings.
 *
 * For example:
 *
 * sample rate with 44100, channel: 2, profile: LC
 *
 * audioConfig set as below:
 *
 *    byte[] audioConfig = new byte[2];
 *    audioConfig[0] = 0x12;
 *    audioConfig[1] = 0x10;
 *
 * @param len buffer length
 *
 * @return {0} if successful
 */
//-(NSInteger) SmartPublisherSetAudioSpecificConfig:(unsigned char*)buffer len:(NSInteger)len;

/**
 * 设置编码后视频数据(AAC)
 *
 * !!!NOTE: 最新版(2018年1月release), 可以用 SmartPublisherPostAudioEncodedData 接口代替
 *
 * @param buffer encoded audio data
 *
 * @param len data length
 *
 * @param isKeyFrame 1
 *
 * @param timeStamp audio timestamp
 *
 * @return {0} if successful
 */
//-(NSInteger) SmartPublisherOnReceivingAACData:(unsigned char*)buffer len:(NSInteger)len isKeyFrame:(NSInteger)isKeyFrame timeStamp:(unsigned long long)timeStamp;

/**
 * 设置编码前视频宽高比例缩放(用于屏幕采集缩放),数据传输对应SmartPublisherPostVideoSampleBuffer接口
 *
 * @param scaleRate 范围(0.1~1.0]:
 * 如: 1.0代表不缩放，0.5代表宽、高分别缩放一倍，默认 0.5
 *
 * 一般建议设置值 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0
 *
 * @return {0} if successful
 */
-(NSInteger) SmartPublisherSetVideoSizeScaleRate:(CGFloat)scaleRate;

/**
 * 设置SDK运行模式
 *
 * <pre>SmartPublisherInit之后，SmartPublisherStartPublisher或SmartPublisherStartRecorder之前调用</pre>
 *
 * mode: 0:正常模式 1:后台推送屏幕时请使用此选项
 *
 * @return {0} if successful
 */
-(NSInteger)SmartPublisherSetSDKRunMode:(NSInteger)mode;

/**
 * 设置编码前视频CMSampleBufferRef数据, 如需缩放比例, 请使用SmartPublisherSetVideoScaleRate接口
 *
 * @param data 编码前的video数据
 *
 * @return {0} if successful
 */
-(NSInteger) SmartPublisherPostVideoSampleBuffer:(CMSampleBufferRef)data;

/**
 * 设置编码前音频CMSampleBufferRef数据
 *
 * @param data 编码前的audio数据
 *
 * @param inputType 1: 麦克风 2: 应用程序音频
 *
 * @return {0} if successful
 */
-(NSInteger) SmartPublisherPostAudioSampleBuffer:(CMSampleBufferRef)data inputType:(NSInteger)inputType;

/**
 * 设置编码后视频数据(H.264)
 *
 * @param codec_id 参见 nt_common_media_define.h, H.264对应 NT_MEDIA_CODEC_ID_H264
 *
 * @param data 编码后的video数据
 *
 * @param size data length
 *
 * @param is_key_frame 是否I帧, if with key frame, please set 1, otherwise, set 0.
 *
 * @param timestamp video timestamp
 *
 * @param pts Presentation Time Stamp, 显示时间戳
 *
 * @return {0} if successful
 */
-(NSInteger) SmartPublisherPostVideoEncodedData:(NSInteger)codec_id data:(unsigned char*)data size:(NSInteger)size is_key_frame:(NSInteger)is_key_frame timestamp:(unsigned long long)timestamp pts:(unsigned long long)pts;

/**
 * 设置音频数据(AAC/PCMA/PCMU/SPEEX)
 *
 * @param codec_id 参见 nt_common_media_define.h
 *
 * @param data audio数据
 *
 * @param size data length
 *
 * @param is_key_frame 是否I帧, if with key frame, please set 1, otherwise, set 0, audio忽略
 *
 * @param timestamp video timestamp
 *
 * @param parameter_info 用于AAC special config信息填充
 *
 * @param parameter_info_size parameter info size
 *
 * @return {0} if successful
 */
-(NSInteger) SmartPublisherPostAudioEncodedData:(NSInteger)codec_id data:(unsigned char*)data size:(NSInteger)size is_key_frame:(NSInteger)is_key_frame timestamp:(unsigned long long)timestamp parameter_info:(unsigned char*)parameter_info parameter_info_size:(NSInteger)parameter_info_size;

/**
 * 设置是否静音
 *
 * <pre>isMute: (0: 不静音；1: 静音)</pre>
 *
 * @return {0} if successful
 */
-(NSInteger)SmartPublisherSetMute:(Boolean)isMute;

/**
 * 录像相关：
 *
 * 是否边推流边本地存储
 * <pre>isRecorder: (0: 不录像；1: 录像)</pre>
 *
 * @return {0} if successful
 */
- (NSInteger)SmartPublisherSetRecorder:(Boolean)isRecorder;

/**
 * 录像相关：
 *
 * <pre>path: 录像文件存放目录</pre>
 *
 * @return {0} if successful
 */
- (NSInteger)SmartPublisherSetRecorderDirectory:(NSString*)path;

/**
 * 录像相关：
 *
 * <pre>size: 每个录像文件的大小 (5~500M), 默认200M</pre>
 *
 * @return {0} if successful
 */
- (NSInteger)SmartPublisherSetRecorderFileMaxSize:(NSInteger)size;

/**
 * Set if needs to save image during publishing stream(设置启用快照)
 *
 * @param is_save_image 1 通过SmartPublisherSaveImage()保存当前image, 0: 不保存
 *
 * @return {0} if successful
 */
- (NSInteger)SmartPublisherSaveImageFlag:(NSInteger)is_save_image;

/**
 * Save current image during publishing stream(实时快照)
 *
 * @param imageName 设置包含全路径的名字
 *
 * @return {0} if successful
 */
- (NSInteger)SmartPublisherSaveCurImage:(NSString*)imageName;

/**
 * Set rtmp PublishingType
 *
 * @param type 0:live, 1:record. please refer to rtmp specification Page 46
 *
 * @return {0} if successful
 */
-(NSInteger)SmartPublisherSetRtmpPublishingType:(NSInteger)type;

/*++++发送用户自定义数据相关接口++++*/
/*
 * 1. 目前使用sei机制发送用户自定数据到播放端
 * 2. 这种机制有可能会丢失数据, 所以这种方式不保证接收端一定能收到
 * 3. 优势:能和视频保持同步，虽然有可能丢失，但一般的需求都满足了
 * 4. 目前提供两种发送方式 第一种发送二进制数据, 第二种发送 utf8字符串
 */

/**
 * 设置发送队列大小，为保证实时性，默认大小为3, 必须设置一个大于0的数
 *
 * @param max_size 队列最大长度
 *
 * @param reserve 保留字段
 *
 * NOTE: 1. 如果数据超过队列大小，将丢掉队头数据; 2. 这个接口请在 StartPublisher 之前调用
 *
 * @return {0} if successful
 */
-(NSInteger)SmartPublisherSetPostUserDataQueueMaxSize:(NSInteger)max_size reserve:(NSInteger)reserve;

/**
 * 清空用户数据队列, 有些情况可能会用到，比如发送队列里面有4条消息再等待发送,又想把最新的消息快速发出去, 可以先清除掉正在排队消息, 再调用PostUserXXX
 *
 * @return {0} if successful
 */
-(NSInteger)SmartPublisherClearPostUserDataQueue;

/**
 * 发送二进制数据
 *
 * NOTE:
 * 1.目前数据大小限制在256个字节以内，太大可能会影响视频传输，如果有特殊需求，需要增大限制，请联系我们
 * 2. 如果积累的数据超过了设置的队列大小，之前的队头数据将被丢弃
 * 3. 必须再调用StartPublisher之后再发送数据
 *
 * @param data 二进制数据
 *
 * @param size 数据大小
 *
 * @param reserve 保留字段
 *
 * @return {0} if successful
 */
-(NSInteger)SmartPublisherPostUserData:(unsigned char*)data size:(NSInteger)size reserve:(NSInteger)reserve;

/**
 * 发送utf8字符串
 *
 * NOTE:
 * 1. 字符串长度不能超过256, 太大可能会影响视频传输，如果有特殊需求，需要增大限制，请联系我们
 * 2. 如果积累的数据超过了设置的队列大小，之前的队头数据将被丢弃
 * 3. 必须再调用StartPublisher之后再发送数据
 *
 * @param utf8_str utf8字符串
 *
 * @param reserve 保留字段
 *
 * @return {0} if successful
 */
-(NSInteger)SmartPublisherPostUserUTF8StringData:(NSString*)utf8_str reserve:(NSInteger)reserve;

/*----发送用户自定义数据相关接口----*/

/**
 * 设置video preview
 *
 * 此接口仅当用daniulive采集视频数据时设置，若视频源来自外部美颜（DN_BEAUTY_ADDITIONAL_BEAUTY）或外部第三方数据，无需调用
 *
 * @return {0} if successful
 */
-(NSInteger)SmartPublisherSetVideoPreview:(UIView*)preview;

/**
 * 开始采集音视频数据(和SmartPublisherStopCaputure配对使用)
 *
 * <pre>resolution：采集分辨率</pre>
 *
 * @return {0} if successful
 */
-(NSInteger)SmartPublisherStartCapture:(DNVideoStreamingQuality)resolution;

/**
 * 切换前后置摄像头
 *
 * 此接口仅当用daniulive采集视频数据时设置
 *
 * <pre>必须在SmartPublisherStartCapture之后调用</pre>
 *
 * @return {0} if successful
 */
-(NSInteger)SmartPublisherSwitchCamera;

/*+++++++++++++++SmartPublisherStartPublish和SmartPublisherStopPublish系2016年之前接口，不建议使用+++++++++++++++*/
/**
 * 开始推流
 *
 * <pre>publisherURL：推流地址</pre>
 *
 * @return {0} if successful
 */
//- (NSInteger)SmartPublisherStartPublish:(NSString *)publisherURL;

/**
 * 停止推流
 *
 * @return {0} if successful
 */
//- (NSInteger)SmartPublisherStopPublish;
/*---------------SmartPublisherStartPublish和SmartPublisherStopPublish系2016年之前接口，不建议使用---------------*/

/**
 * Start publish rtmp stream(启动推送RTMP流)
 *
 * @return {0} if successful
 */
- (NSInteger)SmartPublisherStartPublisher:(NSString*)publisherURL;

/**
 * Stop publish rtmp stream(停止推送RTMP流)
 *
 * @return {0} if successful
 */
- (NSInteger)SmartPublisherStopPublisher;

/*+++++++++++++++推送rtsp相关接口+++++++++++++++*/
/*
 * 设置推送rtsp传输方式
 *
 * @param transport_protocol: 1表示UDP传输rtp包; 2表示TCP传输rtp包. 默认是1, UDP传输. 传其他值SDK报错。
 *
 * @return {0} if successful
 */
- (NSInteger)SetPushRtspTransportProtocol:(NSInteger)transport_protocol;

/*
 * 设置推送RTSP的URL
 *
 * @param url: 推送的RTSP url
 *
 * @return {0} if successful
 */
- (NSInteger)SetPushRtspURL:(NSString*)url;

/*
 * 启动推送RTSP流
 *
 * @param reserve: 保留参数，传0
 *
 * @return {0} if successful
 */
- (NSInteger)StartPushRtsp:(NSInteger)reserve;

/*
 * 停止推送RTSP流
 *
 * @return {0} if successful
 */
- (NSInteger)StopPushRtsp;

/*---------------推送rtsp相关接口---------------*/

/**
 * Start recorder(开始录像)
 *
 * @return {0} if successful
 */
- (NSInteger)SmartPublisherStartRecorder;

/**
 * Stop recorder(停止录像)
 *
 * @return {0} if successful
 */
- (NSInteger)SmartPublisherStopRecorder;

/**
 * 停止采集音视频数据
 *
 * @return {0} if successful
 */
- (NSInteger)SmartPublisherStopCaputure;

/**
 * uninit推流SDK
 *
 * @return {0} if successful
 */
- (NSInteger)SmartPublisherUnInit;

/**
 *  获取当前sdk的版本号
 */
-(NSString*) SmartPublisherGetSDKVersionID;

/*+++++++++++++++内置轻量级RTSP服务SDK+++++++++++++++*/
/*
 * 设置rtsp的流名称
 *
 * stream_name: 流程名称，不能为空字符串，必须是英文
 * 这个作用是: 比如rtsp的url是:rtsp://192.168.0.111/test, test就是设置下去的stream_name
 *
 * @return {0} if successful
 */
- (NSInteger)SetRtspStreamName:(NSString*)stream_name;

/*
 * 给要发布的rtsp流设置rtsp server, 一个流可以发布到多个rtsp server上，rtsp server的创建启动请参考OpenRtspServer和StartRtspServer接口
 *
 * handle: 推送实例句柄
 *
 * rtsp_server_handle：rtsp server句柄
 *
 * reserve： 保留参数，传0
 *
 * @return {0} if successful
 */
- (NSInteger)AddRtspStreamServer:(void*)rtsp_server_handle reserve:(NSInteger)reserve;

/*
 * 清除设置的rtsp server
 *
 * @return {0} if successful
 */
- (NSInteger)ClearRtspStreamServer;

/*
 * 启动rtsp流
 *
 * reserve: 保留参数，传0
 *
 * @return {0} if successful
 */
- (NSInteger)StartRtspStream:(NSInteger)reserve;

/*
 * 停止rtsp流
 *
 * @return {0} if successful
 */
-(NSInteger)StopRtspStream;
/*---------------内置轻量级RTSP服务SDK---------------*/

@end

@protocol SmartPublisherDelegate <NSObject>

/**
 * Event callback handling.
 */

- (NSInteger) handleSmartPublisherEvent:(NSInteger)nID param1:(unsigned long long)param1 param2:(unsigned long long)param2 param3:(NSString*)param3 param4:(NSString*)param4 pObj:(void *)pObj;

@end

