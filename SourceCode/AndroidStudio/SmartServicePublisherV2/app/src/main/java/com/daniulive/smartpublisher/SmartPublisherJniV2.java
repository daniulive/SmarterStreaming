/*
 * SmartPublisherJniV2.java
 * SmartPublisherJniV2
 *
 * WebSite: https://daniulive.com
 * Github: https://github.com/daniulive/SmarterStreaming
 * 
 * Created by DaniuLive on 2015/09/20.
 * Copyright © 2014~2019 DaniuLive. All rights reserved.
 */

package com.daniulive.smartpublisher;

import java.nio.ByteBuffer;

import com.eventhandle.NTSmartEventCallbackV2;

public class SmartPublisherJniV2 {
	
	public static class WATERMARK {
	   	public static final int WATERMARK_FONTSIZE_MEDIUM 			= 0;
	   	public static final int WATERMARK_FONTSIZE_SMALL 			= 1;
	   	public static final int WATERMARK_FONTSIZE_BIG	 			= 2;
	   	
	   	public static final int WATERMARK_POSITION_TOPLEFT 			= 0;
	   	public static final int WATERMARK_POSITION_TOPRIGHT			= 1;
	   	public static final int WATERMARK_POSITION_BOTTOMLEFT		= 2;
	   	public static final int WATERMARK_POSITION_BOTTOMRIGHT 		= 3;
	}
	
	/**
	 * Open publisher(启动推送实例)
	 *
	 * @param ctx: get by this.getApplicationContext()
	 * 
	 * @param audio_opt:
	 * if 0: 不推送音频
	 * if 1: 推送编码前音频(PCM)
	 * if 2: 推送编码后音频(aac/pcma/pcmu/speex).
	 * 
	 * @param video_opt:
	 * if 0: 不推送视频
	 * if 1: 推送编码前视频(YUV420SP/YUV420P/RGBA/ARGB)
	 * if 2: 推送编码后视频(H.264)
	 *
	 * @param width: capture width; height: capture height.
	 *
	 * <pre>This function must be called firstly.</pre>
	 *
	 * @return the handle of publisher instance
	 */
    public native long SmartPublisherOpen(Object ctx, int audio_opt, int video_opt,  int width, int height);

	 /**
	  * Set callback event(设置事件回调)
	  * 
	  * @param callbackv2: callback function
	  * 
	 * @return {0} if successful
	  */
    public native int SetSmartPublisherEventCallbackV2(long handle, NTSmartEventCallbackV2 callbackv2);
    
	 /**
	  * Set Video H.264 HW Encoder, if support HW encoder, it will return 0(设置H.264硬编码)
	  * 
	  * @param kbps: the kbps of different resolution(25 fps).
	  * 
	  * @return {0} if successful
	  */
   public native int SetSmartPublisherVideoHWEncoder(long handle, int kbps);

	/**
	 * Set Video H.265(hevc) hardware encoder, if support H.265(hevc) hardware encoder, it will return 0(设置H.265硬编码)
	 *
	 * @param kbps: the kbps of different resolution(25 fps).
	 *
	 * @return {0} if successful
	 */
	public native int SetSmartPublisherVideoHevcHWEncoder(long handle, int kbps);
    
    /**
     * Set Text water-mark(设置文字水印)
     * 
     * @param fontSize: it should be "MEDIUM", "SMALL", "BIG"
     * 
     * @param waterPostion: it should be "TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT".
     * 
     * @param xPading, yPading: the distance of the original picture.
     * 
     * <pre> The interface is only used for setting font water-mark when publishing stream. </pre>  
     * 
     * @return {0} if successful
     */
    public native int SmartPublisherSetTextWatermark(long handle, String waterText, int isAppendTime, int fontSize, int waterPostion, int xPading, int yPading);
    
    
    /**
     * Set Text water-mark font file name(设置文字水印字体路径)
	 *
     * @param fontFileName:  font full file name, e.g: /system/fonts/DroidSansFallback.ttf
	 *
	 * @return {0} if successful
     */
    public native int SmartPublisherSetTextWatermarkFontFileName(long handle, String fontFileName);
	
