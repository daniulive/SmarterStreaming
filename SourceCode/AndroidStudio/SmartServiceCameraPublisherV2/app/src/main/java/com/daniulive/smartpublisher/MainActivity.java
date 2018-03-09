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
import android.widget.AdapterView.OnItemSelectedListener;

public class MainActivity extends Activity {
    private static final String TAG = "DaniuliveActivity";

    private Spinner cameraResolutionSelector;
    private Spinner recorderSelector;

    private Button btnRecorderMgr;
    private Button btnSwitchCamera;
    private Button btnEncoderType;
    private Button btnInputPushUrl;

    private Button btnPublisher;

    private boolean is_need_local_recorder = false; //默认不录像
    private boolean is_hardware_encoder = false;    //默认软编码
    private boolean is_running = false;

    final private String baseURL = "rtmp://player.daniulive.com:1935/hls/stream";
    private String inputPushURL = "";
    private TextView textCurURL = null;
    private String printText = "URL:";

    private boolean isCameraFaceFront = false; // 当前打开的摄像头标记

    private int videoWidth = 640;
    private int videoHeight = 480;

    private String publishURL = "rtmp://player.daniulive.com:1935/hls/streamservice";

    private String recDir = "/sdcard/daniulive/rec"; // for recorder path

    private Intent intent_bg = null;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        intent_bg = new Intent(MainActivity.this, BackgroudService.class);

        if(intent_bg == null)
        {
            Log.e(TAG, "[MainActivity]intent_bg with null..");
        }

        cameraResolutionSelector = (Spinner) findViewById(R.id.camera_resolution_selctor);
        final String[] resolutionSel = new String[] { "摄像头高分辨率", "摄像头中分辨率",
                "摄像头低分辨率", "摄像头超高分辨率" };
        ArrayAdapter<String> adapterResolution = new ArrayAdapter<String>(this,
                android.R.layout.simple_spinner_item, resolutionSel);
        adapterResolution
                .setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        cameraResolutionSelector.setAdapter(adapterResolution);

        cameraResolutionSelector
                .setOnItemSelectedListener(new OnItemSelectedListener() {

                    @Override
                    public void onItemSelected(AdapterView<?> parent,
                                               View view, int position, long id) {

                        if (is_running) {
                            Log.e(TAG,
                                    "Could not switch resolution during publishing..");
                            return;
                        }

                        Log.i(TAG, "[推送分辨率]Currently choosing: "
                                + resolutionSel[position]);

                        SwitchResolution(position);

                    }

                    @Override
                    public void onNothingSelected(AdapterView<?> parent) {

                    }
                });

        // Recorder related settings
        recorderSelector = (Spinner) findViewById(R.id.recoder_selctor);

        final String[] recoderSel = new String[]{"本地不录像", "本地录像"};
        ArrayAdapter<String> adapterRecoder = new ArrayAdapter<String>(this,
                android.R.layout.simple_spinner_item, recoderSel);

        adapterRecoder
                .setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        recorderSelector.setAdapter(adapterRecoder);

        recorderSelector
                .setOnItemSelectedListener(new OnItemSelectedListener() {

                    @Override
                    public void onItemSelected(AdapterView<?> parent,
                                               View view, int position, long id) {

                        Log.i(TAG, "Currently choosing: "
                                + recoderSel[position]);

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

        btnSwitchCamera = (Button) findViewById(R.id.button_switch_camera);
        btnSwitchCamera.setOnClickListener(new ButtonSwitchCameraListener());

        btnEncoderType = (Button) findViewById(R.id.button_hwencoder);
        btnEncoderType.setOnClickListener(new ButtonHardwareEncoderListener());

        btnInputPushUrl = (Button) findViewById(R.id.button_input_push_url);
        btnInputPushUrl.setOnClickListener(new ButtonInputPushUrlListener());

        btnPublisher = (Button) findViewById(R.id.button_start_stop_capture);
        btnPublisher.setOnClickListener(new OnClickListener() {

            @SuppressLint("NewApi")
            @Override
            public void onClick(View v) {
                if (!is_running) {
                    Log.i(TAG, "Start publish camera++ videoWidth: " + videoWidth + " videoHeight: " + videoHeight);

                    intent_bg.putExtra("CAMERAWIDTH", videoWidth);
                    intent_bg.putExtra("CAMERAHEIGHT", videoHeight);

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

                    intent_bg.putExtra("PUBLISHURL", publishURL);

                    intent_bg.putExtra("RECORDER", is_need_local_recorder);    //是否录像
                    intent_bg.putExtra("HWENCODER", is_hardware_encoder);      //软编还是硬编
                    intent_bg.putExtra("SWITCHCAMERA", isCameraFaceFront);

                    startService(intent_bg);

                    is_running = true;
                    btnPublisher.setText("停止推流");
                    cameraResolutionSelector.setEnabled(false);
                    recorderSelector.setEnabled(false);
                    btnRecorderMgr.setEnabled(false);
                    btnInputPushUrl.setEnabled(false);
                    btnEncoderType.setEnabled(false);
                    btnSwitchCamera.setEnabled(false);
                    Log.i(TAG, "Start publish camera--");
                } else {
                    Log.i(TAG, "Stop publisher camera++");
                    stopService(intent_bg);
                    is_running = false;
                    btnPublisher.setText("开始推流");
                    cameraResolutionSelector.setEnabled(true);
                    btnSwitchCamera.setEnabled(true);

                    recorderSelector.setEnabled(true);
                    btnRecorderMgr.setEnabled(true);
                    btnInputPushUrl.setEnabled(true);
                    btnEncoderType.setEnabled(true);
                    btnSwitchCamera.setEnabled(true);
                    Log.i(TAG, "Stop publisher camera--");
                }
            }
        });
    }

    void SwitchResolution(int position) {
        Log.i(TAG, "Current Resolution position: " + position);

        switch (position) {
            case 0:
                videoWidth = 640;
                videoHeight = 480;
                break;
            case 1:
                videoWidth = 320;
                videoHeight = 240;
                break;
            case 2:
                videoWidth = 176;
                videoHeight = 144;
                break;
            case 3:
                videoWidth = 1280;
                videoHeight = 720;
                break;
            default:
                videoWidth = 640;
                videoHeight = 480;
        }
    }

    class ButtonSwitchCameraListener implements OnClickListener {
        public void onClick(View v) {
            isCameraFaceFront = !isCameraFaceFront;

            if (isCameraFaceFront)
                btnSwitchCamera.setText("当前前置摄像头");
            else
                btnSwitchCamera.setText("当前后置摄像头");
        }
    }

    class ButtonHardwareEncoderListener implements OnClickListener {
        public void onClick(View v) {
            is_hardware_encoder = !is_hardware_encoder;

            if (is_hardware_encoder)
                btnEncoderType.setText("当前硬编码");
            else
                btnEncoderType.setText("当前软编码");
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
            Intent intent = new Intent();
            intent.setClass(MainActivity.this, RecorderManager.class);
            intent.putExtra("RecorderDir", recDir);
            startActivity(intent);
        }
    }

}
