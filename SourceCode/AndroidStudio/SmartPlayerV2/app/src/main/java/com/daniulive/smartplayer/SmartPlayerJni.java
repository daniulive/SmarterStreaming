/*
 * SmartPlayerJni.java
 * SmartPlayerJni
 * 
 * Github: https://github.com/daniulive/SmarterStreaming
 * 
 * Created by DaniuLive on 2015/09/26.
 * Copyright ? 2014~2016 DaniuLive. All rights reserved.
 */

package com.daniulive.smartplayer;

import com.eventhandle.SmartEventCallback;

public class SmartPlayerJni {	
	 /**
	 * Initialize Player.
	 *
	 * @param ctx: get by this.getApplicationContext()
	 *
	 * <pre>This function must be called firstly.</pre>
	 *
	 * @return player handle if successful, if return 0, which means init failed. 
	 */
	 
	 public native long SmartPlayerInit(Object ctx);
	  	
	 /**
	  * Set callback event
	  * 
	  * @param callback function
	  * 
	  * @return {0} if successful
	  */
	 public native int SetSmartPlayerEventCallback(long handle, SmartEventCallback callback);
	 
	 /**
	  * Set Video HW decoder, if support HW decoder, it will return 0
	  * 
	  * @param isHWDecoder: 0: software decoder; 1: hardware decoder.
	  * 
	  * @return {0} if successful
	  */
	 public native int SetSmartPlayerVideoHWDecoder(long handle, int isHWDecoder);
	 
	 /**
	 * Set Surface view.
	 *
	 * @param handle: return value from SmartPlayerInit()
	 *
	 * @param glSurface: surface view
	 * 
	 * <pre> NOTE: if not set or set surface with null, it will playback audio only. </pre> 
	 *
	 * @return {0} if successful
	 */
	 public native int SmartPlayerSetSurface(long handle, Object surface);
	
	 
	 /**
	 * Set External Render.
     *
	 * @param handle: return value from SmartPlayerInit()
	 *
	 * @param external_render:  External Render
	 * 
	 * @return {0} if successful
	 */
	 public native int SmartPlayerSetExternalRender(long handle, Object external_render);
 
	 /**
	 * Set External Audio Output.
     *
	 * @param handle: return value from SmartPlayerInit()
	 *
	 * @param external_audio_output:  External Audio Output
	 * 
	 * @return {0} if successful
	 */
	 public native int SmartPlayerSetExternalAudioOutput(long handle, Object external_audio_output);

	 /**
	  * Set AudioOutput Type
	  * 
	  * @param handle: return value from SmartPlayerInit()
	  * 
	  * @param use_audiotrack: 
	  * 
	  * <pre> NOTE: if use_audiotrack with 0: it will use auto-select output devices; if with 1: will use audiotrack mode. </pre> 
	  * 
	 * @return {0} if successful
	  */
	 public native int SmartPlayerSetAudioOutputType(long handle, int use_audiotrack);	
	 
	 
	 /**
	  * Set buffer
	  * 
	  * @param handle: return value from SmartPlayerInit()
	  * 
	  * @param buffer: 
	  * 
	  * <pre> NOTE: Unit is millisecond, range is 200-5000 ms </pre> 
	  * 
	 * @return {0} if successful
	  */
	 public native int SmartPlayerSetBuffer(long handle, int buffer);
	 
	 
	 /**
	  * Set mute or not
	  * 
	  * @param is_mute: if with 1:mute, if with 0: does not mute
	  * 
	  * @return {0} if successful
	  */
	 public native int SmartPlayerSetMute(long handle, int is_mute);
	 
	 
	 /**
	  * It's only used when playback RTSP stream
	  *
	  * Default with UDP mode
	  *
	  * @param isUsingTCP: if with 1, it will via TCP mode, while 0 with UDP mode
	  *
	  * @return {0} if successful
	  */
	 public native int SmartPlayerSetRTSPTcpMode(long handle, int is_using_tcp);
	 
	 

	 /**
	  * Set fast startup
	  *
	  * @param is_fast_startup: if with 1, it will second play back, if with 0: does not it
	  *
	  * @return {0} if successful
	  */
	 public native int SmartPlayerSetFastStartup(long handle, int is_fast_startup);
	 
	 
	 
	 /**
	  * Set low latency mode
	  *
	  * @param mode: if with 1, low latency mode, if with 0: normal mode
	  *
	  * @return {0} if successful
	  */
	 public native int SmartPlayerSetLowLatencyMode(long handle, int mode);
	 
	 
	 /**
	  * ???????????, ??????0????? ?????????????????????
	  * @param handle
	  * @param degress?? ?????? 0???90??, 180??, 270?? ???
	  * @return
	  */
	 public native int SmartPlayerSetRotation(long handle, int degress);
	 	 
	 
	 /**
	  * Set report download speed
	  * 
	  * @param handle
	  * @param is_report: if with 1, it will report download speed, it with 0: does not it.
	  * @param report_interval: report interval, unit is second, it must be greater than 0.
	  * @return
	  */
	 public native int SmartPlayerSetReportDownloadSpeed(long handle, int is_report, int report_interval );
	  	  	
	 /**
	 * Set playback orientation.
	 *
	 * @param handle: return value from SmartPlayerInit()
	 * 
	 * @param surOrg: current orientation,  PORTRAIT 1, LANDSCAPE with 2
	 *
	 * @return {0} if successful
	 */
	 public native int SmartPlayerSetOrientation(long handle, int surOrg);
	 
	 /**
	  * Set if needs to save image during playback stream
	  *
	  * @param handle: return value from SmartPlayerInit()
	  *
	  * @param is_save_image: if with 1, it will save current image via the interface of SmartPlayerSaveCurImage(), if with 0: does not it
	  *
	  * @return {0} if successful
	  */
	 public native int SmartPlayerSaveImageFlag(long handle, int is_save_image);
		  
	 /**
	  * Save current image during playback stream
	  *
	  * @param handle: return value from SmartPlayerInit()
	  *
	  * @param imageName: image name, which including fully path, "/sdcard/daniuliveimage/daniu.png", etc.
	  *
	  * @return {0} if successful
	  */
	 public native int SmartPlayerSaveCurImage(long handle, String imageName);
	 
	 /**
	 * Start playback stream
	 *
	 * @param handle: return value from SmartPlayerInit()
	 * 
	 * @param uri: playback uri
	 *
	 * @return {0} if successful
	 */
	 public native int SmartPlayerStartPlayback(long handle, String uri);
	 
	 /**
	 * Switch playback url
	 *
	 * @param handle: return value from SmartPlayerInit()
	 * 
	 * @param uri: the new playback uri
	 *
	 * @return {0} if successful
	 */
	 public native int SmartPlayerSwitchPlaybackUrl(long handle, String uri);
		  	
	 /**
	 * Close player instance.
	 *
	 * @param handle: return value from SmartPlayerInit()
	 * 
	 * <pre> NOTE: it could not use player handle after call this function. </pre> 
	 *
	 * @return {0} if successful
	 */
	 public native int SmartPlayerClose(long handle);
}
