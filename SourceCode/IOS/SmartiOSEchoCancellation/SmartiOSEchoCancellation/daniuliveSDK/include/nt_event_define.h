//
//  nt_event_define.h
//  nt_event_define
//
//  GitHub: https://github.com/daniulive/SmarterStreaming
//  website: https://www.daniulive.com
//
//  Created by daniulive on 16/3/24.
//  Copyright © 2014~2019 daniulive. All rights reserved.
//

#ifndef NT_EVENT_DEFINE_H_
#define NT_EVENT_DEFINE_H_

#ifdef __cplusplus
extern "C"{
#endif
    
    /*范围划分*/
#define EVENT_DANIULIVE_COMMON_SDK					0x00000000
#define EVENT_DANIULIVE_PLAYER_SDK					0x01000000
#define EVENT_DANIULIVE_PUBLISHER_SDK				0x02000000
    
    /* player event ID*/
    typedef enum _PLAYER_EVENT_ID
    {
        EVENT_DANIULIVE_ERC_PLAYER_STARTED                      = EVENT_DANIULIVE_PLAYER_SDK | 0x1,	/*开始播放*/
        EVENT_DANIULIVE_ERC_PLAYER_CONNECTING                   = EVENT_DANIULIVE_PLAYER_SDK | 0x2,	/*连接中*/
        EVENT_DANIULIVE_ERC_PLAYER_CONNECTION_FAILED            = EVENT_DANIULIVE_PLAYER_SDK | 0x3,	/*连接失败*/
        EVENT_DANIULIVE_ERC_PLAYER_CONNECTED                    = EVENT_DANIULIVE_PLAYER_SDK | 0x4,	/*已连接*/
        EVENT_DANIULIVE_ERC_PLAYER_DISCONNECTED                 = EVENT_DANIULIVE_PLAYER_SDK | 0x5,	/*断开连接*/
        EVENT_DANIULIVE_ERC_PLAYER_STOP                         = EVENT_DANIULIVE_PLAYER_SDK | 0x6,	/*停止播放*/
        EVENT_DANIULIVE_ERC_PLAYER_RESOLUTION_INFO              = EVENT_DANIULIVE_PLAYER_SDK | 0x7,	/*视频解码分辨率信息*/
        EVENT_DANIULIVE_ERC_PLAYER_NO_MEDIADATA_RECEIVED        = EVENT_DANIULIVE_PLAYER_SDK | 0x8,	/*收不到RTMP数据*/
        EVENT_DANIULIVE_ERC_PLAYER_SWITCH_URL                   = EVENT_DANIULIVE_PLAYER_SDK | 0x9,	/*切换播放url*/
        EVENT_DANIULIVE_ERC_PLAYER_CAPTURE_IMAGE                = EVENT_DANIULIVE_PLAYER_SDK | 0xA,	/*截取快照*/
        EVENT_DANIULIVE_ERC_PLAYER_RTSP_STATUS_CODE             = EVENT_DANIULIVE_PLAYER_SDK | 0xB,  /*rtsp status code上报, 目前只上报401, param1表示status code*/
        /* 录像相关*/
        EVENT_DANIULIVE_ERC_PLAYER_RECORDER_START_NEW_FILE      = EVENT_DANIULIVE_PLAYER_SDK | 0x21,    /*录像写入新文件*/
        EVENT_DANIULIVE_ERC_PLAYER_ONE_RECORDER_FILE_FINISHED   = EVENT_DANIULIVE_PLAYER_SDK | 0x22,    /*一个录像文件完成*/
        
        /* 接下来请从0x81开始*/
        EVENT_DANIULIVE_ERC_PLAYER_START_BUFFERING              = EVENT_DANIULIVE_PLAYER_SDK | 0x81, /*开始缓冲*/
        EVENT_DANIULIVE_ERC_PLAYER_BUFFERING                    = EVENT_DANIULIVE_PLAYER_SDK | 0x82, /*缓冲中, param1 表示百分比进度*/
        EVENT_DANIULIVE_ERC_PLAYER_STOP_BUFFERING               = EVENT_DANIULIVE_PLAYER_SDK | 0x83, /*停止缓冲*/
        
        EVENT_DANIULIVE_ERC_PLAYER_DOWNLOAD_SPEED               = EVENT_DANIULIVE_PLAYER_SDK | 0x91, /*下载速度， param1表示下载速度，单位是(Byte/s)*/
    }PLAYER_EVENT_ID;
    
    
    /* publisher event ID*/
    typedef enum _PUBLISHER_EVENT_ID
    {
        EVENT_DANIULIVE_ERC_PUBLISHER_STARTED                   = EVENT_DANIULIVE_PUBLISHER_SDK | 0x1,	/*开始推流, param3表示推送URL*/
        EVENT_DANIULIVE_ERC_PUBLISHER_CONNECTING                = EVENT_DANIULIVE_PUBLISHER_SDK | 0x2,	/*连接中*/
        EVENT_DANIULIVE_ERC_PUBLISHER_CONNECTION_FAILED         = EVENT_DANIULIVE_PUBLISHER_SDK | 0x3,	/*连接失败*/
        EVENT_DANIULIVE_ERC_PUBLISHER_CONNECTED                 = EVENT_DANIULIVE_PUBLISHER_SDK | 0x4,	/*已连接*/
        EVENT_DANIULIVE_ERC_PUBLISHER_DISCONNECTED              = EVENT_DANIULIVE_PUBLISHER_SDK | 0x5,	/*断开连接*/
        EVENT_DANIULIVE_ERC_PUBLISHER_STOP                      = EVENT_DANIULIVE_PUBLISHER_SDK | 0x6,	/*停止推流, param3表示推送URL*/
        EVENT_DANIULIVE_ERC_PUBLISHER_RECORDER_START_NEW_FILE   = EVENT_DANIULIVE_PUBLISHER_SDK | 0x7,	/*录像写入新文件*/
        EVENT_DANIULIVE_ERC_PUBLISHER_ONE_RECORDER_FILE_FINISHED= EVENT_DANIULIVE_PUBLISHER_SDK | 0x8,	/*一个录像文件完成*/
        EVENT_DANIULIVE_ERC_PUBLISHER_SEND_DELAY                = EVENT_DANIULIVE_PUBLISHER_SDK | 0x9,  /*rtmp发送时延*/
        EVENT_DANIULIVE_ERC_PUBLISHER_CAPTURE_IMAGE             = EVENT_DANIULIVE_PUBLISHER_SDK | 0xA,  /*截取快照*/
        EVENT_DANIULIVE_ERC_PUBLISHER_RTSP_URL                  = EVENT_DANIULIVE_PUBLISHER_SDK | 0xB,  /*通知rtsp url, param1表示rtsp server handle, param3表示rtsp url*/
        EVENT_DANIULIVE_ERC_PUSH_RTSP_SERVER_RESPONSE_STATUS_CODE = EVENT_DANIULIVE_PUBLISHER_SDK | 0xC,  /* 推送rtsp时服务端相应的status code上报，目前只上报401, param1表示status code,  param3表示推送URL */
	    EVENT_DANIULIVE_ERC_PUSH_RTSP_SERVER_NOT_SUPPORT = EVENT_DANIULIVE_PUBLISHER_SDK | 0xD,  /* 推送rtsp时服务器不支持rtsp推送,  param3表示推送URL */
    }PUBLISHER_EVENT_ID;
	
	/**
	 *  错误返回值
	 */
	typedef enum DNErrorCode{
	    DANIULIVE_RETURN_OK = 0,        //!< 返回OK
	    DANIULIVE_RETURN_ERROR,         //!< 返回错误
	    DANIULIVE_RETURN_SDK_EXPIRED    //!< SDK过期
	}DNErrorCode;
    
#ifdef __cplusplus
}
#endif

#endif
