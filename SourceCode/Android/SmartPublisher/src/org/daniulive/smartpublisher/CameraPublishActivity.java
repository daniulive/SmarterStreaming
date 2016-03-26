/*
 * CameraPublishActivity.java
 * CameraPublishActivity
 * 
 * Created by DaniuLive on 2015/09/20.
 * Copyright © 2014~2016 DaniuLive. All rights reserved.
 */

package org.daniulive.smartpublisher;

import java.io.IOException;

import com.voiceengine.NTAudioRecord;

import android.annotation.SuppressLint; //new api
import android.app.Activity;
import android.content.Context;
import android.content.res.Configuration;
import android.graphics.ImageFormat;
import android.graphics.PixelFormat;
import android.hardware.Camera;
import android.hardware.Camera.CameraInfo;
import android.hardware.Camera.Parameters;
import android.hardware.Camera.PreviewCallback;
import android.hardware.Camera.Size;
import android.os.Bundle;
import android.util.Log;
import android.view.SurfaceHolder;
import android.view.SurfaceHolder.Callback;
import android.view.SurfaceView;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemSelectedListener;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.Spinner;
import android.widget.TextView;
import android.hardware.Camera.AutoFocusCallback;

import java.nio.ByteBuffer;
import android.util.Log;


@SuppressWarnings("deprecation")
public class CameraPublishActivity extends Activity implements Callback, PreviewCallback 
{
	private static String TAG = "SmartPublisher";
	private TextView textCurURL = null;
	private SmartPublisherJni libPublisher = null;
	
	private Spinner serverSelector;
	private Spinner resolutionSelector;
	private ImageView imgSwitchCamera;
	private Button btnStartStop;
	
	private SurfaceView mSurfaceView = null;  
    private SurfaceHolder mSurfaceHolder = null;  
    
    private Camera mCamera = null;  
	private Context context;
	private AutoFocusCallback myAutoFocusCallback = null;
	
	private boolean mPreviewRunning = false; 
	NTAudioRecord audioRecord_ = null;
	private boolean isStart = false;
	
	private String publishURL;
	final private String baseURL = "rtmp://daniulive.com:1935/hls/stream";
	
	private String printText = "URL:";
	
	private static final int FRONT = 1;		//前置摄像头标记
	private static final int BACK = 2;		//后置摄像头标记
	private int currentCameraType = BACK;	//当前打开的摄像头标记
	private static final int PORTRAIT = 1;	//竖屏
	private static final int LANDSCAPE = 2;	//横屏
	private int currentOrigentation = PORTRAIT;
	    
	private int videoWidth = 640;
	private int videoHight = 480;
	
	private ByteBuffer videoByteBuffer = null;
	
	private int frameCount = 0;
	
    static {
        System.load("libSmartPublisher.so");
    }
    
	
	@Override
    public void onCreate(Bundle savedInstanceState) 
    {
        Log.i(TAG, "onCreate..");

        //publishURL = baseURL + String.valueOf((int)( System.currentTimeMillis() % 1000000));   
        //printText = printText + publishURL;
        
       // Log.i(TAG, printText);
        
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        serverSelector = (Spinner)findViewById(R.id.serverSelctor);
        final String []servers = new String[]{"电信", "移动", "CDN"};
        ArrayAdapter<String> adapterServer = new ArrayAdapter<String>(this,
                android.R.layout.simple_spinner_item, servers);
        adapterServer.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        serverSelector.setAdapter(adapterServer);

        serverSelector.setOnItemSelectedListener(new OnItemSelectedListener() {

			@Override
			public void onItemSelected(AdapterView<?> parent, View view,
					int position, long id) {
				Log.i(TAG, "Currently choosing: " + servers[position]);
			}

			@Override
			public void onNothingSelected(AdapterView<?> parent) {
				
			}
		});
        
        resolutionSelector = (Spinner)findViewById(R.id.resolutionSelctor);
        final String []resolutionSel = new String[]{"高分辨率", "中分辨率", "低分辨率", "超高分辨率"};
        ArrayAdapter<String> adapterResolution = new ArrayAdapter<String>(this,
                android.R.layout.simple_spinner_item, resolutionSel);
        adapterResolution.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        resolutionSelector.setAdapter(adapterResolution);

        resolutionSelector.setOnItemSelectedListener(new OnItemSelectedListener() {

			@Override
			public void onItemSelected(AdapterView<?> parent, View view,
					int position, long id) {
				
				if(isStart)
				{
					Log.e(TAG, "Could not switch resolution during publishing..");
					return;
				}
				
				Log.i(TAG, "Currently choosing: " + resolutionSel[position]);
				
				SwitchResolution(position);
				
			}

			@Override
			public void onNothingSelected(AdapterView<?> parent) {
				
			}
		});
        
        textCurURL = (TextView)findViewById(R.id.txtCurURL);
        textCurURL.setText(printText);
        
        btnStartStop = (Button)findViewById(R.id.button_start_stop);
        btnStartStop.setOnClickListener(new ButtonStartListener());
        imgSwitchCamera = (ImageView)findViewById(R.id.button_switchCamera);
        imgSwitchCamera.setOnClickListener(new SwitchCameraListener());
        
        mSurfaceView = (SurfaceView) this.findViewById(R.id.surface);  
        mSurfaceHolder = mSurfaceView.getHolder();  
        mSurfaceHolder.addCallback(this);  
        mSurfaceHolder.setType(SurfaceHolder.SURFACE_TYPE_PUSH_BUFFERS); 
       
        
        mSurfaceView.getHolder().setKeepScreenOn(true); // 保持屏幕高亮 
        
        //自动聚焦变量回调       
        myAutoFocusCallback = new AutoFocusCallback() 
		{  
  
            public void onAutoFocus(boolean success, Camera camera) {  
                if(success)//success表示对焦成功  
                {  
                    Log.i(TAG, "onAutoFocus succeed...");   
                }  
                else  
                {  
                    Log.i(TAG, "onAutoFocus failed...");  
                }  
            }  
        }; 
        
        libPublisher = new SmartPublisherJni();
    }
	
