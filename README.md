# SmarterStreaming

SmarterStreaming, which is an excellent cross-platform Live Streaming publisher/playback SDK, based on RTMP protocol, developed by daniulive.

Currently, it has already covered Windows/android/iOS platform with millisecond latency and great scalability.

For commercial support, please contact 89030985@qq.com.

<img src="http://218.25.89.108:8080/files/image/SmarterStreaming.png" width="313" alt="SmarterStreaming" />

SmarterStreaming系列产品，系daniulive（大牛直播）出品的跨平台视频采集、直播SDK（支持私有协议/RTMP推流播放/纯音频推流播放/边推流边录像，如windows推流/android推流/iOS推流/windows播放器/android播放器/iOS播放器），公网毫秒级延迟，也许是国内最靠谱的视频直播推流、播放SDK之一，助您轻松实现类似于花椒、映客、斗鱼手机直播推送与播放。

**[SmarterStreaming SDK调用说明]**

[点击查看](http://daniulive.com:8080/files/SDK/SmarterStreamingSDK调用说明.pdf)

**[一对一实时音视频互动]**

1. 基于P2P或流媒体转发的一对一音视频互动产品；
2. 以秀场、在线教育、远程诊疗、智能门禁等为核心的跨平台音视频实时互动。

**[一对多，多对多直播、互动]**

SmarterStreaming也许是国内为数不多不依赖开源框架、可扩展性好的SDK，适用于秀场直播、在线教育、应急指挥、可视化购物、远程专家指挥系统、企业内训、金融在线直播室、微信直播、监控对接、活动现场直播、游戏直播等场景。

1. windows推流：Windows端实时采集，支持屏幕采集和摄像头采集；
2. windows播放器：Windows端实时播放（支持同时直播多画面，支持CS架构播放和无需安装第三方插件的浏览器端播放）；
3. android推流：Android端实时采集（支持多分辨率采集、采集过程中，前后摄像头切换）；
4. android播放器：Android端实时播放（支持超低延迟播放多路直播视频）；
5. iOS推流：iOS端实时采集（支持多分辨率采集、采集过程中，前后摄像头切换）；
6. iOS播放器：iOS端实时播放（支持超低延迟播放多路直播视频）；
7. 支持微信公众账号集成（RTMP输入，HLS播放）；
8. 公网环境下，**毫秒级延迟**，支持云服务部署、各类厂商的CDN产品对接；
9. 支持**边推送边录像**（如执法记录或移动单兵场景），网络中断仍可继续录制，结束后可本地回放，并可对接第三方云服务，把录像数据保存到云端服务器；
10. 支持跨平台**纯音频推送**、**纯音频播放**、**纯音频实时存储**。

**[基于RTMP安防摄像机平台对接]**

高稳定性、超低延迟的跨平台（Windows/android/iOS）综合视频监控系统对接。

**[多对一实时通讯]**

适用于应急指挥、公安巡检等，以移动单兵设备为采集载体，实时上传音视频数据到指挥中心，并实现指挥中心对现场的实时指导。

您可以用网页进行播放测试：<a href="http://daniulive.com:8080/files/SmartPlayer/SmartPlayer.html" target="_blank">http://daniulive.com:8080/files/SmartPlayer/SmartPlayer.html</a>

**[SmarterStreamServer]**

1. 高并发，分布式部署，支持rtmp摄像机和采集设备完美对接，提供代建服务器或整套软硬件服务器方案；
2. 高性能的流媒体服务器，标准rtmp输入，多种方式流输出（rtmp/hls），并同步保存采集端数据；
3. 支持鉴权认证、各种信息展示；
4. 点播服务器：满足录像文件点播需求；
5. 数据库服务器：媒体数据管理等。

**SmarterStreaming SDK库可供个人学习之用，企业及商用需要经过授权**；

## 公网环境下推流、直播效果展示 ##
<img src="http://daniulive.com:8080/files/image/WindowsPublisher.JPG" alt="Windows采集，跨平台播放" />

<img src="http://daniulive.com:8080/files/image/AndroidPublisher.JPG" alt="Android采集，跨平台播放" />

<img src="http://daniulive.com:8080/files/image/IOSPublisher.JPG" alt="iOS采集，跨平台播放" />

## RTMP摄像机对接 ##
**1. Windows播放器：**
<img src="http://daniulive.com:8080/files/image/windowscameradisplayer.JPG" alt="RTMP摄像机播放" />

**2. Android播放器：**
<img src="http://daniulive.com:8080/files/image/androidcameradisplayer.JPG" alt="android端播放RTMP摄像机数据" />

**3. iOS播放器：**
<img src="http://daniulive.com:8080/files/image/iOScameradisplayer.JPG" alt="iOS端播放RTMP摄像机数据" />

**4. android边推送边录像(支持纯音频推送和播放)：**
<img src="http://daniulive.com:8080/files/image/localrecorder.JPG" alt="android边推送边录像" />

**5. iOS边推送边录像(支持纯音频推送和播放)：**
<img src="http://daniulive.com:8080/files/image/iOSPublisher_Recorder.JPG" alt="iOS边推送边录像" />

**6. iOS边录像管理：**
<img src="http://daniulive.com:8080/files/image/iOS_recorder.JPG" alt="iOS边录像管理" />

## 使用说明 ##

**1. 推流:**

**1.1 Windows推流：**

选择“WindowsPusher&Player”文件，打开“SmartClientDemo.exe”（如需推送桌面，请使用SmartClientDeskDemo.exe，默认会采集PC屏幕左上角一块区域），进入系统后，左侧系推流端，右侧是播放端，推流依次点击:

1. Open;
2. Login（输入用户名、密码)，如需Windows端推流测试，请联系QQ 89030985，或加入QQ群 499687479 和群主联系;
3. 输入用户名、密码之后，会自动根据用户名生成对应的播放URL，如用户名daniulive，则生成的url为：rtmp://daniulive.com:1935/hls/streamdaniulive;
4. 点击PushStream，完成Windows推流。

