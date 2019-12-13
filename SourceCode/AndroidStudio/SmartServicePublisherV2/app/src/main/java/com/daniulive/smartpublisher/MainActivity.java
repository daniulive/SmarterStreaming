/*
 * MainActivity.java
 * MainActivity
 * 
 * Github: https://github.com/daniulive/SmarterStreaming
 * 
 * Created by DaniuLive on 2016/12/12.
 * Copyright © 2014~2018 DaniuLive. All rights reserved.
 */

package com.daniulive.smartpublisher;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.media.projection.MediaProjectionManager;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.Toast;
import android.widget.AdapterView.OnItemSelectedListener;
import android.os.PowerManager;
import android.provider.Settings;
import android.net.Uri;

import android.content.pm.PackageManager;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;

public class MainActivity extends Activity {
    MediaProjectionManager mMediaProjectionManager;

    private static final int REQUEST_MEDIA_PROJECTION = 1;
    private static final int REQUEST_IGNORE_BATTERY_CODE = 2;
    private static final int RESULT_CODE_STARTAUDIO = 3;

    private static final String TAG = "DaniuliveActivity";
    static int mResultCode;
    static Intent mResultData;

    private Spinner screenResolutionSelector;
    private Spinner recorderSelector;

    private Button btnRecorderMgr;
    private Button btnInputPushUrl;

    private Button btnPermissionCheck;
    private Button btnPublisher;

    private Button btnRtspPublisher;    //发布、停止RTSP流按钮

    private boolean is_need_local_recorder = false; //默认不录像

    /* 推送类型选择
     * 0: 视频软编码(H.264)
     * 1: 视频硬编码(H.264)
     * 2: 视频硬编码(H.265)
     * */
    private int VIDEO_ENCODE_TYPE_SW_H264 = 0;
    private int VIDEO_ENCODE_TYPE_HW_H264 = 1;
    private int VIDEO_ENCODE_TYPE_HW_H265 = 2;

    private int video_encode_type = VIDEO_ENCODE_TYPE_SW_H264;  //默认软编码

    private Spinner videoEncodeTypeSelector;

    private static boolean isPushingRtmp = false;
    private static boolean isRTSPPublisherRunning = false;

    final private String baseURL = "rtmp://player.daniulive.com:1935/hls/stream";
    private String inputPushURL = "";
    private TextView textCurURL = null;
    private String printText = "URL:";

    private String publishURL = "rtmp://player.daniulive.com:1935/hls/streamservice";

    private final int SCREEN_RESOLUTION_STANDARD = 0;   //标准分辨率，默认宽高均缩放一半
    private final int SCREEN_RESOLUTION_LOW = 1;        //低分辨率，默认宽高缩放至2/5
    private final int SCREEN_RESOLUTION_ORIGINAL_RESOLUTION = 2;    //原始分辨率

    private int screenResolution = SCREEN_RESOLUTION_STANDARD;

    private final int PUSH_TYPE_RTMP = 0;
    private final int PUSH_TYPE_RTSP = 1;

    private int push_type = PUSH_TYPE_RTMP;

    private String recDir = "/sdcard/daniulive/rec"; // for recorder path

    private Intent intent_bgd_service = null;

    private static boolean is_has_screen_capture_permission = false;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        //加入省电优化白名单，以免8.0及以上版本设备后台运行超过一分钟被自动停掉
        //if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
        if (Build.VERSION.SDK_INT >=26)
        {
            if(!isIgnoringBatteryOptimizations())
            {
                gotoSettingIgnoringBatteryOptimizations();
            }
        }

