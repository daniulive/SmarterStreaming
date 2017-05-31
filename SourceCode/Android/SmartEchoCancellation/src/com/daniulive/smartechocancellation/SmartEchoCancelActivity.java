package com.daniulive.smartechocancellation;

import java.nio.ByteBuffer;
import java.io.ByteArrayOutputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.List;

import com.daniulive.smartplayer.SmartPlayerJni;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.res.Configuration;
import android.graphics.ImageFormat;
import android.graphics.PixelFormat;
import android.hardware.Camera;
import android.hardware.Camera.AutoFocusCallback;
import android.hardware.Camera.CameraInfo;
import android.hardware.Camera.Parameters;
import android.hardware.Camera.PreviewCallback;
import android.hardware.Camera.Size;
import android.os.Bundle;
import android.view.Surface;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.View;
import android.view.WindowManager;
import android.view.SurfaceHolder.Callback;
import android.view.View.OnClickListener;
import android.view.ViewGroup.LayoutParams;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.AdapterView.OnItemSelectedListener;
import android.util.Log;

import com.eventhandle.SmartEventCallback;
import com.eventhandle.SmartEventCallback.EVENTID;
import com.videoengine.NTRenderer;
import com.voiceengine.NTAudioRecord;
import com.voiceengine.NTExternalAudioOutput;
import com.daniulive.smartplayer.SmartPlayerJni;
import com.daniulive.smartpublisher.SmartPublisherJni;
import com.daniulive.smartpublisher.SmartPublisherJni.WATERMARK;;

public class SmartEchoCancelActivity extends Activity implements Callback, PreviewCallback 
{

		private static final String TAG = "SmartEchoCancel";
		private static final String PLAY_TAG = "SmartPlayer";
		private static String PUSH_TAG = "SmartPublisher";
		
		private static final int PORTRAIT = 1;		//竖屏
		private static final int LANDSCAPE = 2;		//横屏
	
		private SmartPlayerJni libPlayer = null;
	    private SurfaceView    playerSurfaceView = null;   
		private long           playerHandle = 0;
		
		private int            currentOrigentation = PORTRAIT;
		private int            currentPushOrigentation = PORTRAIT;
		
		private String         playbackUrl = null;
		private boolean        isPlaybackViewStarted = false;
		private boolean        isPlaybackMute = false;
		private boolean        isPlaybackHardwareDecoder = false;
		private boolean        isPlaybackFastStartup = true; // 是否秒开, 默认true
		private int            playbackBuffer = 200; // 默认200ms
		
		
		LinearLayout linearLayoutAll = null;
		LinearLayout playbackLayout = null;
		LinearLayout pushLayout = null;
		    
		FrameLayout  playFrameLayout = null;
		
		Button btnPlaybackPopInputUrl = null;
		Button btnPlaybackMute = null;;
	    Button btnPlaybackStartStopPlayback= null;
		Button btnPlaybackHardwareDecoder= null;
		Button btnPlaybackFastStartup= null;
		Button btnPlaybackSetPlayBuffer= null;
	    
		
		NTAudioRecord audioRecord_ = null;	//for audio capture
		
		private TextView textPushCurURL = null;
		
		private SmartPublisherJni libPublisher = null;
		
		/* 推送类型选择
		 * 0: 音视频
		 * 1: 纯音频
		 * 2: 纯视频
		 * */
		private Spinner pushTypeSelector;
		private int pushType = 0;
		
		/* 水印类型选择
		 * 0: 图片水印
		 * 1: 全部水印
		 * 2: 文字水印
		 * 3: 不加水印
		 * */
		private Spinner pushWatermarkSelctor;
		private int pushWatemarkType = 0;
		
		/* 推流分辨率选择
		 * 0: 640*480
		 * 1: 320*240
		 * 2: 176*144
		 * 3: 1280*720
		 * */
		private Spinner pushResolutionSelector;
		
		/* video软编码profile设置
	     * 1: baseline profile
	     * 2: main profile
	     * 3: high profile
		 * */
		private Spinner pushSWVideoEncoderProfileSelector;
		
		private int  push_sw_video_encoder_profile = 1;	//default with baseline profile

		private Spinner pushRecorderSelector;
		
		private Button  btnPushRecoderMgr;
		private Button  btnPushNoiseSuppression;
		private Button  btnPushAGC;
		private Button  btnPushSpeex;
		private Button  btnPushMute;
		private Button  btnPushMirror;
		private Button  btnPushEchoCancelDelay; 
		private Button	btnPushHWencoder;
		private ImageView imgPushSwitchCamera;
		private Button btnPushInputPushUrl;
		private Button btnPushStartStop;
		
		private SurfaceView  pushSurfaceView = null;  
	    private SurfaceHolder pushSurfaceHolder = null;  
	    
	    private Camera pushCamera = null;  
		private AutoFocusCallback pushAutoFocusCallback = null;
		
		private boolean pushPreviewRunning = false; 

		private boolean isPushStart = false;
		
		final private String pushLogoPath = "/sdcard/daniulivelogo.png";
		private boolean isPushWritelogoFileSuccess = false;
		
		private String publishURL;
		final private String basePushURL = "rtmp://player.daniulive.com:1935/hls/stream";
		private String inputPushURL ="";

		private String printPushText = "URL:";
		private String pushTxt = "当前状态";
			
		private static final int FRONT = 1;		//前置摄像头标记
		private static final int BACK = 2;		//后置摄像头标记
		private int pushCurrentCameraType = BACK;	//当前打开的摄像头标记

		private int pushCurCameraIndex = -1;
		private int pushVideoWidth     = 640;
		private int pushVideoHight     = 480;
		private int pushFrameCount     = 0;
		
		private int echoCancelDelay    = 0; //100ms
		
		private String pushRecDir = "/sdcard/daniulive/rec";	//for recorder path
		
		private boolean is_push_need_local_recorder = false;		// do not enable recorder in default
		private boolean is_push_noise_suppression = true; 
		private boolean is_push_agc = false;
		private boolean is_push_speex = false;
		private boolean is_push_mute = false;
		private boolean is_push_mirror = false;
		private boolean is_push_hardware_encoder = false;
	    
	    private Context curContext = null; 
	    
		static
		{  
			System.loadLibrary("SmartPlayer");
			System.loadLibrary("SmartPublisher");
		}
	
		
	private byte[] ReadAssetFileDataToByte(InputStream in) throws IOException
	{
		ByteArrayOutputStream bytestream = new ByteArrayOutputStream();
		int c = 0;
		        
		while ( (c = in.read()) != -1 )
		{
		 bytestream.write(c);
		}
		       
		        byte bytedata[] = bytestream.toByteArray();
		        bytestream.close();
		        return bytedata;
	}
		
	
	@Override
	protected void onCreate(Bundle savedInstanceState) 
	{
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_smart_echo_cancel);
		