PushStream，如推流成功的话，会显示推流地址，如本URL对应的链接为：
rtmp://daniulive.com:1935/hls/streamdaniulive.

**1.2 Android推流：**

安装SmartPublisher， 进入系统后，会自动生成urlID, 如 rtmp://daniulive.com:1935/hls/stream123456, 对应的urlID即为 123456（stream后的数字），点击“开始推流”，推流过程中，可点击右上角“切换前后摄像头”图标；来切换视角进行采集；

**1.3 移动端边推送边录像：**

以Android推流端为例，“开始推流”之前，选择“本地录像”，然后点推流，推流结束后，会自动在本地录制推流音视频（mp4文件），并可到“录像管理”页面，查看本地录制文件，单击文件名，即可完成本地文件播放。

**1.4 iOS推流：**

1. 安装SmartPublisher.ipa
2. 进入主页面，选择推流分辨率（流畅 标清 高清）；
3. 设置推送音视频还是纯音频（音视频 纯音频）；
4. [录像相关]设置推流过程中，是否录像（不录像 边推边录）；
5. 进入推流页面；
6. 点击“推流”，会自动生成推流地址，如“rtmp://daniulive.com:1935/hls/stream888888”；
7. 推流过程中，可以点击按钮“前置”、“后置”切换前后置摄像头；
8. 停止推流，点击“停止”；
9. 点击“返回”按钮，返回到主页面，可重新选择分辨率。
10. [录像相关]如有边推送边录像，直播结束后，点击“进入回放页面”，可显示录像文件名称，点击回放，可进行本地录像回放；
11. [录像相关]点击“删除全部文件”，可删除本地录制的所有文件；
12. [录像相关]回放过程中，点击“暂停”，进入播放暂停状态，点击“恢复”继续播放；

**2 播放：**

**2.1 Windows播放器：**

选择“WindowsPusher&Player”文件，打开“SmartClientDemo.exe”，右侧输入框输入 rtmp://daniulive.com:1935/hls/stream123456;， 然后依次点击 PlayerOpen-->StartPlay即可。

**2.2 android播放器**

进入系统后，点击“输入urlID”，在弹出的对话框输入url中，stream后的部分(如“rtmp://daniulive.com:1935/hls/stream123456”,那就输入“123456”)，点击开始播放即可，停止的话，点击停止播放即可。

**2.3 iOS播放器**

进入系统后，在输入框输入“urlID”，stream后的部分(如“rtmp://daniulive.com:1935/hls/stream123456”,那就输入“123456”)，点击“进入播放页面”即可，停止的话，点击“返回”按钮，返回主页面，可重新选择其他url播放。
如需播放纯音频，请选择“纯音频”选项，然后，输入urlID，进入播放状态。

**2.4 Web播放器**

http://daniulive.com:8080/files/SmartPlayer1Stream/SmartPlayer.html

在输入框中，清除老的url，输入推流的url，如 rtmp://daniulive.com:1935/hls/stream123456（以推流端生成的URL为准）。


## 获取更多信息 ##

商务合作：QQ：89030985 
技术支持：QQ: 2679481035

QQ群(大牛直播技术交流群)：499687479

<img src="http://daniulive.com:8080/files/image/erweima.png" width="302" alt="QQ交流群" />
