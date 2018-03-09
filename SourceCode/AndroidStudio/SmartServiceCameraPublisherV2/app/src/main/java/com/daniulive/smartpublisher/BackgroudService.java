/*
 * BackgroudService.java
 * BackgroudService
 * 
 * Github: https://github.com/daniulive/SmarterStreaming
 * 
 * Created by DaniuLive on 2016/12/12.
 * Copyright © 2014~2018 DaniuLive. All rights reserved.
 */

package com.daniulive.smartpublisher;

import java.nio.ByteBuffer;
import java.util.List;

import com.eventhandle.NTSmartEventCallbackV2;
import com.eventhandle.NTSmartEventID;
import com.voiceengine.NTAudioRecordV2;
import com.voiceengine.NTAudioRecordV2Callback;

import android.annotation.SuppressLint;
import android.annotation.TargetApi;
import android.app.Notification;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Intent;
import android.graphics.ImageFormat;
import android.graphics.PixelFormat;
import android.hardware.Camera;
import android.hardware.Camera.AutoFocusCallback;
import android.hardware.Camera.CameraInfo;
import android.hardware.Camera.Parameters;
import android.hardware.Camera.PreviewCallback;
import android.hardware.Camera.Size;
import android.os.Build;
import android.os.IBinder;
import android.util.Log;
import android.view.Gravity;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.WindowManager;

