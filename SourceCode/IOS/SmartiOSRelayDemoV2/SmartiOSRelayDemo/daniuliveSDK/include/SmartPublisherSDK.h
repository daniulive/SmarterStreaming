//
//  SmartPublisherSDK.h
//  SmartPublisherSDK
//
//  GitHub: https://github.com/daniulive/SmarterStreaming
//  website: http://www.daniulive.com
//
//  Created by daniulive on 16/3/24.
//  Copyright © 2015~2018 daniulive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "nt_event_define.h"

//设置delegate
@protocol SmartPublisherDelegate;

/**
 *  错误返回值
 */
/*
typedef enum DNErrorCode{
    DANIULIVE_RETURN_OK = 0,        //!< 返回OK
    DANIULIVE_RETURN_ERROR,         //!< 返回错误
    DANIULIVE_RETURN_SDK_EXPIRED    //!< SDK过期
}DNErrorCode;
*/

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
 * @param audio_opt:
 if with 0: 不推送音频
 if with 1: 推送SDK内部采集的音频
 if with 2: 推送外部编码后音频(目前支持AAC/PCMA/PCMU/SPEEX宽带)
 if with 3: 推送外部编码前音频数据(CMSampleBufferRef类型), 数据传递对应接口: SmartPublisherPostAudioSampleBuffer
 *
 * @param video_opt:
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
 * @param data 编码后的video数据
 *
 * @return {0} if successful
 */
-(NSInteger) SmartPublisherPostVideoSampleBuffer:(CMSampleBufferRef)data;

/**
 * 设置编码前音频CMSampleBufferRef数据
 *
 * @param data 编码后的audio数据
 *
 * @param inputType: 1: 麦克风 2: 应用程序音频
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
-(NSInteger) SmartPublisherSetRtmpPublishingType:(NSInteger)type;

/**
 * 设置video preview
 *
 * 此接口仅当用daniulive采集视频数据时设置，若视频源来自外部美颜（DN_BEAUTY_ADDITIONAL_BEAUTY）或外部第三方数据，无需调用
 *
 * @return {0} if successful
 */
-(NSInteger)SmartPublisherSetVideoPreview:(UIView*)preview;

/**
 * 开始采集音视频数据
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

/**
 * 开始推流
 *
 * <pre>publisherURL：推流地址</pre>
 *
 * @return {0} if successful
 */
- (NSInteger)SmartPublisherStartPublish:(NSString *)publisherURL;

/**
 * 停止推流
 *
 * @return {0} if successful
 */
- (NSInteger)SmartPublisherStopPublish;

/*********增加新的接口 ++ ***************/
/* 增加新接口是为了把推送和录像分离, 老的接口依然可用(SmartPublisherStartPublish, SmartPublisherStopPublish),
 * 但是不要老接口和新接口混着用，这样结果是未定义的
 */

/**
 * Start publish stream
 *
 * @return {0} if successful
 */
- (NSInteger)SmartPublisherStartPublisher:(NSString *)publisherURL;

/**
 * Stop publish stream
 *
 * @return {0} if successful
 */
- (NSInteger)SmartPublisherStopPublisher;

/**
 * Start recorder
 *
 * @return {0} if successful
 */
- (NSInteger)SmartPublisherStartRecorder;

/**
 * Stop recorder
 *
 * @return {0} if successful
 */
- (NSInteger)SmartPublisherStopRecorder;

/*********增加新的接口  -- ***************/

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

@end

@protocol SmartPublisherDelegate <NSObject>

/**
 * Event callback handling.
 */

- (NSInteger) handleSmartPublisherEvent:(NSInteger)nID param1:(unsigned long long)param1 param2:(unsigned long long)param2 param3:(NSString*)param3 param4:(NSString*)param4 pObj:(void *)pObj;

@end


