/*
 * RecorderManager.java
 * RecorderManager
 *  
 * Github: https://github.com/daniulive/SmarterStreaming
 * 
 * Created by DaniuLive on 2015/09/20.
 * Copyright © 2014~2016 DaniuLive. All rights reserved.
 */

package com.daniulive.smartplayer;

import android.app.Activity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.content.Intent;
import android.widget.Button;

import java.io.File;

import android.widget.ListView;

import java.util.ArrayList;  

import android.widget.AdapterView;
import android.widget.SimpleAdapter;

import java.util.Map;  
import java.util.HashMap;

import  android.widget.AdapterView.OnItemClickListener;

public class RecorderManager extends Activity {

	private String recDirPath = null;
	
	private Button btnDelAllRecFiles;
	
	private ListView recFileListView = null;
	
	private ArrayList<ArrayList<String> > fileList = null;  

	private final String Tag = "RecMgr";
	
	@Override
    public void onCreate(Bundle savedInstanceState) 
    {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_recorder_manager);
        
        Intent intent = getIntent();
        recDirPath = intent.getStringExtra("RecoderDir");
        
        btnDelAllRecFiles = (Button)findViewById(R.id.button_delete_all_rec_files);
        btnDelAllRecFiles.setOnClickListener(new ButtonDelAllRecFilesListenser());
        
        recFileListView = (ListView) findViewById(R.id.rec_file_list);
        GetRecFileList();
        
        SimpleAdapter ladapter = new SimpleAdapter(this,getMapData(fileList),R.layout.rec_files_list_view_item,
        		new String[]{"ItemFileName"},new int[]{R.id.ItemFileName});  
        
        recFileListView.setAdapter(ladapter);  
        
