/*
 * SmartPublisherJni.java
 * SmartPublisherJni
 * 
 * Github: https://github.com/daniulive/SmarterStreaming
 * 
 * Created by DaniuLive on 2015/09/20.
 * Copyright © 2014~2016 DaniuLive. All rights reserved.
 */

package com.daniulive.smartpublisher;

import java.nio.ByteBuffer;

import com.eventhandle.SmartEventCallback;

public class SmartPublisherJni {
	
	static class WATERMARK {
	   	public static final int WATERMARK_FONTSIZE_MEDIUM 			= 0;
	   	public static final int WATERMARK_FONTSIZE_SMALL 			= 1;
	   	public static final int WATERMARK_FONTSIZE_BIG	 			= 2;
	   	
	   	public static final int WATERMARK_POSITION_TOPLEFT 			= 0;
	   	public static final int WATERMARK_POSITION_TOPRIGHT			= 1;
	   	public static final int WATERMARK_POSITION_BOTTOMLEFT		= 2;
	   	public static final int WATERMARK_POSITION_BOTTOMRIGHT 		= 3;
	}
	
	/**
	 * Initialized publisher.
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
    public native int SmartPublisherInit(Object ctx, int audio_opt, int video_opt,  int width, int height);
    
	 /**
	  * Set callback event
	  * 
	  * @param callback function
	  * 
	 * @return {0} if successful
	  */
    public native int SetSmartPublisherEventCallback(SmartEventCallback callback);
    
	 /**
	  * Set Video HW Encoder, if support HW encoder, it will return 0
	  * 
	  * @param kbps: the kbps of different resolution(25 fps).
	  * 
	  * @return {0} if successful
	  */
   public native int SetSmartPublisherVideoHWEncoder(int kbps);
    
    /**
     * Set Font water-mark
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
    public native int SmartPublisherSetFontWatermark(String waterText, int isAppendTime, int fontSize, int waterPostion, int xPading, int yPading);
	
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
    public native int SmartPublisherSetPictureWatermark(String picPath, int waterPostion, int picWidth, int picHeight, int xPading, int yPading);
    
    
    /**
     * Set mute or not during publish stream
     * 
     * @param isMute: if with 1:mute, if with 0: does not mute
     * 
     * @return {0} if successful
     */
    public native int SmartPublisherSetMute(int isMute);
    
    /**
     * Set if recorder the stream to local file.
     * 
     * @param isRecorder: (0: do not recorder; 1: recorder)
     * 
     * <pre> NOTE: If set isRecorder with 1: Please make sure before call SmartPublisherStartPublish(), set a valid path via SmartPublisherCreateFileDirectory(). </pre> 
     * 
     * @return {0} if successful
     */
    public native int SmartPublisherSetRecorder(int isRecorder);
    
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
    public native int SmartPublisherSetRecorderDirectory(String path);
    
    /**
     * Set the size of every recorded file. 
     * 
     * @param size: (MB), (5M~500M), if not in this range, set default size with 200MB.
     * 
     * @return {0} if successful
     */
    public native int SmartPublisherSetRecorderFileMaxSize(int size);
    
    /**
	* Set publish stream url.
	* 
	* if not set url or url is empty, it will not publish stream
	*
	* @param url: publish url.
	*
	* @return {0} if successful
	*/
    public native int SmartPublisherSetURL(String url);
    
	/**
	* Start publish stream
	*
	* @return {0} if successful
	*/
    public native int SmartPublisherStart();
	
	/**
	* Set live video data(no encoded data).
	*
	* @param cameraType: CAMERA_FACING_BACK with 0, CAMERA_FACING_FRONT with 1
	* 
	* @param curOrg: LANDSCAPE with 0, PORTRAIT 1
	*
	* @return {0} if successful
	*/
    public native int SmartPublisherOnCaptureVideoData(byte[] data, int len, int cameraType, int curOrg);
    
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
    public native int SmartPublisherOnCaptureVideoI420Data(byte[] data, int len, int yStride, int uStride, int vStride);
    
    
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
    public native int SmartPublisherOnCaptureVideoRGBAData(ByteBuffer data, int rowStride, int width, int height);
	
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
    public native int SmartPublisherOnReceivingVideoEncodedData(byte[] buffer, int len, int isKeyFrame, long timeStamp);
    

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
    public native int SmartPublisherSetAudioSpecificConfig(byte[] buffer, int len);
    
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
    public native int SmartPublisherOnReceivingAACData(byte[] buffer, int len, int isKeyFrame, long timeStamp);
    
	/**
	 * Stop publish stream
	 *
	 * @return {0} if successful
	 */
    public native int SmartPublisherStop();
    
   
}
