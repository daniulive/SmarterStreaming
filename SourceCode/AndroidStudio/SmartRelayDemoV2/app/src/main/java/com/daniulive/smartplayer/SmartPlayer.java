/*
 * SmartPlayer.java
 * SmartPlayer
 * 
 * Github: https://github.com/daniulive/SmarterStreaming
 * 
 * Created by DaniuLive on 2015/09/26.
 * Copyright © 2014~2018 DaniuLive. All rights reserved.
 */

package com.daniulive.smartplayer;

import java.io.File;
//import java.io.FileOutputStream;
//import java.io.IOException;
import java.nio.ByteBuffer;
import java.text.SimpleDateFormat;
import java.util.Date;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.res.Configuration;
import android.os.Bundle;
import android.os.Environment;
import android.util.Log;
import android.view.SurfaceView;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup.LayoutParams;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.daniulive.smartpublisher.SmartPublisherJniV2;
import com.videoengine.*;
import com.eventhandle.NTSmartEventCallbackV2;
import com.eventhandle.NTSmartEventID;
import com.voiceengine.NTAudioDataCallback;
//import android.graphics.YuvImage;  
//import android.graphics.ImageFormat;

public class SmartPlayer extends Activity {

	private SurfaceView sSurfaceView = null;

	private long playerHandle = 0;

	private static final int PORTRAIT = 1; // 竖屏
	private static final int LANDSCAPE = 2; // 横屏
	private static final String TAG = "SmartPlayer";

	private SmartPlayerJniV2 libPlayer = null;

	private int currentOrigentation = PORTRAIT;

	private String playbackUrl = null;

	private String relayStreamUrl = null;

	private boolean isMute = false;

	private boolean isHardwareDecoder = false;

	private int playBuffer = 200; // 默认200ms

	private boolean isLowLatency = false; // 超低延时，默认不开启

	private boolean isFastStartup = true; // 是否秒开, 默认true

	private int rotate_degrees = 0;

	private boolean switchUrlFlag = false;

	private String switchURL = "rtmp://live.hkstv.hk.lxdns.com/live/hks1";

	private String imageSavePath;

	private String recDir = "/sdcard/daniulive/playrec"; // for recorder path

	private boolean isPlaying = false;
	private boolean isRecording = false;
	private boolean isPulling = false;

	// Button ;
	Button btnPopInputUrl;
	Button btnPopInputRelayUrl;
	Button btnMute;
	Button btnStartStopPlayback;
	Button btnStartStopRecorder;
	Button btnStartStopPullStream;
	Button btnRecoderMgr;
	Button btnHardwareDecoder;
	Button btnCaptureImage;
	Button btnFastStartup;
	Button btnSetPlayBuffer;
	Button btnLowLatency;
	Button btnRotation;
	Button btnSwitchUrl;
	TextView txtCopyright;
	TextView txtQQQun;

	LinearLayout lLayout = null;
	FrameLayout fFrameLayout = null;

	private Context myContext;

	private long publisherHandle = 0;

	private SmartPublisherJniV2 libPublisher = null;

	private String txt = "当前状态";

	static {
		System.loadLibrary("SmartPlayer");
		System.loadLibrary("SmartPublisher");
	}

	@Override
	protected void onCreate(Bundle icicle) {
		super.onCreate(icicle);

		Log.i(TAG, "Run into OnCreate++");

		getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON); 	//屏幕常亮

		libPlayer = new SmartPlayerJniV2();
		libPublisher = new SmartPublisherJniV2();

		myContext = this.getApplicationContext();

		// 设置快照路径(具体路径可自行设置)
		File storageDir = getOwnCacheDirectory(myContext, "daniuimage");// 创建保存的路径
		imageSavePath = storageDir.getPath();
		Log.i(TAG, "快照存储路径: " + imageSavePath);

		boolean bViewCreated = CreateView();

