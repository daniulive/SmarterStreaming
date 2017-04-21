//
//  nt_event_define.h
//  nt_event_define
//
//  GitHub: https://github.com/daniulive/SmarterStreaming
//  website: http://www.daniulive.com
//
//  Created by daniulive on 16/3/24.
//  Copyright © 2015~2017 daniulive. All rights reserved.
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
    }PLAYER_EVENT_ID;
    
    
    /* publisher event ID*/
    typedef enum _PUBLISHER_EVENT_ID
    {
        EVENT_DANIULIVE_ERC_PUBLISHER_STARTED                   = EVENT_DANIULIVE_PUBLISHER_SDK | 0x1,	/*开始推流*/
        EVENT_DANIULIVE_ERC_PUBLISHER_CONNECTING                = EVENT_DANIULIVE_PUBLISHER_SDK | 0x2,	/*连接中*/
        EVENT_DANIULIVE_ERC_PUBLISHER_CONNECTION_FAILED         = EVENT_DANIULIVE_PUBLISHER_SDK | 0x3,	/*连接失败*/
        EVENT_DANIULIVE_ERC_PUBLISHER_CONNECTED                 = EVENT_DANIULIVE_PUBLISHER_SDK | 0x4,	/*已连接*/
        EVENT_DANIULIVE_ERC_PUBLISHER_DISCONNECTED              = EVENT_DANIULIVE_PUBLISHER_SDK | 0x5,	/*断开连接*/
        EVENT_DANIULIVE_ERC_PUBLISHER_STOP                      = EVENT_DANIULIVE_PUBLISHER_SDK | 0x6,	/*停止推流*/
        EVENT_DANIULIVE_ERC_PUBLISHER_RECORDER_START_NEW_FILE   = EVENT_DANIULIVE_PUBLISHER_SDK | 0x7,	/*录像写入新文件*/
        EVENT_DANIULIVE_ERC_PUBLISHER_ONE_RECORDER_FILE_FINISHED= EVENT_DANIULIVE_PUBLISHER_SDK | 0x8,	/*一个录像文件完成*/
    }PUBLISHER_EVENT_ID;
    
#ifdef __cplusplus
}
#endif

#endif