    /**
     * Set picture water-mark(设置png图片水印)
     * 											
     * @param picPath: the picture working path, e.g: /sdcard/logo.png
     * 
     * @param waterPostion: it should be "TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT".
     * 
     * @param picWidth, picHeight: picture width & height
     * 
     * @param xPading, yPading: the distance of the original picture.
     * 
     * <pre> The interface is only used for setting picture(logo) water-mark when publishing stream, with "*.png" format </pre>  
     * 
     * @return {0} if successful
     */
    public native int SmartPublisherSetPictureWatermark(long handle, String picPath, int waterPostion, int picWidth, int picHeight, int xPading, int yPading);

	/**
	 * Set software encode vbr mode(软编码可变码率).
	 *
	 * <pre>please set before SmartPublisherStart while after SmartPublisherOpen.</pre>
	 *
	 * is_enable_vbr: if 0: NOT enable vbr mode, 1: enable vbr
	 *
	 * video_quality: vbr video quality, range with (1,50), default 23
	 *
	 * vbr_max_kbitrate: vbr max encode bit-rate(kbps)
	 *
	 * @return {0} if successful
	 */
	public native int SmartPublisherSetSwVBRMode(long handle, int is_enable_vbr, int video_quality, int vbr_max_kbitrate);

    /**
     * Set gop interval(设置I帧间隔)
     *
     * <pre>please set before SmartPublisherStart while after SmartPublisherOpen.</pre>
     *
     * gopInterval: encode I frame interval, the value always > 0
     *
     * @return {0} if successful
     */
    public native int SmartPublisherSetGopInterval(long handle, int gopInterval);
    
    /**
     * Set software encode video bit-rate(设置视频软编码bit-rate)
     *
     * <pre>please set before SmartPublisherStart while after SmartPublisherOpen.</pre>
     *
     * avgBitRate: average encode bit-rate(kbps)
     * 
     * maxBitRate: max encode bit-rate(kbps)
     *
     * @return {0} if successful
     */
    public native int SmartPublisherSetSWVideoBitRate(long handle, int avgBitRate, int maxBitRate);
    
    /**
     * Set fps(设置帧率)
     *
     * <pre>please set before SmartPublisherStart while after SmartPublisherOpen.</pre>
     *
     * fps: the fps of video, range with (1,25).
     *
     * @return {0} if successful
     */
    public native int SmartPublisherSetFPS(long handle, int fps);
    
	/**
     * Set software video encoder profile(设置视频编码profile).
     *
     * <pre>please set before SmartPublisherStart while after SmartPublisherOpen.</pre>
     *
     * profile: the software video encoder profile, range with (1,3).
     * 
     * 1: baseline profile
     * 2: main profile
     * 3: high profile
     *
     * @return {0} if successful
     */
    public native int SmartPublisherSetSWVideoEncoderProfile(long handle, int profile);
    
    
    /**
     * Set software video encoder speed(设置视频软编码编码速度)
     * 
     * <pre>please set before SmartPublisherStart while after SmartPublisherOpen.</pre>
     * 
     * @param speed: range with(1, 6), the default speed is 6. 
     * 
     * if with 1, CPU is lowest.
     * if with 6, CPU is highest.
     * 
     * @return {0} if successful
     */
    public native int SmartPublisherSetSWVideoEncoderSpeed(long handle, int speed);
	
     /**
     * Set Clipping Mode: 设置裁剪模式(仅用于640*480分辨率, 裁剪主要用于移动端宽高适配)
     *
     * <pre>please set before SmartPublisherStart while after SmartPublisherOpen.</pre>
     *
     * @param mode: 0: 非裁剪模式 1:裁剪模式(如不设置, 默认裁剪模式)
     *
     * @return {0} if successful
     */
    public native int SmartPublisherSetClippingMode(long handle, int mode);
	
