package org.daniulive.smartpublisher;


import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.VideoView;
import android.widget.TextView;
import android.util.Log;
import android.widget.MediaController;  
import android.content.res.Configuration;

public class RecoderPlaybak extends Activity {

	private final String Tag = "RecoderPlaybak";
	
	private String recoderFilePath = null;
	private TextView filePathTextView = null;
	private VideoView playVideoView = null;
	
	@Override
    public void onCreate(Bundle savedInstanceState) 
    {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_recoder_playback);
        
        Intent intent = getIntent();
        recoderFilePath = intent.getStringExtra("RecoderFilePath");
        
        
        filePathTextView = (TextView) findViewById(R.id.textViewRecoderPlaybackFilePath);
        if (recoderFilePath != null  )
        {
        	filePathTextView.setText(recoderFilePath);
        }
        else
        {
        	Log.i(Tag, "recoderFilePath is null");
        }
       
           
        playVideoView  = (VideoView) findViewById(R.id.VideoViewRecoderPlayback);
        
        if ( recoderFilePath != null && !recoderFilePath.isEmpty() )
        {
        	playVideoView.setVideoPath(recoderFilePath);
        	playVideoView.setMediaController(new MediaController(this));
        	playVideoView.requestFocus();  
        	playVideoView.start();
        	
        }
    }	
}
