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
	
	/**
	 * Initialized publisher.
	 *
	 * @param ctx: get by this.getApplicationContext()
	 * 
	 * @param isAudioOnly: if with 0: it means publish audio and video; if with 1, it means audio only.
	 * 
	 * @param width: capture width; height: capture height.
	 *
	 * <pre>This function must be called firstly.</pre>
	 *
	 * @return {0} if successful
	 */
    public native int SmartPublisherInit(Object ctx, int isAudioOnly, int width, int height);
	
	 /**
	  * Set callback event
	  * 
	  * @param callback function
	  * 
	 * @return {0} if successful
	  */
    public native int SetSmartPublisherEventCallback(SmartEventCallback callback);
	
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