    /**
     * Set audio encoder type(设置音频编码类型)
     * 
     * @param type: if with 1:AAC, if with 2: SPEEX
     * 
     * @return {0} if successful
     */
    public native int SmartPublisherSetAudioCodecType(long handle, int type);
    
    /**
     * Set speex encoder quality(设置speex编码质量)
     * 
     * @param quality: range with (0, 10), default value is 8
     * 
     * @return {0} if successful
     */
    public native int SmartPublisherSetSpeexEncoderQuality(long handle, int quality);
    
    
    /**
     * Set Audio Noise Suppression(设置音频噪音抑制)
     * 
     * @param isNS: if with 1:suppress, if with 0: does not suppress
     * 
     * @return {0} if successful
     */
    public native int SmartPublisherSetNoiseSuppression(long handle, int isNS);
    
    
    /**
     * Set Audio AGC(设置音频自动增益控制)
     * 
     * @param isAGC: if with 1:AGC, if with 0: does not AGC
     * 
     * @return {0} if successful
     */
    public native int SmartPublisherSetAGC(long handle, int isAGC);
    
    
    /**
     * Set Audio Echo Cancellation(设置音频回音消除)
     * 
     * @param isCancel: if with 1:Echo Cancellation, if with 0: does not cancel
	 *
     * @param delay: echo delay(ms), if with 0, SDK will automatically estimate the delay.
     * 
     * @return {0} if successful
     */
    public native int SmartPublisherSetEchoCancellation(long handle, int isCancel, int delay);
    
    
    /**
     * Set mute or not during publish stream(设置实时静音)
     * 
     * @param isMute: if with 1:mute, if with 0: does not mute
     * 
     * @return {0} if successful
     */
    public native int SmartPublisherSetMute(long handle, int isMute);
    
    /**
     * Set mirror(设置前置摄像头镜像)
     * 
     * @param isMirror: if with 1:mirror mode, if with 0: normal mode
     * 
     * Please note when with "mirror mode", the publisher and player with the same echo direction
     * 
     * @return {0} if successful
     */
    public native int SmartPublisherSetMirror(long handle, int isMirror);
    
    /**
     * Set if recorder the stream to local file(设置是否启动录像)
     * 
     * @param isRecorder: 0: do not recorder; 1: recorder
     * 
     * @return {0} if successful
     */
    public native int SmartPublisherSetRecorder(long handle, int isRecorder);
    
    /**
     * Create file directory(创建录像存放目录)
     * 
     * @param path,  E.g: /sdcard/daniulive/rec
     * 
     * <pre> The interface is only used for recording the stream data to local side. </pre> 
     * 
     * @return {0} if successful
     */
    public native int SmartPublisherCreateFileDirectory(String path);
    
    /**
     * Set recorder directory(设置录像存放目录)
     * 
     * @param path: the directory of recorder file.
     * 
     * <pre> NOTE: make sure the path should be existed, or else the setting failed. </pre>
     * 
     * @return {0} if successful
     */
    public native int SmartPublisherSetRecorderDirectory(long handle, String path);
    
    /**
     * Set the size of every recorded file(设置单个录像文件大小，如超过最大文件大小，自动切换到下个文件录制)
     * 
     * @param size: (MB), (5M~500M), if not in this range, set default size with 200MB.
     * 
     * @return {0} if successful
     */
    public native int SmartPublisherSetRecorderFileMaxSize(long handle, int size);
    
	 /**
	  * Set if needs to save image during publishing stream(设置是否启用快照)
	  *
	  * @param is_save_image: if with 1, it will save current image via the interface of SmartPlayerSaveImage(), if with 0: does not it
	  *
	  * @return {0} if successful
	  */
	 public native int SmartPublisherSaveImageFlag(long handle,  int is_save_image);
		  