		if (bViewCreated) {
			inflateLayout(LinearLayout.VERTICAL);
		}
	}

	private void SaveInputUrl(String url) {
		playbackUrl = "";

		if (url == null)
			return;

		if (url.equals("hks")) {
			btnStartStopPlayback.setEnabled(true);
			playbackUrl = "rtmp://live.hkstv.hk.lxdns.com/live/hks1";

			Log.i(TAG, "Input url:" + playbackUrl);

			return;
		}

		// rtmp:/
		if (url.length() < 8) {
			Log.e(TAG, "Input full url error:" + url);
			return;
		}

		if (!url.startsWith("rtmp://") && !url.startsWith("rtsp://")) {
			Log.e(TAG, "Input full url error:" + url);
			return;
		}

		btnStartStopPlayback.setEnabled(true);
		playbackUrl = url;

		Log.i(TAG, "Input full url:" + url);
	}

	private void SaveInputRelayUrl(String url) {
		relayStreamUrl = "";

		if (url == null)
			return;

		// rtmp://
		if (url.length() < 8) {
			Log.e(TAG, "Input relay fully url error:" + url);
			return;
		}

		if (!url.startsWith("rtmp://")) {
			Log.e(TAG, "Input fully url error:" + url);
			return;
		}

		btnStartStopPullStream.setEnabled(true);
		relayStreamUrl = url;

		Log.i(TAG, "Input full url:" + url);
	}

	private void SaveInputPlayBuffer(String bufferText) {
		try {
			Integer intValue;
			intValue = Integer.valueOf(bufferText);

			playBuffer = intValue;

			Log.i(TAG, "Input play buffer:" + playBuffer);

		} catch (NumberFormatException e) {
			Log.i(TAG, "Input play buffer convert exception");

			e.printStackTrace();
		}
	}

	private void PopFullUrlDialog() {
		final EditText inputUrlTxt = new EditText(this);
		inputUrlTxt.setFocusable(true);
		inputUrlTxt.setText("rtmp://player.daniulive.com:1935/hls/stream");

		AlertDialog.Builder builderUrl = new AlertDialog.Builder(this);
		builderUrl
				.setTitle("播放url如 rtmp://player.daniulive.com:1935/hls/stream123456")
				.setView(inputUrlTxt).setNegativeButton("取消", null);
		builderUrl.setPositiveButton("确认",
				new DialogInterface.OnClickListener() {

					public void onClick(DialogInterface dialog, int which) {
						String fullUrl = inputUrlTxt.getText().toString();
						SaveInputUrl(fullUrl);
					}
				});
		builderUrl.show();
	}

	private void PopRelaylUrlDialog() {
		final EditText inputUrlTxt = new EditText(this);
		inputUrlTxt.setFocusable(true);
		inputUrlTxt.setText("rtmp://player.daniulive.com:1935/hls/stream");

		AlertDialog.Builder builderUrl = new AlertDialog.Builder(this);
		builderUrl
				.setTitle("转发url如 rtmp://player.daniulive.com:1935/hls/stream123456")
				.setView(inputUrlTxt).setNegativeButton("取消", null);
		builderUrl.setPositiveButton("确认",
				new DialogInterface.OnClickListener() {

					public void onClick(DialogInterface dialog, int which) {
						String fullUrl = inputUrlTxt.getText().toString();
						SaveInputRelayUrl(fullUrl);
					}
				});
		builderUrl.show();
	}

	private void PopSettingBufferDialog() {
		final EditText inputBuferTxt = new EditText(this);
		inputBuferTxt.setFocusable(true);

		String str = "";
		str += playBuffer;

		inputBuferTxt.setText(str);

		AlertDialog.Builder builderBuffer = new AlertDialog.Builder(this);

		builderBuffer.setTitle("设置播放缓冲(毫秒),默认200ms").setView(inputBuferTxt)
				.setNegativeButton("取消", null);

		builderBuffer.setPositiveButton("确认",
				new DialogInterface.OnClickListener() {

					public void onClick(DialogInterface dialog, int which) {
						String bufferText = inputBuferTxt.getText().toString();
						SaveInputPlayBuffer(bufferText);
					}
				});

		builderBuffer.show();
	}

	/* Generate basic layout */
	private void inflateLayout(int orientation) {
		if (null == lLayout)
			lLayout = new LinearLayout(this);

		addContentView(lLayout, new android.view.ViewGroup.LayoutParams(
				android.view.ViewGroup.LayoutParams.WRAP_CONTENT,
				android.view.ViewGroup.LayoutParams.WRAP_CONTENT));

		lLayout.setOrientation(orientation);

		fFrameLayout = new FrameLayout(this);

		LayoutParams lp = new LinearLayout.LayoutParams(
				LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT, 1.0f);
		fFrameLayout.setLayoutParams(lp);
		Log.i(TAG, "++inflateLayout..");

		sSurfaceView.setLayoutParams(new LayoutParams(
				LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT));

		fFrameLayout.addView(sSurfaceView, 0);

		RelativeLayout outLinearLayout = new RelativeLayout(this);
		outLinearLayout.setLayoutParams(new LayoutParams(
				LayoutParams.WRAP_CONTENT, LayoutParams.FILL_PARENT));

		LinearLayout lLinearLayout = new LinearLayout(this);
		lLinearLayout.setOrientation(LinearLayout.VERTICAL);
		lLinearLayout.setLayoutParams(new LayoutParams(
				LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT));

		LinearLayout copyRightLinearLayout = new LinearLayout(this);
		copyRightLinearLayout.setOrientation(LinearLayout.VERTICAL);
		RelativeLayout.LayoutParams rl = new RelativeLayout.LayoutParams(
				LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);
		rl.topMargin = getWindowManager().getDefaultDisplay().getHeight() - 270;
		copyRightLinearLayout.setLayoutParams(rl);

		txtCopyright = new TextView(this);
		txtCopyright.setLayoutParams(new LinearLayout.LayoutParams(
				LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT));
		txtCopyright
				.setText("Copyright 2014~2016 www.daniulive.com v1.0.16.0326");
		copyRightLinearLayout.addView(txtCopyright, 0);

		txtQQQun = new TextView(this);
		txtQQQun.setLayoutParams(new LinearLayout.LayoutParams(
				LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT));
		txtQQQun.setText("QQ群:294891451,  499687479");
		copyRightLinearLayout.addView(txtQQQun, 1);

		/* PopInput button */
		/*
		 * btnPopInputText = new Button(this);
		 * btnPopInputText.setText("输入urlID");
		 * btnPopInputText.setLayoutParams(new
		 * LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT));
		 * lLinearLayout.addView(btnPopInputText, 0);
		 */

		btnPopInputUrl = new Button(this);
		btnPopInputUrl.setText("播放url");
		btnPopInputUrl.setLayoutParams(new LayoutParams(
				LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT));
		lLinearLayout.addView(btnPopInputUrl);

		btnPopInputRelayUrl = new Button(this);
		btnPopInputRelayUrl.setText("转发url");
		btnPopInputRelayUrl.setLayoutParams(new LayoutParams(
				LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT));
		lLinearLayout.addView(btnPopInputRelayUrl);

		/* mute button */
		btnMute = new Button(this);

		if (!isMute) {
			btnMute.setText("静音 ");
		} else {
			btnMute.setText("取消静音 ");
		}

		btnMute.setLayoutParams(new LayoutParams(LayoutParams.WRAP_CONTENT,
				LayoutParams.WRAP_CONTENT));
		lLinearLayout.addView(btnMute);

		/* switch url button */
		btnSwitchUrl = new Button(this);

		if (!switchUrlFlag) {
			btnSwitchUrl.setText("切换url1");
		} else {
			btnSwitchUrl.setText("切换url2");
		}

		btnSwitchUrl.setLayoutParams(new LayoutParams(
				LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT));
		lLinearLayout.addView(btnSwitchUrl);

		/* hardware decoder button */
		btnHardwareDecoder = new Button(this);

		if (!isHardwareDecoder) {
			btnHardwareDecoder.setText("当前软解码");
		} else {
			btnHardwareDecoder.setText("当前硬解码");
		}

		LinearLayout LinearLayoutImage = new LinearLayout(this);
		LinearLayoutImage.setOrientation(LinearLayout.HORIZONTAL);
		LinearLayoutImage.setLayoutParams(new LayoutParams(
				LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT));

		/* capture image button */
		btnCaptureImage = new Button(this);

		btnCaptureImage.setText("快照");
		btnCaptureImage.setLayoutParams(new LayoutParams(
				LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT));
		LinearLayoutImage.addView(btnCaptureImage);

		btnRotation = new Button(this);

		if (0 == rotate_degrees) {
			btnRotation.setText("旋转90度");
		} else if (90 == rotate_degrees) {
			btnRotation.setText("旋转180度");
		} else if (180 == rotate_degrees) {
			btnRotation.setText("旋转270度");
		} else if (270 == rotate_degrees) {
			btnRotation.setText("不旋转");
		}

		btnRotation.setLayoutParams(new LayoutParams(LayoutParams.WRAP_CONTENT,
				LayoutParams.WRAP_CONTENT));
		LinearLayoutImage.addView(btnRotation);

		lLinearLayout.addView(LinearLayoutImage);

		btnHardwareDecoder.setLayoutParams(new LayoutParams(
				LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT));
		lLinearLayout.addView(btnHardwareDecoder);

		// buffer setting++

		LinearLayout bufferLinearLayout = new LinearLayout(this);
		bufferLinearLayout.setOrientation(LinearLayout.HORIZONTAL);
		bufferLinearLayout.setLayoutParams(new LayoutParams(
				LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT));

		btnSetPlayBuffer = new Button(this);
		btnSetPlayBuffer.setText("设置缓冲");
		btnSetPlayBuffer.setLayoutParams(new LayoutParams(
				LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT));
		bufferLinearLayout.addView(btnSetPlayBuffer);

		btnLowLatency = new Button(this);

		if (isLowLatency) {
			btnLowLatency.setText("正常延时");
		} else {
			btnLowLatency.setText("超低延时");
		}

		btnLowLatency.setLayoutParams(new LayoutParams(
				LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT));
		bufferLinearLayout.addView(btnLowLatency);

		btnFastStartup = new Button(this);

		if (isFastStartup) {
			btnFastStartup.setText("停用秒开");
		} else {
			btnFastStartup.setText("启用秒开");
		}

		btnFastStartup.setLayoutParams(new LayoutParams(
				LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT));
		bufferLinearLayout.addView(btnFastStartup);

		lLinearLayout.addView(bufferLinearLayout);

		// buffer setting--

		/* Start playback stream button */
		btnStartStopPlayback = new Button(this);
		btnStartStopPlayback.setText("开始播放 ");
		btnStartStopPlayback.setLayoutParams(new LayoutParams(
				LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT));
		lLinearLayout.addView(btnStartStopPlayback);

		/* Start/stop recorder stream button */
		LinearLayout recorderLinearLayout = new LinearLayout(this);
		btnStartStopRecorder = new Button(this);
		btnStartStopRecorder.setText("开始录像 ");
		btnStartStopRecorder.setLayoutParams(new LayoutParams(
				LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT));
		recorderLinearLayout.addView(btnStartStopRecorder);

		btnRecoderMgr = new Button(this);
		btnRecoderMgr.setText("录像管理 ");
		btnRecoderMgr.setLayoutParams(new LayoutParams(
				LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT));
		recorderLinearLayout.addView(btnRecoderMgr);

		lLinearLayout.addView(recorderLinearLayout);

		/* Start/stop pull stream button */
		LinearLayout pullStreamLinearLayout = new LinearLayout(this);
		btnStartStopPullStream = new Button(this);
		btnStartStopPullStream.setText("开始转发 ");
		btnStartStopPullStream.setLayoutParams(new LayoutParams(
				LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT));
		pullStreamLinearLayout.addView(btnStartStopPullStream);
		lLinearLayout.addView(pullStreamLinearLayout);

		btnRecoderMgr.setOnClickListener(new ButtonRecorderMangerListener());

		outLinearLayout.addView(lLinearLayout, 0);
		outLinearLayout.addView(copyRightLinearLayout, 1);
		fFrameLayout.addView(outLinearLayout, 1);

		lLayout.addView(fFrameLayout, 0);

		if (isPlaying || isRecording || isPulling) {
			btnPopInputUrl.setEnabled(false);
			btnHardwareDecoder.setEnabled(false);

			btnSetPlayBuffer.setEnabled(false);
			btnLowLatency.setEnabled(false);
			btnFastStartup.setEnabled(false);
			btnRecoderMgr.setEnabled(false);
		} else {
			btnPopInputUrl.setEnabled(true);
			btnHardwareDecoder.setEnabled(true);

			btnSetPlayBuffer.setEnabled(true);
			btnLowLatency.setEnabled(true);
			btnFastStartup.setEnabled(true);
			btnRecoderMgr.setEnabled(true);
		}

		if (isPlaying) {
			btnStartStopPlayback.setText("停止播放 ");
		} else {
			btnStartStopPlayback.setText("开始播放 ");
		}

		if (isRecording) {
			btnStartStopRecorder.setText("停止录像");
		} else {
			btnStartStopRecorder.setText("开始录像");
		}

		if(isPulling) {
			btnStartStopPullStream.setText("停止转发");
		} else {
			btnStartStopPullStream.setText("开始转发");
		}

		/* PopInput button listener */
		btnPopInputUrl.setOnClickListener(new Button.OnClickListener() {
			public void onClick(View v) {
				PopFullUrlDialog();
			}
		});

		/* Pop relay stream url button listener */
		btnPopInputRelayUrl.setOnClickListener(new Button.OnClickListener() {
			public void onClick(View v) {
				PopRelaylUrlDialog();
			}
		});

		btnMute.setOnClickListener(new Button.OnClickListener() {
			public void onClick(View v) {
				isMute = !isMute;

				if (isMute) {
					btnMute.setText("取消静音");
				} else {
					btnMute.setText("静音");
				}

				if (playerHandle != 0) {
					libPlayer.SmartPlayerSetMute(playerHandle, isMute ? 1 : 0);
				}
			}
		});

		btnSwitchUrl.setOnClickListener(new Button.OnClickListener() {
			public void onClick(View v) {
				switchUrlFlag = !switchUrlFlag;

				if (switchUrlFlag) {
					btnSwitchUrl.setText("切换url2");

					switchURL = "rtmp://live.hkstv.hk.lxdns.com/live/hks1"; //
					// 实际以可切换url为准
					//switchURL = "rtmp://player.daniulive.com:1935/hls/stream2";
				} else {
					btnSwitchUrl.setText("切换url1");

					switchURL = playbackUrl;
				}

				if (playerHandle != 0) {
					libPlayer.SmartPlayerSwitchPlaybackUrl(playerHandle,
							switchURL);
				}
			}
		});

		btnHardwareDecoder.setOnClickListener(new Button.OnClickListener() {
			public void onClick(View v) {
				isHardwareDecoder = !isHardwareDecoder;

				if (isHardwareDecoder) {
					btnHardwareDecoder.setText("当前硬解码");
				} else {
					btnHardwareDecoder.setText("当前软解码");
				}

			}
		});

		btnCaptureImage.setOnClickListener(new Button.OnClickListener() {
			@SuppressLint("SimpleDateFormat")
			public void onClick(View v) {

				String timeStamp = new SimpleDateFormat("yyyyMMdd_HHmmss")
						.format(new Date());
				String imageFileName = "dn_" + timeStamp; // 创建以时间命名的文件名称

				String imagePath = imageSavePath + "/" + imageFileName + ".png";

				Log.i(TAG, "imagePath:" + imagePath);

				libPlayer.SmartPlayerSaveCurImage(playerHandle, imagePath);
			}
		});

		btnRotation.setOnClickListener(new Button.OnClickListener() {
			public void onClick(View v) {

				rotate_degrees += 90;
				rotate_degrees = rotate_degrees % 360;

				if (0 == rotate_degrees) {
					btnRotation.setText("旋转90度");
				} else if (90 == rotate_degrees) {
					btnRotation.setText("旋转180度");
				} else if (180 == rotate_degrees) {
					btnRotation.setText("旋转270度");
				} else if (270 == rotate_degrees) {
					btnRotation.setText("不旋转");
				}

				if (playerHandle != 0) {
					libPlayer.SmartPlayerSetRotation(playerHandle,
							rotate_degrees);
				}
			}
		});

		btnSetPlayBuffer.setOnClickListener(new Button.OnClickListener() {
			public void onClick(View v) {
				PopSettingBufferDialog();
			}
		});

		btnLowLatency.setOnClickListener(new Button.OnClickListener() {
			public void onClick(View v) {
				isLowLatency = !isLowLatency;

				if (isLowLatency) {
					playBuffer = 0;
					Log.i(TAG, "low latency mode, set playBuffer to 0");
					btnLowLatency.setText("正常延时");
				} else {
					btnLowLatency.setText("超低延时");
				}
			}
		});

		btnFastStartup.setOnClickListener(new Button.OnClickListener() {
			public void onClick(View v) {
				isFastStartup = !isFastStartup;

				if (isFastStartup) {
					btnFastStartup.setText("停用秒开");
				} else {
					btnFastStartup.setText("启用秒开");
				}
			}
		});

		btnStartStopPullStream.setOnClickListener(new Button.OnClickListener() {

			// @Override
			public void onClick(View v) {

				if (isPulling) {

					int iRet = libPlayer.SmartPlayerStopPullStream(playerHandle);

					if (iRet != 0) {
						Log.e(TAG, "SmartPlayerStopPullStream failed..");
						return;
					}

					if (!isPlaying && !isRecording) {
						btnPopInputUrl.setEnabled(true);
						btnSetPlayBuffer.setEnabled(true);
						btnFastStartup.setEnabled(true);
						btnRecoderMgr.setEnabled(true);

						libPlayer.SmartPlayerClose(playerHandle);
						playerHandle = 0;
					}

					StopPublisher();
					UnInitPublisher();

					btnStartStopPullStream.setText(" 开始转发");

					isPulling = false;

					return;
				} else {
					Log.i(TAG, "onClick start pull stream..");

					if (!isPlaying && !isRecording) {
						InitAndSetConfig();
					}

					boolean is_init_suc = InitPublisher();
					if(!is_init_suc) {
						Log.e(TAG, "InitPublisher failed!");
						return;
					}

					boolean is_start_suc = StartPublisher();
					if(!is_start_suc) {
						Log.e(TAG, "StartPublisher failed!");
						return;
					}

					libPlayer.SmartPlayerSetAudioDataCallback(playerHandle, new PlayerAudioDataCallback());
					libPlayer.SmartPlayerSetVideoDataCallback(playerHandle, new PlayerVideoDataCallback());

					int is_pull_trans_code  = 1;
					libPlayer.SmartPlayerSetPullStreamAudioTranscodeAAC(playerHandle, is_pull_trans_code);

					int startRet = libPlayer.SmartPlayerStartPullStream(playerHandle);

					if (startRet != 0) {
						Log.e(TAG, "Failed to start pull stream.");
						return;
					}

					btnPopInputUrl.setEnabled(false);
					btnSetPlayBuffer.setEnabled(false);
					btnFastStartup.setEnabled(false);
					btnRecoderMgr.setEnabled(false);

					isPulling = true;
					btnStartStopPullStream.setText("停止转发");
				}
			}
		});

		btnStartStopRecorder.setOnClickListener(new Button.OnClickListener() {

			// @Override
			public void onClick(View v) {

				if (isRecording) {
					
					int iRet = libPlayer.SmartPlayerStopRecorder(playerHandle);

					if (iRet != 0) {
						Log.e(TAG, "SmartPlayerStopRecorder stream failed..");
						return;
					}
					
					if (!isPlaying && !isPulling) {
						btnPopInputUrl.setEnabled(true);
						btnSetPlayBuffer.setEnabled(true);
						btnFastStartup.setEnabled(true);		
						btnRecoderMgr.setEnabled(true);
						
						libPlayer.SmartPlayerClose(playerHandle);
						playerHandle = 0;
					}

					btnStartStopRecorder.setText(" 开始录像");

					isRecording = false;

					return;
				} else {
					Log.i(TAG, "onClick start recorder..");

					if (!isPlaying && !isPulling) {
						InitAndSetConfig();
					}

					ConfigRecorderFuntion();

					int startRet = libPlayer.SmartPlayerStartRecorder(playerHandle);

					if (startRet != 0) {
						Log.e(TAG, "Failed to start recorder.");
						return;
					}

					btnPopInputUrl.setEnabled(false);
					btnSetPlayBuffer.setEnabled(false);
					btnFastStartup.setEnabled(false);
					btnRecoderMgr.setEnabled(false);

					isRecording = true;
					btnStartStopRecorder.setText("停止录像");
				}
			}
		});

		btnStartStopPlayback.setOnClickListener(new Button.OnClickListener() {

			// @Override
			public void onClick(View v) {

				if (isPlaying) {
					Log.i(TAG, "Stop playback stream++");

					int iRet = libPlayer.SmartPlayerStopPlay(playerHandle);

					if (iRet != 0) {
						Log.e(TAG, "SmartPlayerStopPlay strem failed..");
						return;
					}
					
					btnHardwareDecoder.setEnabled(true);
					btnLowLatency.setEnabled(true);

					if (!isRecording && !isPulling) {
						btnPopInputUrl.setEnabled(true);
						btnSetPlayBuffer.setEnabled(true);
						btnFastStartup.setEnabled(true);
						
						btnRecoderMgr.setEnabled(true);
						libPlayer.SmartPlayerClose(playerHandle);
						playerHandle = 0;
					}
					
					isPlaying = false;
					btnStartStopPlayback.setText("开始播放 ");
					Log.i(TAG, "Stop playback stream--");
				} else {
					Log.i(TAG, "Start playback stream++");

					if (!isRecording && !isPulling) {
						InitAndSetConfig();
					}
					
					// 如果第二个参数设置为null，则播放纯音频
					libPlayer.SmartPlayerSetSurface(playerHandle, sSurfaceView);
					// External Render test
					// libPlayer.SmartPlayerSetExternalRender(playerHandle, new
					// RGBAExternalRender());
					// libPlayer.SmartPlayerSetExternalRender(playerHandle, new
					// I420ExternalRender());

					libPlayer.SmartPlayerSetAudioOutputType(playerHandle, 0);

					if (isMute) {
						libPlayer.SmartPlayerSetMute(playerHandle, isMute ? 1
								: 0);
					}

					if (isHardwareDecoder) {
						Log.i(TAG, "check isHardwareDecoder: "
								+ isHardwareDecoder);

						int hwChecking = libPlayer
								.SetSmartPlayerVideoHWDecoder(playerHandle,
										isHardwareDecoder ? 1 : 0);

						Log.i(TAG, "[daniulive] hwChecking: " + hwChecking);
					}

					libPlayer.SmartPlayerSetLowLatencyMode(playerHandle, isLowLatency ? 1
							: 0);

					libPlayer.SmartPlayerSetRotation(playerHandle, rotate_degrees);
					
					int iPlaybackRet = libPlayer
							.SmartPlayerStartPlay(playerHandle);

					if (iPlaybackRet != 0) {
						Log.e(TAG, "StartPlayback strem failed..");
						return;
					}

					btnStartStopPlayback.setText("停止播放 ");

					btnPopInputUrl.setEnabled(false);
					btnHardwareDecoder.setEnabled(false);
					btnSetPlayBuffer.setEnabled(false);
					btnLowLatency.setEnabled(false);
					btnFastStartup.setEnabled(false);
					btnRecoderMgr.setEnabled(false);

					isPlaying = true;
					Log.i(TAG, "Start playback stream--");
				}
			}
		});
	}

	public static final String bytesToHexString(byte[] buffer) {
		StringBuffer sb = new StringBuffer(buffer.length);
		String temp;

		for (int i = 0; i < buffer.length; ++i) {
			temp = Integer.toHexString(0xff & buffer[i]);
			if (temp.length() < 2)
				sb.append(0);

			sb.append(temp);
		}

		return sb.toString();
	}

	class RGBAExternalRender implements NTExternalRender {
		// public static final int NT_FRAME_FORMAT_RGBA = 1;
		// public static final int NT_FRAME_FORMAT_ABGR = 2;
		// public static final int NT_FRAME_FORMAT_I420 = 3;

		private int width_ = 0;
		private int height_ = 0;
		private int row_bytes_ = 0;
		private ByteBuffer rgba_buffer_ = null;

		@Override
		public int getNTFrameFormat() {
			Log.i(TAG, "RGBAExternalRender::getNTFrameFormat return "
					+ NT_FRAME_FORMAT_RGBA);
			return NT_FRAME_FORMAT_RGBA;
		}

		@Override
		public void onNTFrameSizeChanged(int width, int height) {
			width_ = width;
			height_ = height;

			row_bytes_ = width_ * 4;

			Log.i(TAG, "RGBAExternalRender::onNTFrameSizeChanged width_:"
					+ width_ + " height_:" + height_);

			rgba_buffer_ = ByteBuffer.allocateDirect(row_bytes_ * height_);
		}

		@Override
		public ByteBuffer getNTPlaneByteBuffer(int index) {
			if (index == 0) {
				return rgba_buffer_;
			} else {
				Log.e(TAG,
						"RGBAExternalRender::getNTPlaneByteBuffer index error:"
								+ index);
				return null;
			}
		}

		@Override
		public int getNTPlanePerRowBytes(int index) {
			if (index == 0) {
				return row_bytes_;
			} else {
				Log.e(TAG,
						"RGBAExternalRender::getNTPlanePerRowBytes index error:"
								+ index);
				return 0;
			}
		}

		public void onNTRenderFrame(int width, int height, long timestamp) {
			if (rgba_buffer_ == null)
				return;

			rgba_buffer_.rewind();

			// copy buffer

			// test
			// byte[] test_buffer = new byte[16];
			// rgba_buffer_.get(test_buffer);

			Log.i(TAG, "RGBAExternalRender:onNTRenderFrame w=" + width + " h="
					+ height + " timestamp=" + timestamp);

			// Log.i(TAG, "RGBAExternalRender:onNTRenderFrame rgba:" +
			// bytesToHexString(test_buffer));
		}
	}

	class I420ExternalRender implements NTExternalRender {
		// public static final int NT_FRAME_FORMAT_RGBA = 1;
		// public static final int NT_FRAME_FORMAT_ABGR = 2;
		// public static final int NT_FRAME_FORMAT_I420 = 3;

		private int width_ = 0;
		private int height_ = 0;

		private int y_row_bytes_ = 0;
		private int u_row_bytes_ = 0;
		private int v_row_bytes_ = 0;

		private ByteBuffer y_buffer_ = null;
		private ByteBuffer u_buffer_ = null;
		private ByteBuffer v_buffer_ = null;

		@Override
		public int getNTFrameFormat() {
			Log.i(TAG, "I420ExternalRender::getNTFrameFormat return "
					+ NT_FRAME_FORMAT_I420);
			return NT_FRAME_FORMAT_I420;
		}

		@Override
		public void onNTFrameSizeChanged(int width, int height) {
			width_ = width;
			height_ = height;

			y_row_bytes_ = (width_ + 15) & (~15);
			u_row_bytes_ = ((width_ + 1) / 2 + 15) & (~15);
			v_row_bytes_ = ((width_ + 1) / 2 + 15) & (~15);

			y_buffer_ = ByteBuffer.allocateDirect(y_row_bytes_ * height_);
			u_buffer_ = ByteBuffer.allocateDirect(u_row_bytes_
					* ((height_ + 1) / 2));
			v_buffer_ = ByteBuffer.allocateDirect(v_row_bytes_
					* ((height_ + 1) / 2));

			Log.i(TAG, "I420ExternalRender::onNTFrameSizeChanged width_="
					+ width_ + " height_=" + height_ + " y_row_bytes_="
					+ y_row_bytes_ + " u_row_bytes_=" + u_row_bytes_
					+ " v_row_bytes_=" + v_row_bytes_);
		}

		@Override
		public ByteBuffer getNTPlaneByteBuffer(int index) {
			if (index == 0) {
				return y_buffer_;
			} else if (index == 1) {
				return u_buffer_;
			} else if (index == 2) {
				return v_buffer_;
			} else {
				Log.e(TAG, "I420ExternalRender::getNTPlaneByteBuffer index error:" + index);
				return null;
			}
		}

		@Override
		public int getNTPlanePerRowBytes(int index) {
			if (index == 0) {
				return y_row_bytes_;
			} else if (index == 1) {
				return u_row_bytes_;
			} else if (index == 2) {
				return v_row_bytes_;
			} else {
				Log.e(TAG, "I420ExternalRender::getNTPlanePerRowBytes index error:" + index);
				return 0;
			}
		}

    	public void onNTRenderFrame(int width, int height, long timestamp)
    	{
    		if ( y_buffer_ == null )
    			return;
    		
    		if ( u_buffer_ == null )
    			return;
    		
    		if ( v_buffer_ == null )
    			return;
    		
      
    		y_buffer_.rewind();
    		
    		u_buffer_.rewind();
    		
    		v_buffer_.rewind();
    		
    		/*
    		if ( !is_saved_image )
    		{
    			is_saved_image = true;
    			
    			int y_len = y_row_bytes_*height_;
    			
    			int u_len = u_row_bytes_*((height_+1)/2);
    			int v_len = v_row_bytes_*((height_+1)/2);
    			
    			int data_len = y_len + (y_row_bytes_*((height_+1)/2));
    			
    			byte[] nv21_data = new byte[data_len];
    			
    			byte[] u_data = new byte[u_len];
    			byte[] v_data = new byte[v_len];
    			
    			y_buffer_.get(nv21_data, 0, y_len);
    			u_buffer_.get(u_data, 0, u_len);
    			v_buffer_.get(v_data, 0, v_len);
    			
    			int[] strides = new int[2];
    			strides[0] = y_row_bytes_;
    			strides[1] = y_row_bytes_;
    			

    			int loop_row_c = ((height_+1)/2);
    			int loop_c = ((width_+1)/2);
 
    			int dst_row = y_len;
    			int src_v_row = 0;
    			int src_u_row = 0;
    			
    			for ( int i = 0; i < loop_row_c; ++i)
    			{
    				int dst_pos = dst_row;
    				
    				for ( int j = 0; j <loop_c; ++j )
    				{
    					nv21_data[dst_pos++] = v_data[src_v_row + j];  					
    					nv21_data[dst_pos++] = u_data[src_u_row + j];
    				}
    				
    				dst_row   += y_row_bytes_;
    				src_v_row += v_row_bytes_;
    				src_u_row += u_row_bytes_;
    			}
    			
    			String imagePath = "/sdcard" + "/" + "testonv21" + ".jpeg";
    			
    			Log.e(TAG, "I420ExternalRender::begin test save iamge++ image_path:" + imagePath);
    			
    			try
    			{
    				File file = new File(imagePath);
        			
        			FileOutputStream image_os = new FileOutputStream(file);   
        			
        			YuvImage image = new YuvImage(nv21_data, ImageFormat.NV21, width_, height_, strides);  
        			
        			image.compressToJpeg(new android.graphics.Rect(0, 0, width_, height_), 50, image_os);  
        			
        			image_os.flush();  
        			image_os.close();
    			}
    			catch(IOException e)
    			{
    				e.printStackTrace();
    			}
    		
    			Log.e(TAG, "I420ExternalRender::begin test save iamge--");
    		}
    		
    		*/
    		
    		
    		 Log.i(TAG, "I420ExternalRender::onNTRenderFrame w=" + width + " h=" + height + " timestamp=" + timestamp);
    		
    		 // copy buffer
    		
    		// test
    		// byte[] test_buffer = new byte[16];
    		// y_buffer_.get(test_buffer);
    		 
    		// Log.i(TAG, "I420ExternalRender::onNTRenderFrame y data:" + bytesToHexString(test_buffer));
    		 
    		// u_buffer_.get(test_buffer);
    		// Log.i(TAG, "I420ExternalRender::onNTRenderFrame u data:" + bytesToHexString(test_buffer));
    		 
    		// v_buffer_.get(test_buffer);
    		// Log.i(TAG, "I420ExternalRender::onNTRenderFrame v data:" + bytesToHexString(test_buffer));
    	}
    }

	class EventHandePlayerV2 implements NTSmartEventCallbackV2 {
		@Override
		public void onNTSmartEventCallbackV2(long handle, int id, long param1,
				long param2, String param3, String param4, Object param5) {

			//Log.i(TAG, "EventHandePlayerV2: handle=" + handle + " id:" + id);

			switch (id) {
			case NTSmartEventID.EVENT_DANIULIVE_ERC_PLAYER_STARTED:
				Log.i(TAG, "[SmartPlayer]开始。。");
				break;
			case NTSmartEventID.EVENT_DANIULIVE_ERC_PLAYER_CONNECTING:
				Log.i(TAG, "[SmartPlayer]连接中。。");
				break;
			case NTSmartEventID.EVENT_DANIULIVE_ERC_PLAYER_CONNECTION_FAILED:
				Log.i(TAG, "[SmartPlayer]连接失败。。");
				break;
			case NTSmartEventID.EVENT_DANIULIVE_ERC_PLAYER_CONNECTED:
				Log.i(TAG, "[SmartPlayer]连接成功。。");
				break;
			case NTSmartEventID.EVENT_DANIULIVE_ERC_PLAYER_DISCONNECTED:
				Log.i(TAG, "[SmartPlayer]连接断开。。");
				break;
			case NTSmartEventID.EVENT_DANIULIVE_ERC_PLAYER_STOP:
				Log.i(TAG, "[SmartPlayer]停止播放。。");
				break;
			case NTSmartEventID.EVENT_DANIULIVE_ERC_PLAYER_RESOLUTION_INFO:
				Log.i(TAG, "[SmartPlayer]分辨率信息: width: " + param1 + ", height: " + param2);
				break;
			case NTSmartEventID.EVENT_DANIULIVE_ERC_PLAYER_NO_MEDIADATA_RECEIVED:
				Log.i(TAG, "[SmartPlayer]收不到媒体数据，可能是url错误。。");
				break;
			case NTSmartEventID.EVENT_DANIULIVE_ERC_PLAYER_SWITCH_URL:
				Log.i(TAG, "[SmartPlayer]切换播放URL。。");
				break;
			case NTSmartEventID.EVENT_DANIULIVE_ERC_PLAYER_CAPTURE_IMAGE:
				Log.i(TAG, "[SmartPlayer]快照: " + param1 + " 路径：" + param3);

				if (param1 == 0) {
					Log.i(TAG, "[SmartPlayer]截取快照成功。.");
				} else {
					Log.i(TAG, "[SmartPlayer]截取快照失败。.");
				}
				break;
				
			case NTSmartEventID.EVENT_DANIULIVE_ERC_PLAYER_RECORDER_START_NEW_FILE:
           	 	Log.i(TAG, "[SmartPlayer-record]开始一个新的录像文件 : " + param3);
                break;
            case NTSmartEventID.EVENT_DANIULIVE_ERC_PLAYER_ONE_RECORDER_FILE_FINISHED:
           	 Log.i(TAG, "[SmartPlayer-record]已生成一个录像文件 : " + param3);
                break;

			case NTSmartEventID.EVENT_DANIULIVE_ERC_PLAYER_START_BUFFERING:
				Log.i(TAG, "[SmartPlayer]Start_Buffering");
				break;

			case NTSmartEventID.EVENT_DANIULIVE_ERC_PLAYER_BUFFERING:
				Log.i(TAG, "[SmartPlayer]Buffering:" + param1 + "%");
				break;

			case NTSmartEventID.EVENT_DANIULIVE_ERC_PLAYER_STOP_BUFFERING:
				Log.i(TAG, "[SmartPlayer]Stop_Buffering");
				break;

			case NTSmartEventID.EVENT_DANIULIVE_ERC_PLAYER_DOWNLOAD_SPEED:
				Log.i(TAG, "[SmartPlayer]download_speed:" + param1 + "Byte/s" + ", "
						+ (param1 * 8 / 1000) + "kbps" + ", " + (param1 / 1024)
						+ "KB/s");
				break;

			case NTSmartEventID.EVENT_DANIULIVE_ERC_PLAYER_RTSP_STATUS_CODE:
				Log.e(TAG, "RTSP error code received, please make sure username/password is correct, error code:" + param1);
				break;
			}
		}
	}

	class EventHandePublisherV2 implements NTSmartEventCallbackV2
	{
		@Override
		public void onNTSmartEventCallbackV2(long handle, int id, long param1, long param2, String param3, String param4, Object param5){

			Log.i(TAG, "[SmartPublisher]EventHandePublisherV2: handle=" + handle + " id:" + id);

			switch (id) {
				case NTSmartEventID.EVENT_DANIULIVE_ERC_PUBLISHER_STARTED:
					txt = "[SmartPublisher]开始。。";
					break;
				case NTSmartEventID.EVENT_DANIULIVE_ERC_PUBLISHER_CONNECTING:
					txt = "[SmartPublisher]连接中。。";
					break;
				case NTSmartEventID.EVENT_DANIULIVE_ERC_PUBLISHER_CONNECTION_FAILED:
					txt = "[SmartPublisher]连接失败。。";
					break;
				case NTSmartEventID.EVENT_DANIULIVE_ERC_PUBLISHER_CONNECTED:
					txt = "[SmartPublisher]连接成功。。";
					break;
				case NTSmartEventID.EVENT_DANIULIVE_ERC_PUBLISHER_DISCONNECTED:
					txt = "[SmartPublisher]连接断开。。";
					break;
				case NTSmartEventID.EVENT_DANIULIVE_ERC_PUBLISHER_STOP:
					txt =  "[SmartPublisher]关闭。。";
					break;
				case NTSmartEventID.EVENT_DANIULIVE_ERC_PUBLISHER_RECORDER_START_NEW_FILE:
					Log.i(TAG, "[SmartPublisher]开始一个新的录像文件 : " + param3);
					txt = "[SmartPublisher]开始一个新的录像文件。。";
					break;
				case NTSmartEventID.EVENT_DANIULIVE_ERC_PUBLISHER_ONE_RECORDER_FILE_FINISHED:
					Log.i(TAG, "[SmartPublisher]已生成一个录像文件 : " + param3);
					txt = "[SmartPublisher]已生成一个录像文件。。";
					break;

				case NTSmartEventID.EVENT_DANIULIVE_ERC_PUBLISHER_SEND_DELAY:
					Log.i(TAG, "[SmartPublisher]发送时延: " + param1 + " 帧数:" + param2);
					txt = "[SmartPublisher]收到发送时延..";
					break;

				case NTSmartEventID.EVENT_DANIULIVE_ERC_PUBLISHER_CAPTURE_IMAGE:
					Log.i(TAG, "[SmartPublisher]快照: " + param1 + " 路径：" + param3);

					if(param1 == 0)
					{
						txt = "[SmartPublisher]截取快照成功。.";
					}
					else
					{
						txt = "[SmartPublisher]截取快照失败。.";
					}
					break;
			}

			String str = "当前回调状态：" + txt;

			Log.i(TAG, str);

		}
	}

	/* Create rendering */
	private boolean CreateView() {

		if (sSurfaceView == null) {
			/*
			 * useOpenGLES2: If with true: Check if system supports openGLES, if
			 * supported, it will choose openGLES. If with false: it will set
			 * with default surfaceView;
			 */
			sSurfaceView = NTRenderer.CreateRenderer(this, false);

		}

		if (sSurfaceView == null) {
			Log.i(TAG, "Create render failed..");
			return false;
		}

		return true;
	}

	@Override
	public void onConfigurationChanged(Configuration newConfig) {
		super.onConfigurationChanged(newConfig);

		Log.i(TAG, "Run into onConfigurationChanged++");

		if (null != fFrameLayout) {
			fFrameLayout.removeAllViews();
			fFrameLayout = null;
		}

		if (null != lLayout) {
			lLayout.removeAllViews();
			lLayout = null;
		}

		if (newConfig.orientation == Configuration.ORIENTATION_LANDSCAPE) {
			Log.i(TAG, "onConfigurationChanged, with LANDSCAPE。。");

			inflateLayout(LinearLayout.HORIZONTAL);

			currentOrigentation = LANDSCAPE;
		} else {
			Log.i(TAG, "onConfigurationChanged, with PORTRAIT。。");

			inflateLayout(LinearLayout.VERTICAL);

			currentOrigentation = PORTRAIT;
		}

		if (!isPlaying)
			return;

		libPlayer.SmartPlayerSetOrientation(playerHandle, currentOrigentation);

		Log.i(TAG, "Run out of onConfigurationChanged--");
	}

    @Override
    protected void onResume() {
    	Log.i(TAG, "Run into activity onResume++");
    	
    	if(isPlaying && playerHandle != 0)
    	{
    		libPlayer.SmartPlayerSetOrientation(playerHandle, currentOrigentation);
    	}
    	
        super.onResume();
    }

	@Override
	protected void onDestroy() {
		Log.i(TAG, "Run into activity destory++");

		if (playerHandle != 0) {
			if (isPlaying) {
				libPlayer.SmartPlayerStopPlay(playerHandle);
			}

			if (isRecording) {
				libPlayer.SmartPlayerStopRecorder(playerHandle);
			}

			libPlayer.SmartPlayerClose(playerHandle);
			playerHandle = 0;
		}
		super.onDestroy();
		finish();
		System.exit(0);
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
		// 判断sd卡正常挂载并且拥有权限的时候创建文件
		if (Environment.MEDIA_MOUNTED.equals(Environment
				.getExternalStorageState())
				&& hasExternalStoragePermission(context)) {
			appCacheDir = new File(Environment.getExternalStorageDirectory(),
					cacheDir);
			Log.i(TAG, "appCacheDir: " + appCacheDir);
		}
		if (appCacheDir == null || !appCacheDir.exists()
				&& !appCacheDir.mkdirs()) {
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
		int perm = context
				.checkCallingOrSelfPermission("android.permission.WRITE_EXTERNAL_STORAGE");
		return perm == 0;
	}

	// Configure recorder related function.
	@SuppressLint("NewApi")
	void ConfigRecorderFuntion() {
		if (libPlayer != null) {
			int is_rec_trans_code  = 1;
			libPlayer.SmartPlayerSetRecorderAudioTranscodeAAC(playerHandle, is_rec_trans_code);

			if (recDir != null && !recDir.isEmpty()) {
				int ret = libPlayer.SmartPlayerCreateFileDirectory(recDir);
				if (0 == ret) {
					if (0 != libPlayer.SmartPlayerSetRecorderDirectory(
							playerHandle, recDir)) {
						Log.e(TAG, "Set recoder dir failed , path:" + recDir);
						return;
					}

					if (0 != libPlayer.SmartPlayerSetRecorderFileMaxSize(
							playerHandle, 200)) {
						Log.e(TAG,
								"SmartPublisherSetRecoderFileMaxSize failed.");
						return;
					}

				} else {
					Log.e(TAG, "Create recoder dir failed, path:" + recDir);
				}
			}
		}
	}

	class ButtonRecorderMangerListener implements OnClickListener {
		public void onClick(View v) {
			if (isPlaying || isRecording) {
				return;
			}

			Intent intent = new Intent();
			intent.setClass(SmartPlayer.this, RecorderManager.class);
			intent.putExtra("RecoderDir", recDir);
			startActivity(intent);
		}
	}

	private void InitAndSetConfig() {
		playerHandle = libPlayer.SmartPlayerOpen(myContext);

		if (playerHandle == 0) {
			Log.e(TAG, "surfaceHandle with nil..");
			return;
		}

		libPlayer.SetSmartPlayerEventCallbackV2(playerHandle,
				new EventHandePlayerV2());

		libPlayer.SmartPlayerSetBuffer(playerHandle, playBuffer);

		// set report download speed
		// libPlayer.SmartPlayerSetReportDownloadSpeed(playerHandle, 1, 5);

		libPlayer.SmartPlayerSetFastStartup(playerHandle, isFastStartup ? 1 : 0);

		//设置RTSP超时时间
		int rtsp_timeout = 12;
		libPlayer.SmartPlayerSetRTSPTimeout(playerHandle, rtsp_timeout);

		//设置RTSP TCP/UDP模式自动切换
		int is_auto_switch_tcp_udp = 1;
		libPlayer.SmartPlayerSetRTSPAutoSwitchTcpUdp(playerHandle, is_auto_switch_tcp_udp);

		libPlayer.SmartPlayerSaveImageFlag(playerHandle, 1);

		// It only used when playback RTSP stream..
		//libPlayer.SmartPlayerSetRTSPTcpMode(playerHandle, 1);

		//playbackUrl = "rtmp://live.hkstv.hk.lxdns.com/live/hks";

		//playbackUrl = "rtmp://player.daniulive.com:1935/hls/stream11";

		 //playbackUrl =
		 //"rtsp://184.72.239.149/vod/mp4://BigBuckBunny_175k.mov";		//这个url请打开rtsp-tcp模式(SmartPlayerSetRTSPTcpMode)

		// playbackUrl =
		// "rtsp://rtsp-v3-spbtv.msk.spbtv.com/spbtv_v3_1/214_110.sdp";

		if (playbackUrl == null) {
			Log.e(TAG, "playback URL with NULL...");
			return;
		}

		libPlayer.SmartPlayerSetUrl(playerHandle, playbackUrl);
	}

	private boolean InitPublisher()
	{
		int audio_opt = 2;
		int video_opt = 2;

		int videoWidth = 640;
		int videoHeight  = 480;

		publisherHandle = libPublisher.SmartPublisherOpen(myContext, audio_opt, video_opt,
				videoWidth, videoHeight);

		if (publisherHandle == 0 )
		{
			Log.e(TAG, "sdk open failed!");
			return false;
		}

		Log.i(TAG, "publisherHandle=" + publisherHandle);

		libPublisher.SetSmartPublisherEventCallbackV2(publisherHandle, new EventHandePublisherV2());

		return true;
	}

	private boolean StartPublisher()
	{
		if(relayStreamUrl == null)
		{
			relayStreamUrl = "rtmp://player.daniulive.com:1935/hls/stream123";	//方便测试，给个默认url，开发者可以根据自己逻辑实现
		}

		if ( libPublisher.SmartPublisherSetURL(publisherHandle, relayStreamUrl) != 0 )
		{
			Log.e(TAG, "Failed to set publish stream URL..");
		}

		int startRet = libPublisher.SmartPublisherStartPublisher(publisherHandle);
		if( startRet != 0)
		{
			Log.e(TAG, "Failed to start push stream..");
			return false;
		}

		return true;
	}

	private boolean StopPublisher()
	{
		Log.i(TAG, "StopPublisher++");

		if ( libPublisher != null )
		{
			libPublisher.SmartPublisherStopPublisher(publisherHandle);
		}

		Log.i(TAG, "StopPublisher--");
		return true;
	}

	private boolean UnInitPublisher()
	{
		Log.i(TAG, "UnInitPublisher++");

		if ( publisherHandle != 0 )
		{
			if ( libPublisher != null )
			{
				libPublisher.SmartPublisherClose(publisherHandle);
				publisherHandle = 0;
			}
		}

		Log.i(TAG, "UnInitPublisher--");
		return true;
	}

	class PlayerAudioDataCallback implements NTAudioDataCallback
	{
		private int audio_buffer_size = 0;
		private int param_info_size = 0;

		private ByteBuffer audio_buffer_ = null;
		private ByteBuffer parameter_info_ = null;

		@Override
		public ByteBuffer getAudioByteBuffer(int size)
		{
			//Log.i("getAudioByteBuffer", "size: " + size);

			if( size < 1 )
			{
				return null;
			}

			if ( size <= audio_buffer_size && audio_buffer_ != null )
			{
				return audio_buffer_;
			}

			audio_buffer_size = size + 512;
			audio_buffer_size = (audio_buffer_size+0xf) & (~0xf);

			audio_buffer_ = ByteBuffer.allocateDirect(audio_buffer_size);

			// Log.i("getAudioByteBuffer", "size: " + size + " buffer_size:" + audio_buffer_size);

			return audio_buffer_;
		}

		@Override
		public ByteBuffer getAudioParameterInfo(int size)
		{
			//Log.i("getAudioParameterInfo", "size: " + size);

			if(size < 1)
			{
				return null;
			}

			if ( size <= param_info_size &&  parameter_info_ != null )
			{
				return  parameter_info_;
			}

			param_info_size = size + 32;
			param_info_size = (param_info_size+0xf) & (~0xf);

			parameter_info_ = ByteBuffer.allocateDirect(param_info_size);

			//Log.i("getAudioParameterInfo", "size: " + size + " buffer_size:" + param_info_size);

			return parameter_info_;
		}

		public void onAudioDataCallback(int ret, int audio_codec_id, int sample_size, int is_key_frame, long timestamp, int sample_rate, int channel, int parameter_info_size, long reserve)
		{
			//Log.i("onAudioDataCallback", "ret: " + ret + ", audio_codec_id: " + audio_codec_id + ", sample_size: " + sample_size + ", timestamp: " + timestamp +
			//		",sample_rate:" + sample_rate);

			if ( audio_buffer_ == null)
				return;

			audio_buffer_.rewind();

			if ( ret == 0 && isPulling ) {
				libPublisher.SmartPublisherPostAudioEncodedData(publisherHandle, audio_codec_id, audio_buffer_, sample_size, is_key_frame, timestamp, parameter_info_, parameter_info_size);
			}
			// test

    		/*
    		byte[] test_buffer = new byte[16];
    		pcm_buffer_.get(test_buffer);

    		Log.i(TAG, "onGetPcmFrame data:" + bytesToHexString(test_buffer));
    		*/
		}
	}

	class PlayerVideoDataCallback implements NTVideoDataCallback
	{
		private int video_buffer_size = 0;

		private ByteBuffer video_buffer_ = null;

		@Override
		public ByteBuffer getVideoByteBuffer(int size)
		{
			//Log.i("getVideoByteBuffer", "size: " + size);

			if( size < 1 )
			{
				return null;
			}

			if ( size <= video_buffer_size &&  video_buffer_ != null )
			{
				return  video_buffer_;
			}

			video_buffer_size = size + 1024;
			video_buffer_size = (video_buffer_size+0xf) & (~0xf);

			video_buffer_ = ByteBuffer.allocateDirect(video_buffer_size);

			// Log.i("getVideoByteBuffer", "size: " + size + " buffer_size:" + video_buffer_size);

			return video_buffer_;
		}

		public void onVideoDataCallback(int ret, int video_codec_id, int sample_size, int is_key_frame, long timestamp, int width, int height, long presentation_timestamp)
		{
			//Log.i("onVideoDataCallback", "ret: " + ret + ", video_codec_id: " + video_codec_id + ", sample_size: " + sample_size + ", is_key_frame: "+ is_key_frame +  ", timestamp: " + timestamp +
			//		",presentation_timestamp:" + presentation_timestamp);

			if ( video_buffer_ == null)
				return;

			video_buffer_.rewind();

			if ( ret == 0 && isPulling ) {

				libPublisher.SmartPublisherPostVideoEncodedData(publisherHandle, video_codec_id, video_buffer_, sample_size, is_key_frame, timestamp, presentation_timestamp);
			}
		}
	}
}