        //6.0及以上版本，动态获取Audio权限
        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.M)
        {
            RequestAudioPermission();
        }

        intent_bgd_service = new Intent(MainActivity.this, BackgroudService.class);

        screenResolutionSelector = (Spinner) findViewById(R.id.screen_resolution_selctor);
        final String[] sceenResolutionSel = new String[]{"屏幕标准分辨率", "屏幕低分辨率", "屏幕原始分辨率"};
        ArrayAdapter<String> adapterScreenResolution = new ArrayAdapter<String>(
                this, android.R.layout.simple_spinner_item, sceenResolutionSel);
        adapterScreenResolution
                .setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        screenResolutionSelector.setAdapter(adapterScreenResolution);

        screenResolutionSelector
                .setOnItemSelectedListener(new OnItemSelectedListener() {

                    @Override
                    public void onItemSelected(AdapterView<?> parent,
                                               View view, int position, long id) {

                        if (isPushingRtmp || isRTSPPublisherRunning ) {
                            Log.e(TAG,
                                    "Could not switch screen resolution during publishing..");
                            return;
                        }

                        Log.i(TAG, "[推送屏幕分辨率]Currently choosing: "
                                + sceenResolutionSel[position]);

                        SwitchScreenResolution(position);

                    }

                    @Override
                    public void onNothingSelected(AdapterView<?> parent) {

                    }
                });

        // Recorder related settings
        recorderSelector = (Spinner) findViewById(R.id.recoder_selctor);

        final String[] recorderSel = new String[]{"本地不录像", "本地录像"};
        ArrayAdapter<String> adapterRecorder = new ArrayAdapter<String>(this,
                android.R.layout.simple_spinner_item, recorderSel);

        adapterRecorder
                .setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        recorderSelector.setAdapter(adapterRecorder);

        recorderSelector
                .setOnItemSelectedListener(new OnItemSelectedListener() {

                    @Override
                    public void onItemSelected(AdapterView<?> parent,
                                               View view, int position, long id) {

                        Log.i(TAG, "Currently choosing: "
                                + recorderSel[position]);

                        if (1 == position) {
                            is_need_local_recorder = true;
                        } else {
                            is_need_local_recorder = false;
                        }
                    }

                    @Override
                    public void onNothingSelected(AdapterView<?> parent) {

                    }
                });

        btnRecorderMgr = (Button) findViewById(R.id.button_recoder_manage);
        btnRecorderMgr.setOnClickListener(new ButtonRecorderMangerListener());

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

                if (isRTSPPublisherRunning || isPushingRtmp ) {
                    Log.e(TAG, "Could not switch video encoder type during publishing..");
                    return;
                }

                SwitchVideoEncodeType(position);
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {

            }
        });
        //视频编码类型选择----------

        btnInputPushUrl = (Button) findViewById(R.id.button_input_push_url);
        btnInputPushUrl.setOnClickListener(new ButtonInputPushUrlListener());

        btnRtspPublisher = (Button) findViewById(R.id.button_rtsp_publisher);
        btnRtspPublisher.setOnClickListener(new ButtonRtspPublisherListener());
        btnRtspPublisher.setEnabled(false);

        btnPermissionCheck = (Button) findViewById(R.id.permission_check);
        btnPermissionCheck.setOnClickListener(new OnClickListener() {
            @SuppressLint("NewApi")
            @Override
            public void onClick(View v) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                    mMediaProjectionManager = (MediaProjectionManager) getApplicationContext()
                            .getSystemService(MEDIA_PROJECTION_SERVICE);
                    startActivityForResult(mMediaProjectionManager
                                    .createScreenCaptureIntent(),
                            REQUEST_MEDIA_PROJECTION);
                }
            }
        });

        btnPublisher = (Button) findViewById(R.id.button_start_stop_capture);
        btnPublisher.setEnabled(false);
        btnPublisher.setOnClickListener(new OnClickListener() {

            @SuppressLint("NewApi")
            @Override
            public void onClick(View v) {
                if(isRTSPPublisherRunning)
                {
                    Log.e(TAG, "(简单Demo演示)推送RTMP之前，确保RTSP内置服务关闭..");
                    return;
                }
                if (!isPushingRtmp) {
                    Log.i(TAG, "Start publish screen++");

                    intent_bgd_service.putExtra("SCREENRESOLUTION", screenResolution);

                    if (inputPushURL != null && inputPushURL.length() > 1) {
                        publishURL = inputPushURL;
                        Log.i(TAG, "start, input publish url:" + publishURL);
                    } else {
                        publishURL = baseURL
                                + String.valueOf((int) (System
                                .currentTimeMillis() % 1000000));
                        Log.i(TAG, "start, generate random url:" + publishURL);
                    }

                    printText = "URL:" + publishURL;
                    Log.i(TAG, printText);

                    textCurURL = (TextView) findViewById(R.id.txtCurURL);
                    textCurURL.setText(printText);

                    intent_bgd_service.putExtra("PUBLISHURL", publishURL);

                    intent_bgd_service.putExtra("RECORDER", is_need_local_recorder);    //是否录像
                    intent_bgd_service.putExtra("VIDEOENCODETYPE", video_encode_type);      //视频编码类型选择

                    push_type = PUSH_TYPE_RTMP;  //RTMP
                    intent_bgd_service.putExtra("PUSHTYPE", push_type);

                    startService(intent_bgd_service);

                    btnPublisher.setText("停止RTMP推送");
                    screenResolutionSelector.setEnabled(false);
                    recorderSelector.setEnabled(false);
                    btnRecorderMgr.setEnabled(false);
                    btnInputPushUrl.setEnabled(false);
                    videoEncodeTypeSelector.setEnabled(false);

                    btnRtspPublisher.setEnabled(false);
                    isPushingRtmp = true;
                    Log.i(TAG, "Start publish screen--");
                } else {
                    Log.i(TAG, "Stop publisher screen++");
                    stopService(intent_bgd_service);
                    btnPublisher.setText("开始RTMP推送");
                    screenResolutionSelector.setEnabled(true);
                    btnPermissionCheck.setEnabled(true);
                    recorderSelector.setEnabled(true);
                    btnRecorderMgr.setEnabled(true);
                    btnInputPushUrl.setEnabled(true);
                    videoEncodeTypeSelector.setEnabled(true);

                    btnPublisher.setEnabled(false);
                    isPushingRtmp = false;
                    is_has_screen_capture_permission = false;
                    Log.i(TAG, "Stop publisher screen--");
                }
            }
        });
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == REQUEST_MEDIA_PROJECTION) {
            if (resultCode != Activity.RESULT_OK) {
                Log.e(TAG, "REQUEST_MEDIA_PROJECTION, 用户已取消..");
                Toast.makeText(this, "用户已取消获取APP采集屏幕权限..", Toast.LENGTH_SHORT)
                        .show();

                is_has_screen_capture_permission = false;
                return;
            }
            else
            {
                is_has_screen_capture_permission = true;
                Log.i(TAG, "APP采集屏幕权限已获取..");
            }

            mResultCode = resultCode;
            mResultData = data;
            btnPermissionCheck.setEnabled(false);
            btnPublisher.setEnabled(true);
            btnRtspPublisher.setEnabled(true);
        }
        else if(requestCode == REQUEST_IGNORE_BATTERY_CODE)
        {
            if (resultCode != Activity.RESULT_OK) {
                Log.e(TAG, "REQUEST_IGNORE_BATTERY_CODE, 用户已取消..");
                Toast.makeText(this, "用户已取消开启忽略电池优化..", Toast.LENGTH_SHORT)
                        .show();
            }
            else
            {
                Log.i(TAG, "APP已加入省电白名单..");
            }
        }
    }

    void SwitchScreenResolution(int position) {
        Log.i(TAG, "Current Screen Resolution position: " + position);

        switch (position) {
            case 0:
                screenResolution = SCREEN_RESOLUTION_STANDARD;
                break;
            case 1:
                screenResolution = SCREEN_RESOLUTION_LOW;
                break;
            case 2:
                screenResolution = SCREEN_RESOLUTION_ORIGINAL_RESOLUTION;
                break;
            default:
                screenResolution = SCREEN_RESOLUTION_STANDARD;
        }
    }

    void SwitchVideoEncodeType(int position) {
        Log.i(TAG, "Current encode type: " + position);

        switch (position) {
            case 0:
                video_encode_type = VIDEO_ENCODE_TYPE_SW_H264;
                break;
            case 1:
                video_encode_type = VIDEO_ENCODE_TYPE_HW_H264;
                break;
            case 2:
                video_encode_type = VIDEO_ENCODE_TYPE_HW_H265;
                break;
            default:
                video_encode_type = VIDEO_ENCODE_TYPE_SW_H264;
        }
    }

    private void PopInputUrlDialog() {
        final EditText inputUrlTxt = new EditText(this);
        inputUrlTxt.setFocusable(true);
        inputUrlTxt.setText(baseURL
                + String.valueOf((int) (System.currentTimeMillis() % 1000000)));

        AlertDialog.Builder builderUrl = new AlertDialog.Builder(this);
        builderUrl.setTitle("如 rtmp://player.daniulive.com:1935/hls/stream123456")
                .setView(inputUrlTxt).setNegativeButton("取消", null);

        builderUrl.setPositiveButton("确认",
                new DialogInterface.OnClickListener() {

                    public void onClick(DialogInterface dialog, int which) {
                        String fullPushUrl = inputUrlTxt.getText().toString();
                        SaveInputUrl(fullPushUrl);
                    }
                });

        builderUrl.show();
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

        if (!url.startsWith("rtmp://")) {
            Log.e(TAG, "Input publish url error:" + url);
            return;
        }

        inputPushURL = url;
    }

    class ButtonInputPushUrlListener implements OnClickListener {
        public void onClick(View v) {
            PopInputUrlDialog();
        }
    }

    class ButtonRecorderMangerListener implements OnClickListener {
        public void onClick(View v) {
            Intent intent_rec = new Intent();
            intent_rec.setClass(MainActivity.this, RecorderManager.class);
            intent_rec.putExtra("RecorderDir", recDir);
            startActivity(intent_rec);
        }
    }

    //启动/停止RTSP服务
    class ButtonRtspPublisherListener implements OnClickListener {
        public void onClick(View v) {

            if(isPushingRtmp)
            {
                Log.e(TAG, "(简单Demo演示)启动内置RTSP服务之前，确保RTMP推送关闭..");
                return;
            }

            if (!isRTSPPublisherRunning ) {
                Log.i(TAG, "Start RTSP publisher++");

                intent_bgd_service.putExtra("SCREENRESOLUTION", screenResolution);

                intent_bgd_service.putExtra("RECORDER", is_need_local_recorder);    //是否录像
                intent_bgd_service.putExtra("VIDEOENCODETYPE", video_encode_type);      //视频编码类型选择

                push_type = PUSH_TYPE_RTSP;  //RTSP
                intent_bgd_service.putExtra("PUSHTYPE", push_type);

                startService(intent_bgd_service);

                btnRtspPublisher.setText("停止RTSP流");
                screenResolutionSelector.setEnabled(false);
                recorderSelector.setEnabled(false);
                btnRecorderMgr.setEnabled(false);
                videoEncodeTypeSelector.setEnabled(false);

                btnPublisher.setEnabled(false);
                isRTSPPublisherRunning = true;
                Log.i(TAG, "Start RTSP publisher--");
            } else {
                Log.i(TAG, "Stop RTSP publisher++");
                stopService(intent_bgd_service);
                btnRtspPublisher.setText("发布RTSP流");
                screenResolutionSelector.setEnabled(true);
                btnPermissionCheck.setEnabled(true);

                recorderSelector.setEnabled(true);
                btnRecorderMgr.setEnabled(true);
                videoEncodeTypeSelector.setEnabled(true);

                btnRtspPublisher.setEnabled(false);
                isRTSPPublisherRunning = false;

                is_has_screen_capture_permission = false;
                Log.i(TAG, "Stop RTSP publisher--");
            }
        }
    }

    //判断是否加入省电白名单弹窗
    private boolean isIgnoringBatteryOptimizations(){
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            String packageName = getPackageName();
            PowerManager pm = (PowerManager) getSystemService(POWER_SERVICE);
            return pm.isIgnoringBatteryOptimizations(packageName);
        }
        return false;
    }

    //拉起请求加入省电白名单弹窗
    private void gotoSettingIgnoringBatteryOptimizations() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            try {
                Intent intent = new Intent();
                String packageName = getPackageName();
                intent.setAction(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS);
                intent.setData(Uri.parse("package:" + packageName));
                startActivityForResult(intent, REQUEST_IGNORE_BATTERY_CODE);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    //动态获取Audio权限
    private void RequestAudioPermission()
    {
        if (PackageManager.PERMISSION_GRANTED ==  ContextCompat.checkSelfPermission(this.getApplicationContext(), android.Manifest.permission.RECORD_AUDIO))
        {
        }
        else {
            //提示用户开户权限音频
            String[] perms = {"android.permission.RECORD_AUDIO"};
            ActivityCompat.requestPermissions(this, perms, RESULT_CODE_STARTAUDIO);
        }
    }

    @Override
    public void onRequestPermissionsResult(int permsRequestCode, String[] permissions, int[] grantResults){
        switch(permsRequestCode){
            case RESULT_CODE_STARTAUDIO:
                boolean albumAccepted = grantResults[0]==PackageManager.PERMISSION_GRANTED;
                if(!albumAccepted){
                    Toast.makeText(this, "请开启应用录音权限..", Toast.LENGTH_SHORT)
                            .show();
                }
                break;
        }
    }

    @Override
    protected void onResume() {
        Log.i(TAG, "Run into onResume, isPushingRtmp:" + isPushingRtmp + ", isRTSPPublisherRunning: " + isRTSPPublisherRunning);

        if(is_has_screen_capture_permission)
        {
            btnPublisher.setEnabled(true);

            if(isPushingRtmp)
            {
                btnPublisher.setText("停止RTMP推送");
                btnRtspPublisher.setEnabled(false);
            }
            else
            {
                btnPublisher.setText("开始RTMP推送");
            }

            btnRtspPublisher.setEnabled(true);
            if(isRTSPPublisherRunning)
            {
                btnRtspPublisher.setText("停止RTSP流");
                btnPublisher.setEnabled(false);
            }
            else
            {
                btnRtspPublisher.setText("发布RTSP流");
            }
        }
        else
        {
            btnPublisher.setEnabled(false);
            btnRtspPublisher.setEnabled(false);
            btnPublisher.setText("开始RTMP推送");
            btnRtspPublisher.setText("发布RTSP流");
        }

        super.onResume();
    }
}