	 /**
	  * Save current image during publishing stream(实时快照)
	  *
	  * @param imageName: image name, which including fully path, "/sdcard/daniuliveimage/daniu.png", etc.
	  *
	  * @return {0} if successful
	  */
	 public native int SmartPublisherSaveCurImage(long handle,  String imageName);
    
    /**
     * Set rtmp publish type(设置RTMP推送类型 live|record)
     * 
     * @param type: 0:live, 1:record. please refer to rtmp specification Page 46
     * 
     * @return {0} if successful
     */
    public native int SetRtmpPublishingType(long handle,  int type);
        
    /**
	* Set rtmp publish stream url(设置推送的RTMP url)
	*
	* @param url: rtmp publish url.
	*
	* @return {0} if successful
	*/
    public native int SmartPublisherSetURL(long handle,  String url);
    

    /**
	* Set live video data(no encoded data).
	*
	* @param cameraType: CAMERA_FACING_BACK with 0, CAMERA_FACING_FRONT with 1
	* 
	* @param curOrg:
		 * PORTRAIT = 1;	//竖屏
		 * LANDSCAPE = 2;	//横屏 home键在右边的情况
		 * LANDSCAPE_LEFT_HOME_KEY = 3; //横屏 home键在左边的情况
	*
	* @return {0} if successful
	*/
    public native int SmartPublisherOnCaptureVideoData(long handle, byte[] data, int len, int cameraType, int curOrg);
    
    /**
	* Set live video data(no encoded data).
	*
	* @param data: I420 data
	* 
	* @param len: I420 data length
	* 
	* @param yStride: y stride
	* 
	* @param uStride: u stride
	* 
	* @param vStride: v stride
	*
	* @return {0} if successful
	*/
    public native int SmartPublisherOnCaptureVideoI420Data(long handle,  byte[] data, int len, int yStride, int uStride, int vStride);
    
    
    /**
	* Set live video data(no encoded data).
	*
	* @param data: RGBA data
	* 
	* @param rowStride: stride information
	* 
	* @param width: width
	* 
	* @param height: height
	*
	* @return {0} if successful
	*/
    public native int SmartPublisherOnCaptureVideoRGBAData(long handle,  ByteBuffer data, int rowStride, int width, int height);
	
	/**
	 * Set live video data(no encoded data).
	 *
	 * @param data: ABGR flip vertical(垂直翻转) data
	 *
	 * @param rowStride: stride information
	 *
	 * @param width: width
	 *
	 * @param height: height
	 *
	 * @return {0} if successful
	 */
	public native int SmartPublisherOnCaptureVideoABGRFlipVerticalData(long handle,  ByteBuffer data, int rowStride, int width, int height);


	/**
	 * Set live video data(no encoded data).
	 *
	 * @param data: RGB565 data
	 *
	 * @param row_stride: stride information
	 *
	 * @param width: width
	 *
	 * @param height: height
	 *
	 * @return {0} if successful
	 */
	public native int SmartPublisherOnCaptureVideoRGB565Data(long handle,ByteBuffer data, int row_stride, int width, int height);

	
	/**
	 * 传递PCM音频数据给SDK, 每10ms音频数据传入一次
	 * 
	 *  @param pcmdata: pcm数据
	 *  @param size: pcm数据大小
	 *  @param sampleRate: 采样率，当前只支持44100
	 *  @param channel: 通道, 当前通道只支持1
	 *  @param per_channel_sample_number: 这个请传入的是 sampleRate/100
	 */
	public native int SmartPublisherOnPCMData(long handle, ByteBuffer pcmdata, int size, int sampleRate, int channel, int per_channel_sample_number);		

	/**
	 * Set far end pcm data
	 * 
	 * @param pcmdata : 16bit pcm data
	 * @param sampleRate: audio sample rate
	 * @param channel: auido channel
	 * @param per_channel_sample_number: per channel sample numbers
	 * @param is_low_latency: if with 0, it is not low_latency, if with 1, it is low_latency
	 * @return {0} if successful
	 */
	public native int SmartPublisherOnFarEndPCMData(long handle,  ByteBuffer pcmdata, int sampleRate, int channel, int per_channel_sample_number, int is_low_latency);

