/*
 * SmartPublisherJniV2.java
 * SmartPublisherJniV2
 * 
 * Github: https://github.com/daniulive/SmarterStreaming
 * 
 * Created by DaniuLive on 2015/09/20.
 * Copyright © 2014~2016 DaniuLive. All rights reserved.
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
	 * Open publisher.
	 *
	 * @param ctx: get by this.getApplicationContext()
	 * 
	 * @param audio_opt: if with 0: it does not publish audio; if with 1, it publish audio; if with 2, it publish external encoded audio, only support aac.
	 * 
	 * @param video_opt: if with 0: it does not publish video; if with 1, it publish video; if with 2, it publish external encoded video, only support h264, data:0000000167....
	 * 
	 * @param width: capture width; height: capture height.
	 *
	 * <pre>This function must be called firstly.</pre>
	 *
	 * @return {0} if successful
	 */
    public native long SmartPublisherOpen(Object ctx, int audio_opt, int video_opt,  int width, int height);
    
    
	 /**
	  * Set callbackv2 event
	  * 
	  * @param callback function
	  * 
	 * @return {0} if successful
	  */
    public native int SetSmartPublisherEventCallbackV2(long handle, NTSmartEventCallbackV2 callbackv2);
    
	 /**
	  * Set Video HW Encoder, if support HW encoder, it will return 0
	  * 
	  * @param kbps: the kbps of different resolution(25 fps).
	  * 
	  * @return {0} if successful
	  */
   public native int SetSmartPublisherVideoHWEncoder(long handle, int kbps);
    
    /**
     * Set Text water-mark
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
     * Set Text water-mark font file name
     * @param fontFileName:  font full file name,  e.g: /system/fonts/DroidSansFallback.ttf
	 *
	 * @return {0} if successful
     */
    public native int SmartPublisherSetTextWatermarkFontFileName(long handle, String fontFileName);
	
    /**
     * Set picture water-mark
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
     * Set gop interval.
     *
     * <pre>please set before SmartPublisherStart while after SmartPublisherInit.</pre>
     *
     * gopInterval: encode I frame interval, the value always > 0
     *
     * @return {0} if successful
     */
    public native int SmartPublisherSetGopInterval(long handle, int gopInterval);
    
    /**
     * Set software encode video bit-rate.
     *
     * <pre>please set before SmartPublisherStart while after SmartPublisherInit.</pre>
     *
     * avgBitRate: average encode bit-rate(kbps)
     * 
     * maxBitRate: max encode bit-rate(kbps)
     *
     * @return {0} if successful
     */
    public native int SmartPublisherSetSWVideoBitRate(long handle, int avgBitRate, int maxBitRate);
    
    /**
     * Set fps.
     *
     * <pre>please set before SmartPublisherStart while after SmartPublisherInit.</pre>
     *
     * fps: the fps of video, range with (1,25).
     *
     * @return {0} if successful
     */
    public native int SmartPublisherSetFPS(long handle, int fps);
    
	/**
     * Set software video encoder profile.
     *
     * <pre>please set before SmartPublisherStart while after SmartPublisherInit.</pre>
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
     * 
     * Set software video encoder speed.
     * 
     * <pre>please set before SmartPublisherStart while after SmartPublisherInit.</pre>
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
     * <pre>please set before SmartPublisherStart while after SmartPublisherInit.</pre>
     *
     * @param mode: 0: 非裁剪模式 1:裁剪模式(如不设置, 默认裁剪模式)
     *
     * @return {0} if successful
     */
    public native int SmartPublisherSetClippingMode(long handle, int mode);
	
    /**
     * Set audio encoder type
     * 
     * @param type: if with 1:AAC, if with 2: SPEEX
     * 
     * @return {0} if successful
     */
    public native int SmartPublisherSetAudioCodecType(long handle, int type);
    
    /**
     * Set speex encoder quality
     * 
     * @param quality: range with (0, 10), default value is 8
     * 
     * @return {0} if successful
     */
    public native int SmartPublisherSetSpeexEncoderQuality(long handle, int quality);
    
    
    /**
     * Set Audio Noise Suppression
     * 
     * @param isNS: if with 1:suppress, if with 0: does not suppress
     * 
     * @return {0} if successful
     */
    public native int SmartPublisherSetNoiseSuppression(long handle, int isNS);
    
    
    /**
     * Set Audio AGC
     * 
     * @param isNS: if with 1:AGC, if with 0: does not AGC
     * 
     * @return {0} if successful
     */
    public native int SmartPublisherSetAGC(long handle, int isAGC);
    
    
    /**
     * Set Audio Echo Cancellation
     * 
     * @param isCancel: if with 1:Echo Cancellation, if with 0: does not cancel
     * @param delay: echo delay(ms), if with 0, SDK will automatically estimate the delay.
     * 
     * @return {0} if successful
     */
    public native int SmartPublisherSetEchoCancellation(long handle, int isCancel, int delay);
    
    
    /**
     * Set mute or not during publish stream
     * 
     * @param isMute: if with 1:mute, if with 0: does not mute
     * 
     * @return {0} if successful
     */
    public native int SmartPublisherSetMute(long handle, int isMute);
    
    /**
     * Set mirror
     * 
     * @param isMirror: if with 1:mirror mode, if with 0: normal mode
     * 
     * Please note when with "mirror mode", the publisher and player with the same echo direction
     * 
     * @return {0} if successful
     */
    public native int SmartPublisherSetMirror(long handle, int isMirror);
    
    /**
     * Set if recorder the stream to local file.
     * 
     * @param isRecorder: (0: do not recorder; 1: recorder)
     * 
     * <pre> NOTE: If set isRecorder with 1: Please make sure before call SmartPublisherStartPublish(), set a valid path via SmartPublisherCreateFileDirectory(). </pre> 
     * 
     * @return {0} if successful
     */
    public native int SmartPublisherSetRecorder(long handle, int isRecorder);
    
    /**
     * Create file directory
     * 
     * @param path,  E.g: /sdcard/daniulive/rec
     * 
     * <pre> The interface is only used for recording the stream data to local side. </pre> 
     * 
     * @return {0} if successful
     */
    public native int SmartPublisherCreateFileDirectory(String path);
    
    /**
     * Set recorder directory.
     * 
     * @param path: the directory of recorder file.
     * 
     * <pre> NOTE: make sure the path should be existed, or else the setting failed. </pre>
     * 
     * @return {0} if successful
     */
    public native int SmartPublisherSetRecorderDirectory(long handle, String path);
    
    /**
     * Set the size of every recorded file. 
     * 
     * @param size: (MB), (5M~500M), if not in this range, set default size with 200MB.
     * 
     * @return {0} if successful
     */
    public native int SmartPublisherSetRecorderFileMaxSize(long handle, int size);
    
	 /**
	  * Set if needs to save image during publishing stream
	  *
	  * @param is_save_image: if with 1, it will save current image via the interface of SmartPlayerSaveImage(), if with 0: does not it
	  *
	  * @return {0} if successful
	  */
	 public native int SmartPublisherSaveImageFlag(long handle,  int is_save_image);
		  
	 /**
	  * Save current image during publishing stream
	  *
	  * @param imageName: image name, which including fully path, "/sdcard/daniuliveimage/daniu.png", etc.
	  *
	  * @return {0} if successful
	  */
	 public native int SmartPublisherSaveCurImage(long handle,  String imageName);
    
    /**
     * Set rtmp PublishingType
     * 
     * @param type: 0:live, 1:record. please refer to rtmp specification Page 46
     * 
     * @return {0} if successful
     */
    public native int SetRtmpPublishingType(long handle,  int type);
        
    /**
	* Set publish stream url.
	* 
	* if not set url or url is empty, it will not publish stream
	*
	* @param url: publish url.
	*
	* @return {0} if successful
	*/
    public native int SmartPublisherSetURL(long handle,  String url);
    

		/**
	* Set live video data(no encoded data).
	*
	* @param cameraType: CAMERA_FACING_BACK with 0, CAMERA_FACING_FRONT with 1
	* 
	* @param curOrg: LANDSCAPE with 0, PORTRAIT 1
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
	* Start publish stream 
	*
	* @return {0} if successful
	*/
    public native int SmartPublisherStartPublisher(long handle);
    
    /**
   	* Stop publish stream 
   	*
   	* @return {0} if successful
   	*/
    public native int SmartPublisherStopPublisher(long handle);
    
    /**
	* Start recorder
	*
	* @return {0} if successful
	*/
    public native int SmartPublisherStartRecorder(long handle);
    
    /**
   	* Stop recorder 
   	*
   	* @return {0} if successful
   	*/
    public native int SmartPublisherStopRecorder(long handle);
    
       
    /**
     * 结束时必须调用close接口释放资源
     * @param handle
     * @return
     */
    public native int SmartPublisherClose(long handle);
    
}
