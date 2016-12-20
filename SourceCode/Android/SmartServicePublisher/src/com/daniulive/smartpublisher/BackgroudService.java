/*
 * BackgroudService.java
 * BackgroudService
 * 
 * Github: https://github.com/daniulive/SmarterStreaming
 * 
 * Created by DaniuLive on 2016/12/12.
 * Copyright © 2014~2016 DaniuLive. All rights reserved.
 */

package com.daniulive.smartpublisher;

import java.nio.ByteBuffer;
import java.util.List;

import com.eventhandle.SmartEventCallback;
import com.voiceengine.NTAudioRecord;

import android.annotation.SuppressLint;
import android.annotation.TargetApi;
import android.app.Notification;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.graphics.ImageFormat;
import android.graphics.PixelFormat;
import android.hardware.Camera;
import android.hardware.Camera.AutoFocusCallback;
import android.hardware.Camera.CameraInfo;
import android.hardware.Camera.Parameters;
import android.hardware.Camera.PreviewCallback;
import android.hardware.Camera.Size;
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
import android.view.Gravity;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.WindowManager;

@SuppressLint({ "ClickableViewAccessibility", "NewApi" })
public class BackgroudService extends Service implements
		SurfaceHolder.Callback, PreviewCallback {

	private boolean mPreviewRunning = false;

	private boolean is_running = false;

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
	private int videoHight = 480;

	private int frameCount = 0;

	NTAudioRecord audioRecord_ = null; // for audio capture

	Notification notification = null;

	private SurfaceView bgSurfaceView;

	private SmartPublisherJni libPublisher = null;

	private String txt = "当前状态";

	private int audio_opt = 1;
	private int video_opt = 1;

	private final int PUSH_TYPE_SCREEN = 0;
	private final int PUSH_TYPE_CAMERA = 1;

	private int pushType = PUSH_TYPE_SCREEN;

	private final int SCREEN_RESOLUTION_STANDARD = 0;
	private final int SCREEN_RESOLUTION_LOW = 1;

	private int screenResolution = SCREEN_RESOLUTION_STANDARD;

	private String recDir = "/sdcard/daniulive/rec"; // for recorder path

	private boolean is_need_local_recorder = false; // do not enable recorder in
													// default

	static {
		System.load("libSmartPublisher.so");
	}

	@Override
	public void onCreate() {
		super.onCreate();
		Log.i(TAG, "onCreate..");
	}

	@SuppressWarnings("deprecation")
	@Override
	public void onStart(Intent intent, int startId) {
		// TODO Auto-generated method stub
		super.onStart(intent, startId);
		Log.i(TAG, "onStart..");

		pushType = intent.getExtras().getInt("PUSHTYPE");

		videoWidth = intent.getExtras().getInt("CAMERAWIDTH");

		videoHight = intent.getExtras().getInt("CAMERAHEIGHT");

		screenResolution = intent.getExtras().getInt("SCREENRESOLUTION");

		boolean isCameraFaceFront = intent.getExtras().getBoolean(
				"SWITCHCAMERA");

		if (isCameraFaceFront) {
			currentCameraType = FRONT;
		} else {
			currentCameraType = BACK;
		}

		if (!is_running) {
			// 对于6.0以上的设备
			/*
			 * if (Build.VERSION.SDK_INT >= 23) { //如果支持悬浮窗功能 if
			 * (Settings.canDrawOverlays(getApplicationContext())) {
			 * showWindow(); } else { //手动去开启悬浮窗 Intent intent = new
			 * Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION);
			 * intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
			 * getApplicationContext().startActivity(intent); } } else {
			 * //6.0以下的设备直接开启 showWindow(); }
			 */

			mWindowManager = (WindowManager) getSystemService(Service.WINDOW_SERVICE);

			if (pushType == PUSH_TYPE_CAMERA) {
				intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK
						| Intent.FLAG_ACTIVITY_SINGLE_TOP);
				PendingIntent contentIntent = PendingIntent.getActivity(this,
						0, intent, 0);

				Intent bIntent = new Intent(this, BackgroudService.class);
				PendingIntent deleteIntent = PendingIntent.getService(this, 0,
						bIntent, 0);

				notification = new Notification.Builder(this)
						.setContentTitle("后台采集中。。").setAutoCancel(true)
						.setDeleteIntent(deleteIntent)
						.setContentIntent(contentIntent).build();

				startForeground(android.os.Process.myPid(), notification);

				bgSurfaceView = new SurfaceView(this);

				WindowManager.LayoutParams layoutParams = new WindowManager.LayoutParams(
						1, 1, WindowManager.LayoutParams.TYPE_SYSTEM_OVERLAY,
						WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH,
						PixelFormat.TRANSLUCENT);
				layoutParams.gravity = Gravity.LEFT | Gravity.TOP;
				mWindowManager.addView(bgSurfaceView, layoutParams);

				bgSurfaceView.getHolder().addCallback(this);
			} else {
				// 窗口管理者
				createScreenEnvironment();
				startRecorderScreen();
			}

			CheckInitAudioRecorder();

			libPublisher = new SmartPublisherJni();

			if (libPublisher == null)
				return;

			if (pushType == PUSH_TYPE_CAMERA) {
				libPublisher.SmartPublisherInit(this.getApplicationContext(),
						audio_opt, video_opt, videoWidth, videoHight);
			} else {
				libPublisher.SmartPublisherInit(this.getApplicationContext(),
						audio_opt, video_opt, sreenWindowWidth,
						screenWindowHeight);
			}

			libPublisher.SetSmartPublisherEventCallback(new EventHande());

			boolean isHwEncoder = intent.getExtras().getBoolean("HWENCODER");

			if (isHwEncoder) {
				int kbps = setHardwareEncoderKbps(sreenWindowWidth,
						screenWindowHeight);

				Log.i(TAG, "hwHWKbps: " + kbps);

				int isSupportHWEncoder = libPublisher
						.SetSmartPublisherVideoHWEncoder(kbps);

				if (isSupportHWEncoder == 0) {
					Log.i(TAG, "Great, it supports hardware encoder!");
				}
			}

			is_need_local_recorder = intent.getExtras().getBoolean("RECORDER");

			ConfigRecorderFuntion();

			String publishURL = intent.getStringExtra("PUBLISHURL");

			Log.i(TAG, "publishURL: " + publishURL);

			// IF not set url or url is empty, it will not publish stream
			// if ( libPublisher.SmartPublisherSetURL("") != 0 )
			if (libPublisher.SmartPublisherSetURL(publishURL) != 0) {
				Log.e(TAG, "Failed to set publish stream URL..");
			}

			int isStarted = libPublisher.SmartPublisherStart();
			if (isStarted != 0) {
				Log.e(TAG, "Failed to publish stream..");
			}

			is_running = true;
		}
	}

	@Override
	public void onDestroy() {
		// TODO Auto-generated method stub
		Log.i(TAG, "Service stopped..");
		StopPublisher();
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

	private void StopPublisher() {
		if (is_running) {
			StopPublish();
			stopScreenCapture();
			is_running = false;
		}
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
		Log.i(TAG, "record start..");
		if (startScreenCapture()) {
			new Thread() {
				@Override
				public void run() {
					Log.i(TAG, "start record..");
				}
			}.start();
		}
	}

	/**
	 * Process image data as desired.
	 */
	@SuppressLint("NewApi")
	private void processScreenImage(Image image) {
		int width = image.getWidth();
		int height = image.getHeight();

		final Image.Plane[] planes = image.getPlanes();
		final ByteBuffer buffer = planes[0].getBuffer();

		int rowStride = planes[0].getRowStride();

		libPublisher.SmartPublisherOnCaptureVideoRGBAData(buffer, rowStride,
				width, height);
	}

	@SuppressLint("NewApi")
	private void stopScreenCapture() {
		if (pushType == PUSH_TYPE_CAMERA) {
			mCamera.setPreviewCallback(null);
			mCamera.stopPreview();
			mCamera.release();
		}

		if (mVirtualDisplay != null) {
			mVirtualDisplay.release();
			mVirtualDisplay = null;
		}
	}

	class EventHande implements SmartEventCallback {
		@Override
		public void onCallback(int code, long param1, long param2,
				String param3, String param4, Object param5) {
			switch (code) {
			case EVENTID.EVENT_DANIULIVE_ERC_PUBLISHER_STARTED:
				txt = "开始。。";
				break;
			case EVENTID.EVENT_DANIULIVE_ERC_PUBLISHER_CONNECTING:
				txt = "连接中。。";
				break;
			case EVENTID.EVENT_DANIULIVE_ERC_PUBLISHER_CONNECTION_FAILED:
				txt = "连接失败。。";
				break;
			case EVENTID.EVENT_DANIULIVE_ERC_PUBLISHER_CONNECTED:
				txt = "连接成功。。";
				break;
			case EVENTID.EVENT_DANIULIVE_ERC_PUBLISHER_DISCONNECTED:
				txt = "连接断开。。";
				break;
			case EVENTID.EVENT_DANIULIVE_ERC_PUBLISHER_STOP:
				txt = "关闭。。";
				break;
			case EVENTID.EVENT_DANIULIVE_ERC_PUBLISHER_RECORDER_START_NEW_FILE:
				Log.i(TAG, "开始一个新的录像文件 : " + param3);
				txt = "开始一个新的录像文件。。";
				break;
			case EVENTID.EVENT_DANIULIVE_ERC_PUBLISHER_ONE_RECORDER_FILE_FINISHED:
				Log.i(TAG, "已生成一个录像文件 : " + param3);
				txt = "已生成一个录像文件。。";
				break;
			}

			String str = "当前回调状态：" + txt;

			Log.i(TAG, str);

		}
	}

	void CheckInitAudioRecorder() {
		if (audioRecord_ == null) {
			audioRecord_ = new NTAudioRecord(this, 1);
		}

		if (audioRecord_ != null) {
			Log.i(TAG, "onCreate, call executeAudioRecordMethod..");
			audioRecord_.executeAudioRecordMethod();
		}
	}

	private void StopPublish() {
		if (audioRecord_ != null) {
			Log.i(TAG, "surfaceDestroyed, call StopRecording..");
			audioRecord_.StopRecording();
			audioRecord_ = null;
		}

		if (libPublisher != null) {
			libPublisher.SmartPublisherStop();
		}
	}

	private int setHardwareEncoderKbps(int width, int height) {
		int hwEncoderKpbs = 0;

		if (width < 200) {
			hwEncoderKpbs = 300;
		} else if (width < 400) {
			hwEncoderKpbs = 500;
		} else if (width < 600) {
			hwEncoderKpbs = 800;
		} else if (width < 800) {
			hwEncoderKpbs = 1100;
		} else if (width < 1000) {
			hwEncoderKpbs = 1500;
		} else if (width < 1300) {
			hwEncoderKpbs = 2000;
		} else {
			hwEncoderKpbs = 1000;
		}

		return hwEncoderKpbs;
	}

	// Configure recorder related function.
	void ConfigRecorderFuntion() {
		if (libPublisher != null) {
			if (is_need_local_recorder) {
				if (recDir != null && !recDir.isEmpty()) {
					int ret = libPublisher
							.SmartPublisherCreateFileDirectory(recDir);
					if (0 == ret) {
						if (0 != libPublisher
								.SmartPublisherSetRecorderDirectory(recDir)) {
							Log.e(TAG, "Set recoder dir failed , path:"
									+ recDir);
							return;
						}

						if (0 != libPublisher.SmartPublisherSetRecorder(1)) {
							Log.e(TAG, "SmartPublisherSetRecoder failed.");
							return;
						}

						if (0 != libPublisher
								.SmartPublisherSetRecorderFileMaxSize(200)) {
							Log.e(TAG,
									"SmartPublisherSetRecoderFileMaxSize failed.");
							return;
						}

					} else {
						Log.e(TAG, "Create recoder dir failed, path:" + recDir);
					}
				}
			} else {
				if (0 != libPublisher.SmartPublisherSetRecorder(0)) {
					Log.e(TAG, "SmartPublisherSetRecoder failed.");
					return;
				}
			}
		}
	}

	/* it will call when surfaceChanged */
	@SuppressWarnings("deprecation")
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

		parameters.setPictureSize(videoWidth, videoHight);
		parameters.setPreviewSize(videoWidth, videoHight);
		parameters.setPictureFormat(PixelFormat.JPEG);
		parameters.setPreviewFormat(PixelFormat.YCbCr_420_SP);

		SetCameraFPS(parameters);

		mCamera.setParameters(parameters);

		int bufferSize = (((videoWidth | 0xf) + 1) * videoHight * ImageFormat
				.getBitsPerPixel(parameters.getPreviewFormat())) / 8;

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

	@SuppressWarnings("deprecation")
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

	@SuppressWarnings("deprecation")
	@Override
	public void onPreviewFrame(byte[] data, Camera camera) {
		frameCount++;
		if (frameCount % 3000 == 0) {
			Log.i("OnPre", "gc+");
			System.gc();
			Log.i("OnPre", "gc-");
		}

		if (data == null) {
			@SuppressWarnings("deprecation")
			Parameters params = camera.getParameters();
			Size size = params.getPreviewSize();
			int bufferSize = (((size.width | 0x1f) + 1) * size.height * ImageFormat
					.getBitsPerPixel(params.getPreviewFormat())) / 8;
			camera.addCallbackBuffer(new byte[bufferSize]);
		} else {
			if (is_running) {
				// Log.i(TAG, "callback data length: " + data.length);
				libPublisher.SmartPublisherOnCaptureVideoData(data,
						data.length, currentCameraType, currentOrigentation);
			}
			camera.addCallbackBuffer(data);
		}
	}

	@SuppressWarnings("deprecation")
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
					Log.i(TAG, "Camera index:" + i + " support min fps:"
							+ range[Camera.Parameters.PREVIEW_FPS_MIN_INDEX]);

					Log.i(TAG, "Camera index:" + i + " support max fps:"
							+ range[Camera.Parameters.PREVIEW_FPS_MAX_INDEX]);

					if (findRange == null) {
						if (defFPS <= range[Camera.Parameters.PREVIEW_FPS_MAX_INDEX]) {
							findRange = range;

							Log.i(TAG,
									"Camera found appropriate fps, min fps:"
											+ range[Camera.Parameters.PREVIEW_FPS_MIN_INDEX]
											+ " ,max fps:"
											+ range[Camera.Parameters.PREVIEW_FPS_MAX_INDEX]);
						}
					}
				}
			}
		}

		if (findRange != null) {
			parameters.setPreviewFpsRange(
					findRange[Camera.Parameters.PREVIEW_FPS_MIN_INDEX],
					findRange[Camera.Parameters.PREVIEW_FPS_MAX_INDEX]);
		}
	}

	// Check if it has front camera
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

	// Check if it has back camera
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

	@Override
	public void surfaceCreated(SurfaceHolder holder) {
		Log.i(TAG, "surfaceCreated");
		if (pushType == PUSH_TYPE_CAMERA) {
			try {
				// User could check if the device has back/front camera here..
				/*
				 * int CammeraIndex = findBackCamera(); Log.i(TAG,
				 * "BackCamera: " + CammeraIndex);
				 * 
				 * if (CammeraIndex == -1) { CammeraIndex = findFrontCamera();
				 * currentCameraType = FRONT; if (CammeraIndex == -1) {
				 * Log.i(TAG, "NO camera!!"); return; } } else {
				 * currentCameraType = BACK; }
				 */

				if (mCamera == null) {
					mCamera = openCamera(currentCameraType);
				}

			} catch (Exception e) {
				e.printStackTrace();
			}

			initCamera(holder);
		}
	}

	@Override
	public void surfaceChanged(SurfaceHolder holder, int format, int width,
			int height) {
		Log.i(TAG, "surfaceChanged");
	}

	@Override
	public void surfaceDestroyed(SurfaceHolder holder) {
		Log.i(TAG, "surfaceDestroyed");

		if (pushType == PUSH_TYPE_CAMERA) {
			mCamera.setPreviewCallback(null);
			mCamera.stopPreview();
			mCamera.release();
		}

		if (libPublisher != null) {
			libPublisher.SmartPublisherStop();
		}
	}
}