	/**
	 * 设置编码后视频数据(H.264)
	 *
	 * @param codec_id, H.264对应 1
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
	public native int SmartPublisherPostVideoEncodedData(long handle, int codec_id, ByteBuffer data, int size, int is_key_frame, long timestamp, long pts);

	/**
	 * 设置编码后视频数据(H.264)
	 *
	 * @param codec_id, H.264对应 1
	 *
	 * @param data 编码后的video数据
	 *
	 *@param offset data的偏移
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
	public native int SmartPublisherPostVideoEncodedDataV2(long handle, int codec_id,
														   ByteBuffer data, int offset, int size,
														   int is_key_frame, long timestamp, long pts,
														   byte[] sps, int sps_len,
														   byte[] pps, int pps_len);

	/**
	 * 设置音频数据(AAC/PCMA/PCMU/SPEEX)
	 *
	 * @param codec_id:
	 *
	 *  NT_MEDIA_CODEC_ID_AUDIO_BASE = 0x10000,
	 *	NT_MEDIA_CODEC_ID_PCMA = NT_MEDIA_CODEC_ID_AUDIO_BASE,
	 *	NT_MEDIA_CODEC_ID_PCMU,
	 *	NT_MEDIA_CODEC_ID_AAC,
	 *	NT_MEDIA_CODEC_ID_SPEEX,
	 *	NT_MEDIA_CODEC_ID_SPEEX_NB,
	 *	NT_MEDIA_CODEC_ID_SPEEX_WB,
	 *	NT_MEDIA_CODEC_ID_SPEEX_UWB,
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
	public native int SmartPublisherPostAudioEncodedData(long handle, int codec_id, ByteBuffer data, int size, int is_key_frame, long timestamp,ByteBuffer parameter_info, int parameter_info_size);

	/**
	 * 设置音频数据(AAC/PCMA/PCMU/SPEEX)
	 *
	 * @param codec_id:
	 *
	 *  NT_MEDIA_CODEC_ID_AUDIO_BASE = 0x10000,
	 *	NT_MEDIA_CODEC_ID_PCMA = NT_MEDIA_CODEC_ID_AUDIO_BASE,
	 *	NT_MEDIA_CODEC_ID_PCMU,
	 *	NT_MEDIA_CODEC_ID_AAC,
	 *	NT_MEDIA_CODEC_ID_SPEEX,
	 *	NT_MEDIA_CODEC_ID_SPEEX_NB,
	 *	NT_MEDIA_CODEC_ID_SPEEX_WB,
	 *	NT_MEDIA_CODEC_ID_SPEEX_UWB,
	 *
	 * @param data audio数据
	 *
	 * @param offset data的偏移
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
	public native int SmartPublisherPostAudioEncodedDataV2(long handle, int codec_id,
														   ByteBuffer data, int offset, int size,
														   int is_key_frame, long timestamp,
														   byte[] parameter_info, int parameter_info_size);

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
	 * @param max_size: 队列最大长度
	 *
	 * @param reserve: 保留字段
	 *
	 * NOTE: 1. 如果数据超过队列大小，将丢掉队头数据; 2. 这个接口请在 StartPublisher 之前调用
	 *
	 * @return {0} if successful
	 */
	public native int SmartPublisherSetPostUserDataQueueMaxSize(long handle, int max_size, int reserve);

	/**
	 * 清空用户数据队列, 有些情况可能会用到，比如发送队列里面有4条消息再等待发送,又想把最新的消息快速发出去, 可以先清除掉正在排队消息, 再调用PostUserXXX
	 *
	 * @return {0} if successful
	 */
	public native int SmartPublisherClearPostUserDataQueue(long handle);

