/*
 * CameraPublishActivity.java
 * CameraPublishActivity
 *
 * Github: https://github.com/daniulive/SmarterStreaming
 *
 * Created by DaniuLive on 2015/09/20.
 * Copyright (C) 2014~2018 DaniuLive. All rights reserved.
 */

package com.daniulive.smartpublisher;

import com.daniulive.smartpublisher.SmartPublisherJniV2.WATERMARK;
import com.eventhandle.NTSmartEventCallbackV2;
import com.eventhandle.NTSmartEventID;
//import com.voiceengine.NTAudioRecord;	//for audio capture..
import com.voiceengine.NTAudioRecordV2;
import com.voiceengine.NTAudioRecordV2Callback;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.res.Configuration;
import android.graphics.ImageFormat;
import android.graphics.PixelFormat;
import android.hardware.Camera;
import android.hardware.Camera.CameraInfo;
import android.hardware.Camera.Parameters;
import android.hardware.Camera.PreviewCallback;
import android.hardware.Camera.Size;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.view.SurfaceHolder;
import android.view.SurfaceHolder.Callback;
import android.view.Surface;
import android.view.SurfaceView;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.WindowManager;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemSelectedListener;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.Spinner;
import android.widget.TextView;
import android.hardware.Camera.AutoFocusCallback;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;

import java.io.ByteArrayOutputStream;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.ByteBuffer;
import java.util.Random;

@SuppressWarnings("deprecation")
public class CameraPublishActivity extends Activity implements Callback, PreviewCallback {
    private static String TAG = "SmartPublisher";

    private SmartPublisherJniV2 libPublisher = null;

    //NTAudioRecord audioRecord_ = null;	//for audio capture
    NTAudioRecordV2 audioRecord_ = null;
    NTAudioRecordV2Callback audioRecordCallback_ = null;

    private Context myContext;    //上下文context
    private long publisherHandle = 0;    //推送handle
    private long rtsp_handle_ = 0;    //RTSP handle

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
    private Spinner watermarkSelctor;
    private int watemarkType = 3;

    /* 推流分辨率选择
     * 0: 640*480
     * 1: 320*240
     * 2: 720*480
     * 3: 1280*720
     * */
    //分辨率为演示方便设置4个档位，可与系统枚举到的分辨率比较后再设置，以防系统不支持
    private Spinner resolutionSelector;

    /* video软编码profile设置
     * 1: baseline profile
     * 2: main profile
     * 3: high profile
     * */
    private Spinner swVideoEncoderProfileSelector;
    private int sw_video_encoder_profile = 1;    //default with baseline profile

    private Button btnRecorderMgr;    //录像管理按钮
    private Button btnNoiseSuppression;    //噪音抑制按钮
    private Button btnAGC; //自动增益补偿按钮
    private Button btnSpeex;    //是否启用speex编码按钮，如不启用，默认AAC编码
    private Button btnMute;    //实时静音按钮
    private Button btnMirror; //实时镜像按钮

    private Spinner swVideoEncoderSpeedSelector;

    /* 推送类型选择
     * 0: 视频软编码(H.264)
     * 1: 视频硬编码(H.264)
     * 2: 视频硬编码(H.265)
     * */
    private Spinner videoEncodeTypeSelector;
    private int videoEncodeType = 0;

    private Button btnBitrateControl;    //编码码率类型选择：可变码率或固定码率，默认可变码率(软编码)
    private ImageView imgSwitchCamera;    //前后摄像头切换按钮
    private Button btnInputPushUrl;    //推送的RTMP url设置按钮
    private Button btnPushUserData;    //用户扩展数据发送按钮

    private Button btnStartPush;    //RTMP推送按钮
    private Button btnStartRecorder;    //录像按钮
    private Button btnCaptureImage;    //快照按钮

    private Button btnRtspService;    //启动、停止RTSP服务按钮
    private Button btnRtspPublisher;    //发布、停止RTSP流按钮
    private Button btnGetRtspSessionNumbers;    //获取RTSP会话数按钮

    private Button btnPushRtsp;    //启动、停止推送RTSP

    private SurfaceView mSurfaceView = null;
    private SurfaceHolder mSurfaceHolder = null;

    private Camera mCamera = null;
    private AutoFocusCallback myAutoFocusCallback = null;    //自动对焦

    private boolean mPreviewRunning = false; //priview状态
    private boolean isPushingRtmp = false;    //RTMP推送状态
    private boolean isRecording = false;    //录像状态
    private boolean isRTSPServiceRunning = false;    //RTSP服务状态
    private boolean isRTSPPublisherRunning = false; //RTSP流发布状态
    private boolean isPushingRtsp = false;     //RTSP推送状态

    final private String logoPath = "/sdcard/daniulivelogo.png";
    private boolean isWritelogoFileSuccess = false;

    private String publishURL;    //RTMP推送URL
    final private String baseURL = "rtmp://player.daniulive.com:1935/hls/stream";
    private String inputPushURL = "";
    private String printText = "推流URL:";

    private TextView textCurURL = null;    //UI推送URL展示
    private TextView textEventMsg = null;     //UI Event消息展示

    private static final int FRONT = 1;        //前置摄像头标记
    private static final int BACK = 2;        //后置摄像头标记
    private int currentCameraType = BACK;    //当前打开的摄像头标记
    private static final int PORTRAIT = 1;    //竖屏
    private static final int LANDSCAPE = 2;    //横屏 home键在右边的情况
    private static final int LANDSCAPE_LEFT_HOME_KEY = 3; // 横屏 home键在左边的情况
    private int currentOrigentation = PORTRAIT;
    private int curCameraIndex = -1;

    private int videoWidth = 640;
    private int videoHeight = 480;

    private int frameCount = 0;

    private String recDir = "/sdcard/daniulive/rec";    //for recorder path

    private boolean is_noise_suppression = true;
    private boolean is_agc = false;
    private boolean is_speex = false;
    private boolean is_mute = false;
    private boolean is_mirror = false;
    private int sw_video_encoder_speed = 3;
    private boolean is_sw_vbr_mode = true;

    private String imageSavePath;

    private static final int PUBLISHER_EVENT_MSG = 1;
    private static final int PUBLISHER_USER_DATA_MSG = 2;

    static {
        System.loadLibrary("SmartPublisher");
    }

    //用于读取asset目录下logo，方便图片水印测试
    private byte[] ReadAssetFileDataToByte(InputStream in) throws IOException {
        ByteArrayOutputStream bytestream = new ByteArrayOutputStream();
        int c = 0;

        while ((c = in.read()) != -1) {
            bytestream.write(c);
        }

        byte bytedata[] = bytestream.toByteArray();
        bytestream.close();
        return bytedata;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        Log.i(TAG, "onCreate..");

        super.onCreate(savedInstanceState);

        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);    //屏幕常亮

        setContentView(R.layout.activity_main);

        myContext = this.getApplicationContext();

        //设置快照路径(具体路径可自行设置)
        File storageDir = getOwnCacheDirectory(myContext, "daniuimage");//创建保存的路径
        imageSavePath = storageDir.getPath();
        Log.i(TAG, "快照存储路径: " + imageSavePath);

