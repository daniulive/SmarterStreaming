package com.daniulive.smartplayer;

public class SmartPlayerJni {	
	 /**
	 * Initialized with width and height.
	 *
	 * @param ctx: get by this.getApplicationContext()
	 * @param width
	 * @param height
	 *
	 * <pre>This function must be called firstly.</pre>
	 *
	 * @return {0} if successful
	 */
	 
	 public static native int SmartPlayerInit(Object ctx, int width, int height);
	  	
	 /**
	 * Set Surface view.
	 *
	 * @param glSurface: surface view, 如果不设置glSurface的话，将只播放音频
	 *
	 * @return player handle if successful
	 */
	 public static native long SmartPlayerSetSurface(Object glSurface);
	 
	 
	 /**
	  * Set AudioOutput Type
	  * @param handle: return value from SmartPlayerSetSurface()
	  * @param use_audiotrack: use_audiotrack 设置为0,将自动选择输出设备, 设置为1的话，将使用AudioTrack.
	  * @return
	  */
	 public static native int SmartPlayerSetAudioOutputType(long handle, int use_audiotrack);	
	  	  	
	 /**
	 * Set playback orientation.
	 *
	 * @param handle: return value from SmartPlayerSetSurface()
	 * @param surOrg: current orientation,  PORTRAIT 1, LANDSCAPE with 2
	 *
	 * @return {0} if successful
	 */
	 public static native int SmartPlayerSetOrientation(long handle, int surOrg);
		  	
	 /**
	 * Start playback stream
	 *
	 * @param handle: return value from SmartPlayerSetSurface()
	 * @param uri: playback uri
	 *
	 * @return {0} if successful
	 */
	 public static native int SmartPlayerStartPlayback(long handle, String uri);
		  	
	 /**
	 * Close the player instance.
	 *
	 * @param handle: return value from SmartPlayerSetSurface()
	 *
	 * @return {0} if successful
	 */
	 public static native int SmartPlayerClose(long handle);
}