	/**
	 * 发送二进制数据
	 *
	 * NOTE:
	 * 1.目前数据大小限制在256个字节以内，太大可能会影响视频传输，如果有特殊需求，需要增大限制，请联系我们
	 * 2. 如果积累的数据超过了设置的队列大小，之前的队头数据将被丢弃
	 * 3. 必须再调用StartPublisher之后再发送数据
	 *
	 * @param data: 二进制数据
	 *
	 * @param size: 数据大小
	 *
	 * @param reserve: 保留字段
	 *
	 * @return {0} if successful
	 */
	public native int SmartPublisherPostUserData(long handle, byte[] data, int size, int reserve);

	/**
	 * 发送utf8字符串
	 *
	 * NOTE:
	 * 1. 字符串长度不能超过256, 太大可能会影响视频传输，如果有特殊需求，需要增大限制，请联系我们
	 * 2. 如果积累的数据超过了设置的队列大小，之前的队头数据将被丢弃
	 * 3. 必须再调用StartPublisher之后再发送数据
	 *
	 * @param utf8_str: utf8字符串
	 *
	 * @param reserve: 保留字段
	 *
	 * @return {0} if successful
	 */
	public native int SmartPublisherPostUserUTF8StringData(long handle, String utf8_str, int reserve);

	/*----发送用户自定义数据相关接口----*/

	/**
	* Set encoded video data.
	*
	* @param buffer: encoded video data
	* 
	* @param len: data length
	* 
	* @param isKeyFrame: if with key frame, please set 1, otherwise, set 0.
	* 
	* @param timeStamp: video timestamp
	*
	* @return {0} if successful
	*/
    public native int SmartPublisherOnReceivingVideoEncodedData(long handle,  byte[] buffer, int len, int isKeyFrame, long timeStamp);

	/**
	* set audio specific configure.
	*
	* @param buffer: audio specific settings.
	* 
	* For example:
	* 
	* sample rate with 44100, channel: 2, profile: LC
	* 
	* audioConfig set as below:
	* 
	*	byte[] audioConfig = new byte[2];
	*	audioConfig[0] = 0x12;
	*	audioConfig[1] = 0x10;
	* 
	* @param len: buffer length
	*
	* @return {0} if successful
	*/
    public native int SmartPublisherSetAudioSpecificConfig(long handle,  byte[] buffer, int len);
    
	/**
	* Set encoded audio data.
	*
	* @param data: encoded audio data
	* 
	* @param len: data length
	* 
	* @param isKeyFrame: 1
	* 
	* @param timeStamp: audio timestamp
	*
	* @return {0} if successful
	*/
    public native int SmartPublisherOnReceivingAACData(long handle,  byte[] buffer, int len, int isKeyFrame, long timeStamp);

	/**
	 * Set Audio Encoded Data Callback.
	 *
	 * @param audio_encoded_data_callback: Audio Encoded Data Callback.
	 *
	 * @return {0} if successful
	 */
	public native int SmartPublisherSetAudioEncodedDataCallback(long handle, Object audio_encoded_data_callback);

	/**
	 * Set Video Encoded Data Callback.
	 *
	 * @param video_encoded_data_callback: Video Encoded Data Callback.
	 *
	 * @return {0} if successful
	 */
	public native int SmartPublisherSetVideoEncodedDataCallback(long handle, Object video_encoded_data_callback);

    /**
	 * Start publish rtmp stream(启动推送RTMP流)
	 *
	 * @return {0} if successful
	 */
    public native int SmartPublisherStartPublisher(long handle);
    
    /**
   	 * Stop publish rtmp stream(停止推送RTMP流)
   	 *
   	 * @return {0} if successful
   	 */
    public native int SmartPublisherStopPublisher(long handle);

