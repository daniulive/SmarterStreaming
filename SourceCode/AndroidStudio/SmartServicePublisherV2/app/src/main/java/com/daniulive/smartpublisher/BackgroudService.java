/*
 * BackgroudService.java
 * BackgroudService
 * 
 * Github: https://github.com/daniulive/SmarterStreaming
 * 
 * Created by DaniuLive on 2016/12/12.
 * Copyright (C) 2014~2018 DaniuLive. All rights reserved.
 */

package com.daniulive.smartpublisher;

import java.nio.ByteBuffer;

import com.eventhandle.NTSmartEventCallbackV2;
import com.eventhandle.NTSmartEventID;
import com.voiceengine.NTAudioRecordV2;
import com.voiceengine.NTAudioRecordV2Callback;

import android.annotation.SuppressLint;
import android.annotation.TargetApi;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.content.res.Configuration;
import android.hardware.display.DisplayManager;
import android.hardware.display.VirtualDisplay;
import android.media.Image;
import android.media.ImageReader;
import android.media.projection.MediaProjection;
import android.media.projection.MediaProjectionManager;
import android.os.Build;
import android.os.IBinder;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.Surface;
import android.view.SurfaceHolder;
import android.view.WindowManager;
import java.util.ArrayList;

@SuppressLint({"ClickableViewAccessibility", "NewApi"})
public class BackgroudService extends Service implements
        SurfaceHolder.Callback {

    /**
     * 窗口管理者
     */
    private WindowManager mWindowManager;

    // desk capture
    private int mScreenDensity;
    private int sreenWindowWidth;
    private int screenWindowHeight;
    private VirtualDisplay mVirtualDisplay;
    private ImageReader mImageReader;

    private MediaProjectionManager mMediaProjectionManager;
    private MediaProjection mMediaProjection;

    private static final String TAG = "SmartServicePublisher";

    NTAudioRecordV2 audioRecord_ = null;
    NTAudioRecordV2Callback audioRecordCallback_ = null;

    private long publisherHandle = 0;    //推送handle
    private long rtsp_handle_ = 0;       //RTSP handle

    private SmartPublisherJniV2 libPublisher = null;

    private String txt = "当前状态";

    private int audio_opt = 1;
    private int video_opt = 1;

    private final int SCREEN_RESOLUTION_STANDARD = 0;
    private final int SCREEN_RESOLUTION_LOW = 1;

    private int screenResolution = SCREEN_RESOLUTION_STANDARD;

    private final int PUSH_TYPE_RTMP = 0;
    private final int PUSH_TYPE_RTSP = 1;

    private int push_type = PUSH_TYPE_RTMP;

    private String recDir = "/sdcard/daniulive/rec"; // for recorder path

    private boolean is_need_local_recorder = false; // do not enable recorder in
    // default

    private boolean isPushing = false;    //RTMP推送状态
    private boolean isRecording = false;    //录像状态
    private boolean isRTSPServiceRunning = false;    //RTSP服务状态
    private boolean isRTSPPublisherRunning = false;  //RTSP流发布状态

    private int sw_video_encoder_profile = 1;    //default with baseline profile

    private boolean is_sw_vbr_mode = true;          //默认软编码可变码率

    /* 推送类型选择
     * 0: 视频软编码(H.264)
     * 1: 视频硬编码(H.264)
     * 2: 视频硬编码(H.265)
     * */
    private int videoEncodeType = 0;

    private Thread post_data_thread = null;

    private boolean is_post_data_thread_alive = false;

    private int width_  = 0;

    private int height_ = 0;

    private int row_stride_ = 0;

    private ArrayList<ByteBuffer> data_list = new ArrayList<ByteBuffer>();

    private int frame_added_interval_setting = 300;    //如果300ms没有数据帧回调下去，补帧，可自行设置补帧间隔

    static {
        System.loadLibrary("SmartPublisher");
    }

    @Override
    public void onCreate() {
        super.onCreate();
        Log.i(TAG, "onCreate..");

        libPublisher = new SmartPublisherJniV2();

        libPublisher.InitRtspServer(this.getApplicationContext());
    }

    @SuppressWarnings("deprecation")
    @Override
    public void onStart(Intent intent, int startId) {
        // TODO Auto-generated method stub
        super.onStart(intent, startId);
        Log.i(TAG, "onStart++");

        if (libPublisher == null)
            return;

        synchronized(this)
        {
            data_list.clear();
        }

        screenResolution = intent.getExtras().getInt("SCREENRESOLUTION");

        videoEncodeType = intent.getExtras().getInt("VIDEOENCODETYPE");

        push_type = intent.getExtras().getInt("PUSHTYPE");

        Log.e(TAG, "push_type: " + push_type);

        mWindowManager = (WindowManager) getSystemService(Service.WINDOW_SERVICE);

        // 窗口管理者
        createScreenEnvironment();
        startRecorderScreen();

        //如果同时推送和录像，设置一次就可以
        InitAndSetConfig();

        if ( publisherHandle == 0 )
        {
            stopScreenCapture();

            return;
        }

        if(push_type == PUSH_TYPE_RTMP)
        {
            String publishURL = intent.getStringExtra("PUBLISHURL");

            Log.i(TAG, "publishURL: " + publishURL);

            if (libPublisher.SmartPublisherSetURL(publisherHandle, publishURL) != 0) {
                stopScreenCapture();

                Log.e(TAG, "Failed to set publish stream URL..");

                if (publisherHandle != 0) {
                    if (libPublisher != null) {
                        libPublisher.SmartPublisherClose(publisherHandle);
                        publisherHandle = 0;
                    }
                }

                return;
            }
        }

        //启动传递数据线程
        post_data_thread = new Thread(new DataRunnable());
        Log.i(TAG, "new post_data_thread..");

        is_post_data_thread_alive = true;
        post_data_thread.start();

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
                //return;   //注释掉掉话，录像不成功也可以推送
            }
            else
            {
                isRecording = true;
            }
        }
        //录像相关——

        if(push_type == PUSH_TYPE_RTMP)
        {
            Log.e(TAG, "Push RTMP..");
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
        }
        else if(push_type == PUSH_TYPE_RTSP)
        {
            Log.e(TAG, "Push RTSP..");

            if (isRTSPPublisherRunning)
            {
                stopRtspPublisher();
                isRTSPPublisherRunning = false;
                if (isRTSPServiceRunning)
                {
                    stopRtspService();
                    isRTSPServiceRunning = false;
                    return;
                }
                return;
            }

            Log.i(TAG, "onClick start rtsp service..");

            rtsp_handle_ = libPublisher.OpenRtspServer(0);

            if (rtsp_handle_ == 0) {
                Log.e(TAG, "创建rtsp server实例失败! 请检查SDK有效性");
            } else {
                int port = 8554;
                if (libPublisher.SetRtspServerPort(rtsp_handle_, port) != 0) {
                    libPublisher.CloseRtspServer(rtsp_handle_);
                    rtsp_handle_ = 0;
                    Log.e(TAG, "创建rtsp server端口失败! 请检查端口是否重复或者端口不在范围内!");
                }

                //String user_name = "admin";
                //String password = "12345";

                //libPublisher.SetRtspServerUserNamePassword(rtsp_handle_, user_name, password);

                if (libPublisher.StartRtspServer(rtsp_handle_, 0) == 0) {
                    Log.i(TAG, "启动rtsp server 成功!");
                } else {
                    libPublisher.CloseRtspServer(rtsp_handle_);
                    rtsp_handle_ = 0;
                    Log.e(TAG, "启动rtsp server失败! 请检查设置的端口是否被占用!");
                }

                isRTSPServiceRunning = true;
            }

            if(isRTSPServiceRunning)
            {
                Log.i(TAG, "onClick start rtsp publisher..");

                String rtsp_stream_name = "stream1";
                libPublisher.SetRtspStreamName(publisherHandle, rtsp_stream_name);
                libPublisher.ClearRtspStreamServer(publisherHandle);

                libPublisher.AddRtspStreamServer(publisherHandle, rtsp_handle_, 0);

                if (libPublisher.StartRtspStream(publisherHandle, 0) != 0) {
                    Log.e(TAG, "调用发布rtsp流接口失败!");
                    return;
                }

                isRTSPPublisherRunning = true;
            }
        }

        //如果同时推送和录像，Audio启动一次就可以了
        CheckInitAudioRecorder();

        Log.i(TAG, "onStart--");
    }

    private void stopPush() {
        if(!isPushing)
        {
            return;
        }

        if (!isRecording && !isRTSPPublisherRunning) {
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

        if (!isRecording && !isRTSPPublisherRunning) {
            if (publisherHandle != 0) {
                if (libPublisher != null) {
                    libPublisher.SmartPublisherClose(publisherHandle);
                    publisherHandle = 0;
                }
            }
        }
    }

    private void stopRecorder() {
        if(!isRecording)
        {
            return;
        }
        if (!isPushing && !isRTSPPublisherRunning) {
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

        if (!isPushing && !isRTSPPublisherRunning) {
            if (publisherHandle != 0) {
                if (libPublisher != null) {
                    libPublisher.SmartPublisherClose(publisherHandle);
                    publisherHandle = 0;
                }
            }
        }
    }

    //停止发布RTSP流
    private void stopRtspPublisher() {
        if(!isRTSPPublisherRunning)
        {
            return;
        }

        if (!isPushing && !isRecording) {
            if (audioRecord_ != null) {
                Log.i(TAG, "stopRtspPublisher, call audioRecord_.StopRecording..");

                audioRecord_.Stop();

                if (audioRecordCallback_ != null) {
                    audioRecord_.RemoveCallback(audioRecordCallback_);
                    audioRecordCallback_ = null;
                }

                audioRecord_ = null;
            }
        }

        if (libPublisher != null) {
            libPublisher.StopRtspStream(publisherHandle);
        }

        if (!isPushing && !isRecording) {
            if (publisherHandle != 0) {
                if (libPublisher != null) {
                    libPublisher.SmartPublisherClose(publisherHandle);
                    publisherHandle = 0;
                }
            }
        }
    }

    //停止RTSP服务
    private void stopRtspService() {
        if(!isRTSPServiceRunning)
        {
            return;
        }

        if (libPublisher != null && rtsp_handle_ != 0) {
            libPublisher.StopRtspServer(rtsp_handle_);
            libPublisher.CloseRtspServer(rtsp_handle_);
            rtsp_handle_ = 0;
        }
    }

    @Override
    public void onDestroy() {
        // TODO Auto-generated method stub
        Log.i(TAG, "Service stopped..");

        stopScreenCapture();

        synchronized(this)
        {
            data_list.clear();
        }

        if( is_post_data_thread_alive && post_data_thread != null )
        {
            Log.i(TAG, "onDestroy close post_data_thread++");

            is_post_data_thread_alive = false;

            try {
                post_data_thread.join();
            } catch (InterruptedException e) {
                e.printStackTrace();
            }

            post_data_thread = null;

            Log.i(TAG, "onDestroy post_data_thread closed--");
        }

        if (isPushing || isRecording || isRTSPPublisherRunning)
        {
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
            isPushing = false;

            stopRecorder();
            isRecording = false;

            stopRtspPublisher();
            isRTSPPublisherRunning = false;

            stopRtspService();
            isRTSPServiceRunning = false;

            if (publisherHandle != 0) {
                if (libPublisher != null) {
                    libPublisher.SmartPublisherClose(publisherHandle);
                    publisherHandle = 0;
                }
            }
        }

        libPublisher.UnInitRtspServer();

        super.onDestroy();
    }

    @Override
    public IBinder onBind(Intent intent) {
        Log.i(TAG, "onBind..");
        return null;
    }

    @Override
    public boolean onUnbind(Intent intent) {
        Log.i(TAG, "onUnbind..");
        return super.onUnbind(intent);
    }

    @TargetApi(Build.VERSION_CODES.LOLLIPOP)
    private boolean startScreenCapture() {
        Log.i(TAG, "startScreenCapture..");

        setupMediaProjection();
        setupVirtualDisplay();

        return true;
    }

    private int align(int d, int a) {
        return (((d) + (a - 1)) & ~(a - 1));
    }

    @SuppressWarnings("deprecation")
    @SuppressLint("NewApi")
    private void createScreenEnvironment() {
        sreenWindowWidth = mWindowManager.getDefaultDisplay().getWidth();
        screenWindowHeight = mWindowManager.getDefaultDisplay().getHeight();

        if (sreenWindowWidth > 800) {
            if (screenResolution == SCREEN_RESOLUTION_STANDARD) {
                sreenWindowWidth = align(sreenWindowWidth / 2, 16);
                screenWindowHeight = align(screenWindowHeight / 2, 16);
            } else {
                sreenWindowWidth = align(sreenWindowWidth * 2 / 5, 16);
                screenWindowHeight = align(screenWindowHeight * 2 / 5, 16);
            }
        }

        Log.i(TAG, "mWindowWidth : " + sreenWindowWidth + ",mWindowHeight : "
                + screenWindowHeight);
        DisplayMetrics displayMetrics = new DisplayMetrics();
        mWindowManager.getDefaultDisplay().getMetrics(displayMetrics);
        mScreenDensity = displayMetrics.densityDpi;

        mImageReader = ImageReader.newInstance(sreenWindowWidth,
                screenWindowHeight, 0x1, 2);

        mMediaProjectionManager = (MediaProjectionManager) getSystemService(Context.MEDIA_PROJECTION_SERVICE);
    }

    @SuppressLint("NewApi")
    private void setupMediaProjection() {
        mMediaProjection = mMediaProjectionManager.getMediaProjection(
                MainActivity.mResultCode, MainActivity.mResultData);
    }

    @SuppressLint("NewApi")
    private void setupVirtualDisplay() {
        mVirtualDisplay = mMediaProjection.createVirtualDisplay(
                "ScreenCapture", sreenWindowWidth, screenWindowHeight,
                mScreenDensity,
                DisplayManager.VIRTUAL_DISPLAY_FLAG_AUTO_MIRROR,
                mImageReader.getSurface(), null, null);

        mImageReader.setOnImageAvailableListener(
                new ImageReader.OnImageAvailableListener() {
                    @Override
                    public void onImageAvailable(ImageReader reader) {
                        Image image = mImageReader.acquireLatestImage();
                        if (image != null) {
                            processScreenImage(image);
                            image.close();
                        }
                    }
                }, null);
    }

    private void startRecorderScreen() {
        Log.i(TAG, "start recorder screen..");
        if (startScreenCapture()) {
            new Thread() {
                @Override
                public void run() {
                    Log.i(TAG, "start record..");
                }
            }.start();
        }
    }

    private ByteBuffer deepCopy(ByteBuffer source) {

        int sourceP = source.position();
        int sourceL = source.limit();

        ByteBuffer target = ByteBuffer.allocateDirect(source.remaining());

        target.put(source);
        target.flip();

        source.position(sourceP);
        source.limit(sourceL);
        return target;
    }

    /**
     * Process image data as desired.
     */
    @SuppressLint("NewApi")
    private void processScreenImage(Image image) {

        if(!isPushing && !isRecording &&!isRTSPPublisherRunning)
        {
            return;
        }

        final Image.Plane[] planes = image.getPlanes();

        width_ = image.getWidth();
        height_ = image.getHeight();

        row_stride_ = planes[0].getRowStride();

        ByteBuffer buf = deepCopy(planes[0].getBuffer());

        synchronized(this)
        {
            data_list.add(buf);
        }
    }

    @SuppressLint("NewApi")
    private void stopScreenCapture() {
        if (mVirtualDisplay != null) {
            mVirtualDisplay.release();
            mVirtualDisplay = null;
        }
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
                case NTSmartEventID.EVENT_DANIULIVE_ERC_PUBLISHER_RTSP_URL:
                    txt = "RTSP服务URL: " + param3;
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

            if ( publisherHandle != 0 && (isRecording || isPushing || isRTSPPublisherRunning) )
            {
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

            //audioRecord_.IsMicSource(true);		//如音频采集声音过小，建议开启

            // audioRecord_.IsRemoteSubmixSource(true);

            audioRecord_.AddCallback(audioRecordCallback_);

            audioRecord_.Start();

            Log.i(TAG, "CheckInitAudioRecorder call audioRecord_.start()---...");


            //Log.i(TAG, "onCreate, call executeAudioRecordMethod..");
            // auido_ret: 0 ok, other failed
            //int auido_ret= audioRecord_.executeAudioRecordMethod();
            //Log.i(TAG, "onCreate, call executeAudioRecordMethod.. auido_ret=" + auido_ret);
        }
    }

    //设置H.264/H.265硬编码码率(按照25帧计算)
    private int setHardwareEncoderKbps(boolean isH264, int width, int height)
    {
        int kbit_rate = 2000;
        int area = width * height;

        if (area <= (320 * 300)) {
            kbit_rate = isH264?450:380;
        } else if (area <= (370 * 320)) {
            kbit_rate = isH264?570:500;
        } else if (area <= (640 * 360)) {
            kbit_rate = isH264?850:750;
        } else if (area <= (640 * 480)) {
            kbit_rate = isH264?1000:900;
        } else if (area <= (800 * 600)) {
            kbit_rate = isH264?1150:1050;
        } else if (area <= (1000 * 700)) {
            kbit_rate = isH264?1450:1200;
        } else if (area <= (1280 * 720)) {
            kbit_rate = isH264?2000:1600;
        } else if (area <= (1366 * 768)) {
            kbit_rate = isH264?2200:1900;
        } else if (area <= (1600 * 900)) {
            kbit_rate = isH264?2700:2300;
        } else if (area <= (1600 * 1050)) {
            kbit_rate =isH264?3000:2500;
        } else if (area <= (1920 * 1080)) {
            kbit_rate = isH264?4500:2800;
        } else {
            kbit_rate = isH264?4000:3000;
        }
        return kbit_rate;
    }

    private int CalVideoQuality(int w, int h, boolean is_h264)
    {
        int area = w*h;

        int quality = is_h264 ? 23 : 28;

        if ( area <= (320 * 240) )
        {
            quality = is_h264? 23 : 27;
        }
        else if ( area <= (640 * 360) )
        {
            quality = is_h264? 25 : 28;
        }
        else if ( area <= (640 * 480) )
        {
            quality = is_h264? 26 : 28;
        }
        else if ( area <= (960 * 600) )
        {
            quality = is_h264? 26 : 28;
        }
        else if ( area <= (1280 * 720) )
        {
            quality = is_h264? 27 : 29;
        }
        else if ( area <= (1600 * 900) )
        {
            quality = is_h264 ? 28 : 30;
        }
        else if ( area <= (1920 * 1080) )
        {
            quality = is_h264 ? 29 : 31;
        }
        else
        {
            quality = is_h264 ? 30 : 32;
        }

        return quality;
    }

    private int CalVbrMaxKBitRate(int w, int h)
    {
        int max_kbit_rate = 2000;

        int area = w*h;

        if (area <= (320 * 300))
        {
            max_kbit_rate = 320;
        }
        else if (area <= (360 * 320))
        {
            max_kbit_rate = 400;
        }
        else if (area <= (640 * 360))
        {
            max_kbit_rate = 600;
        }
        else if (area <= (640 * 480))
        {
            max_kbit_rate = 700;
        }
        else if (area <= (800 * 600))
        {
            max_kbit_rate = 800;
        }
        else if (area <= (900 * 700))
        {
            max_kbit_rate = 1000;
        }
        else if (area <= (1280 * 720))
        {
            max_kbit_rate = 1400;
        }
        else if (area <= (1366 * 768))
        {
            max_kbit_rate = 1700;
        }
        else if (area <= (1600 * 900))
        {
            max_kbit_rate = 2400;
        }
        else if (area <= (1600 * 1050))
        {
            max_kbit_rate = 2600;
        }
        else if (area <= (1920 * 1080))
        {
            max_kbit_rate = 2900;
        }
        else
        {
            max_kbit_rate = 3500;
        }

        return max_kbit_rate;
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
    }

    @Override
    public void surfaceChanged(SurfaceHolder holder, int format, int width,
                               int height) {
        Log.i(TAG, "surfaceChanged");
    }

    @Override
    public void surfaceDestroyed(SurfaceHolder holder) {
        Log.i(TAG, "surfaceDestroyed");
    }

    private void InitAndSetConfig() {
        //开始要不要采集音频或视频，请自行设置
        publisherHandle = libPublisher.SmartPublisherOpen(this.getApplicationContext(),
                audio_opt, video_opt, sreenWindowWidth,
                screenWindowHeight);

        if ( publisherHandle == 0 )
        {
            return;
        }

        Log.i(TAG, "publisherHandle=" + publisherHandle);

        libPublisher.SetSmartPublisherEventCallbackV2(publisherHandle, new EventHandeV2());

        if(videoEncodeType == 1)
        {
            int h264HWKbps = setHardwareEncoderKbps(true, sreenWindowWidth,
                    screenWindowHeight);

            Log.i(TAG, "h264HWKbps: " + h264HWKbps);

            int isSupportH264HWEncoder = libPublisher
                    .SetSmartPublisherVideoHWEncoder(publisherHandle, h264HWKbps);

            if (isSupportH264HWEncoder == 0) {
                Log.i(TAG, "Great, it supports h.264 hardware encoder!");
            }
        }
        else if (videoEncodeType == 2)
        {
            int hevcHWKbps = setHardwareEncoderKbps(false, sreenWindowWidth,
                    screenWindowHeight);

            Log.i(TAG, "hevcHWKbps: " + hevcHWKbps);

            int isSupportHevcHWEncoder = libPublisher
                    .SetSmartPublisherVideoHevcHWEncoder(publisherHandle, hevcHWKbps);

            if (isSupportHevcHWEncoder == 0) {
                Log.i(TAG, "Great, it supports hevc hardware encoder!");
            }
        }

        if(is_sw_vbr_mode)
        {
            int is_enable_vbr = 1;
            int video_quality = CalVideoQuality(sreenWindowWidth,
                    screenWindowHeight, true);
            int vbr_max_bitrate = CalVbrMaxKBitRate(sreenWindowWidth,
                    screenWindowHeight);

            libPublisher.SmartPublisherSetSwVBRMode(publisherHandle, is_enable_vbr, video_quality, vbr_max_bitrate);
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

        // libPublisher.SmartPublisherSetClippingMode(publisherHandle, 0);

        //libPublisher.SmartPublisherSetSWVideoEncoderProfile(publisherHandle, sw_video_encoder_profile);

        //libPublisher.SmartPublisherSetSWVideoEncoderSpeed(publisherHandle, sw_video_encoder_speed);

        // libPublisher.SetRtmpPublishingType(publisherHandle, 0);

         libPublisher.SmartPublisherSetFPS(publisherHandle, 18);    //帧率可调

         libPublisher.SmartPublisherSetGopInterval(publisherHandle, 18*3);

         libPublisher.SmartPublisherSetSWVideoBitRate(publisherHandle, 1200, 2400); //针对软编码有效，一般最大码率是平均码率的二倍

         libPublisher.SmartPublisherSetSWVideoEncoderSpeed(publisherHandle, 3);

         //libPublisher.SmartPublisherSaveImageFlag(publisherHandle, 1);

    }

    public void onConfigurationChanged(Configuration newConfig) {
        try {
            super.onConfigurationChanged(newConfig);
            if (this.getResources().getConfiguration().orientation == Configuration.ORIENTATION_LANDSCAPE) {
                Log.i(TAG, "onConfigurationChanged cur: LANDSCAPE");
            } else if (this.getResources().getConfiguration().orientation == Configuration.ORIENTATION_PORTRAIT) {
                Log.i(TAG, "onConfigurationChanged cur: PORTRAIT");
            }

            if(isPushing || isRecording || isRTSPPublisherRunning)
            {
                stopScreenCapture();
                synchronized(this)
                {
                    data_list.clear();
                }
                createScreenEnvironment();
                setupVirtualDisplay();
            }
        } catch (Exception ex) {
        }
    }

    public class DataRunnable implements Runnable{
        private final static String TAG = "DataRunnable==> ";

        @Override
        public void run() {
            // TODO Auto-generated method stub
            Log.i(TAG, "post data thread is running..");

            ByteBuffer last_buffer = null;

            long last_post_time = System.currentTimeMillis();

            while (is_post_data_thread_alive)
            {
                boolean is_skip = false;

                synchronized (this)
                {
                    if ( data_list.isEmpty())
                    {
                        if((System.currentTimeMillis() - last_post_time) > frame_added_interval_setting)
                        {
                            if(last_buffer != null)
                            {
                                Log.i(TAG, "补帧中..");
                            }
                            else
                            {
                                is_skip = true;
                            }
                        }
                        else
                        {
                           is_skip = true;
                        }
                    }
                    else
                    {
                        last_buffer = data_list.get(0);

                        data_list.remove(0);
                    }
                }

                if( is_skip )
                {
                    try {
                        Thread.sleep(10);   //休眠10ms
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                }
                else
                {
                    if( last_buffer != null && publisherHandle != 0 && (isPushing || isRecording || isRTSPPublisherRunning) )
                    {
                        libPublisher.SmartPublisherOnCaptureVideoRGBAData(publisherHandle, last_buffer, row_stride_,
                                width_, height_);

                        last_post_time = System.currentTimeMillis();

                        //Log.i(TAG, "post data: " + last_post_time);
                    }
                }
            }
        }
    }
}
