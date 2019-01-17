//
//  SmartRTSPServerSDK.h
//  SmartRTSPServerSDK
//
//  GitHub: https://github.com/daniulive/SmarterStreaming
//  website: https://www.daniulive.com
//
//  Created by daniulive on 18/6/20.
//  Copyright © 2014~2019 daniulive. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SmartRTSPServerSDK : NSObject

/*
 * 创建一个rtsp server
 *
 * reserve：保留参数传0
 *
 * @return rtsp server 句柄
 */
-(void*)OpenRtspServer:(NSInteger)reserve;

/*
 * 设置rtsp server 监听端口, 在StartRtspServer之前必须要设置端口
 * rtsp_server_handle: rtsp server 句柄
 * port: 端口号，可以设置为554,或者是1024到65535之间,其他值返回失败
 *
 * @return {0} if successful
 */
-(NSInteger)SetRtspServerPort:(void*)rtsp_server_handle port:(NSInteger)port;

/*
 * 设置rtsp server 鉴权用户名和密码, 这个可以不设置，只有需要鉴权的再设置
 * rtsp_server_handle: rtsp server 句柄
 * user_name: 用户名,必须是英文
 * password：密码,必须是英文
 *
 * @return {0} if successful
 */
-(NSInteger)SetRtspServerUserNamePassword:(void*)rtsp_server_handle user_name:(NSString*)user_name password:(NSString*)password;

/*
 * 获取rtsp server当前的客户会话数, 这个接口必须在StartRtspServer之后再调用
 * rtsp_server_handle: rtsp server 句柄
 * session_numbers: 会话数
 *
 * @return {0} if successful
 */
-(NSInteger)GetRtspServerClientSessionNumbers:(void*)rtsp_server_handle session_numbers:(NSInteger*)session_numbers;

/*
 * 启动rtsp server
 * rtsp_server_handle: rtsp server 句柄
 * reserve: 保留参数传0
 *
 * @return {0} if successful
 */
-(NSInteger)StartRtspServer:(void*)rtsp_server_handle reserve:(NSInteger)reserve;

/*
 * 停止rtsp server
 * rtsp_server_handle: rtsp server 句柄
 *
 * @return {0} if successful
 */
-(NSInteger)StopRtspServer:(void*)rtsp_server_handle;

/*
 * 关闭rtsp server
 * 调用这个接口之后rtsp_server_handle失效，
 *
 * @return {0} if successful
 */
-(NSInteger)CloseRtspServer:(void*)rtsp_server_handle;

@end