    /*+++++++++++++++推送rtsp相关接口+++++++++++++++*/
    /*
     * 设置推送rtsp传输方式
     *
     * @param transport_protocol: 1表示UDP传输rtp包; 2表示TCP传输rtp包. 默认是1, UDP传输. 传其他值SDK报错。
     *
     * @return {0} if successful
     */
    public native int SetPushRtspTransportProtocol(long handle, int transport_protocol);

    /*
     * 设置推送RTSP的URL
     *
     * @param url: 推送的RTSP url
     *
     * @return {0} if successful
     */
    public native int SetPushRtspURL(long handle, String url);

    /*
     * 启动推送RTSP流
     *
     * @param reserve: 保留参数，传0
     *
     * @return {0} if successful
     */
    public native int StartPushRtsp(long handle, int reserve);

    /*
     * 停止推送RTSP流
     *
     * @return {0} if successful
     */
    public native int StopPushRtsp(long handle);

    /*---------------推送rtsp相关接口---------------*/

    /**
	* Start recorder(开始录像)
	*
	* @return {0} if successful
	*/
    public native int SmartPublisherStartRecorder(long handle);
    
    /**
   	* Stop recorder(停止录像)
   	*
   	* @return {0} if successful
   	*/
    public native int SmartPublisherStopRecorder(long handle);

	/**
	 * Start output Encoded Data(用于编码后的音视频数据回调)
	 *
	 * @return {0} if successful
	 */
	public native int SmartPublisherStartOutputEncodedData(long handle);

	/**
	 *  Stop output Encoded Data
	 *
	 * @return {0} if successful
	 */
	public native int SmartPublisherStopOutputEncodedData(long handle);

	/*+++++++++++++++内置轻量级RTSP服务SDK+++++++++++++++*/

	/*+++++++++++++++SmartRTSPServerSDK+++++++++++++++*/

	/*
	 * Init rtsp server(和UnInitRtspServer配对使用，即便是启动多个RTSP服务，也只需调用一次InitRtspServer，请确保在OpenRtspServer之前调用)
	 *
	 * @param ctx: get by this.getApplicationContext()
	 *
	 * @return {0} if successful
	 */
	public native int InitRtspServer(Object ctx);

	/*
	 * 创建一个rtsp server
	 *
   	 * @param reserve：保留参数传0
	 *
	 * @return rtsp server 句柄
	 */
	public native long OpenRtspServer(int reserve);

	/*
	 * 设置rtsp server 监听端口, 在StartRtspServer之前必须要设置端口
	 *
   	 * @param rtsp_server_handle: rtsp server 句柄
	 *
   	 * @param port: 端口号，可以设置为554,或者是1024到65535之间,其他值返回失败
	 *
	 * @return {0} if successful
	 */
	public native int SetRtspServerPort(long rtsp_server_handle, int port);

	/*
	 * 设置rtsp server 鉴权用户名和密码, 这个可以不设置，只有需要鉴权的再设置
	 *
   	 * @param rtsp_server_handle: rtsp server 句柄
	 *
   	 * @param user_name: 用户名(必须是英文)
	 * 
   	 * @param password：密码(必须是英文)
	 *
	 * @return {0} if successful
	 */
	public native int SetRtspServerUserNamePassword(long rtsp_server_handle, String user_name, String password);

	/*
	 * 设置rtsp server 组播, 如果server设置成组播就不能单播，组播和单播只能选一个, 一般来说单播网络设备支持的好，wifi组播很多路由器不支持
	 *
	 * @param rtsp_server_handle: rtsp server 句柄
	 *
	 * @param is_multicast: 是否组播, 1为组播, 0为单播, 其他值接口返回错误, 默认是单播
	 *
	 * @return {0} if successful
	 */
	public native int SetRtspServerMulticast(long rtsp_server_handle, int is_multicast);

