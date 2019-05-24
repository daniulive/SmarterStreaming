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
 * 设置rtsp server 组播, 如果server设置成组播就不能单播，组播和单播只能选一个, 一般来说单播网络设备支持的好，wifi组播很多路由器不支持
 *
 * @param rtsp_server_handle: rtsp server 句柄
 *
 * @param is_multicast: 是否组播, 1为组播, 0为单播, 其他值接口返回错误, 默认是单播
 *
 * @return {0} if successful
 */
-(NSInteger)SetRtspServerMulticast:(void*)rtsp_server_handle is_multicast:(NSInteger)is_multicast;

/*
 * 设置rtsp server 组播组播地址
 *
 * @param rtsp_server_handle: rtsp server 句柄
 *
 * @param multicast_address: 组播地址
 *
 * 如果设置的不是组播地址, 将返回错误
 * 组播地址范围说明: [224.0.0.0, 224.0.0.255] 为组播预留地址, 不能设置. 可设置范围为[224.0.1.0, 239.255.255.255], 其中SSM地址范围为[232.0.0.0, 232.255.255.255]
 *
 *  @return {0} if successful
 */
-(NSInteger)SetRtspServerMulticastAddress:(void*)rtsp_server_handle multicast_address:(NSString*)multicast_address;

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