        //图片水印相关++++++++++
        try {
            InputStream logo_input_stream = getClass().getResourceAsStream(
                    "/assets/logo.png");

            byte[] logo_data = ReadAssetFileDataToByte(logo_input_stream);

            if (logo_data != null) {
                try {
                    FileOutputStream out = new FileOutputStream(logoPath);
                    out.write(logo_data);
                    out.close();
                    isWritelogoFileSuccess = true;
                } catch (Exception e) {
                    e.printStackTrace();
                    Log.e(TAG, "write logo file to /sdcard/ failed");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            Log.e(TAG, "write logo file to /sdcard/ failed");
        }
        //图片水印相关----------

        //音视频推送类型选择++++++++++
        pushTypeSelector = (Spinner) findViewById(R.id.pushTypeSelctor);
        final String[] types = new String[]{"音视频", "纯音频", "纯视频"};
        ArrayAdapter<String> adapterType = new ArrayAdapter<String>(this,
                android.R.layout.simple_spinner_item, types);
        adapterType.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        pushTypeSelector.setAdapter(adapterType);

        pushTypeSelector.setOnItemSelectedListener(new OnItemSelectedListener() {

            @Override
            public void onItemSelected(AdapterView<?> parent, View view,
                                       int position, long id) {

                if (isRTSPPublisherRunning || isPushingRtmp || isRecording || isPushingRtsp) {
                    Log.e(TAG, "Could not switch push type during publishing..");
                    return;
                }

                pushType = position;

                Log.i(TAG, "[推送类型]Currently choosing: " + types[position] + ", pushType: " + pushType);
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {

            }
        });
        //音视频推送类型选择----------

        //水印效果选择++++++++++
        watermarkSelctor = (Spinner) findViewById(R.id.watermarkSelctor);

        final String[] watermarks = new String[]{"图片水印", "全部水印", "文字水印", "不加水印"};

        ArrayAdapter<String> adapterWatermark = new ArrayAdapter<String>(this,
                android.R.layout.simple_spinner_item, watermarks);

        adapterWatermark.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);

        watermarkSelctor.setAdapter(adapterWatermark);

        watermarkSelctor.setSelection(3,true);
        watemarkType = 3;   //默认不加水印

        watermarkSelctor.setOnItemSelectedListener(new OnItemSelectedListener() {

            @Override
            public void onItemSelected(AdapterView<?> parent, View view,
                                       int position, long id) {
                if (isPushingRtmp || isRecording || isRTSPPublisherRunning|| isPushingRtsp) {
                    Log.e(TAG, "Could not switch watermark type during publishing..");
                    return;
                }

                watemarkType = position;

                Log.i(TAG, "[水印类型]Currently choosing: " + watermarks[position] + ", watemarkType: " + watemarkType);
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {

            }
        });
        //水印效果选择----------

        //采集分辨率选择++++++++++
        resolutionSelector = (Spinner) findViewById(R.id.resolutionSelctor);
        final String[] resolutionSel = new String[]{"680*480", "320*240", "864*480", "1280*720"};
        ArrayAdapter<String> adapterResolution = new ArrayAdapter<String>(this,
                android.R.layout.simple_spinner_item, resolutionSel);
        adapterResolution.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        resolutionSelector.setAdapter(adapterResolution);

        resolutionSelector.setOnItemSelectedListener(new OnItemSelectedListener() {

            @Override
            public void onItemSelected(AdapterView<?> parent, View view,
                                       int position, long id) {

                if (isPushingRtmp || isRecording || isRTSPPublisherRunning|| isPushingRtsp) {
                    Log.e(TAG, "Could not switch resolution during publishing..");
                    return;
                }

                Log.i(TAG, "[推送分辨率]Currently choosing: " + resolutionSel[position]);

                SwitchResolution(position);

            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {

            }
        });
        //采集分辨率选择----------

        //video编码profile选择++++++++++
        swVideoEncoderProfileSelector = (Spinner) findViewById(R.id.swVideoEncoderProfileSelector);
        final String[] profileSel = new String[]{"BaseLineProfile", "MainProfile", "HighProfile"};
        ArrayAdapter<String> adapterProfile = new ArrayAdapter<String>(this,
                android.R.layout.simple_spinner_item, profileSel);
        adapterProfile.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        swVideoEncoderProfileSelector.setAdapter(adapterProfile);

        swVideoEncoderProfileSelector.setOnItemSelectedListener(new OnItemSelectedListener() {

            @Override
            public void onItemSelected(AdapterView<?> parent, View view,
                                       int position, long id) {

                if (isRTSPPublisherRunning || isPushingRtmp || isRecording|| isPushingRtsp) {
                    Log.e(TAG, "Could not switch video profile during publishing..");
                    return;
                }

                Log.i(TAG, "[VideoProfile]Currently choosing: " + profileSel[position]);

                sw_video_encoder_profile = position + 1;
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {

            }
        });
        //video编码profile选择----------

        btnRecorderMgr = (Button) findViewById(R.id.button_recorder_mgr);
        btnRecorderMgr.setOnClickListener(new ButtonRecorderMangerListener());

        btnNoiseSuppression = (Button) findViewById(R.id.button_noise_suppression);
        btnNoiseSuppression.setOnClickListener(new ButtonNoiseSuppressionListener());

        btnAGC = (Button) findViewById(R.id.button_agc);
        btnAGC.setOnClickListener(new ButtonAGCListener());

        btnSpeex = (Button) findViewById(R.id.button_speex);
        btnSpeex.setOnClickListener(new ButtonSpeexListener());

        btnMute = (Button) findViewById(R.id.button_mute);
        btnMute.setOnClickListener(new ButtonMuteListener());

        btnMirror = (Button) findViewById(R.id.button_mirror);
        btnMirror.setOnClickListener(new ButtonMirrorListener());

        //video软编码speed设置++++++++++
        swVideoEncoderSpeedSelector = (Spinner) findViewById(R.id.sw_video_encoder_speed_selector);

        final String[] video_encoder_speed_Sel = new String[]{"6", "5", "4", "3", "2", "1"};
        ArrayAdapter<String> adapterVideoEncoderSpeed = new ArrayAdapter<String>(this,
                android.R.layout.simple_spinner_item, video_encoder_speed_Sel);

        adapterVideoEncoderSpeed.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        swVideoEncoderSpeedSelector.setAdapter(adapterVideoEncoderSpeed);

        swVideoEncoderSpeedSelector.setOnItemSelectedListener(new OnItemSelectedListener() {

            @Override
            public void onItemSelected(AdapterView<?> parent, View view,
                                       int position, long id) {

                Log.i(TAG, "Currently video encoder speed choosing: " + video_encoder_speed_Sel[position]);

                sw_video_encoder_speed = 6 - position;

                Log.i(TAG, "Choose speed=" + sw_video_encoder_speed);
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {

            }
        });
        //video软编码speed设置----------

        //视频编码类型选择++++++++++
        videoEncodeTypeSelector = (Spinner) findViewById(R.id.videoEncodeTypeSelector);
        final String[] videoEncodeTypes = new String[]{"软编(H.264)", "硬编(H.264)", "硬编(H.265)"};
        ArrayAdapter<String> adapterVideoEncodeType = new ArrayAdapter<String>(this,
                android.R.layout.simple_spinner_item, videoEncodeTypes);
        adapterVideoEncodeType.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        videoEncodeTypeSelector.setAdapter(adapterVideoEncodeType);

        videoEncodeTypeSelector.setOnItemSelectedListener(new OnItemSelectedListener() {

            @Override
            public void onItemSelected(AdapterView<?> parent, View view,
                                       int position, long id) {

                if (isRTSPPublisherRunning || isPushingRtmp || isRecording || isPushingRtsp) {
                    Log.e(TAG, "Could not switch video encoder type during publishing..");
                    return;
                }

                videoEncodeType = position;

                Log.i(TAG, "[视频编码类型]Currently choosing: " + videoEncodeTypes[position] + ", videoEncodeType: " + videoEncodeType);
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {

            }
        });
        //视频编码类型选择----------

        btnBitrateControl = (Button) findViewById(R.id.button_bitratecontrol);
        btnBitrateControl.setOnClickListener(new ButtonBitrateControlListener());

        textCurURL = (TextView) findViewById(R.id.txtCurURL);
        textCurURL.setText(printText);

        textEventMsg = (TextView) findViewById(R.id.txtEventMsg);

        btnInputPushUrl = (Button) findViewById(R.id.button_input_push_url);
        btnInputPushUrl.setOnClickListener(new ButtonInputPushUrlListener());

        btnPushUserData = (Button) findViewById(R.id.button_push_user_data);
        btnPushUserData.setOnClickListener(new ButtonPushUserDataListener());

        btnStartPush = (Button) findViewById(R.id.button_start_push);
        btnStartPush.setOnClickListener(new ButtonStartPushListener());

        btnStartRecorder = (Button) findViewById(R.id.button_start_recorder);
        btnStartRecorder.setOnClickListener(new ButtonStartRecorderListener());

        btnCaptureImage = (Button) findViewById(R.id.button_capture_image);
        btnCaptureImage.setOnClickListener(new ButtonCaptureImageListener());

        btnRtspService = (Button) findViewById(R.id.button_rtsp_service);
        btnRtspService.setOnClickListener(new ButtonRtspServiceListener());

        btnRtspPublisher = (Button) findViewById(R.id.button_rtsp_publisher);
        btnRtspPublisher.setOnClickListener(new ButtonRtspPublisherListener());
        btnRtspPublisher.setEnabled(false);

        btnGetRtspSessionNumbers = (Button) findViewById(R.id.button_get_session_numbers);
        btnGetRtspSessionNumbers.setOnClickListener(new ButtonGetRtspSessionNumbersListener());
        btnGetRtspSessionNumbers.setEnabled(false);

        btnPushRtsp = (Button) findViewById(R.id.button_push_rtsp);
        btnPushRtsp.setOnClickListener(new ButtonPushRtspListener());

        imgSwitchCamera = (ImageView) findViewById(R.id.button_switchCamera);
        imgSwitchCamera.setOnClickListener(new SwitchCameraListener());

        mSurfaceView = (SurfaceView) this.findViewById(R.id.surface);
        mSurfaceHolder = mSurfaceView.getHolder();
        mSurfaceHolder.addCallback(this);
        mSurfaceHolder.setType(SurfaceHolder.SURFACE_TYPE_PUSH_BUFFERS);

        //自动聚焦变量回调
        myAutoFocusCallback = new AutoFocusCallback() {
            public void onAutoFocus(boolean success, Camera camera) {
                if (success)//success表示对焦成功
                {
                    Log.i(TAG, "onAutoFocus succeed...");
                } else {
                    Log.i(TAG, "onAutoFocus failed...");
                }
            }
        };

        libPublisher = new SmartPublisherJniV2();

        libPublisher.InitRtspServer(myContext);      //和UnInitRtspServer配对使用，即便是启动多个RTSP服务，也只需调用一次InitRtspServer，请确保在OpenRtspServer之前调用
    }

    class SwitchCameraListener implements OnClickListener {
        public void onClick(View v) {
            Log.i(TAG, "Switch camera..");
            try {
                switchCamera();
            } catch (IOException e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }
        }
    };

    void SwitchResolution(int position) {
        Log.i(TAG, "Current Resolution position: " + position);

        switch (position) {
            case 0:
                videoWidth = 640;
                videoHeight = 480;
                sw_video_encoder_speed = 3;
                break;
            case 1:
                videoWidth = 320;
                videoHeight = 240;
                sw_video_encoder_speed = 5;
                break;
            case 2:
                videoWidth = 864;
                videoHeight = 480;
                sw_video_encoder_speed = 3;
                break;
            case 3:
                videoWidth = 1280;
                videoHeight = 720;
                sw_video_encoder_speed = 2;
                break;
            default:
                videoWidth = 640;
                videoHeight = 480;
                sw_video_encoder_speed = 3;
        }

        swVideoEncoderSpeedSelector.setSelection(swVideoEncoderSpeedSelector.getCount() - sw_video_encoder_speed,true);

        mCamera.stopPreview();
        initCamera(mSurfaceHolder);
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

            // audioRecord_.IsMicSource(true);      //如采集音频声音过小，可以打开此选项

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

    //Configure recorder related function.
    void ConfigRecorderFuntion(boolean isNeedLocalRecorder) {
        if (libPublisher != null && publisherHandle != 0) {
            if (isNeedLocalRecorder) {
                if (recDir != null && !recDir.isEmpty()) {
                    int ret = libPublisher.SmartPublisherCreateFileDirectory(recDir);
                    if (0 == ret) {
                        if (0 != libPublisher.SmartPublisherSetRecorderDirectory(publisherHandle, recDir)) {
                            Log.e(TAG, "Set record dir failed , path:" + recDir);
                            return;
                        }

                        if (0 != libPublisher.SmartPublisherSetRecorder(publisherHandle, 1)) {
                            Log.e(TAG, "SmartPublisherSetRecorder failed.");
                            return;
                        }

                        if (0 != libPublisher.SmartPublisherSetRecorderFileMaxSize(publisherHandle, 200)) {
                            Log.e(TAG, "SmartPublisherSetRecorderFileMaxSize failed.");
                            return;
                        }

                    } else {
                        Log.e(TAG, "Create record dir failed, path:" + recDir);
                    }
                }
            } else {
                if (0 != libPublisher.SmartPublisherSetRecorder(publisherHandle, 0)) {
                    Log.e(TAG, "SmartPublisherSetRecorder failed.");
                }
            }
        }
    }

    class ButtonRecorderMangerListener implements OnClickListener {
        public void onClick(View v) {
            if (mCamera != null) {
                mCamera.stopPreview();
                mCamera.release();
                mCamera = null;
            }

            Intent intent = new Intent();
            intent.setClass(CameraPublishActivity.this, RecorderManager.class);
            intent.putExtra("RecoderDir", recDir);
            startActivity(intent);
        }
    }

    class ButtonNoiseSuppressionListener implements OnClickListener {
        public void onClick(View v) {
            is_noise_suppression = !is_noise_suppression;

            if (is_noise_suppression)
                btnNoiseSuppression.setText("已打开噪音抑制");
            else
                btnNoiseSuppression.setText("已关闭噪音抑制");
        }
    }

    class ButtonAGCListener implements OnClickListener {
        public void onClick(View v) {
            is_agc = !is_agc;

            if (is_agc)
                btnAGC.setText("已打开AGC");
            else
                btnAGC.setText("已关闭AGC");
        }
    }

    class ButtonSpeexListener implements OnClickListener {
        public void onClick(View v) {
            is_speex = !is_speex;

            if (is_speex)
                btnSpeex.setText("当前SPEEX编码");
            else
                btnSpeex.setText("当前AAC编码");
        }
    }

    class ButtonMuteListener implements OnClickListener {
        public void onClick(View v) {
            is_mute = !is_mute;

            if (is_mute)
                btnMute.setText("取消静音");
            else
                btnMute.setText("实时静音");

            if (libPublisher != null)
                libPublisher.SmartPublisherSetMute(publisherHandle, is_mute ? 1 : 0);
        }
    }

    class ButtonMirrorListener implements OnClickListener {
        public void onClick(View v) {
            is_mirror = !is_mirror;

            if (is_mirror)
                btnMirror.setText("已打开镜像");
            else
                btnMirror.setText("已关闭镜像");

            if (libPublisher != null)
                libPublisher.SmartPublisherSetMirror(publisherHandle, is_mirror ? 1 : 0);
        }
    }

    class ButtonBitrateControlListener implements OnClickListener {
        public void onClick(View v) {
            is_sw_vbr_mode = !is_sw_vbr_mode;

            if (is_sw_vbr_mode)
                btnBitrateControl.setText("当前可变码率");
            else
                btnBitrateControl.setText("当前固定码率");
        }
    }

    @SuppressLint("HandlerLeak")
    private Handler handler = new Handler() {
        @Override
        public void handleMessage(Message msg) {
            super.handleMessage(msg);

            switch (msg.what) {
                case PUBLISHER_EVENT_MSG:
                    String cur_event = "Event: " + (String) msg.obj;
                    textEventMsg.setText(cur_event);
                    break;
                default:
                    break;
            }
        }
    };

    class EventHandeV2 implements NTSmartEventCallbackV2 {
        @Override
        public void onNTSmartEventCallbackV2(long handle, int id, long param1, long param2, String param3, String param4, Object param5) {

            Log.i(TAG, "EventHandeV2: handle=" + handle + " id:" + id);

            String publisher_event = "";

            switch (id) {
                case NTSmartEventID.EVENT_DANIULIVE_ERC_PUBLISHER_STARTED:
                    publisher_event = "开始..";
                    break;
                case NTSmartEventID.EVENT_DANIULIVE_ERC_PUBLISHER_CONNECTING:
                    publisher_event = "连接中..";
                    break;
                case NTSmartEventID.EVENT_DANIULIVE_ERC_PUBLISHER_CONNECTION_FAILED:
                    publisher_event = "连接失败..";
                    break;
                case NTSmartEventID.EVENT_DANIULIVE_ERC_PUBLISHER_CONNECTED:
                    publisher_event = "连接成功..";
                    break;
                case NTSmartEventID.EVENT_DANIULIVE_ERC_PUBLISHER_DISCONNECTED:
                    publisher_event = "连接断开..";
                    break;
                case NTSmartEventID.EVENT_DANIULIVE_ERC_PUBLISHER_STOP:
                    publisher_event = "关闭..";
                    break;
                case NTSmartEventID.EVENT_DANIULIVE_ERC_PUBLISHER_RECORDER_START_NEW_FILE:
                    publisher_event = "开始一个新的录像文件 : " + param3;
                    break;
                case NTSmartEventID.EVENT_DANIULIVE_ERC_PUBLISHER_ONE_RECORDER_FILE_FINISHED:
                    publisher_event = "已生成一个录像文件 : " + param3;
                    break;

                case NTSmartEventID.EVENT_DANIULIVE_ERC_PUBLISHER_SEND_DELAY:
                    publisher_event = "发送时延: " + param1 + " 帧数:" + param2;
                    break;

                case NTSmartEventID.EVENT_DANIULIVE_ERC_PUBLISHER_CAPTURE_IMAGE:
                    publisher_event = "快照: " + param1 + " 路径：" + param3;

                    if (param1 == 0) {
                        publisher_event = publisher_event + "截取快照成功..";
                    } else {
                        publisher_event = publisher_event + "截取快照失败..";
                    }
                    break;
                case NTSmartEventID.EVENT_DANIULIVE_ERC_PUBLISHER_RTSP_URL:
                    publisher_event = "RTSP服务URL: " + param3;
                    break;
                case NTSmartEventID.EVENT_DANIULIVE_ERC_PUSH_RTSP_SERVER_RESPONSE_STATUS_CODE:
                    publisher_event ="RTSP status code received, codeID: " + param1 + ", RTSP URL: " + param3;
                    break;
                case NTSmartEventID.EVENT_DANIULIVE_ERC_PUSH_RTSP_SERVER_NOT_SUPPORT:
                    publisher_event ="服务器不支持RTSP推送, 推送的RTSP URL: " + param3;
                    break;
            }

            String str = "当前回调状态：" + publisher_event;

            Log.i(TAG, str);

            Message message = new Message();
            message.what = PUBLISHER_EVENT_MSG;
            message.obj = publisher_event;
            handler.sendMessage(message);
        }
    }

    private void SaveInputUrl(String url) {
        inputPushURL = "";

        if (url == null)
            return;

        // rtmp://
        if (url.length() < 8) {
            Log.e(TAG, "Input publish url error:" + url);
            return;
        }

        if (!url.startsWith("rtmp://") && !url.startsWith("rtsp://")) {
            Log.e(TAG, "Input publish url error:" + url);
            return;
        }

        inputPushURL = url;

        Log.i(TAG, "Input publish url:" + url);
    }

    //RTMP推送URL设置
    private void PopInputUrlDialog() {
        final EditText inputUrlTxt = new EditText(this);
        inputUrlTxt.setFocusable(true);
        inputUrlTxt.setText(baseURL + String.valueOf((int) (System.currentTimeMillis() % 1000000)));

        AlertDialog.Builder builderUrl = new AlertDialog.Builder(this);
        builderUrl.setTitle("如 rtmp://player.daniulive.com:1935/hls/stream123456").setView(inputUrlTxt).setNegativeButton(
                "取消", null);

        builderUrl.setPositiveButton("确认", new DialogInterface.OnClickListener() {

            public void onClick(DialogInterface dialog, int which) {
                String fullPushUrl = inputUrlTxt.getText().toString();
                SaveInputUrl(fullPushUrl);
            }
        });

        builderUrl.show();
    }

    class ButtonInputPushUrlListener implements OnClickListener {
        public void onClick(View v) {
            PopInputUrlDialog();
        }
    }

    class ButtonPushUserDataListener implements OnClickListener {
        public void onClick(View v) {

            if(isPushingRtmp || isRTSPPublisherRunning|| isPushingRtsp)
            {
                String timeStamp = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date());
                String utf8_string = "大牛直播SDK: " + timeStamp;    //创建以时间命名的文件名称

                libPublisher.SmartPublisherPostUserUTF8StringData(publisherHandle, utf8_string, 0);

			/*
			String user_data = "chinease is great, we like school, and food is good too..";

			byte[] midbytes = new byte[user_data.length()+1];

			midbytes[user_data.length()] = 0;

			try {
				midbytes = user_data.getBytes("UTF8");
			}catch (UnsupportedEncodingException e)
			{
			}
			libPublisher.SmartPublisherPostUserData(publisherHandle, midbytes, midbytes.length, 0);
			*/
            }
           else
            {
                Log.e(TAG, "发送自定义文本失败，请确保已开启推送或内置RTSP服务..");
            }
        }
    }

    private void ConfigControlEnable(boolean isEnable) {
        btnRecorderMgr.setEnabled(isEnable);
        videoEncodeTypeSelector.setEnabled(isEnable);
        btnBitrateControl.setEnabled(isEnable);
        btnNoiseSuppression.setEnabled(isEnable);
        btnAGC.setEnabled(isEnable);
        btnSpeex.setEnabled(isEnable);
        btnInputPushUrl.setEnabled(isEnable);
    }

    private void InitAndSetConfig() {
        Log.i(TAG, "videoWidth: " + videoWidth + " videoHeight: " + videoHeight
                + " pushType:" + pushType);

        int audio_opt = 1;
        int video_opt = 1;

        if (pushType == 1) {
            video_opt = 0;
        } else if (pushType == 2) {
            audio_opt = 0;
        }

        publisherHandle = libPublisher.SmartPublisherOpen(myContext, audio_opt, video_opt,
                videoWidth, videoHeight);

        if (publisherHandle == 0) {
            Log.e(TAG, "sdk open failed!");
            return;
        }

        Log.i(TAG, "publisherHandle=" + publisherHandle);

        if(videoEncodeType == 1)
        {
            int h264HWKbps = setHardwareEncoderKbps(true, videoWidth, videoHeight);

            Log.i(TAG, "h264HWKbps: " + h264HWKbps);

            int isSupportH264HWEncoder = libPublisher
                    .SetSmartPublisherVideoHWEncoder(publisherHandle, h264HWKbps);

            if (isSupportH264HWEncoder == 0) {
                Log.i(TAG, "Great, it supports h.264 hardware encoder!");
            }
        }
        else if (videoEncodeType == 2)
        {
            int hevcHWKbps = setHardwareEncoderKbps(false, videoWidth, videoHeight);

            Log.i(TAG, "hevcHWKbps: " + hevcHWKbps);

            int isSupportHevcHWEncoder = libPublisher
                    .SetSmartPublisherVideoHevcHWEncoder(publisherHandle, hevcHWKbps);

            if (isSupportHevcHWEncoder == 0) {
                Log.i(TAG, "Great, it supports hevc hardware encoder!");
            }
        }

        if(is_sw_vbr_mode)	//H.264 software encoder
        {
            int is_enable_vbr = 1;
            int video_quality = CalVideoQuality(videoWidth, videoHeight, true);
            int vbr_max_bitrate = CalVbrMaxKBitRate(videoWidth, videoHeight);

            libPublisher.SmartPublisherSetSwVBRMode(publisherHandle, is_enable_vbr, video_quality, vbr_max_bitrate);
        }

        libPublisher.SetSmartPublisherEventCallbackV2(publisherHandle, new EventHandeV2());

        // 如果想和时间显示在同一行，请去掉'\n'
        String watermarkText = "大牛直播(daniulive)\n\n";

        String path = logoPath;

        if (watemarkType == 0) {
            if (isWritelogoFileSuccess)
                libPublisher.SmartPublisherSetPictureWatermark(publisherHandle, path,
                        WATERMARK.WATERMARK_POSITION_TOPRIGHT, 160,
                        160, 10, 10);

        } else if (watemarkType == 1) {
            if (isWritelogoFileSuccess)
                libPublisher.SmartPublisherSetPictureWatermark(publisherHandle, path,
                        WATERMARK.WATERMARK_POSITION_TOPRIGHT, 160,
                        160, 10, 10);

            libPublisher.SmartPublisherSetTextWatermark(publisherHandle, watermarkText, 1,
                    WATERMARK.WATERMARK_FONTSIZE_BIG,
                    WATERMARK.WATERMARK_POSITION_BOTTOMRIGHT, 10, 10);

            // libPublisher.SmartPublisherSetTextWatermarkFontFileName("/system/fonts/DroidSansFallback.ttf");

            // libPublisher.SmartPublisherSetTextWatermarkFontFileName("/sdcard/DroidSansFallback.ttf");
        } else if (watemarkType == 2) {
            libPublisher.SmartPublisherSetTextWatermark(publisherHandle, watermarkText, 1,
                    WATERMARK.WATERMARK_FONTSIZE_BIG,
                    WATERMARK.WATERMARK_POSITION_BOTTOMRIGHT, 10, 10);

            // libPublisher.SmartPublisherSetTextWatermarkFontFileName("/system/fonts/DroidSansFallback.ttf");
        } else {
            Log.i(TAG, "no watermark settings..");
        }
        // end

        if (!is_speex) {
            // set AAC encoder
            libPublisher.SmartPublisherSetAudioCodecType(publisherHandle, 1);
        } else {
            // set Speex encoder
            libPublisher.SmartPublisherSetAudioCodecType(publisherHandle, 2);
            libPublisher.SmartPublisherSetSpeexEncoderQuality(publisherHandle, 8);
        }

        libPublisher.SmartPublisherSetNoiseSuppression(publisherHandle, is_noise_suppression ? 1
                : 0);

        libPublisher.SmartPublisherSetAGC(publisherHandle, is_agc ? 1 : 0);

        // libPublisher.SmartPublisherSetClippingMode(publisherHandle, 0);

        libPublisher.SmartPublisherSetSWVideoEncoderProfile(publisherHandle, sw_video_encoder_profile);

        libPublisher.SmartPublisherSetSWVideoEncoderSpeed(publisherHandle, sw_video_encoder_speed);

        // libPublisher.SetRtmpPublishingType(publisherHandle, 0);

        // libPublisher.SmartPublisherSetGopInterval(publisherHandle, 40);

        // libPublisher.SmartPublisherSetFPS(publisherHandle, 15);

        // libPublisher.SmartPublisherSetSWVideoBitRate(publisherHandle, 600, 1200);

        libPublisher.SmartPublisherSaveImageFlag(publisherHandle, 1);

        if (libPublisher.SmartPublisherSetPostUserDataQueueMaxSize(publisherHandle, 3, 0) != 0) {
            Log.e(TAG, "Failed to SetPostUserDataQueueMaxSize..");
        }
    }

    class ButtonStartPushListener implements OnClickListener {
        public void onClick(View v) {
            if (isPushingRtmp) {
                stopPush();

                if (!isRecording && !isRTSPPublisherRunning&& !isPushingRtsp) {
                    ConfigControlEnable(true);
                }

                btnStartPush.setText("推送RTMP");
                isPushingRtmp = false;

                return;
            }

            Log.i(TAG, "onClick start push..");

            if (libPublisher == null)
                return;

            if (!isRecording && !isRTSPPublisherRunning && !isPushingRtsp) {
                InitAndSetConfig();
            }

            if (inputPushURL != null && inputPushURL.length() > 1) {
                publishURL = inputPushURL;
                Log.i(TAG, "start, input publish url:" + publishURL);
            } else {
                publishURL = baseURL + String.valueOf((int) (System.currentTimeMillis() % 1000000));
                Log.i(TAG, "start, generate random url:" + publishURL);
            }

            printText = "推流URL:" + publishURL;

            Log.i(TAG, printText);

            if (libPublisher.SmartPublisherSetURL(publisherHandle, publishURL) != 0) {
                Log.e(TAG, "Failed to set publish stream URL..");
            }

            int startRet = libPublisher.SmartPublisherStartPublisher(publisherHandle);
            if (startRet != 0) {
                isPushingRtmp = false;

                Log.e(TAG, "Failed to start push stream..");
                return;
            }

            if (!isRecording && !isRTSPPublisherRunning && !isPushingRtsp) {
                if (pushType == 0 || pushType == 1) {
                    CheckInitAudioRecorder();    //enable pure video publisher..
                }

                ConfigControlEnable(false);
            }

            textCurURL = (TextView) findViewById(R.id.txtCurURL);
            textCurURL.setText(printText);

            btnStartPush.setText("停止推送 ");
            isPushingRtmp = true;
        }
    }

    class ButtonStartRecorderListener implements OnClickListener {
        public void onClick(View v) {
            if (isRecording) {
                stopRecorder();

                if (!isPushingRtmp && !isRTSPPublisherRunning && !isPushingRtsp) {
                    ConfigControlEnable(true);
                }

                btnStartRecorder.setText("实时录像");
                isRecording = false;

                return;
            }

            Log.i(TAG, "onClick start recorder..");

            if (libPublisher == null)
                return;

            if (!isPushingRtmp && !isRTSPPublisherRunning&& !isPushingRtsp) {
                InitAndSetConfig();
            }

            ConfigRecorderFuntion(true);

            int startRet = libPublisher.SmartPublisherStartRecorder(publisherHandle);
            if (startRet != 0) {
                isRecording = false;

                Log.e(TAG, "Failed to start recorder.");
                return;
            }

            if (!isPushingRtmp && !isRTSPPublisherRunning && !isPushingRtsp) {
                if (pushType == 0 || pushType == 1) {
                    CheckInitAudioRecorder();    //enable pure video publisher..
                }

                ConfigControlEnable(false);
            }

            btnStartRecorder.setText("停止录像");
            isRecording = true;
        }
    }

    class ButtonCaptureImageListener implements OnClickListener {
        @SuppressLint("SimpleDateFormat")
        public void onClick(View v) {
            if(isPushingRtmp || isRecording || isRTSPPublisherRunning || isPushingRtsp)
            {
                String timeStamp = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date());
                String imageFileName = "dn_" + timeStamp;    //创建以时间命名的文件名称

                String imagePath = imageSavePath + "/" + imageFileName + ".png";

                Log.i(TAG, "imagePath:" + imagePath);

                libPublisher.SmartPublisherSaveCurImage(publisherHandle, imagePath);
            }
            else
            {
                Log.e(TAG, "快照失败，请确保在推送、录像或内置RTSP服务发布状态..");
            }
        }
    }

    /*
    private String MakeMulticastAddress()
    {
        // 239.0.1.0 ~ 239.255.255.255
        long begin = 0xEF000100;
        long end = 0xEFFFFFFF;

        long count = end - begin;

        Random random = new Random();
        long addr_host = begin + (random.nextInt((int)count));

        return DigitToIpAddr(addr_host);
    }

    private String MakeSSMMulticastAddress()
    {
        // 232.0.1.0 ~ 232.255.255.255

        long begin = 0xE8000100;
        long end = 0xE8FFFFFF;

        long count = end - begin;

        Random random = new Random();
        long addr_host = begin + (random.nextInt((int)count));

        return DigitToIpAddr(addr_host);
    }

    private String DigitToIpAddr(long ip) {
        return ((ip >> 24) & 0xFF) + "."
                + ((ip >> 16) & 0xFF) + "."
                + ((ip >> 8) & 0xFF) + "."
                + (ip & 0xFF);
    }
    */

    //启动/停止RTSP服务
    class ButtonRtspServiceListener implements OnClickListener {
        public void onClick(View v) {
            if (isRTSPServiceRunning) {
                stopRtspService();

                btnRtspService.setText("启动RTSP服务");
                btnRtspPublisher.setEnabled(false);

                isRTSPServiceRunning = false;
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

                //一般来说单播网络设备支持的好，wifi组播很多路由器不支持，默认单播模式；如需使用组播模式，确保设备支持后，打开注释代码测试即可
                /*
                boolean is_enable_multicast = true;

                if(is_enable_multicast)
                {
                    int is_multicast = 1;

                    libPublisher.SetRtspServerMulticast(rtsp_handle_, is_multicast);

                    boolean is_enable_ssm_multicast = true;

                    String multicast_address = "";

                    if(is_enable_ssm_multicast)
                    {
                        multicast_address = MakeSSMMulticastAddress();
                    }
                    else
                    {
                        multicast_address = MakeMulticastAddress();
                    }

                    Log.i(TAG, "is_enable_ssm_multicast:" + is_enable_ssm_multicast + " multiAddr: " + multicast_address);

                    libPublisher.SetRtspServerMulticastAddress(rtsp_handle_, multicast_address);
                }
                */

                if (libPublisher.StartRtspServer(rtsp_handle_, 0) == 0) {
                    Log.i(TAG, "启动rtsp server 成功!");
                } else {
                    libPublisher.CloseRtspServer(rtsp_handle_);
                    rtsp_handle_ = 0;
                    Log.e(TAG, "启动rtsp server失败! 请检查设置的端口是否被占用!");
                }

                btnRtspService.setText("停止RTSP服务");
                btnRtspPublisher.setEnabled(true);

                isRTSPServiceRunning = true;
            }
        }
    }

    //发布/停止RTSP流
    class ButtonRtspPublisherListener implements OnClickListener {
        public void onClick(View v) {
            if (isRTSPPublisherRunning) {
                stopRtspPublisher();

                if (!isPushingRtmp && !isRecording && !isPushingRtsp) {
                    ConfigControlEnable(true);
                }

                btnRtspPublisher.setText("发布RTSP流");
                btnGetRtspSessionNumbers.setEnabled(false);
                btnRtspService.setEnabled(true);
                isRTSPPublisherRunning = false;

                return;
            }

            Log.i(TAG, "onClick start rtsp publisher..");

            if (!isPushingRtmp && !isRecording && !isPushingRtsp) {
                InitAndSetConfig();
            }

            if (publisherHandle == 0) {
                Log.e(TAG, "Start rtsp publisher, publisherHandle is null..");
                return;
            }

            String rtsp_stream_name = "stream1";
            libPublisher.SetRtspStreamName(publisherHandle, rtsp_stream_name);
            libPublisher.ClearRtspStreamServer(publisherHandle);

            libPublisher.AddRtspStreamServer(publisherHandle, rtsp_handle_, 0);

            if (libPublisher.StartRtspStream(publisherHandle, 0) != 0) {
                Log.e(TAG, "调用发布rtsp流接口失败!");
                return;
            }

            if (!isPushingRtmp && !isRecording && !isPushingRtsp) {
                if (pushType == 0 || pushType == 1) {
                    CheckInitAudioRecorder();    //enable pure video publisher..
                }

                ConfigControlEnable(false);
            }

            btnRtspPublisher.setText("停止RTSP流");
            btnGetRtspSessionNumbers.setEnabled(true);
            btnRtspService.setEnabled(false);
            isRTSPPublisherRunning = true;
        }
    }

    ;

    //当前RTSP会话数弹出框
    private void PopRtspSessionNumberDialog(int session_numbers) {
        final EditText inputUrlTxt = new EditText(this);
        inputUrlTxt.setFocusable(true);
        inputUrlTxt.setEnabled(false);

        String session_numbers_tag = "RTSP服务当前客户会话数: " + session_numbers;
        inputUrlTxt.setText(session_numbers_tag);

        AlertDialog.Builder builderUrl = new AlertDialog.Builder(this);
        builderUrl
                .setTitle("内置RTSP服务")
                .setView(inputUrlTxt).setNegativeButton("确定", null);
        builderUrl.show();
    }

    //获取RTSP会话数
    class ButtonGetRtspSessionNumbersListener implements OnClickListener {
        public void onClick(View v) {
            if (libPublisher != null && rtsp_handle_ != 0) {
                int session_numbers = libPublisher.GetRtspServerClientSessionNumbers(rtsp_handle_);

                Log.i(TAG, "GetRtspSessionNumbers: " + session_numbers);

                PopRtspSessionNumberDialog(session_numbers);
            }
        }
    };

    class ButtonPushRtspListener implements OnClickListener {
        public void onClick(View v) {
            if (isPushingRtsp) {
                stopPushRtsp();

                if (!isRecording && !isRTSPPublisherRunning && !isPushingRtmp) {
                    ConfigControlEnable(true);
                }

                btnPushRtsp.setText("推送RTSP");
                isPushingRtsp = false;

                return;
            }

            Log.i(TAG, "onClick start push rtsp..");

            if (libPublisher == null)
                return;

            if (!isRecording && !isRTSPPublisherRunning && !isPushingRtmp) {
                InitAndSetConfig();
            }

            if (inputPushURL != null && inputPushURL.length() > 1) {
                publishURL = inputPushURL;
                Log.i(TAG, "start, input rtsp publish url:" + publishURL);
            } else {
                String baseRtspUrl = "rtsp://player.daniulive.com:554/live";
                publishURL = baseRtspUrl + String.valueOf((int) (System.currentTimeMillis() % 1000000)) + ".sdp";
                Log.i(TAG, "start, generate random url:" + publishURL);
            }

            //publishURL = "rtsp://player.daniulive.com:554/live123.sdp";

            printText = "推流URL:" + publishURL;

            Log.i(TAG, printText);

            if (libPublisher.SetPushRtspURL(publisherHandle, publishURL) != 0) {
                Log.e(TAG, "Failed to set rtsp publish stream URL..");
            }

            int transport_protocol = 1;
            libPublisher.SetPushRtspTransportProtocol(publisherHandle, transport_protocol);

            int startRet = libPublisher.StartPushRtsp(publisherHandle, 0);
            if (startRet != 0) {
                isPushingRtsp = false;

                Log.e(TAG, "Failed to start push rtsp stream..");
                return;
            }

            if (!isRecording && !isRTSPPublisherRunning && !isPushingRtmp) {
                if (pushType == 0 || pushType == 1) {
                    CheckInitAudioRecorder();    //enable pure video publisher..
                }

                ConfigControlEnable(false);
            }

            textCurURL = (TextView) findViewById(R.id.txtCurURL);
            textCurURL.setText(printText);

            btnPushRtsp.setText("停止推送 ");
            isPushingRtsp = true;
        }
    };

    //停止rtmp推送
    private void stopPush() {
        if(!isPushingRtmp)
        {
            return;
        }
        if (!isRecording && !isRTSPPublisherRunning && !isPushingRtsp) {
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

        if (!isRecording && !isRTSPPublisherRunning & !isPushingRtsp) {
            if (publisherHandle != 0) {
                if (libPublisher != null) {
                    libPublisher.SmartPublisherClose(publisherHandle);
                    publisherHandle = 0;
                }
            }
        }
    }

    //停止录像
    private void stopRecorder() {
        if(!isRecording)
        {
            return;
        }
        if (!isPushingRtmp && !isRTSPPublisherRunning && !isPushingRtsp) {
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

        if (!isPushingRtmp && !isRTSPPublisherRunning && !isPushingRtsp) {
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
        if (!isPushingRtmp && !isRecording && !isPushingRtsp) {
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

        if (!isPushingRtmp && !isRecording && !isPushingRtsp) {
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

    //停止rtsp推送
    private void stopPushRtsp() {
        if(!isPushingRtsp)
        {
            return;
        }
        if (!isRecording && !isRTSPPublisherRunning && !isPushingRtmp) {
            if (audioRecord_ != null) {
                Log.i(TAG, "stopPushRtsp, call audioRecord_.StopRecording..");

                audioRecord_.Stop();

                if (audioRecordCallback_ != null) {
                    audioRecord_.RemoveCallback(audioRecordCallback_);
                    audioRecordCallback_ = null;
                }

                audioRecord_ = null;
            }
        }

        if (libPublisher != null) {
            libPublisher.StopPushRtsp(publisherHandle);
        }

        if (!isRecording && !isRTSPPublisherRunning & !isPushingRtmp) {
            if (publisherHandle != 0) {
                if (libPublisher != null) {
                    libPublisher.SmartPublisherClose(publisherHandle);
                    publisherHandle = 0;
                }
            }
        }
    }

    @Override
    protected void onDestroy() {
        Log.i(TAG, "activity destory!");

        if (isPushingRtmp || isRecording || isRTSPPublisherRunning || isPushingRtsp) {
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
            isPushingRtmp = false;

            stopRecorder();
            isRecording = false;

            stopRtspPublisher();
            isRTSPPublisherRunning = false;

            stopRtspService();
            isRTSPServiceRunning = false;

            stopPushRtsp();
            isPushingRtsp = false;

            if (publisherHandle != 0) {
                if (libPublisher != null) {
                    libPublisher.SmartPublisherClose(publisherHandle);
                    publisherHandle = 0;
                }
            }
			
			libPublisher.UnInitRtspServer();      //如已启用内置服务功能(InitRtspServer)，调用UnInitRtspServer, 注意，即便是启动多个RTSP服务，也只需调用UnInitRtspServer一次
        }

        super.onDestroy();
        finish();
        System.exit(0);
    }

    private void SetCameraFPS(Camera.Parameters parameters) {
        if (parameters == null)
            return;

        int[] findRange = null;

        int defFPS = 20 * 1000;

        List<int[]> fpsList = parameters.getSupportedPreviewFpsRange();
        if (fpsList != null && fpsList.size() > 0) {
            for (int i = 0; i < fpsList.size(); ++i) {
                int[] range = fpsList.get(i);
                if (range != null
                        && Camera.Parameters.PREVIEW_FPS_MIN_INDEX < range.length
                        && Camera.Parameters.PREVIEW_FPS_MAX_INDEX < range.length) {
                    Log.i(TAG, "Camera index:" + i + " support min fps:" + range[Camera.Parameters.PREVIEW_FPS_MIN_INDEX]);

                    Log.i(TAG, "Camera index:" + i + " support max fps:" + range[Camera.Parameters.PREVIEW_FPS_MAX_INDEX]);

                    if (findRange == null) {
                        if (defFPS <= range[Camera.Parameters.PREVIEW_FPS_MAX_INDEX]) {
                            findRange = range;

                            Log.i(TAG, "Camera found appropriate fps, min fps:" + range[Camera.Parameters.PREVIEW_FPS_MIN_INDEX]
                                    + " ,max fps:" + range[Camera.Parameters.PREVIEW_FPS_MAX_INDEX]);
                        }
                    }
                }
            }
        }

        if (findRange != null) {
            parameters.setPreviewFpsRange(findRange[Camera.Parameters.PREVIEW_FPS_MIN_INDEX], findRange[Camera.Parameters.PREVIEW_FPS_MAX_INDEX]);
        }
    }

    /*it will call when surfaceChanged*/
    private void initCamera(SurfaceHolder holder) {
        Log.i(TAG, "initCamera..");

        if (mPreviewRunning)
            mCamera.stopPreview();

        Camera.Parameters parameters;
        try {
            parameters = mCamera.getParameters();
        } catch (Exception e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
            return;
        }

        /*
        List<Size> pictureSizes = parameters.getSupportedPictureSizes();
        int length = pictureSizes.size();
        for (int i = 0; i < length; i++) {
            Log.e("SupportedPictureSizes","SupportedPictureSizes : " + pictureSizes.get(i).width + "x" + pictureSizes.get(i).height);
        }

        List<Size> previewSizes = parameters.getSupportedPreviewSizes();
        length = previewSizes.size();
        for (int i = 0; i < length; i++) {
            Log.e("SupportedPreviewSizes","SupportedPreviewSizes : " + previewSizes.get(i).width + "x" + previewSizes.get(i).height);
        }
        */

        parameters.setPreviewSize(videoWidth, videoHeight);
        parameters.setPictureFormat(PixelFormat.JPEG);
        parameters.setPreviewFormat(PixelFormat.YCbCr_420_SP);

        SetCameraFPS(parameters);

        setCameraDisplayOrientation(this, curCameraIndex, mCamera);

        mCamera.setParameters(parameters);

        int bufferSize = (((videoWidth | 0xf) + 1) * videoHeight * ImageFormat.getBitsPerPixel(parameters.getPreviewFormat())) / 8;

        mCamera.addCallbackBuffer(new byte[bufferSize]);

        mCamera.setPreviewCallbackWithBuffer(this);
        try {
            mCamera.setPreviewDisplay(holder);
        } catch (Exception ex) {
            // TODO Auto-generated catch block
            if (null != mCamera) {
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

            int CammeraIndex = findBackCamera();
            Log.i(TAG, "BackCamera: " + CammeraIndex);

            if (CammeraIndex == -1) {
                CammeraIndex = findFrontCamera();
                currentCameraType = FRONT;
                imgSwitchCamera.setEnabled(false);
                if (CammeraIndex == -1) {
                    Log.i(TAG, "NO camera!!");
                    return;
                }
            } else {
                currentCameraType = BACK;
            }

            if (mCamera == null) {
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
    }

    public void onConfigurationChanged(Configuration newConfig) {
        try {
            super.onConfigurationChanged(newConfig);
            Log.i(TAG, "onConfigurationChanged");
            if (this.getResources().getConfiguration().orientation == Configuration.ORIENTATION_LANDSCAPE) {
                if (!isRTSPPublisherRunning && !isPushingRtmp && !isRecording && !isPushingRtsp) {

                    int rotation = getWindowManager().getDefaultDisplay().getRotation();
                    if (Surface.ROTATION_270 == rotation) {
                        Log.i(TAG, "onConfigurationChanged rotation=" + rotation + " LANDSCAPE_LEFT_HOME_KEY");

                        currentOrigentation = LANDSCAPE_LEFT_HOME_KEY;
                    } else {
                        Log.i(TAG, "onConfigurationChanged rotation=" + rotation + " LANDSCAPE");

                        currentOrigentation = LANDSCAPE;
                    }
                }
            } else if (this.getResources().getConfiguration().orientation == Configuration.ORIENTATION_PORTRAIT) {
                if (!isRTSPPublisherRunning && !isPushingRtmp && !isRecording && !isPushingRtsp) {
                    currentOrigentation = PORTRAIT;
                }
            }
        } catch (Exception ex) {
        }
    }

    @Override
    public void onPreviewFrame(byte[] data, Camera camera) {
        frameCount++;
        if (frameCount % 3000 == 0) {
            Log.i("OnPre", "gc+");
            System.gc();
            Log.i("OnPre", "gc-");
        }

        if (data == null) {
            Parameters params = camera.getParameters();
            Size size = params.getPreviewSize();
            int bufferSize = (((size.width | 0x1f) + 1) * size.height * ImageFormat.getBitsPerPixel(params.getPreviewFormat())) / 8;
            camera.addCallbackBuffer(new byte[bufferSize]);
        } else {
            if (isRTSPPublisherRunning || isPushingRtmp || isRecording || isPushingRtsp) {
                libPublisher.SmartPublisherOnCaptureVideoData(publisherHandle, data, data.length, currentCameraType, currentOrigentation);
            }

            camera.addCallbackBuffer(data);
        }
    }

    @SuppressLint("NewApi")
    private Camera openCamera(int type) {
        int frontIndex = -1;
        int backIndex = -1;
        int cameraCount = Camera.getNumberOfCameras();
        Log.i(TAG, "cameraCount: " + cameraCount);

        CameraInfo info = new CameraInfo();
        for (int cameraIndex = 0; cameraIndex < cameraCount; cameraIndex++) {
            Camera.getCameraInfo(cameraIndex, info);

            if (info.facing == CameraInfo.CAMERA_FACING_FRONT) {
                frontIndex = cameraIndex;
            } else if (info.facing == CameraInfo.CAMERA_FACING_BACK) {
                backIndex = cameraIndex;
            }
        }

        currentCameraType = type;
        if (type == FRONT && frontIndex != -1) {
            curCameraIndex = frontIndex;
            return Camera.open(frontIndex);
        } else if (type == BACK && backIndex != -1) {
            curCameraIndex = backIndex;
            return Camera.open(backIndex);
        }
        return null;
    }

    private void switchCamera() throws IOException {
        mCamera.setPreviewCallback(null);
        mCamera.stopPreview();
        mCamera.release();

        if (currentCameraType == FRONT) {
            mCamera = openCamera(BACK);
        } else if (currentCameraType == BACK) {
            mCamera = openCamera(FRONT);
        }
        initCamera(mSurfaceHolder);
    }

    //Check if it has front camera
    private int findFrontCamera() {
        int cameraCount = 0;
        Camera.CameraInfo cameraInfo = new Camera.CameraInfo();
        cameraCount = Camera.getNumberOfCameras();

        for (int camIdx = 0; camIdx < cameraCount; camIdx++) {
            Camera.getCameraInfo(camIdx, cameraInfo);
            if (cameraInfo.facing == Camera.CameraInfo.CAMERA_FACING_FRONT) {
                return camIdx;
            }
        }
        return -1;
    }

    //Check if it has back camera
    private int findBackCamera() {
        int cameraCount = 0;
        Camera.CameraInfo cameraInfo = new Camera.CameraInfo();
        cameraCount = Camera.getNumberOfCameras();

        for (int camIdx = 0; camIdx < cameraCount; camIdx++) {
            Camera.getCameraInfo(camIdx, cameraInfo);
            if (cameraInfo.facing == Camera.CameraInfo.CAMERA_FACING_BACK) {
                return camIdx;
            }
        }
        return -1;
    }

    private void setCameraDisplayOrientation(Activity activity, int cameraId, android.hardware.Camera camera) {
        android.hardware.Camera.CameraInfo info = new android.hardware.Camera.CameraInfo();
        android.hardware.Camera.getCameraInfo(cameraId, info);
        int rotation = activity.getWindowManager().getDefaultDisplay().getRotation();
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
            result = (info.orientation - degrees + 360) % 360;
        }

        Log.i(TAG, "curDegree: " + result);

        camera.setDisplayOrientation(result);
    }

    //设置H.264/H.265硬编码码率(按照25帧计算)
    private int setHardwareEncoderKbps(boolean isH264, int width, int height)
    {
        int kbit_rate = 2000;
        int area = width * height;

        if (area <= (320 * 300)) {
            kbit_rate = isH264?350:280;
        } else if (area <= (370 * 320)) {
            kbit_rate = isH264?470:400;
        } else if (area <= (640 * 360)) {
            kbit_rate = isH264?850:650;
        } else if (area <= (640 * 480)) {
            kbit_rate = isH264?1000:800;
        } else if (area <= (800 * 600)) {
            kbit_rate = isH264?1050:950;
        } else if (area <= (900 * 700)) {
            kbit_rate = isH264?1450:1100;
        } else if (area <= (1280 * 720)) {
            kbit_rate = isH264?2000:1500;
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

    /**
     * 根据目录创建文件夹
     *
     * @param context
     * @param cacheDir
     * @return
     */
    public static File getOwnCacheDirectory(Context context, String cacheDir) {
        File appCacheDir = null;
        //判断sd卡正常挂载并且拥有权限的时候创建文件
        if (Environment.MEDIA_MOUNTED.equals(Environment.getExternalStorageState()) && hasExternalStoragePermission(context)) {
            appCacheDir = new File(Environment.getExternalStorageDirectory(), cacheDir);
            Log.i(TAG, "appCacheDir: " + appCacheDir);
        }
        if (appCacheDir == null || !appCacheDir.exists() && !appCacheDir.mkdirs()) {
            appCacheDir = context.getCacheDir();
        }
        return appCacheDir;
    }

    /**
     * 检查是否有权限
     *
     * @param context
     * @return
     */
    private static boolean hasExternalStoragePermission(Context context) {
        int perm = context.checkCallingOrSelfPermission("android.permission.WRITE_EXTERNAL_STORAGE");
        return perm == 0;
    }
}