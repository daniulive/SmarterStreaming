/*
 * SmartPublisherJni.java
 * SmartPublisherJni
 * 
 * Github: https://github.com/daniulive/SmarterStreaming
 * 
 * Created by DaniuLive on 2015/09/20.
 * Copyright © 2014~2016 DaniuLive. All rights reserved.
 */

package org.daniulive.smartpublisher;

public class SmartPublisherJni {
	
	/**
	 * Initialized publisher with width and height.
	 *
	 * <pre>This function must be called firstly.</pre>
	 *
	 * @return {0} if successful
	 */
    public native int SmartPublisherInit(int width, int height);
	
    /**
     * Create file directory
     * 
     * The interface is only used for recording the stream data to local side.
     * 
     * @param path,  E.g: /sdcard/daniulive/rec
     * @return {0} if successful
     */
    public native int SmartPublisherCreateFileDirectory(String path);
    
    /**
     * Set if recorder the stream to local file.
     * 
     * @param isRecorder: (0: do not recorder; 1: recorder)
     * @param If set isRecorder with 1: Please make sure before call "SmartPublisherStartPublish", set a valid path via "SmartPublisherCreateFileDirectory".
     * 
     * @return {0} if successful
     */
    public native int SmartPublisherSetRecorder(int isRecorder);
    
    /**
     * Set recorder directory.
     * @param path: the directory of recorder file, NOTE make sure the path should be existed, or else the setting failed.
     * 
     * @return {0} if successful
     */
    public native int SmartPublisherSetRecorderDirectory(String path);
    
    /**
     * Set the size of every recorded file. 
     * 
     * @param size: (MB), (5M~500M), if not in this range, set default size with 200MB.
     * @return {0} if successful
     */
    public native int SmartPublisherSetRecorderFileMaxSize(int size);
    
    
	/**
	* start to publish stream.
	*
	* @param url
	*
	* @return {0} if successful
	*/
    public native int SmartPublisherStartPublish(String url);
	
	/**
	* set live video data.
	*
	* @param cameraType: CAMERA_FACING_BACK with 0, CAMERA_FACING_FRONT with 1
	* @param curOrg: LANDSCAPE with 0, PORTRAIT 1
	*
	* @return {0} if successful
	*/
    public native int SmartPublisherOnCaptureVideoData(byte[] data, int len, int cameraType, int curOrg);
	
    
	/**
	 * Stop publisher.
	 *
	 * @return {0} if successful
	 */
    public native int SmartPublisherStopPublish();
}