        recFileListView.setOnItemClickListener(new OnItemClickListener()
        {  
        	   @SuppressWarnings("unchecked")  
        	   @Override
			public  void onItemClick(AdapterView<?> parent, View view,  int position, long id) 
        	   {  
        		   ListView listView = (ListView)parent;  
        		   HashMap<String, String> map = (HashMap<String, String>) listView.getItemAtPosition(position);  
        		   String fileName = map.get("ItemFileName");  
        		   PlayRecFile(fileName);
        	   }  
        });
             
    }
	
	private void PlayRecFile(String fileName)
	{
		if ( fileName == null || fileName.isEmpty() )
			return;
		
		if ( fileList == null )
			return;
		

		String filePath = null;
		
		for ( int i =0; i < fileList.size(); ++i )
		{
			ArrayList<String> item = fileList.get(i);
			if ( item.get(0) != null && item.get(0) == fileName )
			{
				filePath = item.get(1);
				break;
			}
		}
		
		if ( filePath != null && !filePath.isEmpty() )
		{
			Log.i(Tag, "PlayRecFile name:" + fileName + " path:" + filePath);
			
			 Intent intent = new Intent();
             intent.setClass(RecorderManager.this, RecorderPlayback.class);
             intent.putExtra("RecorderFilePath", filePath);
             startActivity(intent);
		}
	}
	
    private ArrayList<Map<String, Object>> getMapData(ArrayList<ArrayList<String> > list)
	 {  
	        ArrayList<Map<String, Object>> data = new ArrayList<Map<String, Object>>(); 
	       
	        if ( list  == null )
	        	return data;
	        
	        for(int i=0;i<list.size();i++)
	        {  
	        	Map<String, Object> item = new HashMap<String,Object>();  
	        	item.put("ItemFileName",list.get(i).get(0));  
	        	data.add(item);  
	        }
	        
	        return data;  
	 }  
	
	
	private void GetRecFileList()
	{
		if ( recDirPath == null )
		{
			Log.i(Tag, "recDirPath is null");
			return;
		}
			
		
		if ( recDirPath.isEmpty() )
		{
			Log.i(Tag, "recDirPath is empty");
			return;
		}
			
		
		File recDirFile = null;
		
		try
		{
			 recDirFile = new File(recDirPath);
		}
		catch(Exception e)
		{
			e.printStackTrace();
			return;
		}
		
		if ( !recDirFile.exists() )
		{
			Log.e("Tag", "rec dir is not exist, path:" + recDirPath);
			return;
		}
		
		if ( !recDirFile.isDirectory() )
		{
			Log.e(Tag, recDirPath + " is not dir");
			return;
		}
		
		
		 File[] files = recDirFile.listFiles();
		 if ( files == null )
		 {
			 return;
		 }
		
		 fileList = new ArrayList<ArrayList<String> >();
		 
		 try
		 {
			 for ( int i =0; i < files.length; ++i )
			 {
				 
				 File recFile = files[i];
				 if ( recFile == null )
				 {
					 continue;
				 }
				 
				 //Log.i(Tag, "recfile:" + recFile.getAbsolutePath());
				 
				 if ( !recFile.isFile() )
				 {
					 continue;
				 }
				 
				 if ( !recFile.exists() )
				 {
					 continue;
				 }
				 
				 String name = recFile.getName();
				 if ( name == null )
				 {
					 continue;
				 }
				 
				 if ( name.isEmpty() )
				 {
					 continue;
				 }
				
				 if ( name.endsWith(".mp4") )
				 {
					 ArrayList<String> item = new ArrayList<String>();
					 item.add(name);
					 item.add(recFile.getAbsolutePath());
					 
					 fileList.add(item);
				 }
			 }
		 }
		 catch(Exception e)
		 {
			 e.printStackTrace();
		 }		
	}
	
	private void DelAllRecFiles()
	{
		Log.i(Tag, "DelAllRecFiles++++");
		
		if ( recDirPath == null )
		{
			Log.i(Tag, "recDirPath is null");
			return;
		}
			
		
		if ( recDirPath.isEmpty() )
		{
			Log.i(Tag, "recDirPath is empty");
			return;
		}
			

		File recDirFile = null;
		
		try
		{
			 recDirFile = new File(recDirPath);
		}
		catch(Exception e)
		{
			e.printStackTrace();
			return;
		}
		
		if ( !recDirFile.exists() )
		{
			Log.e("Tag", "rec dir is not exist, path:" + recDirPath);
			return;
		}
		
		if ( !recDirFile.isDirectory() )
		{
			Log.e(Tag, recDirPath + " is not dir");
			return;
		}
		
		 File[] files = recDirFile.listFiles();
		 if ( files == null )
		 {
			 return;
		 }
		 
		 try
		 {
			 for ( int i =0; i < files.length; ++i )
			 {
				
				 
				 File recFile = files[i];
				 if ( recFile == null )
				 {
					 continue;
				 }
				 
				 //Log.i(Tag, "recfile:" + recFile.getAbsolutePath());
				 
				 if ( !recFile.isFile() )
				 {
					 continue;
				 }
				 
				 if ( !recFile.exists() )
				 {
					 continue;
				 }
				 
				 String name = recFile.getName();
				 if ( name == null )
				 {
					 continue;
				 }
				 
				 if ( name.isEmpty() )
				 {
					 continue;
				 }
				
				 if ( name.endsWith(".mp4") )
				 {
					 if ( recFile.delete()  )
					 {
						 Log.i(Tag, "Delete file:" + name);
					 }
					 else
					 {
						 Log.i(Tag, "Delete file failed, " + name);
					 }
					
				 }
				 
				
				 
			 }
		 }
		 catch(Exception e)
		 {
			 e.printStackTrace();
		 }
		 
		 fileList = null;
		 
		 SimpleAdapter ladapter = new SimpleAdapter(this,getMapData(fileList),R.layout.rec_files_list_view_item,
	        		new String[]{"ItemFileName"},new int[]{R.id.ItemFileName});  
	        
	      recFileListView.setAdapter(ladapter);  
		 
	 
		 Log.i(Tag, "DelAllRecFiles----");
	}
	
	 class ButtonDelAllRecFilesListenser implements OnClickListener
	 {
	    public void onClick(View v)
	    {
	    	DelAllRecFiles();
	    }
	}
}