		 getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON); 	//屏幕常亮
		
		 Log.i(TAG, "Run into OnCreate++");
	      
	     libPlayer    = new SmartPlayerJni();
	     libPublisher = new SmartPublisherJni();
	     
	     curContext = this.getApplicationContext();
	     
	     linearLayoutAll = (LinearLayout)findViewById(R.id.linear_layout_all);
	     
	     playbackLayout =  (LinearLayout)findViewById(R.id.linear_layout_player);
	     
	     pushLayout =  (LinearLayout)findViewById(R.id.linear_layout_push);

		 boolean bViewCreated = CreatePlayerSurfaceView();
		    
		 if( bViewCreated )
		 {
			  PlayInflateLayout(LinearLayout.VERTICAL);
		 }
		 
		 OnPushCreate();
	}
	

	private void OnPushCreate()
	{
		 Log.i(PUSH_TAG, "OnPushCreate..");
	        
	      try 
	        {
	        	
	         InputStream logo_input_stream = getClass().getResourceAsStream("/assets/logo.png");	
	         
	         byte[] logo_data = ReadAssetFileDataToByte(logo_input_stream);
	        
	         if ( logo_data != null )
	         {
	        	 try {  
	                 FileOutputStream out = new FileOutputStream(pushLogoPath);
	                 out.write(logo_data);
	                 out.close();                   
	                 isPushWritelogoFileSuccess = true;
	             } catch (Exception e) 
	        	 {  
	                 e.printStackTrace();  
	                 Log.e(PUSH_TAG, "write logo file to /sdcard/ failed");
	             }
	         }
	              
	        } catch(Exception e)
	        {
	        	  e.printStackTrace();  
	              Log.e(PUSH_TAG, "write logo file to /sdcard/ failed");
	        }
	          
	        //push type, audio/video/audio&video
	        pushTypeSelector = (Spinner)findViewById(R.id.push_type_selctor);
	        final String []types = new String[]{"音视频", "纯音频", "纯视频"};
	        ArrayAdapter<String> adapterType = new ArrayAdapter<String>(this,
	                android.R.layout.simple_spinner_item, types);
	        adapterType.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
	        pushTypeSelector.setAdapter(adapterType);

	        pushTypeSelector.setOnItemSelectedListener(new OnItemSelectedListener() {

				@Override
				public void onItemSelected(AdapterView<?> parent, View view,
						int position, long id) {
					
					if(isPushStart)
					{
						Log.e(PUSH_TAG, "Could not switch push type during publishing..");
						return;
					}
					
					pushType = position;
					
					Log.i(PUSH_TAG, "[推送类型]Currently choosing: " + types[position] + ", pushType: " + pushType);
				}

				@Override
				public void onNothingSelected(AdapterView<?> parent) {
					
				}
			});
	        //end
	        
	        //水印
	        pushWatermarkSelctor = (Spinner)findViewById(R.id.push_watermark_selctor);
	        
	        final String []watermarks = new String[]{"图片水印", "全部水印", "文字水印", "不加水印"};
	        
	        ArrayAdapter<String> adapterWatermark = new ArrayAdapter<String>(this,
	                android.R.layout.simple_spinner_item, watermarks);
	        
	        adapterWatermark.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
	        
	        pushWatermarkSelctor.setAdapter(adapterWatermark);

	        pushWatermarkSelctor.setOnItemSelectedListener(new OnItemSelectedListener() {

				@Override
				public void onItemSelected(AdapterView<?> parent, View view,
						int position, long id) {
					if(isPushStart)
					{
						Log.e(PUSH_TAG, "Could not switch water type during publishing..");
						return;
					}
					
					pushWatemarkType = position;
					
					Log.i(PUSH_TAG, "[水印类型]Currently choosing: " + watermarks[position] + ", watemarkType: " + pushWatemarkType);
				}

				@Override
				public void onNothingSelected(AdapterView<?> parent) {
					
				}
			});
	        //end
	        
	        pushResolutionSelector = (Spinner)findViewById(R.id.push_resolution_selctor);
	        final String []resolutionSel = new String[]{"高分辨率", "中分辨率", "低分辨率", "超高分辨率"};
	        ArrayAdapter<String> adapterResolution = new ArrayAdapter<String>(this,
	                android.R.layout.simple_spinner_item, resolutionSel);
	        adapterResolution.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
	        pushResolutionSelector.setAdapter(adapterResolution);

	        pushResolutionSelector.setOnItemSelectedListener(new OnItemSelectedListener() {

				@Override
				public void onItemSelected(AdapterView<?> parent, View view,
						int position, long id) {
					
					if(isPushStart)
					{
						Log.e(PUSH_TAG, "Could not switch resolution during publishing..");
						return;
					}
					
					Log.i(PUSH_TAG, "[推送分辨率]Currently choosing: " + resolutionSel[position]);
					
					SwitchPushResolution(position);
			
				}

				@Override
				public void onNothingSelected(AdapterView<?> parent) {
					
				}
			});
	        
	      
	        pushSWVideoEncoderProfileSelector = (Spinner)findViewById(R.id.push_sw_video_encoder_profile_selector);
	        final String []profileSel = new String[]{"BaseLineProfile", "MainProfile", "HighProfile"};
	        ArrayAdapter<String> adapterProfile = new ArrayAdapter<String>(this,
	                android.R.layout.simple_spinner_item, profileSel);
	        adapterProfile.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
	        pushSWVideoEncoderProfileSelector.setAdapter(adapterProfile);

	        pushSWVideoEncoderProfileSelector.setOnItemSelectedListener(new OnItemSelectedListener() {

				@Override
				public void onItemSelected(AdapterView<?> parent, View view,
						int position, long id) {
					
					if(isPushStart)
					{
						Log.e(PUSH_TAG, "Could not switch video profile during publishing..");
						return;
					}
					
					Log.i(PUSH_TAG, "[VideoProfile]Currently choosing: " + profileSel[position]);
					
					push_sw_video_encoder_profile = position + 1;		
				}

				@Override
				public void onNothingSelected(AdapterView<?> parent) {
					
				}
			});
	        
	        
	        //Recorder related settings
	        pushRecorderSelector = (Spinner)findViewById(R.id.push_recoder_selctor);
	        
	        final String []recoderSel = new String[]{"本地不录像", "本地录像"};
	        ArrayAdapter<String> adapterRecoder = new ArrayAdapter<String>(this,
	                android.R.layout.simple_spinner_item, recoderSel);
	        
	        adapterRecoder.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
	        pushRecorderSelector.setAdapter(adapterRecoder);
	        
	        pushRecorderSelector.setOnItemSelectedListener(new OnItemSelectedListener() {

				@Override
				public void onItemSelected(AdapterView<?> parent, View view,
						int position, long id) {
							
					Log.i(PUSH_TAG, "Currently choosing: " + recoderSel[position]);
					
					if ( 1 == position )
					{
						is_push_need_local_recorder = true;
					}
					else
					{
						is_push_need_local_recorder = false;
					}
				}

				@Override
				public void onNothingSelected(AdapterView<?> parent) {
					
				}
			});
	        
	        btnPushRecoderMgr = (Button)findViewById(R.id.btn_push_recoder_manage);
	        btnPushRecoderMgr.setOnClickListener(new ButtonPushRecorderMangerListener()); 
	        //end
	        
	        btnPushNoiseSuppression = (Button)findViewById(R.id.btn_push_noise_suppression);
	        btnPushNoiseSuppression.setOnClickListener(new ButtonPushNoiseSuppressionListener()); 
	        
	        btnPushAGC = (Button)findViewById(R.id.btn_push_agc);
	        btnPushAGC.setOnClickListener(new ButtonPushAGCListener());
	        
	        btnPushSpeex = (Button)findViewById(R.id.btn_push_speex);
	        btnPushSpeex.setOnClickListener(new ButtonPushSpeexListener());
	        
	        btnPushMute = (Button)findViewById(R.id.btn_push_mute);
	        btnPushMute.setOnClickListener(new ButtonPushMuteListener());
	        
	        btnPushMirror = (Button)findViewById(R.id.btn_push_mirror);
	        btnPushMirror.setOnClickListener(new ButtonPushMirrorListener());
	        
	        btnPushEchoCancelDelay = (Button)findViewById(R.id.btn_push_echo_cancel_delay);
	        btnPushEchoCancelDelay.setOnClickListener(new ButtonPushEchoCancelDelayListener());
	        
	        btnPushHWencoder = (Button)findViewById(R.id.btn_push_hwencoder);
	        btnPushHWencoder.setOnClickListener(new ButtonPushHardwareEncoderListener());
	        
	        textPushCurURL = (TextView)findViewById(R.id.txt_push_cur_url);
	        textPushCurURL.setText(printPushText);
	        
	        btnPushInputPushUrl =(Button)findViewById(R.id.btn_push_input_push_url);
	        btnPushInputPushUrl.setOnClickListener(new ButtonPushInputUrlListener());
	        
	        btnPushStartStop = (Button)findViewById(R.id.btn_push_start_stop);
	        btnPushStartStop.setOnClickListener(new ButtonPushStartListener());
	        imgPushSwitchCamera = (ImageView)findViewById(R.id.btn_push_switch_camera);
	        imgPushSwitchCamera.setOnClickListener(new PushSwitchCameraListener());
	        
	        pushSurfaceView = (SurfaceView) this.findViewById(R.id.push_camera_surface);  
	        pushSurfaceHolder = pushSurfaceView.getHolder();  
	        pushSurfaceHolder.addCallback(this);  
	        pushSurfaceHolder.setType(SurfaceHolder.SURFACE_TYPE_PUSH_BUFFERS); 
	        
	        //自动聚焦变量回调       
	        pushAutoFocusCallback = new AutoFocusCallback() 
			{  
	            public void onAutoFocus(boolean success, Camera camera) {  
	                if(success)//success表示对焦成功  
	                {  
	                    Log.i(PUSH_TAG, "onAutoFocus succeed...");   
	                }  
	                else  
	                {  
	                    Log.i(PUSH_TAG, "onAutoFocus failed...");  
	                }  
	            }  
	        }; 
	}
	
	
	class PlaybackEventHande implements SmartEventCallback
	 {
	    	 @Override
	    	 public void onCallback(int code, long param1, long param2, String param3, String param4, Object param5){
	             switch (code) {
	                 case EVENTID.EVENT_DANIULIVE_ERC_PLAYER_STARTED:
	                     Log.i(PLAY_TAG, "播放开始。。");
	                     break;
	                 case EVENTID.EVENT_DANIULIVE_ERC_PLAYER_CONNECTING:
	                     Log.i(PLAY_TAG, "播放连接中。。");
	                     break;
	                 case EVENTID.EVENT_DANIULIVE_ERC_PLAYER_CONNECTION_FAILED:
	                     Log.i(PLAY_TAG, "播放连接失败。。");
	                     break;
	                 case EVENTID.EVENT_DANIULIVE_ERC_PLAYER_CONNECTED:
	                     Log.i(PLAY_TAG, "播放连接成功。。");
	                     break;
	                 case EVENTID.EVENT_DANIULIVE_ERC_PLAYER_DISCONNECTED:
	                     Log.i(PLAY_TAG, "播放连接断开。。");
	                     break;
	                 case EVENTID.EVENT_DANIULIVE_ERC_PLAYER_STOP:
	                     Log.i(PLAY_TAG, "播放关闭。。");
	                     break;
	                 case EVENTID.EVENT_DANIULIVE_ERC_PLAYER_RESOLUTION_INFO:
	                	 Log.i(PLAY_TAG, "播放分辨率信息: width: " + param1 + ", height: " + param2);
	                	 break;
	                 case EVENTID.EVENT_DANIULIVE_ERC_PLAYER_NO_MEDIADATA_RECEIVED:
	                	 Log.i(PLAY_TAG, "播放收不到媒体数据，可能是url错误。。");
	                	 break;
	                 case EVENTID.EVENT_DANIULIVE_ERC_PLAYER_SWITCH_URL:
	                	 Log.i(PLAY_TAG, "播放切换播放URL。。");
	             }
	    	 }
	  }
	
	
	/* Create rendering */
    private boolean CreatePlayerSurfaceView() 
    {
    	
        if( playerSurfaceView == null )
        {
        	 /*
             *  useOpenGLES2:
             *  If with true: Check if system supports openGLES, if supported, it will choose openGLES.
             *  If with false: it will set with default surfaceView;	
             */
        	playerSurfaceView = NTRenderer.CreateRenderer(this, true);
        }
        
        if( playerSurfaceView == null )
        {
        	Log.i(TAG, "Create player render failed..");
        	return false;
        }

        return true;
	}
    
    private void SavePlayInputUrl(String url)
    {
    	playbackUrl = "";
    	
    	if ( url == null )
    		return;
    	
    	if ( url.equals("hks") )
    	{
    		btnPlaybackStartStopPlayback.setEnabled(true);
        	playbackUrl = "rtmp://live.hkstv.hk.lxdns.com/live/hks";
        	
        	Log.i(TAG, "Input url:" + playbackUrl);
        	 
    		return;
    	}
    	
    	// rtmp:/
    	if ( url.length() < 8 )
    	{
    		Log.e(TAG, "Input full url error:" + url);
    		return;
    	}
    	
    	if ( !url.startsWith("rtmp://") && !url.startsWith("rtsp://"))
    	{
    	    Log.e(TAG, "Input full url error:" + url);
    		return;
    	}
    		
    	btnPlaybackStartStopPlayback.setEnabled(true);
    	playbackUrl = url;
    	
    	Log.i(TAG, "Input full url:" + url);
    }
    
    
    private void SavePlayInputPlayBuffer(String bufferText)
    {
    	try
    	{
    		Integer intValue;
        	intValue = Integer.valueOf(bufferText);
            
            playbackBuffer = intValue;
            
            Log.i(TAG, "Input play buffer:" + playbackBuffer);
            
    	}catch(NumberFormatException e)
    	{
    		 Log.i(TAG, "Input play buffer convert exception");
    		 
    		e.printStackTrace();
    	}
    }
    
    private void PopPlayFullUrlDialog()
    {
    	final EditText inputUrlTxt = new EditText(this);
    	inputUrlTxt.setFocusable(true);
    	inputUrlTxt.setText("rtmp://player.daniulive.com:1935/hls/stream");

        AlertDialog.Builder builderUrl = new AlertDialog.Builder(this);
        builderUrl.setTitle("如 rtmp://player.daniulive.com:1935/hls/stream123456").setView(inputUrlTxt).setNegativeButton(
                "取消", null);
        builderUrl.setPositiveButton("确认", new DialogInterface.OnClickListener() {

                    public void onClick(DialogInterface dialog, int which) {
                        String fullUrl = inputUrlTxt.getText().toString();
                        SavePlayInputUrl(fullUrl);
                    }
                });
        
        builderUrl.show();
    }
    
    
    private void PopPlaySettingBufferDialog()
    {
    	final EditText inputBuferTxt = new EditText(this);
    	inputBuferTxt.setFocusable(true);
    	
    	String str = "";
    	str += playbackBuffer;
    	
    	inputBuferTxt.setText(str);

        AlertDialog.Builder builderBuffer = new AlertDialog.Builder(this);
        
        builderBuffer.setTitle("设置播放缓冲(毫秒),默认200ms").setView(inputBuferTxt).setNegativeButton(
                "取消", null);
        
        builderBuffer.setPositiveButton("确认", new DialogInterface.OnClickListener(){

                    public void onClick(DialogInterface dialog, int which)
                    {
                        String bufferText = inputBuferTxt.getText().toString();
                        SavePlayInputPlayBuffer(bufferText);
                    }
                });
        
        builderBuffer.show();
    }
    
    /* Generate basic layout */
    private void PlayInflateLayout(int orientation) 
    {
    	if ( null != playFrameLayout )
        {
    		playFrameLayout.removeAllViews();
    		playFrameLayout = null;
        }
    	
    	if (playbackLayout == null )
    		return;
    	
    	playbackLayout.removeAllViews();
    	
  
    	//playLayout.setOrientation(orientation);
    	
    	
    	playFrameLayout = new FrameLayout(this);
        
        LayoutParams lp = new LinearLayout.LayoutParams(LayoutParams.MATCH_PARENT,LayoutParams.MATCH_PARENT, 1.0f);
        playFrameLayout.setLayoutParams(lp);
        Log.i(PLAY_TAG, "++PlayInflateLayout..");
               
        playerSurfaceView.setLayoutParams(new LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT));       
        
        playFrameLayout.addView(playerSurfaceView, 0);

        RelativeLayout outLinearLayout = new RelativeLayout(this);
        outLinearLayout.setLayoutParams(new LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.FILL_PARENT));
        
        LinearLayout lLinearLayout = new LinearLayout(this);
        lLinearLayout.setOrientation(LinearLayout.VERTICAL);
        lLinearLayout.setLayoutParams(new LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT));
  
        LinearLayout firstLineLinearLayout = new LinearLayout(this);
        firstLineLinearLayout.setOrientation(LinearLayout.HORIZONTAL);
        firstLineLinearLayout.setLayoutParams(new LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT));
        
        btnPlaybackPopInputUrl = new Button(this);
        btnPlaybackPopInputUrl.setText("输入url");
        btnPlaybackPopInputUrl.setLayoutParams(new LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT));
        
        firstLineLinearLayout.addView(btnPlaybackPopInputUrl);
        
        /*mute button */
        btnPlaybackMute = new Button(this);
        
        if ( !isPlaybackMute )
        {
        	btnPlaybackMute.setText("静音 ");
        }
        else
        {
        	btnPlaybackMute.setText("取消静音 ");
        }
        
        btnPlaybackMute.setLayoutParams(new LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT));
        firstLineLinearLayout.addView(btnPlaybackMute);
         
        /*hardware decoder button */
        btnPlaybackHardwareDecoder = new Button(this);
        
        if ( !isPlaybackHardwareDecoder )
        {
        	btnPlaybackHardwareDecoder.setText("当前软解码");
        }
        else
        {
        	btnPlaybackHardwareDecoder.setText("当前硬解码");
        }
        
        btnPlaybackHardwareDecoder.setLayoutParams(new LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT));
        firstLineLinearLayout.addView(btnPlaybackHardwareDecoder);
        
        lLinearLayout.addView(firstLineLinearLayout);
        
        // buffer setting++
        LinearLayout bufferLinearLayout = new LinearLayout(this);
        bufferLinearLayout.setOrientation(LinearLayout.HORIZONTAL);
        bufferLinearLayout.setLayoutParams(new LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT));
        
    	btnPlaybackSetPlayBuffer = new Button(this);
    	btnPlaybackSetPlayBuffer.setText("设置缓冲");
    	btnPlaybackSetPlayBuffer.setLayoutParams(new LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT));
    	bufferLinearLayout.addView(btnPlaybackSetPlayBuffer);
    	
    	btnPlaybackFastStartup = new Button(this);
    	
    	if ( isPlaybackFastStartup )
    	{
    		btnPlaybackFastStartup.setText("停用秒开");
    	}
    	else
    	{
    		btnPlaybackFastStartup.setText("启用秒开");
    	}
    	
    	btnPlaybackFastStartup.setLayoutParams(new LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT));
    	bufferLinearLayout.addView(btnPlaybackFastStartup);
    	
    	lLinearLayout.addView(bufferLinearLayout);
    	
       // buffer setting--
        
        
        /* Start playback stream button */
        btnPlaybackStartStopPlayback = new Button(this);
        btnPlaybackStartStopPlayback.setText("开始播放 ");
        btnPlaybackStartStopPlayback.setLayoutParams(new LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT));
        lLinearLayout.addView(btnPlaybackStartStopPlayback);
               
        outLinearLayout.addView(lLinearLayout);
        playFrameLayout.addView(outLinearLayout, 1);

        playbackLayout.addView(playFrameLayout, 0); 
  
        if( isPlaybackViewStarted )
        {
        	btnPlaybackPopInputUrl.setEnabled(false);
        	btnPlaybackHardwareDecoder.setEnabled(false);
        	
        	btnPlaybackSetPlayBuffer.setEnabled(false);
        	btnPlaybackFastStartup.setEnabled(false);
        	
        	btnPlaybackStartStopPlayback.setText("停止播放 ");
        }
        else
        {
        	btnPlaybackPopInputUrl.setEnabled(true);
        	btnPlaybackHardwareDecoder.setEnabled(true);
        	
        	btnPlaybackSetPlayBuffer.setEnabled(true);
        	btnPlaybackFastStartup.setEnabled(true);
        	
        	btnPlaybackStartStopPlayback.setText("开始播放 ");
      
        }
        
        
        btnPlaybackPopInputUrl.setOnClickListener(new Button.OnClickListener()
        { 
        	 public void onClick(View v) { 
        		 PopPlayFullUrlDialog();
        	 }
        });
        
        btnPlaybackMute.setOnClickListener(new Button.OnClickListener() 
        { 
       	  public void onClick(View v) { 
    		 isPlaybackMute = !isPlaybackMute;
    		 
    		 if ( isPlaybackMute )
    		 {
    			 btnPlaybackMute.setText("取消静音");
    		 }
    		 else
    		 {
    			 btnPlaybackMute.setText("静音");
    		 }
    		 
    		 if ( playerHandle != 0 )
    		 {
    			 libPlayer.SmartPlayerSetMute(playerHandle, isPlaybackMute?1:0);
    		 }
    	  }
       });

   
        btnPlaybackHardwareDecoder.setOnClickListener(new Button.OnClickListener() 
        { 
       	 public void onClick(View v) { 
    		 isPlaybackHardwareDecoder = !isPlaybackHardwareDecoder;
    		 
    		 if ( isPlaybackHardwareDecoder )
    		 {
    			 btnPlaybackHardwareDecoder.setText("当前硬解码");
    		 }
    		 else
    		 {
    			 btnPlaybackHardwareDecoder.setText("当前软解码");
    		 }
    		 
    	 }
       });
        
        
        btnPlaybackSetPlayBuffer.setOnClickListener(new Button.OnClickListener()
        {
        	public void onClick(View v) 
        	{ 
        		PopPlaySettingBufferDialog();
        	}
        });
        
        
        btnPlaybackFastStartup.setOnClickListener(new Button.OnClickListener(){
        	public void onClick(View v)
        	{ 
        		isPlaybackFastStartup = !isPlaybackFastStartup;
        		
        		if ( isPlaybackFastStartup )
        		{
        			btnPlaybackFastStartup.setText("停用秒开");
        		}
        		else
        		{
        			btnPlaybackFastStartup.setText("启用秒开");
        		}
        	}
        });
    	
         
        btnPlaybackStartStopPlayback.setOnClickListener(new Button.OnClickListener() 
        {  
        	  
            //  @Override  
              public void onClick(View v) {  
	              
            	  if(isPlaybackViewStarted)
            	  {
                	  Log.i(PLAY_TAG, "Stop playback stream++");
            		  btnPlaybackStartStopPlayback.setText("开始播放 ");
            		  
            		  //btnPopInputText.setEnabled(true);
            		 
            		  btnPlaybackPopInputUrl.setEnabled(true);
            		  btnPlaybackHardwareDecoder.setEnabled(true);
            		  
            		  btnPlaybackSetPlayBuffer.setEnabled(true);
                  	  btnPlaybackFastStartup.setEnabled(true);
            		  
            		  libPlayer.SmartPlayerClose(playerHandle);	
            		  playerHandle = 0;
            		  isPlaybackViewStarted = false;
                      Log.i(PLAY_TAG, "Stop playback stream--");
            	  }
            	  else
            	  {
            		  Log.i(PLAY_TAG, "Start playback stream++");
            		  
            		  playerHandle = libPlayer.SmartPlayerInit(curContext);
            	      
            	      if(playerHandle == 0)
            	      {
            	    	  Log.e(PLAY_TAG, "surfaceHandle with nil..");
            	    	  return;
            	      }
            		  
					  libPlayer.SetSmartPlayerEventCallback(playerHandle, new PlaybackEventHande());
					  
            	      libPlayer.SmartPlayerSetSurface(playerHandle, playerSurfaceView); 	//if set the second param with null, it means it will playback audio only..
            		  	
            	      // libPlayer.SmartPlayerSetSurface(playerHandle, null); 
            	      
            	      // External Render test
            	      //libPlayer.SmartPlayerSetExternalRender(playerHandle, new RGBAExternalRender());
            	      //libPlayer.SmartPlayerSetExternalRender(playerHandle, new I420ExternalRender());
            	      
            	      libPlayer.SmartPlayerSetExternalAudioOutput(playerHandle, new PlayerExternalPcmOutput());
 	              	 
            	      libPlayer.SmartPlayerSetAudioOutputType(playerHandle, 0);
            	      
            	      libPlayer.SmartPlayerSetBuffer(playerHandle, playbackBuffer);
            	      
            	      libPlayer.SmartPlayerSetFastStartup(playerHandle, isPlaybackFastStartup?1:0);
            	      
            	      
            	      if ( isPlaybackMute )
            	      {
            	    	  libPlayer.SmartPlayerSetMute(playerHandle, isPlaybackMute?1:0);
            	      }
            	      
            	      if( isPlaybackHardwareDecoder )
            	      {
            	    	  Log.i(PLAY_TAG, "check isHardwareDecoder: " + isPlaybackHardwareDecoder);
            	    	  
                	      int hwChecking = libPlayer.SetSmartPlayerVideoHWDecoder(playerHandle, isPlaybackHardwareDecoder?1:0);
  						
    					  Log.i(PLAY_TAG, "[daniulive] hwChecking: " + hwChecking);
            	      }
     
            	      
            	     	            	      
	              	  if( playbackUrl == null )
	              	  {
	              		 Log.e(PLAY_TAG, "playback URL with NULL..."); 
	              		 return;
	              	  }
	              	  
	              	  
	              	  int iPlaybackRet = libPlayer.SmartPlayerStartPlayback(playerHandle, playbackUrl);
	              	  	              	  
	                  if( iPlaybackRet != 0 )
	                  {
	                	 Log.e(PLAY_TAG, "StartPlayback strem failed.."); 
	                	 return;
	                  }
	
	        		  btnPlaybackStartStopPlayback.setText("停止播放 ");
	                 	                  
	        		  btnPlaybackPopInputUrl.setEnabled(false);
	                  btnPlaybackHardwareDecoder.setEnabled(false);
	                  
	                  btnPlaybackSetPlayBuffer.setEnabled(false);
                  	  btnPlaybackFastStartup.setEnabled(false);
	                  
	              	  isPlaybackViewStarted = true;
	              	  Log.i(PLAY_TAG, "Start playback stream--");
	        	  }
	          	}
              });
	}
    
    
    @Override  
	public void onConfigurationChanged(Configuration newConfig) {
		super.onConfigurationChanged(newConfig);

		Log.i(TAG, "Run into onConfigurationChanged++");

		if (newConfig.orientation == Configuration.ORIENTATION_LANDSCAPE)
		{
			Log.i(TAG, "onConfigurationChanged, with LANDSCAPE。。");

			if (linearLayoutAll != null) {
				linearLayoutAll.setOrientation(LinearLayout.HORIZONTAL);
			}

			if (playbackLayout != null) {
				LayoutParams plp = new LinearLayout.LayoutParams(0,
						LayoutParams.MATCH_PARENT, 0.8f);
				playbackLayout.setLayoutParams(plp);
			}

			if (pushLayout != null) {
				LayoutParams plp = new LinearLayout.LayoutParams(0,
						LayoutParams.MATCH_PARENT, 1.2f);
				pushLayout.setLayoutParams(plp);
			}

			PlayInflateLayout(LinearLayout.HORIZONTAL);

			currentOrigentation = LANDSCAPE;
			
			if ( !isPushStart )
			{
				currentPushOrigentation = LANDSCAPE;
			}
			
		} else
		{
			Log.i(TAG, "onConfigurationChanged, with PORTRAIT。。");

			if (linearLayoutAll != null) {
				linearLayoutAll.setOrientation(LinearLayout.VERTICAL);
			}

			if (playbackLayout != null) {
				LayoutParams plp = new LinearLayout.LayoutParams(
						LayoutParams.MATCH_PARENT, 0, 0.7f);
				playbackLayout.setLayoutParams(plp);
			}

			if (pushLayout != null) {
				LayoutParams plp = new LinearLayout.LayoutParams(
						LayoutParams.MATCH_PARENT, 0, 1.3f);
				pushLayout.setLayoutParams(plp);
			}

			PlayInflateLayout(LinearLayout.VERTICAL);

			currentOrigentation = PORTRAIT;
			
			if ( !isPushStart )
			{
				currentPushOrigentation = PORTRAIT;
			}
		}

		if (isPlaybackViewStarted)
		{
			libPlayer.SmartPlayerSetOrientation(playerHandle,
					currentOrigentation);
		}

		Log.i(TAG, "Run out of onConfigurationChanged--");

	}
    
    class PushSwitchCameraListener implements OnClickListener
    {
        public void onClick(View v)
        {    
        	Log.i(TAG, "Switch camera..");
        	 try {
                 switchCamera();
             } catch (IOException e) {
                 // TODO Auto-generated catch block
                 e.printStackTrace();
             }
         }
    };
    
    void SwitchPushResolution(int position)
    {
    	Log.i(PUSH_TAG, "Current Resolution position: " + position);
    	
    	switch(position) {
        case 0:
        	pushVideoWidth = 640;
    		pushVideoHight = 480;
            break;
        case 1:
        	pushVideoWidth = 320;
        	pushVideoHight = 240;
            break;
        case 2:
        	pushVideoWidth = 176;
        	pushVideoHight = 144;
            break;
        case 3:
        	pushVideoWidth = 1280;
        	pushVideoHight = 720;
            break;
        default:
        	pushVideoWidth = 640;
        	pushVideoHight = 480;
    	}
    	   	
    	pushCamera.stopPreview();   
        initPushCamera(pushSurfaceHolder);
    }
    
    void CheckPushInitAudioRecorder()
    {
    	if ( audioRecord_ == null )
		{
			audioRecord_ = new NTAudioRecord(this, 1);
		}
			
        if(audioRecord_ != null)
        {
        	Log.i(PUSH_TAG, "onCreate, call executeAudioRecordMethod.."); 
        	audioRecord_.executeAudioRecordMethod();
        }
    }
    
    //Configure recorder related function.
    void ConfigPushRecorderFuntion()
    {
    	if ( libPublisher != null )
    	{
    		if ( is_push_need_local_recorder )
    		{
    			if ( pushRecDir != null && !pushRecDir.isEmpty() )
        		{
        			int ret = libPublisher.SmartPublisherCreateFileDirectory(pushRecDir);
            		if ( 0 == ret )
            		{
            			if ( 0 != libPublisher.SmartPublisherSetRecorderDirectory(pushRecDir) )
            			{
            				Log.e(PUSH_TAG, "Set recoder dir failed , path:" + pushRecDir);
            				return;
            			}
            			
            			if ( 0 != libPublisher.SmartPublisherSetRecorder(1) )
            			{
            				Log.e(PUSH_TAG, "SmartPublisherSetRecoder failed.");
            				return;
            			}
            			
            			if ( 0 != libPublisher.SmartPublisherSetRecorderFileMaxSize(200) )
            			{
            				Log.e(PUSH_TAG, "SmartPublisherSetRecoderFileMaxSize failed.");
            				return;
            			}
            		
            		}
            		else
            		{
            			Log.e(PUSH_TAG, "Create recoder dir failed, path:" + pushRecDir);
            		}
        		}
    		}
    		else
    		{
    			if ( 0 != libPublisher.SmartPublisherSetRecorder(0) )
    			{
    				Log.e(PUSH_TAG, "SmartPublisherSetRecoder failed.");
    				return;
    			}
    		}
    	}
    }
    
    class ButtonPushRecorderMangerListener implements OnClickListener
    {
    	public  void onClick(View v)
    	{
    		/*
    		if (mCamera != null )
    		{
    			mCamera.stopPreview();
    			mCamera.release();
    			mCamera = null;
    		}
    		
    	      Intent intent = new Intent();
              intent.setClass(CameraPublishActivity.this, RecorderManager.class);
              intent.putExtra("RecoderDir", recDir);
              startActivity(intent);
              */
    	}
    }
    
    class ButtonPushNoiseSuppressionListener implements OnClickListener
    {
    	public void onClick(View v)
    	{
    		is_push_noise_suppression = !is_push_noise_suppression;
    		
    		if ( is_push_noise_suppression )
    			btnPushNoiseSuppression.setText("停用噪音抑制");
    		else
    			btnPushNoiseSuppression.setText("启用噪音抑制");
    	}
    }
    
    
    class ButtonPushAGCListener  implements OnClickListener
    {
    	public void onClick(View v)
    	{
    		is_push_agc = !is_push_agc;
    		
    		if ( is_push_agc )
    			btnPushAGC.setText("停用AGC");
    		else
    			btnPushAGC.setText("启用AGC");
    	}
    }
    
    class ButtonPushSpeexListener  implements OnClickListener
    {
    	public void onClick(View v)
    	{
    		is_push_speex = !is_push_speex;
    		
    		if ( is_push_speex  )
    			btnPushSpeex.setText("不使用Speex");
    		else
    			btnPushSpeex.setText("使用Speex");
    	}
    }
    
    class ButtonPushMuteListener  implements OnClickListener
    {
    	public void onClick(View v)
    	{
    		is_push_mute = !is_push_mute;
    		
    		if ( is_push_mute )
    			btnPushMute.setText("取消静音");
    		else
    			btnPushMute.setText("静音");
    		
    		if ( libPublisher != null )
    			libPublisher.SmartPublisherSetMute(is_push_mute?1:0);
    	}
    }
    
    class ButtonPushMirrorListener  implements OnClickListener
    {
    	public void onClick(View v)
    	{
    		is_push_mirror = !is_push_mirror;
    		
    		if ( is_push_mirror )
    			btnPushMirror.setText("关镜像");
    		else
    			btnPushMirror.setText("开镜像");
    		
    		if ( libPublisher != null )
    			libPublisher.SmartPublisherSetMirror(is_push_mirror?1:0);
    	}
    }
    
    private void SaveEchoCancelDelay(String delayText)
    {
    	try
    	{
    		Integer intValue;
        	intValue = Integer.valueOf(delayText);
            
        	echoCancelDelay = intValue;
            
            Log.i(TAG, "Input echo cancel delay :" + echoCancelDelay);
            
    	}catch(NumberFormatException e)
    	{
    		 Log.i(TAG, "Input  echo cancel delay convert exception");
    		 
    		e.printStackTrace();
    	}
    }
    
    private void PopPushSettingEchoCancelDelayDialog()
    {
    	final EditText inputBuferTxt = new EditText(this);
    	inputBuferTxt.setFocusable(true);
    	
    	String str = "";
    	str += echoCancelDelay;
    	
    	inputBuferTxt.setText(str);

        AlertDialog.Builder builderDelay = new AlertDialog.Builder(this);
        
        builderDelay.setTitle("设置回声消除时延(毫秒),默认0为SDK自动估计时延").setView(inputBuferTxt).setNegativeButton(
                "取消", null);
        
        builderDelay.setPositiveButton("确认", new DialogInterface.OnClickListener(){

                    public void onClick(DialogInterface dialog, int which)
                    {
                        String bufferText = inputBuferTxt.getText().toString();
                        SaveEchoCancelDelay(bufferText);
                    }
                });
        
        builderDelay.show();
    }
    
    
    class ButtonPushEchoCancelDelayListener  implements OnClickListener
    {
    	public void onClick(View v)
    	{
    		PopPushSettingEchoCancelDelayDialog();
    	}
    }
    
    class ButtonPushHardwareEncoderListener  implements OnClickListener
    {
    	public void onClick(View v)
    	{
    		is_push_hardware_encoder = !is_push_hardware_encoder;
    		
    		if ( is_push_hardware_encoder )
    			btnPushHWencoder.setText("当前硬解码");
    		else
    			btnPushHWencoder.setText("当前软解码");
    	}
    }
    
    class PushEventHande implements SmartEventCallback
    {
    	 @Override
    	 public void onCallback(int code, long param1, long param2, String param3, String param4, Object param5){
             switch (code) {
                 case EVENTID.EVENT_DANIULIVE_ERC_PUBLISHER_STARTED:
                	 pushTxt = "开始。。";
                     break;
                 case EVENTID.EVENT_DANIULIVE_ERC_PUBLISHER_CONNECTING:
                	 pushTxt = "连接中。。";
                     break;
                 case EVENTID.EVENT_DANIULIVE_ERC_PUBLISHER_CONNECTION_FAILED:
                	 pushTxt = "连接失败。。";
                     break;
                 case EVENTID.EVENT_DANIULIVE_ERC_PUBLISHER_CONNECTED:
                	 pushTxt = "连接成功。。";
                     break;
                 case EVENTID.EVENT_DANIULIVE_ERC_PUBLISHER_DISCONNECTED:
                	 pushTxt = "连接断开。。";
                     break;
                 case EVENTID.EVENT_DANIULIVE_ERC_PUBLISHER_STOP:
                	 pushTxt =  "关闭。。";
                     break;
                 case EVENTID.EVENT_DANIULIVE_ERC_PUBLISHER_RECORDER_START_NEW_FILE:
                	 Log.i(PUSH_TAG, "开始一个新的录像文件 : " + param3);
                	 pushTxt = "开始一个新的录像文件。。";
                     break;
                 case EVENTID.EVENT_DANIULIVE_ERC_PUBLISHER_ONE_RECORDER_FILE_FINISHED:
                	 Log.i(PUSH_TAG, "已生成一个录像文件 : " + param3);
                	 pushTxt = "已生成一个录像文件。。";
                     break;
                     
                 case EVENTID.EVENT_DANIULIVE_ERC_PUBLISHER_SEND_DELAY:
                	 Log.i(PUSH_TAG, "发送时延: " + param1 + " 帧数:" + param2);
                	 pushTxt = "收到发送时延..";
                	 break;
             }
             
             String str = "当前回调状态：" + pushTxt;
                          
             Log.i(PUSH_TAG, str);
             
         }
    }
    
    private void SavePushInputUrl(String url)
    {
    	inputPushURL = "";
    	
    	if ( url == null )
    		return;
    	
    	// rtmp://
    	if ( url.length() < 8 )
    	{
    		Log.e(TAG, "Input publish url error:" + url);
    		return;
    	}
    	
    	if ( !url.startsWith("rtmp://") )
    	{
    	    Log.e(TAG, "Input publish url error:" + url);
    		return;
    	}
    		
    	inputPushURL = url;
    	
    	Log.i(TAG, "Input publish url:" + url);
    }
    
    private void PopPushInputUrlDialog()
    {
    	final EditText inputUrlTxt = new EditText(this);
    	inputUrlTxt.setFocusable(true);
    	inputUrlTxt.setText(basePushURL + String.valueOf((int)( System.currentTimeMillis() % 1000000)));

        AlertDialog.Builder builderUrl = new AlertDialog.Builder(this);
        builderUrl.setTitle("如 rtmp://player.daniulive.com:1935/hls/stream123456").setView(inputUrlTxt).setNegativeButton(
                "取消", null);
        
        builderUrl.setPositiveButton("确认", new DialogInterface.OnClickListener() {

                    public void onClick(DialogInterface dialog, int which) {
                        String fullPushUrl = inputUrlTxt.getText().toString();
                        SavePushInputUrl(fullPushUrl);
                    }
                });
        
        builderUrl.show();
    }
    
    class ButtonPushInputUrlListener implements OnClickListener
    {
    	 public void onClick(View v)
    	 {
    		 PopPushInputUrlDialog();
    	 }
    }
    
    class ButtonPushStartListener implements OnClickListener
    {
        public void onClick(View v)
        {    
        	if ( isPushStart )
        	{
        		stopPubliser();
        		btnPushStartStop.setText(" 开始推流 ");
        		btnPushRecoderMgr.setEnabled(true);
        		btnPushHWencoder.setEnabled(true);
        		
        		btnPushNoiseSuppression.setEnabled(true);
        		btnPushAGC.setEnabled(true);
        		btnPushSpeex.setEnabled(true);
        		
        		return;
        	}
        	
        	isPushStart = true;
        	btnPushStartStop.setText(" 停止推流 ");
        	Log.i(PUSH_TAG, "onClick start..");        
            
			if(libPublisher!=null)
			{
				if ( inputPushURL != null && inputPushURL.length() > 1 )
				{
					publishURL = inputPushURL;
					Log.i(PUSH_TAG, "start, input publish url:" + publishURL);
				}
				else
				{
					publishURL = basePushURL + String.valueOf((int)( System.currentTimeMillis() % 1000000)); 
					Log.i(PUSH_TAG, "start, generate random url:" + publishURL);
					
				}
				
				
			    printPushText = "URL:" + publishURL;
			        
			    Log.i(PUSH_TAG, printPushText);
			     
			    textPushCurURL = (TextView)findViewById(R.id.txt_push_cur_url);
			    textPushCurURL.setText(printPushText);
				
			    ConfigPushRecorderFuntion(); 
			    
			    Log.i(PUSH_TAG, "videoWidth: "+ pushVideoWidth + " videoHight: " + pushVideoHight + " pushType:" + pushType);
			    		
			    int audio_opt = 1;
			    int video_opt = 1;
			    
			    if ( pushType == 1 )
			    {
			    	video_opt = 0;
			    } 
			    else if (pushType == 2 )
			    {
			    	audio_opt = 0;
			    }    
			    
			    libPublisher.SmartPublisherInit(curContext, audio_opt, video_opt, pushVideoWidth, pushVideoHight);
			   	
			    if( is_push_hardware_encoder )
			    {
				    int hwHWKbps = setHardwareEncoderKbps(pushVideoWidth, pushVideoHight);
				    
			        Log.i(TAG, "hwHWKbps: " + hwHWKbps); 
				    
					int isSupportHWEncoder = libPublisher.SetSmartPublisherVideoHWEncoder(hwHWKbps);
			        
					if(isSupportHWEncoder == 0)
					{
				        Log.i(TAG, "Great, it supports hardware encoder!"); 
					}
			    }
			    
			    libPublisher.SetSmartPublisherEventCallback(new PushEventHande()); 
			    
			    //如果想和时间显示在同一行，请去掉'\n'
			    String watermarkText = "大牛直播(daniulive)\n\n";
			    
			    String path = pushLogoPath;
			    
			    if( pushWatemarkType == 0 )
			    {
			    	if ( isPushWritelogoFileSuccess )
			    		libPublisher.SmartPublisherSetPictureWatermark(path, WATERMARK.WATERMARK_POSITION_TOPRIGHT, 160, 160, 10, 10);
			    }
			    else if( pushWatemarkType == 1 )
			    {
			    	if ( isPushWritelogoFileSuccess )
			    		libPublisher.SmartPublisherSetPictureWatermark(path, WATERMARK.WATERMARK_POSITION_TOPRIGHT, 160, 160, 10, 10);
				    
			    	libPublisher.SmartPublisherSetTextWatermark(watermarkText, 1, WATERMARK.WATERMARK_FONTSIZE_BIG, WATERMARK.WATERMARK_POSITION_BOTTOMRIGHT, 10, 10);
			    	
			    	//libPublisher.SmartPublisherSetTextWatermarkFontFileName("/system/fonts/DroidSansFallback.ttf");
			    	
			    	//libPublisher.SmartPublisherSetTextWatermarkFontFileName("/sdcard/DroidSansFallback.ttf");
			    }
			    else if(pushWatemarkType == 2)
			    {
				    libPublisher.SmartPublisherSetTextWatermark(watermarkText, 1, WATERMARK.WATERMARK_FONTSIZE_BIG, WATERMARK.WATERMARK_POSITION_BOTTOMRIGHT, 10, 10);
				    
				    //libPublisher.SmartPublisherSetTextWatermarkFontFileName("/system/fonts/DroidSansFallback.ttf");
			    }
			    else
			    {
			    	Log.i(TAG, "no watermark settings..");
			    }
			    //end
			    
			    
			    if ( !is_push_speex )
			    {
			    	 // set AAC encoder
			    	 libPublisher.SmartPublisherSetAudioCodecType(1);
			    }
			    else
			    {
			    	// set Speex encoder
			    	libPublisher.SmartPublisherSetAudioCodecType(2);
			    	libPublisher.SmartPublisherSetSpeexEncoderQuality(8);
			    }
			    
			    libPublisher.SmartPublisherSetNoiseSuppression(is_push_noise_suppression?1:0);
			    
			    libPublisher.SmartPublisherSetAGC(is_push_agc?1:0);
			    
			    libPublisher.SmartPublisherSetEchoCancellation(1, echoCancelDelay);
			    
			    //libPublisher.SmartPublisherSetClippingMode(0);
			    
				libPublisher.SmartPublisherSetSWVideoEncoderProfile(push_sw_video_encoder_profile);
			    
			    //libPublisher.SetRtmpPublishingType(0);
			    
				
			    //libPublisher.SmartPublisherSetGopInterval(40);
			    
			    //libPublisher.SmartPublisherSetFPS(15);
			    			        
			    //libPublisher.SmartPublisherSetSWVideoBitRate(600, 1200);
			    
			    
			    // IF not set url or url is empty, it will not publish stream
			   // if ( libPublisher.SmartPublisherSetURL("") != 0 )
			    if ( libPublisher.SmartPublisherSetURL(publishURL) != 0 )
			    {
			    	Log.e(TAG, "Failed to set publish stream URL..");
			    }
			    
            	int isStarted = libPublisher.SmartPublisherStart();
            	if(isStarted != 0)
            	{
            		Log.e(TAG, "Failed to publish stream..");
            	}
            	else
            	{
            		btnPushRecoderMgr.setEnabled(false);
            		btnPushHWencoder.setEnabled(false);
            		
            		btnPushNoiseSuppression.setEnabled(false);
            		btnPushAGC.setEnabled(false);
            		btnPushSpeex.setEnabled(false);
            	}
			}
			
			if(pushType == 0 || pushType ==1)
			{
				CheckPushInitAudioRecorder();	//enable pure video publisher..
			}
        }
    };
    
    class ButtonPushStopListener implements OnClickListener
    {
        public void onClick(View v)
        {    
           //onDestroy();
        }
    };
    
    private void stopPubliser()
    {
    	 Log.i(PUSH_TAG, "onClick stop..");
 
    	 if( audioRecord_ != null )
	     {
			Log.i(PUSH_TAG, "surfaceDestroyed, call StopRecording.."); 
	        audioRecord_.StopRecording();
	        audioRecord_ = null;
	     }
    	 
    	 if ( libPublisher != null )
		 {
			libPublisher.SmartPublisherStop();
		 }
    	
    	 isPushStart = false;
    }
    
    
    private void SetPushCameraFPS(Camera.Parameters parameters)
	{
		if ( parameters == null )
			return;
		
		int[] findRange = null;
		
		int defFPS = 20*1000;
		
		List<int[]> fpsList = parameters.getSupportedPreviewFpsRange();
		if ( fpsList != null && fpsList.size() > 0 )
		{
			for ( int i = 0; i < fpsList.size(); ++i )
			{
				int[] range = fpsList.get(i);
				if ( range != null 
						&& Camera.Parameters.PREVIEW_FPS_MIN_INDEX <  range.length 
						 && Camera.Parameters.PREVIEW_FPS_MAX_INDEX < range.length )
				{
					Log.i(TAG, "Camera index:" + i + " support min fps:" + range[Camera.Parameters.PREVIEW_FPS_MIN_INDEX]);
					
					Log.i(TAG, "Camera index:" + i + " support max fps:" + range[Camera.Parameters.PREVIEW_FPS_MAX_INDEX]);	
						
					if ( findRange == null )
					{
						if ( defFPS <= range[Camera.Parameters.PREVIEW_FPS_MAX_INDEX] )
						{
							findRange = range;
							
							Log.i(TAG, "Camera found appropriate fps, min fps:" + range[Camera.Parameters.PREVIEW_FPS_MIN_INDEX]
									+ " ,max fps:" + range[Camera.Parameters.PREVIEW_FPS_MAX_INDEX]);
						}
					}
				}
			}
		}
		
		if ( findRange != null  )
		{
			parameters.setPreviewFpsRange(findRange[Camera.Parameters.PREVIEW_FPS_MIN_INDEX], findRange[Camera.Parameters.PREVIEW_FPS_MAX_INDEX]);
		}
	}

	/*it will call when surfaceChanged*/
	private void initPushCamera(SurfaceHolder holder)
	{  
		Log.i(TAG, "initCamera..");
	
		if( pushPreviewRunning )
			pushCamera.stopPreview();
		
		Camera.Parameters parameters;
		try {
			parameters = pushCamera.getParameters();
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return;
		}
			
		parameters.setPreviewSize(pushVideoWidth, pushVideoHight);
		parameters.setPictureFormat(PixelFormat.JPEG); 
		parameters.setPreviewFormat(PixelFormat.YCbCr_420_SP); 
		
		SetPushCameraFPS(parameters);
		
		setCameraDisplayOrientation(this, pushCurCameraIndex, pushCamera);
        
		pushCamera.setParameters(parameters); 
		
		int bufferSize = (((pushVideoWidth|0xf)+1) * pushVideoHight * ImageFormat.getBitsPerPixel(parameters.getPreviewFormat())) / 8;
		
		pushCamera.addCallbackBuffer(new byte[bufferSize]);
		
		pushCamera.setPreviewCallbackWithBuffer(this);  
        try {  
            pushCamera.setPreviewDisplay(holder);  
        } catch (Exception ex) {
        	// TODO Auto-generated catch block 
        	if(null != pushCamera){  
        		pushCamera.release();  
        		pushCamera = null;  
            }
        	ex.printStackTrace();
        }
        
        pushCamera.startPreview();  
        pushCamera.autoFocus(pushAutoFocusCallback);
        pushPreviewRunning = true;  	
	}  
	
	@Override
	public void surfaceCreated(SurfaceHolder holder) {
		Log.i(TAG, "surfaceCreated..");
		try {
			
	        int CammeraIndex=findBackCamera();
	        Log.i(TAG, "BackCamera: " + CammeraIndex);
	       
	        if(CammeraIndex==-1){  
	            CammeraIndex=findFrontCamera();
	            pushCurrentCameraType = FRONT;
	            imgPushSwitchCamera.setEnabled(false);
	            if(CammeraIndex == -1)
	            {
	            	Log.i(TAG, "NO camera!!");
	            	return;
	            }   
	        }
	        else
	        {
	        	 pushCurrentCameraType = BACK;
	        }
			
	        if ( pushCamera == null )
	        {
	        	pushCamera = openCamera(pushCurrentCameraType);
	        }
	        
        } catch (Exception e) {
            e.printStackTrace();
        }

	}

	@Override
	public void surfaceChanged(SurfaceHolder holder, int format, int width, int height) {
		Log.i(TAG, "surfaceChanged..");
		initPushCamera(holder);
	}

	@Override
	public void surfaceDestroyed(SurfaceHolder holder) {
		// TODO Auto-generated method stub
		Log.i(TAG, "Surface Destroyed"); 
	}
	

	@Override
	public void onPreviewFrame(byte[] data, Camera camera) {
		pushFrameCount++;
		if ( pushFrameCount % 3000 == 0 )
		{
			Log.i("OnPre", "gc+");
			System.gc();
			Log.i("OnPre", "gc-");
		}
	
		if (data == null) {
			Parameters params = camera.getParameters();
			Size size = params.getPreviewSize();
			int bufferSize = (((size.width|0x1f)+1) * size.height * ImageFormat.getBitsPerPixel(params.getPreviewFormat())) / 8;
			camera.addCallbackBuffer(new byte[bufferSize]);
		} 
		else 
		{
			if( isPushStart )
			{
				libPublisher.SmartPublisherOnCaptureVideoData(data, data.length, pushCurrentCameraType, currentPushOrigentation);	
			}
			
			camera.addCallbackBuffer(data);
		}
	} 
	
    @SuppressLint("NewApi")
    private Camera openCamera(int type){
        int frontIndex =-1;
        int backIndex = -1;
        int cameraCount = Camera.getNumberOfCameras();
        Log.i(TAG, "cameraCount: " + cameraCount);
        
        CameraInfo info = new CameraInfo();
        for(int cameraIndex = 0; cameraIndex<cameraCount; cameraIndex++){
            Camera.getCameraInfo(cameraIndex, info);
            
            if(info.facing == CameraInfo.CAMERA_FACING_FRONT){
                frontIndex = cameraIndex;
            }else if(info.facing == CameraInfo.CAMERA_FACING_BACK){
                backIndex = cameraIndex;
            }
        }

        pushCurrentCameraType = type;
        if(type == FRONT && frontIndex != -1){
        	pushCurCameraIndex = frontIndex;
            return Camera.open(frontIndex);
        }else if(type == BACK && backIndex != -1){
        	pushCurCameraIndex = backIndex;
            return Camera.open(backIndex);
        }
        
        return null;
    }
	
	private void switchCamera() throws IOException
	{
		 pushCamera.setPreviewCallback(null);
		 pushCamera.stopPreview();
		 pushCamera.release();
	     if( pushCurrentCameraType == FRONT){
	        pushCamera = openCamera(BACK);
	     }else if(pushCurrentCameraType == BACK){
	        pushCamera = openCamera(FRONT);
	     }
	        
	     initPushCamera(pushSurfaceHolder);
	}
	 
	
	//Check if it has front camera
	private int findFrontCamera(){	
        int cameraCount = 0;
        Camera.CameraInfo cameraInfo = new Camera.CameraInfo();
        cameraCount = Camera.getNumberOfCameras(); 
        
        for ( int camIdx = 0; camIdx < cameraCount;camIdx++ ) {
            Camera.getCameraInfo( camIdx, cameraInfo );
            if ( cameraInfo.facing ==Camera.CameraInfo.CAMERA_FACING_FRONT ) {
               return camIdx;
            }
        }
    	return -1;
    }
	
	//Check if it has back camera
    private int findBackCamera(){
        int cameraCount = 0;
        Camera.CameraInfo cameraInfo = new Camera.CameraInfo();
        cameraCount = Camera.getNumberOfCameras();
              
        for ( int camIdx = 0; camIdx < cameraCount;camIdx++ ) {
            Camera.getCameraInfo( camIdx, cameraInfo );
            if ( cameraInfo.facing ==Camera.CameraInfo.CAMERA_FACING_BACK ) {
               return camIdx;
            }
        }
    	return -1;
    }
    
    private void setCameraDisplayOrientation (Activity activity, int cameraId, android.hardware.Camera camera) {  
        android.hardware.Camera.CameraInfo info = new android.hardware.Camera.CameraInfo();  
        android.hardware.Camera.getCameraInfo (cameraId , info);  
        int rotation = activity.getWindowManager ().getDefaultDisplay ().getRotation ();  
        int degrees = 0;  
        switch (rotation) {  
            case Surface.ROTATION_0:  
                degrees = 0;  
                break;  
            case Surface.ROTATION_90:  
                degrees = 90;  
                break;  
            case Surface.ROTATION_180:  
                degrees = 180;  
                break;  
            case Surface.ROTATION_270:  
                degrees = 270;  
                break;  
        }  
        int result;  
        if (info.facing == Camera.CameraInfo.CAMERA_FACING_FRONT) {  
            result = (info.orientation + degrees) % 360;  
            result = (360 - result) % 360;  
        } else {  
            // back-facing  
            result = ( info.orientation - degrees + 360) % 360;  
        }  
        
    	Log.i(TAG, "curDegree: "+ result); 
    	
        camera.setDisplayOrientation (result);  
    }
    
    private int setHardwareEncoderKbps(int width, int height)
    {
    	int hwEncoderKpbs = 0;
    	
    	switch(width) {
        case 176:
        	hwEncoderKpbs = 300;
            break;
        case 320:
        	hwEncoderKpbs = 500;
            break;
        case 640:
        	hwEncoderKpbs = 1000;
            break;
        case 1280:
        	hwEncoderKpbs = 1700;
            break;
        default:
        	hwEncoderKpbs = 1000;
    	}
    	
    	return hwEncoderKpbs;
    }
    
    
    public static final String bytesToHexString(byte[] buffer)
    {   
        StringBuffer sb = new StringBuffer(buffer.length);   
        String temp;
        
        for (int i = 0; i < buffer.length; ++i)
        {   
        	temp = Integer.toHexString(0xff&buffer[i]);   
          if (temp.length() < 2)   
            sb.append(0);
          
          sb.append(temp);   
        }   
        
        return sb.toString();   
    }  
    
    class PlayerExternalPcmOutput implements NTExternalAudioOutput
    {    	
    	private int sample_rate_ = 0;
    	private int channel_ = 0;
    	private int sample_size = 0;
    	private int buffer_size = 0;
    	
    	private ByteBuffer pcm_buffer_ = null;

    	@Override
    	public ByteBuffer getPcmByteBuffer(int size)
    	{
    		//Log.i("getPcmByteBuffer", "size: " + size);
    		   		
    		if(size < 1)
    		{
    			return null;
    		}
    		
    		if(buffer_size != size)
    		{
    			buffer_size = size;
        		pcm_buffer_ = ByteBuffer.allocateDirect(buffer_size);
    		}
    		
    		return pcm_buffer_;
    	}

    	public void onGetPcmFrame(int ret, int sampleRate, int channel, int sampleSize, int is_low_latency)
    	{
    		/*
    		Log.i("onGetPcmFrame", "ret: " + ret + ", sampleRate: " + sampleRate + ", channel: " + channel + ", sampleSize: " + sampleSize +
    				",is_low_latency:" + is_low_latency);
    		*/
    		
    		if ( pcm_buffer_ == null)
    			return;
    		
    		pcm_buffer_.rewind();
    		
    		if ( ret == 0 && isPushStart )
    		{
    			libPublisher.SmartPublisherOnFarEndPCMData(pcm_buffer_, sampleRate, channel, sampleSize, is_low_latency);
    		}
    		

    		// test
    		
    		/*
    		byte[] test_buffer = new byte[16];
    		pcm_buffer_.get(test_buffer);
    		 
    		Log.i(TAG, "onGetPcmFrame data:" + bytesToHexString(test_buffer));
    		*/
    	}
    }
    
    @Override
    protected  void onDestroy()
	{
		Log.i(TAG, "Run into activity destory++");   	
    	
		if( playerHandle!=0 )
		{
			libPlayer.SmartPlayerClose(playerHandle);	
			playerHandle = 0;
		}
		
    	if ( isPushStart )
    	{
    		stopPubliser();
    		Log.i(TAG, "onDestroy StopPublish");
    	}
    		
		super.onDestroy();
    	finish();
    	System.exit(0);
    }
  
}