    class SwitchCameraListener implements OnClickListener
    {
        public void onClick(View v)
        {    
        	Log.i(TAG, "Switch camera..");
        	 try {
                 changeCamera();
             } catch (IOException e) {
                 // TODO Auto-generated catch block
                 e.printStackTrace();
             }
         }
    };
    
    void SwitchResolution(int position)
    {
    	Log.i(TAG, "Current Resolution position: " + position);
    	
    	switch(position) {
        case 0:
        	videoWidth = 640;
    		videoHight = 480;
            break;
        case 1:
    		videoWidth = 320;
    		videoHight = 240;
            break;
        case 2:
    		videoWidth = 176;
    		videoHight = 144;
            break;
        case 3:
    		videoWidth = 1280;
    		videoHight = 720;
            break;
        default:
        	videoWidth = 640;
    		videoHight = 480;
    	}
    	   	
    	mCamera.stopPreview();   
        initCamera(mSurfaceHolder);
        
        libPublisher.SmartPublisherInit(videoWidth, videoHight);
    }
    
    void CheckInitAudioRecorder()
    {
    	if ( audioRecord_ == null )
		{
			audioRecord_ = new NTAudioRecord(this, 1);
			
		}
			
        if(audioRecord_ != null)
        {
        	Log.i(TAG, "onCreate, call executeAudioRecordMethod.."); 
        	audioRecord_.executeAudioRecordMethod();
        }
    }
    
    class ButtonStartListener implements OnClickListener
    {
        public void onClick(View v)
        {    
        	if (isStart)
        	{
        		stop();
        		return;
        	}
        	isStart = true;
        	btnStartStop.setText(" 停止推流 ");
        	Log.i(TAG, "onClick start..");        
            
			if(libPublisher!=null)
			{
				 publishURL = baseURL + String.valueOf((int)( System.currentTimeMillis() % 1000000));   
			     printText = "URL:" + publishURL;
			        
			     Log.i(TAG, printText);
			     
			     textCurURL = (TextView)findViewById(R.id.txtCurURL);
			     textCurURL.setText(printText);
				
            	int isStarted = libPublisher.SmartPublisherStartPublish(publishURL);
            	if(isStarted != 0)
            	{
            		Log.e(TAG, "Failed to publish stream..");
            	}
			}
			
			CheckInitAudioRecorder();
 
        }
    };
    
    class ButtonStopListener implements OnClickListener
    {
        public void onClick(View v)
        {    
           //onDestroy();
        }
    };
    
    private void stop()
    {
    	Log.i(TAG, "onClick stop..");
    	StopPublish();
    	isStart = false;
    	btnStartStop.setText(" 开始推流 ");
    }

	@Override
    protected  void onDestroy(){
    	Log.i(TAG, "activity destory!");
    	super.onDestroy();
    	finish();
    	System.exit(0);
    }

	private void initCamera(SurfaceHolder holder)//it will call when surfaceChanged
	{  
		Log.i(TAG, "initCamera..");
	
		if(mPreviewRunning)
			mCamera.stopPreview();
		
		Camera.Parameters parameters;
		try {
			parameters = mCamera.getParameters();
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return;
		}
	
		parameters.setPreviewSize(videoWidth, videoHight);
		parameters.setPictureFormat(PixelFormat.JPEG); 
		parameters.setPreviewFormat(PixelFormat.YCbCr_420_SP); 
		
		// 横竖屏镜头自动调整
        if (this.getResources().getConfiguration().orientation != Configuration.ORIENTATION_LANDSCAPE) {
            parameters.set("orientation", "portrait"); //
            mCamera.setDisplayOrientation(90); // 在2.2以上可以使用
        } else// 如果是横屏
        {
            parameters.set("orientation", "landscape");
            mCamera.setDisplayOrientation(0); // 在2.2以上可以使用
        }		
		
		mCamera.setParameters(parameters); 

		int bufferSize = (((videoWidth|0xf)+1) * videoHight * ImageFormat.getBitsPerPixel(parameters.getPreviewFormat())) / 8;
		//bufferSize += bufferSize / 20;
		
		mCamera.addCallbackBuffer(new byte[bufferSize]);
		
		mCamera.setPreviewCallbackWithBuffer(this);  
        try {  
            mCamera.setPreviewDisplay(holder);  
        } catch (Exception ex) {
        	// TODO Auto-generated catch block 
        	if(null != mCamera){  
        		mCamera.release();  
        		mCamera = null;  
            }
        	ex.printStackTrace();
        }  
        mCamera.startPreview();  
        mCamera.autoFocus(myAutoFocusCallback);
        mPreviewRunning = true;  	
	}  
	