@SuppressLint({"ClickableViewAccessibility", "NewApi"})
public class BackgroudService extends Service implements
        SurfaceHolder.Callback, PreviewCallback {

    private boolean mPreviewRunning = false;

    /**
     * 窗口管理者
     */
    private WindowManager mWindowManager;

    private static final String TAG = "SmartServicePublisher";

    private static final int FRONT = 1; // 前置摄像头标记
    private static final int BACK = 2; // 后置摄像头标记
    private int currentCameraType = BACK; // 当前打开的摄像头标记
    private static final int PORTRAIT = 1; // 竖屏
    private static final int LANDSCAPE = 2; // 横屏
    private int currentOrigentation = PORTRAIT;
    private int curCameraIndex = -1;

    @SuppressWarnings("deprecation")
    private Camera mCamera = null;
    private AutoFocusCallback myAutoFocusCallback = null;

    private int videoWidth = 640;
    private int videoHeight = 480;

    private int frameCount = 0;

    Notification notification = null;
    private SurfaceView bgSurfaceView;

    NTAudioRecordV2 audioRecord_ = null;
    NTAudioRecordV2Callback audioRecordCallback_ = null;

    private long publisherHandle = 0;

    private SmartPublisherJniV2 libPublisher = null;

    private String txt = "当前状态";

    private int audio_opt = 1;
    private int video_opt = 1;

    private String recDir = "/sdcard/daniulive/rec"; // for recorder path

    private boolean is_need_local_recorder = false; // do not enable recorder in
    // default

    private boolean isPushing = false;
    private boolean isRecording = false;

    private int sw_video_encoder_profile = 1;    //default with baseline profile

    private boolean is_hardware_encoder = false;

    static {
        System.loadLibrary("SmartPublisher");
    }

    @Override
    public void onCreate() {
        super.onCreate();
        Log.i(TAG, "onCreate..");

        libPublisher = new SmartPublisherJniV2();
    }

    @SuppressWarnings("deprecation")
    @Override
    public void onStart(Intent intent, int startId) {
        // TODO Auto-generated method stub
        super.onStart(intent, startId);
        Log.i(TAG, "onStart..");

        videoWidth = intent.getExtras().getInt("CAMERAWIDTH");

        videoHeight = intent.getExtras().getInt("CAMERAHEIGHT");

        boolean isCameraFaceFront = intent.getExtras().getBoolean(
                "SWITCHCAMERA");

        Log.i(TAG, "videoWidth: " + videoWidth + "videoHeight: " + videoHeight + " isCameraFaceFront: " + isCameraFaceFront);

        if (isCameraFaceFront) {
            currentCameraType = FRONT;
        } else {
            currentCameraType = BACK;
        }

        is_hardware_encoder = intent.getExtras().getBoolean("HWENCODER");

        mWindowManager = (WindowManager) getSystemService(Service.WINDOW_SERVICE);

        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK
                | Intent.FLAG_ACTIVITY_SINGLE_TOP);
        PendingIntent contentIntent = PendingIntent.getActivity(this,
                0, intent, 0);

        /*
        Intent bIntent = new Intent(this, BackgroudService.class);

        PendingIntent deleteIntent = PendingIntent.getService(this, 0,
                bIntent, 0);

        notification = new Notification.Builder(this)
                .setContentTitle("后台采集中。。").setAutoCancel(true)
                .setDeleteIntent(deleteIntent)
                .setContentIntent(contentIntent).build();

        startForeground(android.os.Process.myPid(), notification);
        */

        bgSurfaceView = new SurfaceView(this);

        WindowManager.LayoutParams layoutParams = new WindowManager.LayoutParams(
                1, 1, WindowManager.LayoutParams.TYPE_SYSTEM_OVERLAY,
                WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH,
                PixelFormat.TRANSLUCENT);
        layoutParams.gravity = Gravity.LEFT | Gravity.TOP;
        mWindowManager.addView(bgSurfaceView, layoutParams);

        bgSurfaceView.getHolder().addCallback(this);

        if (libPublisher == null)
            return;

        //如果同时推送和录像，设置一次就可以
        InitAndSetConfig();

        String publishURL = intent.getStringExtra("PUBLISHURL");

        //String publishURL = "rtmp://player.daniulive.com:1935/hls/stream111";

        Log.i(TAG, "publishURL: " + publishURL);

        if (libPublisher.SmartPublisherSetURL(publisherHandle, publishURL) != 0) {
            Log.e(TAG, "Failed to set publish stream URL..");
        }

        //录像相关++
        is_need_local_recorder = intent.getExtras().getBoolean("RECORDER");

        ConfigRecorderFuntion(is_need_local_recorder);

        if(is_need_local_recorder)
        {
            int startRet = libPublisher.SmartPublisherStartRecorder(publisherHandle);
            if( startRet != 0 )
            {
                isRecording = false;

                Log.e(TAG, "Failed to start recorder.");
                return;
            }
            else
            {
                isRecording = true;
            }
        }
        //录像相关——

        //推流相关++
        int startRet = libPublisher.SmartPublisherStartPublisher(publisherHandle);

        if (startRet != 0) {
            isPushing = false;

            Log.e(TAG, "Failed to start push stream..");
            return;
        }
        else
        {
            isPushing = true;
        }
        //推流相关--

        //如果同时推送和录像，Audio启动一次就可以了
        CheckInitAudioRecorder();
    }

    private void stopPush() {
        if (!isRecording) {
            if (audioRecord_ != null) {
                Log.i(TAG, "stopPush, call audioRecord_.StopRecording..");


                audioRecord_.Stop();

                if (audioRecordCallback_ != null) {
                    audioRecord_.RemoveCallback(audioRecordCallback_);
                    audioRecordCallback_ = null;
                }

                audioRecord_ = null;
            }
        }

        if (libPublisher != null) {
            libPublisher.SmartPublisherStopPublisher(publisherHandle);
        }

        if (!isRecording) {
            if (publisherHandle != 0) {
                if (libPublisher != null) {
                    libPublisher.SmartPublisherClose(publisherHandle);
                    publisherHandle = 0;
                }
            }
        }
    }

    private void stopRecorder() {
        if (!isPushing) {
            if (audioRecord_ != null) {
                Log.i(TAG, "stopRecorder, call audioRecord_.StopRecording..");

                audioRecord_.Stop();

                if (audioRecordCallback_ != null) {
                    audioRecord_.RemoveCallback(audioRecordCallback_);
                    audioRecordCallback_ = null;
                }

                audioRecord_ = null;
            }
        }

        if (libPublisher != null) {
            libPublisher.SmartPublisherStopRecorder(publisherHandle);
        }

        if (!isPushing) {
            if (publisherHandle != 0) {
                if (libPublisher != null) {
                    libPublisher.SmartPublisherClose(publisherHandle);
                    publisherHandle = 0;
                }
            }
        }
    }

    @Override
    public void onDestroy() {
        // TODO Auto-generated method stub
        Log.i(TAG, "Service stopped..");

        if (isPushing || isRecording) {
            if (audioRecord_ != null) {
                Log.i(TAG, "surfaceDestroyed, call StopRecording..");

                audioRecord_.Stop();

                if (audioRecordCallback_ != null) {
                    audioRecord_.RemoveCallback(audioRecordCallback_);
                    audioRecordCallback_ = null;
                }

                audioRecord_ = null;
            }

            stopPush();
            stopRecorder();

            isPushing = false;
            isRecording = false;

            if (publisherHandle != 0) {
                if (libPublisher != null) {
                    libPublisher.SmartPublisherClose(publisherHandle);
                    publisherHandle = 0;
                }
            }
        }

        super.onDestroy();
    }

    @Override
    public IBinder onBind(Intent intent) {
        Log.e(TAG, "onBind..");
        return null;
    }

    @Override
    public boolean onUnbind(Intent intent) {
        Log.e(TAG, "onUnbind..");
        return super.onUnbind(intent);
    }

    class EventHandeV2 implements NTSmartEventCallbackV2 {
        @Override
        public void onNTSmartEventCallbackV2(long handle, int id, long param1, long param2, String param3, String param4, Object param5) {

            Log.i(TAG, "EventHandeV2: handle=" + handle + " id:" + id);

            switch (id) {
                case NTSmartEventID.EVENT_DANIULIVE_ERC_PUBLISHER_STARTED:
                    txt = "开始。。";
                    break;
                case NTSmartEventID.EVENT_DANIULIVE_ERC_PUBLISHER_CONNECTING:
                    txt = "连接中。。";
                    break;
                case NTSmartEventID.EVENT_DANIULIVE_ERC_PUBLISHER_CONNECTION_FAILED:
                    txt = "连接失败。。";
                    break;
                case NTSmartEventID.EVENT_DANIULIVE_ERC_PUBLISHER_CONNECTED:
                    txt = "连接成功。。";
                    break;
                case NTSmartEventID.EVENT_DANIULIVE_ERC_PUBLISHER_DISCONNECTED:
                    txt = "连接断开。。";
                    break;
                case NTSmartEventID.EVENT_DANIULIVE_ERC_PUBLISHER_STOP:
                    txt = "关闭。。";
                    break;
                case NTSmartEventID.EVENT_DANIULIVE_ERC_PUBLISHER_RECORDER_START_NEW_FILE:
                    Log.i(TAG, "开始一个新的录像文件 : " + param3);
                    txt = "开始一个新的录像文件。。";
                    break;
                case NTSmartEventID.EVENT_DANIULIVE_ERC_PUBLISHER_ONE_RECORDER_FILE_FINISHED:
                    Log.i(TAG, "已生成一个录像文件 : " + param3);
                    txt = "已生成一个录像文件。。";
                    break;

                case NTSmartEventID.EVENT_DANIULIVE_ERC_PUBLISHER_SEND_DELAY:
                    Log.i(TAG, "发送时延: " + param1 + " 帧数:" + param2);
                    txt = "收到发送时延..";
                    break;

                case NTSmartEventID.EVENT_DANIULIVE_ERC_PUBLISHER_CAPTURE_IMAGE:
                    Log.i(TAG, "快照: " + param1 + " 路径：" + param3);

                    if (param1 == 0) {
                        txt = "截取快照成功。.";
                    } else {
                        txt = "截取快照失败。.";
                    }
                    break;
            }

            String str = "当前回调状态：" + txt;

            Log.i(TAG, str);

        }
    }

    class NTAudioRecordV2CallbackImpl implements NTAudioRecordV2Callback {
        @Override
        public void onNTAudioRecordV2Frame(ByteBuffer data, int size, int sampleRate, int channel, int per_channel_sample_number) {
             /*
    		 Log.i(TAG, "onNTAudioRecordV2Frame size=" + size + " sampleRate=" + sampleRate + " channel=" + channel
    				 + " per_channel_sample_number=" + per_channel_sample_number);

    		 */

            if (publisherHandle != 0) {
                libPublisher.SmartPublisherOnPCMData(publisherHandle, data, size, sampleRate, channel, per_channel_sample_number);
            }
        }
    }

    void CheckInitAudioRecorder() {
        if (audioRecord_ == null) {
            //audioRecord_ = new NTAudioRecord(this, 1);

            audioRecord_ = new NTAudioRecordV2(this);
        }

        if (audioRecord_ != null) {
            Log.i(TAG, "CheckInitAudioRecorder call audioRecord_.start()+++...");

            audioRecordCallback_ = new NTAudioRecordV2CallbackImpl();

            audioRecord_.AddCallback(audioRecordCallback_);

            audioRecord_.Start();

            Log.i(TAG, "CheckInitAudioRecorder call audioRecord_.start()---...");

            //Log.i(TAG, "onCreate, call executeAudioRecordMethod..");
            // auido_ret: 0 ok, other failed
            //int auido_ret= audioRecord_.executeAudioRecordMethod();
            //Log.i(TAG, "onCreate, call executeAudioRecordMethod.. auido_ret=" + auido_ret);
        }
    }

    //这里硬编码码率是按照25帧来计算的
    private int setHardwareEncoderKbps(int width, int height) {
        int hwEncoderKpbs = 0;

        int area = width * height;

        if ( area < (200*180) )
        {
            hwEncoderKpbs = 300;
        }
        else if (area < (400*320) )
        {
            hwEncoderKpbs = 600;
        }
        else if (area < (640*500) )
        {
            hwEncoderKpbs = 1200;
        }
        else if (area < (960*600))
        {
            hwEncoderKpbs = 1500;
        }
        else if (area < (1300*720) )
        {
            hwEncoderKpbs = 2000;
        }
        else if ( area < (2000*1080) )
        {
            hwEncoderKpbs = 3000;
        }
        else
        {
            hwEncoderKpbs = 4000;
        }

        return hwEncoderKpbs;
    }

    // Configure recorder related function.
    void ConfigRecorderFuntion(boolean isNeedLocalRecorder) {
        if (libPublisher != null) {
            if (isNeedLocalRecorder) {
                if (recDir != null && !recDir.isEmpty()) {
                    int ret = libPublisher.SmartPublisherCreateFileDirectory(recDir);
                    if (0 == ret) {
                        if (0 != libPublisher.SmartPublisherSetRecorderDirectory(publisherHandle, recDir)) {
                            Log.e(TAG, "Set recoder dir failed , path:" + recDir);
                            return;
                        }

                        if (0 != libPublisher.SmartPublisherSetRecorder(publisherHandle, 1)) {
                            Log.e(TAG, "SmartPublisherSetRecoder failed.");
                            return;
                        }

                        if (0 != libPublisher.SmartPublisherSetRecorderFileMaxSize(publisherHandle, 200)) {
                            Log.e(TAG, "SmartPublisherSetRecoderFileMaxSize failed.");
                            return;
                        }

                    } else {
                        Log.e(TAG, "Create recoder dir failed, path:" + recDir);
                    }
                }
            } else {
                if (0 != libPublisher.SmartPublisherSetRecorder(publisherHandle, 0)) {
                    Log.e(TAG, "SmartPublisherSetRecoder failed.");
                    return;
                }
            }
        }
    }

    @Override
    public void surfaceCreated(SurfaceHolder holder) {
        Log.i(TAG, "surfaceCreated");

        try {
            if ( mCamera == null )
            {
                mCamera = openCamera(currentCameraType);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        initCamera(holder);
    }

    @Override
    public void surfaceChanged(SurfaceHolder holder, int format, int width,
                               int height) {
        Log.i(TAG, "surfaceChanged");
        initCamera(holder);
    }

    @Override
    public void surfaceDestroyed(SurfaceHolder holder) {
        Log.i(TAG, "surfaceDestroyed");

        mCamera.setPreviewCallback(null);
        mCamera.stopPreview();
        mCamera.release();
    }

    private void InitAndSetConfig() {
        //开始要不要采集音频或视频，请自行设置
        publisherHandle = libPublisher.SmartPublisherOpen(this.getApplicationContext(),
                audio_opt, video_opt, videoWidth,
                videoHeight);

        Log.i(TAG, "publisherHandle=" + publisherHandle);


        libPublisher.SetSmartPublisherEventCallbackV2(publisherHandle, new EventHandeV2());

        if (is_hardware_encoder) {
            int kbps = setHardwareEncoderKbps(videoWidth,
                    videoHeight);

            Log.i(TAG, "hwHWKbps: " + kbps);

            int isSupportHWEncoder = libPublisher
                    .SetSmartPublisherVideoHWEncoder(publisherHandle, kbps);

            if (isSupportHWEncoder == 0) {
                Log.i(TAG, "Great, it supports hardware encoder!");
            }
        }

        //水印可以参考SmartPublisher工程
		/*
		// 如果想和时间显示在同一行，请去掉'\n'
		String watermarkText = "大牛直播(daniulive)\n\n";

		String path = logoPath;

		if (watemarkType == 0)
		{
			if (isWritelogoFileSuccess)
				libPublisher.SmartPublisherSetPictureWatermark(publisherHandle, path,
						WATERMARK.WATERMARK_POSITION_TOPRIGHT, 160,
						160, 10, 10);

		}
		else if (watemarkType == 1)
		{
			if (isWritelogoFileSuccess)
				libPublisher.SmartPublisherSetPictureWatermark(publisherHandle, path,
						WATERMARK.WATERMARK_POSITION_TOPRIGHT, 160,
						160, 10, 10);

			libPublisher.SmartPublisherSetTextWatermark(publisherHandle, watermarkText, 1,
					WATERMARK.WATERMARK_FONTSIZE_BIG,
					WATERMARK.WATERMARK_POSITION_BOTTOMRIGHT, 10, 10);

			// libPublisher.SmartPublisherSetTextWatermarkFontFileName("/system/fonts/DroidSansFallback.ttf");

			// libPublisher.SmartPublisherSetTextWatermarkFontFileName("/sdcard/DroidSansFallback.ttf");
		}
		else if (watemarkType == 2)
		{
			libPublisher.SmartPublisherSetTextWatermark(publisherHandle, watermarkText, 1,
					WATERMARK.WATERMARK_FONTSIZE_BIG,
					WATERMARK.WATERMARK_POSITION_BOTTOMRIGHT, 10, 10);

			// libPublisher.SmartPublisherSetTextWatermarkFontFileName("/system/fonts/DroidSansFallback.ttf");
		} else
		{
			Log.i(TAG, "no watermark settings..");
		}
		// end
		*/

        //音频相关可以参考SmartPublisher工程
		/*
		if (!is_speex)
		{
			// set AAC encoder
			libPublisher.SmartPublisherSetAudioCodecType(publisherHandle, 1);
		}
		else
		{
			// set Speex encoder
			libPublisher.SmartPublisherSetAudioCodecType(publisherHandle, 2);
			libPublisher.SmartPublisherSetSpeexEncoderQuality(publisherHandle, 8);
		}

		libPublisher.SmartPublisherSetNoiseSuppression(publisherHandle, is_noise_suppression ? 1
				: 0);

		libPublisher.SmartPublisherSetAGC(publisherHandle, is_agc ? 1 : 0);
		*/

        libPublisher.SmartPublisherSetClippingMode(publisherHandle, 0);

        //libPublisher.SmartPublisherSetSWVideoEncoderProfile(publisherHandle, sw_video_encoder_profile);

        //libPublisher.SmartPublisherSetSWVideoEncoderSpeed(publisherHandle, sw_video_encoder_speed);

        // libPublisher.SetRtmpPublishingType(publisherHandle, 0);

         libPublisher.SmartPublisherSetFPS(publisherHandle, 18);

         libPublisher.SmartPublisherSetGopInterval(publisherHandle, 18*3);

         //libPublisher.SmartPublisherSetSWVideoBitRate(publisherHandle, 1200, 2400); //针对软编码有效

         libPublisher.SmartPublisherSetSWVideoEncoderSpeed(publisherHandle, 3);

         //libPublisher.SmartPublisherSaveImageFlag(publisherHandle, 1);

    }


    private void SetCameraFPS(Camera.Parameters parameters)
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
    private void initCamera(SurfaceHolder holder)
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

        parameters.setPreviewSize(videoWidth, videoHeight);
        parameters.setPictureFormat(PixelFormat.JPEG);
        parameters.setPreviewFormat(PixelFormat.YCbCr_420_SP);

        SetCameraFPS(parameters);

        mCamera.setParameters(parameters);

        int bufferSize = (((videoWidth|0xf)+1) * videoHeight * ImageFormat.getBitsPerPixel(parameters.getPreviewFormat())) / 8;

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
            curCameraIndex = frontIndex;
            return Camera.open(frontIndex);
        }else if(type == BACK && backIndex != -1){
            curCameraIndex = backIndex;
            return Camera.open(backIndex);
        }
        return null;
    }

    @Override
    public void onPreviewFrame(byte[] data, Camera camera) {
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
            camera.addCallbackBuffer(new byte[bufferSize]);
        }
        else
        {
            if(isPushing || isRecording)
            {
                libPublisher.SmartPublisherOnCaptureVideoData(publisherHandle, data, data.length, currentCameraType, currentOrigentation);
            }

            camera.addCallbackBuffer(data);
        }
    }
}
