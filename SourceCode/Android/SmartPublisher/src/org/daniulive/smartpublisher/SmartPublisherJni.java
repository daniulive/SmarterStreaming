/*
 * SmartPublisherJni.java
 * SmartPublisherJni
 * 
 * Created by DaniuLive on 2015/09/20.
 * Copyright 漏 2014~2016 DaniuLive. All rights reserved.
 */
package org.daniulive.smartpublisher;

import java.nio.ByteBuffer;

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
     * @param path,  E.g: /sdcard/daniulive/rec
     * @return {0} if successful
     */
    public native int SmartPublisherCreateFileDirectory(String path);
    
    /**
     * 设置是否录像
     * @param isRecoder, 1:表示录像， 0：表示不录像. 默认不录像. 如果设置为1,在调用SmartPublisherStartPublish之前必须调用SmartPublisherSetRecoderDirectory, 设置一个有效的目录
     * @return {0} if successful
     */
    public native int SmartPublisherSetRecoder(int isRecoder);
    
    /**
     * 设置录像目录
     * @param path, 录像文件存放目录，这个目录必须已经存在，如果不存在，则设置失败
     * @return {0} if successful
     */
    public native int SmartPublisherSetRecoderDirectory(String path);
    
    /**
     * 设置单个录像文件最大文件大小。
     *@param size, 单位是MB，最小5MB，最大500MB，如果超过范围则设置失败，默认是200MB
     * @return {0} if successful
     */
    public native int SmartPublisherSetRecoderFileMaxSize(int size);
    
    
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