	@Override
	public void surfaceCreated(SurfaceHolder holder) {
		Log.i(TAG, "surfaceCreated..");
		try {
			
	        int CammeraIndex=FindBackCamera();
	        Log.i(TAG, "BackCamera: " + CammeraIndex);
	       
	        if(CammeraIndex==-1){  
	            CammeraIndex=FindFrontCamera();
	            currentCameraType = FRONT;
	            imgSwitchCamera.setEnabled(false);
	            if(CammeraIndex == -1)
	            {
	            	Log.i(TAG, "NO camera!!");
	            	return;
	            }   
	        }
	        else
	        {
	        	 currentCameraType = BACK;
	        }
			
	        if ( mCamera == null )
	        {
	        	mCamera = openCamera(currentCameraType);
	        }
	        
        } catch (Exception e) {
            e.printStackTrace();
        }

	}

	@Override
	public void surfaceChanged(SurfaceHolder holder, int format, int width, int height) {
		Log.i(TAG, "surfaceChanged..");
		initCamera(holder);
	}

	@Override
	public void surfaceDestroyed(SurfaceHolder holder) {
		// TODO Auto-generated method stub
		Log.i(TAG, "Surface Destroyed"); 
		/*
		if (mCamera != null) {  
            mCamera.setPreviewCallback(null);  
            mCamera.stopPreview();  
            mPreviewRunning = false;  
            mCamera.release();  
            mCamera = null;  
        }  
		
		if(audioRecord_ != null)
        {
			Log.i(TAG, "surfaceDestroyed, call StopRecording.."); 
        	audioRecord_.StopRecording();
        	audioRecord_ = null;
        }
        */
	}
	
	public void onConfigurationChanged(Configuration newConfig) {  
        try {  
            super.onConfigurationChanged(newConfig);  
        	Log.i(TAG, "onConfigurationChanged, start:" + isStart);
            if (this.getResources().getConfiguration().orientation == Configuration.ORIENTATION_LANDSCAPE) { 
            	if(!isStart)
            		currentOrigentation = LANDSCAPE;
            } else if (this.getResources().getConfiguration().orientation == Configuration.ORIENTATION_PORTRAIT) {
            	if(!isStart)
            		currentOrigentation = PORTRAIT;
            }  
        } catch (Exception ex) {  
        }  
    }

	@Override
	public void onPreviewFrame(byte[] data, Camera camera) {
		// forward image data to JNI
		
		frameCount++;
		if ( frameCount % 3000 == 0 )
		{
			Log.i("OnPre", "gc+");
			System.gc();
			Log.i("OnPre", "gc-");
		}
	
		if (data == null) {
			Parameters params = camera.getParameters();
			Size size = params.getPreviewSize();
			int bufferSize = (((size.width|0x1f)+1) * size.height * ImageFormat.getBitsPerPixel(params.getPreviewFormat())) / 8;
			//bufferSize += bufferSize / 20;
			camera.addCallbackBuffer(new byte[bufferSize]);
		} 
		else {
			if(isStart)
			{
				libPublisher.SmartPublisherOnCaptureVideoData(data, data.length, currentCameraType, currentOrigentation);	
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
        
        currentCameraType = type;
        if(type == FRONT && frontIndex != -1){
            return Camera.open(frontIndex);
        }else if(type == BACK && backIndex != -1){
            return Camera.open(backIndex);
        }
        return null;
    }
	
	 private void changeCamera() throws IOException{
		 	mCamera.stopPreview();
		 	mCamera.release();
	        if(currentCameraType == FRONT){
	        	mCamera = openCamera(BACK);
	        }else if(currentCameraType == BACK){
	        	mCamera = openCamera(FRONT);
	        }
	        
	        initCamera(mSurfaceHolder);
	      
	    }
	 
	 private void StopPublish()
	 {
		 if(audioRecord_ != null)
	        {
				Log.i(TAG, "surfaceDestroyed, call StopRecording.."); 
	        	audioRecord_.StopRecording();
	        	audioRecord_ = null;
	        }
         
		 if ( libPublisher != null )
		 {
			 libPublisher.SmartPublisherStopPublish();
		 }
	 }
	 
	private int FindFrontCamera(){	
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
    private int FindBackCamera(){
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
}