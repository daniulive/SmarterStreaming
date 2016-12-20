/*
 * MainActivity.java
 * MainActivity
 * 
 * Github: https://github.com/daniulive/SmarterStreaming
 * 
 * Created by DaniuLive on 2016/12/12.
 * Copyright © 2014~2016 DaniuLive. All rights reserved.
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

public class MainActivity extends Activity {
	MediaProjectionManager mMediaProjectionManager;

	private static final int REQUEST_MEDIA_PROJECTION = 1;

	private static final String TAG = "DaniuliveActivity";
	static int mResultCode;
	static Intent mResultData;

	private Spinner typeSelector;
	private Spinner cameraResolutionSelector;
	private Spinner screenResolutionSelector;
	private Spinner recorderSelector;
	private Button btnRecoderMgr;
	private Button btnHWencoder;
	private Button btnSwitchCamera;
	private Button btnInputPushUrl;

	private Button btnPermissionCheck;
	private Button btnCapture;
	private boolean is_need_local_recorder = false; // do not enable recorder in
													// default

	private boolean isCameraFaceFront = false; // 当前打开的摄像头标记
	private boolean is_hardware_encoder = false;
	private boolean isStart = false;
	final private String baseURL = "rtmp://daniulive.com:1935/hls/stream";
	private String inputPushURL = "";
	private TextView textCurURL = null;
	private String printText = "URL:";

	private int videoWidth = 640;
	private int videoHight = 480;

	private String publishURL = "rtmp://daniulive.com:1935/hls/streamservice";

	private final int PUSH_TYPE_SCREEN = 0;
	private final int PUSH_TYPE_CAMERA = 1;

	private int pushType = PUSH_TYPE_SCREEN;

	private final int SCREEN_RESOLUTION_STANDARD = 0;
	private final int SCREEN_RESOLUTION_LOW = 1;

	private int screenResolution = SCREEN_RESOLUTION_STANDARD;

	private String recDir = "/sdcard/daniulive/rec"; // for recorder path

	BackgroudService bgService;

	private Intent intent = null;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main);

		intent = new Intent(MainActivity.this, BackgroudService.class);

		typeSelector = (Spinner) findViewById(R.id.pushTpyeSelctor);
		final String[] pushTypeSel = new String[] { "推送屏幕", "推送摄像头" };
		ArrayAdapter<String> adapterPushType = new ArrayAdapter<String>(this,
				android.R.layout.simple_spinner_item, pushTypeSel);
		adapterPushType
				.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
		typeSelector.setAdapter(adapterPushType);

		typeSelector.setOnItemSelectedListener(new OnItemSelectedListener() {

			@Override
			public void onItemSelected(AdapterView<?> parent, View view,
					int position, long id) {

				if (isStart) {
					Log.e(TAG, "Could not switch push type during publishing..");
					return;
				}

				Log.i(TAG, "[推送类型]Currently choosing: " + pushTypeSel[position]);

				SwitchPushType(position);

			}

			@Override
			public void onNothingSelected(AdapterView<?> parent) {

			}
		});

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

						if (isStart) {
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

		screenResolutionSelector = (Spinner) findViewById(R.id.screen_resolution_selctor);
		final String[] sceenResolutionSel = new String[] { "屏幕标准分辨率", "屏幕低分辨率" };
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

						if (isStart) {
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

		final String[] recoderSel = new String[] { "本地不录像", "本地录像" };
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

		btnRecoderMgr = (Button) findViewById(R.id.button_recoder_manage);
		btnRecoderMgr.setOnClickListener(new ButtonRecorderMangerListener());

		btnSwitchCamera = (Button) findViewById(R.id.button_switch_camera);
		btnSwitchCamera.setOnClickListener(new ButtonSwitchCameraListener());

		btnHWencoder = (Button) findViewById(R.id.button_hwencoder);
		btnHWencoder.setOnClickListener(new ButtonHardwareEncoderListener());

		btnInputPushUrl = (Button) findViewById(R.id.button_input_push_url);
		btnInputPushUrl.setOnClickListener(new ButtonInputPushUrlListener());

		btnPermissionCheck = (Button) findViewById(R.id.permission_check);
		btnPermissionCheck.setOnClickListener(new OnClickListener() {
			@SuppressLint("NewApi")
			@Override
			public void onClick(View v) {

				if (pushType == PUSH_TYPE_SCREEN) {
					if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
						mMediaProjectionManager = (MediaProjectionManager) getApplicationContext()
								.getSystemService(MEDIA_PROJECTION_SERVICE);
						startActivityForResult(mMediaProjectionManager
								.createScreenCaptureIntent(),
								REQUEST_MEDIA_PROJECTION);
					}
				}
			}
		});

		btnCapture = (Button) findViewById(R.id.button_start_stop_capture);
		btnCapture.setEnabled(false);
		btnCapture.setOnClickListener(new OnClickListener() {

			@SuppressLint("NewApi")
			@Override
			public void onClick(View v) {
				if (!isStart) {
					Log.i(TAG, "Start publisher..");
					intent.putExtra("PUSHTYPE", pushType);

					intent.putExtra("CAMERAWIDTH", videoWidth);
					intent.putExtra("CAMERAHEIGHT", videoHight);

					intent.putExtra("SCREENRESOLUTION", screenResolution);

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

					intent.putExtra("PUBLISHURL", publishURL);

					intent.putExtra("RECORDER", is_need_local_recorder);
					intent.putExtra("HWENCODER", is_hardware_encoder);
					intent.putExtra("SWITCHCAMERA", isCameraFaceFront);

					startService(intent);

					isStart = true;
					btnCapture.setText("停止推送");
					cameraResolutionSelector.setEnabled(false);
					screenResolutionSelector.setEnabled(false);
					recorderSelector.setEnabled(false);
					btnRecoderMgr.setEnabled(false);
					btnInputPushUrl.setEnabled(false);
					btnHWencoder.setEnabled(false);
					btnSwitchCamera.setEnabled(false);
				} else {
					Log.i(TAG, "Stop publisher..");
					stopService(intent);
					isStart = false;
					btnCapture.setText("开始推流");
					if (pushType == PUSH_TYPE_SCREEN) {
						btnCapture.setEnabled(false);
						cameraResolutionSelector.setEnabled(false);
						screenResolutionSelector.setEnabled(true);
						btnPermissionCheck.setEnabled(true);
						btnSwitchCamera.setEnabled(false);
					} else {
						btnCapture.setEnabled(true);
						cameraResolutionSelector.setEnabled(true);
						screenResolutionSelector.setEnabled(false);
						btnPermissionCheck.setEnabled(false);
						btnSwitchCamera.setEnabled(true);
					}
					
					recorderSelector.setEnabled(true);
					btnRecoderMgr.setEnabled(true);
					btnInputPushUrl.setEnabled(true);
					btnHWencoder.setEnabled(true);
					btnSwitchCamera.setEnabled(true);
				}
			}
		});
	}

	@Override
	public void onActivityResult(int requestCode, int resultCode, Intent data) {
		if (requestCode == REQUEST_MEDIA_PROJECTION) {
			if (resultCode != Activity.RESULT_OK) {
				Log.e(TAG, "User cancelled");
				Toast.makeText(this, "User cancelled", Toast.LENGTH_SHORT)
						.show();
				return;
			}

			mResultCode = resultCode;
			mResultData = data;
			btnPermissionCheck.setEnabled(false);
			btnCapture.setEnabled(true);
		}
	}

	void SwitchPushType(int position) {
		Log.i(TAG, "Current push type position: " + position);

		switch (position) {
		case 0:
			pushType = PUSH_TYPE_SCREEN;
			cameraResolutionSelector.setEnabled(false);
			screenResolutionSelector.setEnabled(true);
			btnPermissionCheck.setEnabled(true);
			btnSwitchCamera.setEnabled(false);
			btnCapture.setEnabled(false);
			break;
		case 1:
			pushType = PUSH_TYPE_CAMERA;
			cameraResolutionSelector.setEnabled(true);
			screenResolutionSelector.setEnabled(false);
			btnPermissionCheck.setEnabled(false);
			btnCapture.setEnabled(true);
			btnSwitchCamera.setEnabled(true);
			btnCapture.setEnabled(true);
			break;
		default:
			pushType = PUSH_TYPE_SCREEN;
		}
	}

	void SwitchResolution(int position) {
		Log.i(TAG, "Current Resolution position: " + position);

		switch (position) {
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
		default:
			screenResolution = SCREEN_RESOLUTION_STANDARD;
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
				btnHWencoder.setText("当前硬解码");
			else
				btnHWencoder.setText("当前软编码");
		}
	}

	private void PopInputUrlDialog() {
		final EditText inputUrlTxt = new EditText(this);
		inputUrlTxt.setFocusable(true);
		inputUrlTxt.setText(baseURL
				+ String.valueOf((int) (System.currentTimeMillis() % 1000000)));

		AlertDialog.Builder builderUrl = new AlertDialog.Builder(this);
		builderUrl.setTitle("如 rtmp://daniulive.com:1935/hls/stream123456")
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
			intent.putExtra("RecoderDir", recDir);
			startActivity(intent);
		}
	}

}