	/*
	 * 设置rtsp server 组播组播地址
	 *
	 * @param rtsp_server_handle: rtsp server 句柄
	 *
	 * @param multicast_address: 组播地址
	 *
	 * 如果设置的不是组播地址, 将返回错误
	 * 组播地址范围说明: [224.0.0.0, 224.0.0.255] 为组播预留地址, 不能设置. 可设置范围为[224.0.1.0, 239.255.255.255], 其中SSM地址范围为[232.0.0.0, 232.255.255.255]
	 *
	 *  @return {0} if successful
	 */
	public native int SetRtspServerMulticastAddress(long rtsp_server_handle, String multicast_address);

	/*
	 * 获取rtsp server当前的客户会话数, 这个接口必须在StartRtspServer之后再调用
	 *
   	 * @param rtsp_server_handle: rtsp server 句柄
	 *
	 * @return {当前rtsp server会话数}
	 */
	public native int GetRtspServerClientSessionNumbers(long rtsp_server_handle);

	/*
	 * 启动rtsp server
	 *
   	 * @param rtsp_server_handle: rtsp server 句柄
	 *
   	 * @param reserve: 保留参数传0
	 *
	 * @return {0} if successful
	 */
	public native int StartRtspServer(long rtsp_server_handle, int reserve);

	/*
	 * 停止rtsp server
	 *
   	 * @param rtsp_server_handle: rtsp server 句柄
	 *
	 * @return {0} if successful
	 */
	public native int StopRtspServer(long rtsp_server_handle);

	/*
	 * 关闭rtsp server
	 *
	 * @param rtsp_server_handle: rtsp server 句柄
	 *
	 * NOTE: 调用这个接口之后rtsp_server_handle失效，
	 *
	 * @return {0} if successful
	 */
	public native int CloseRtspServer(long rtsp_server_handle);

	/*
	 * UnInit rtsp server(和InitRtspServer配对使用，即便是启动多个RTSP服务，也只需调用一次UnInitRtspServer)
	 *
	 * @return {0} if successful
	 */
	public native int UnInitRtspServer();
	/*---------------SmartRTSPServerSDK---------------*/

	/*+++++++++++++++SmartRTSPServerSDK供Publisher调用的接口+++++++++++++++*/
	/*
	 * 设置rtsp的流名称
	 *
	 * @param handle: 推送实例句柄
	 *
   	 * @param stream_name: 流程名称，不能为空字符串，必须是英文
	 *
	 * 这个作用是: 比如rtsp的url是:rtsp://192.168.0.111/test, test就是设置下去的stream_name
	 *
	 * @return {0} if successful
	 */
	public native int SetRtspStreamName(long handle, String stream_name);

	/*
	 * 给要发布的rtsp流设置rtsp server, 一个流可以发布到多个rtsp server上，rtsp server的创建启动请参考OpenRtspServer和StartRtspServer接口
	 *
   	 * @param handle: 推送实例句柄
	 *
   	 * @param rtsp_server_handle：rtsp server句柄
   	 *
	 * @param reserve：保留参数，传0
	 *
	 * @return {0} if successful
	 */
	public native int AddRtspStreamServer(long handle, long rtsp_server_handle, int reserve);

	/*
	 * 清除设置的rtsp server
	 *
	 * @param handle: 推送实例句柄
	 *
	 * @return {0} if successful
	 */
	public native int ClearRtspStreamServer(long handle);

	/*
	 * 启动rtsp流
	 *
	 * @param handle: 推送实例句柄
	 *
	 * @param reserve: 保留参数，传0
	 *
	 * @return {0} if successful
	 */
	public native int StartRtspStream(long handle, int reserve);

	/*
	 * 停止rtsp流
	 *
	 * @param handle: 推送实例句柄
	 *
	 * @return {0} if successful
	 */
	public native int StopRtspStream(long handle);
	/*---------------SmartRTSPServerSDK供Publisher调用的接口---------------*/

	/*---------------内置轻量级RTSP服务SDK---------------*/

    /**
     * 关闭推送实例，结束时必须调用close接口释放资源
	 *
	 * @return {0} if successful
	 */
    public native int SmartPublisherClose(long handle);
}
