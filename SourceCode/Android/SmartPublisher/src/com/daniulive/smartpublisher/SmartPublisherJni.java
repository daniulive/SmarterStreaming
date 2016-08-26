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
	 * @param audio_opt: if with 0: it does not publish audio; if with 1, it publish audio
	 * 
	 * @param video_opt: if with 0: it does not publish video; if with 1, it publish video
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
     * <pre> The interface is only used for recording the stream data to local side. </pre> 
     * 
     * @param path,  E.g: /sdcard/daniulive/rec
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
	* set publish stream url.
	* if not set url or url is empty, it will not publish stream
	*
	* @param url: publish url.
	*
	* @return {0} if successful
	*/
    public native int SmartPublisherSetURL(String url);
    
	/**
	* 
	* start
	*
	* @return {0} if successful
	*/
    public native int SmartPublisherStart();
	
	/**
	* set live video data.
	*
	* @param cameraType: CAMERA_FACING_BACK with 0, CAMERA_FACING_FRONT with 1
	* 
	* @param curOrg: LANDSCAPE with 0, PORTRAIT 1
	*
	* @return {0} if successful
	*/
    public native int SmartPublisherOnCaptureVideoData(byte[] data, int len, int cameraType, int curOrg);
	
    
	/**
	 * Stop
	 *
	 * @return {0} if successful
	 */
    public native int SmartPublisherStop();
    
   
}
