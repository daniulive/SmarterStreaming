# SmarterStreaming
跨平台的视频采集、直播SDK（支持Windows/android/iOS），也许是国内最靠谱的视频直播推流、播放SDK之一，助您轻松实现类似于花椒、映客、斗鱼手机直播推送与播放。

<img src="http://daniulive.com:8080/files/image/SmarterStreaming.png" width="313" alt="SmarterStreaming" />


1. Windows端实时采集(支持屏幕采集和摄像头采集)；
2. Windows端实时播放（支持同时直播多画面，支持CS架构播放和无需安装第三方插件的浏览器端播放）；

3. Android端实时采集（支持多分辨率采集、采集过程中，前后摄像头切换）；
4. Android端实时播放（支持超低延迟播放多路直播视频）；

5. iOS端实时采集（支持多分辨率采集、采集过程中，前后摄像头切换）；
6. iOS端实时播放（支持超低延迟播放多路直播视频）；

7. 支持微信公众账号集成；
8. 公网环境下，毫秒级延迟，支持云服务部署、各类厂商的CDN产品对接。


你可以用网页进行播放测试：<a href="http://daniulive.com:8080/files/SmartPlayer/SmartPlayer.html" target="_blank">http://daniulive.com:8080/files/SmartPlayer/SmartPlayer.html</a>


**SmarterStreaming SDK库个人使用免费，企业及商用需要经过授权**；

## 推流、直播效果展示 ##
<img src="http://daniulive.com:8080/files/image/WindowsPublisher.JPG" width="800" alt="Windows采集，跨平台播放" />

<img src="http://daniulive.com:8080/files/image/AndroidPublisher.JPG" width="800" alt="Android采集，跨平台播放" />

<img src="http://daniulive.com:8080/files/image/IOSPublisher.JPG" width="800" alt="iOS采集，跨平台播放" />


## 使用说明 ##

1. 推流:

1.1 Windows端推流：

选择“WindowsPusher&Player”文件，打开“SmartClientDemo.exe”，进入系统后，左侧系推流端，右侧是播放端，推流依次点击:

1. Open;
2. Login（输入用户名、密码)，如需Windows端推流测试，请联系QQ 89030985，或加入QQ群 499687479 和群主联系;
3. 输入用户名、密码之后，会自动根据用户名生成对应的播放URL，如用户名daniulive，则生成的url为：rtmp://daniulive.com:1935/hls/streamdaniulive;
4. 点击PushStream，完成Windows推流。

PushStream，如推流成功的话，会显示推流地址，如本URL对应的链接为：
rtmp://daniulive.com:1935/hls/streamdaniulive.

1.2 Android端推流：

安装SmartPublisher， 进入系统后，会自动生成urlID, 如 rtmp://daniulive.com:1935/hls/stream123456, 对应的urlID即为 123456（stream后的数字），点击“开始推流”，推流过程中，可点击右上角“切换前后摄像头”图标；来切换视角进行采集；

2 播放：

2.1 Windows播放：
选择“WindowsPusher&Player”文件，打开“SmartClientDemo.exe”，右侧输入框输入 rtmp://daniulive.com:1935/hls/stream123456;， 然后依次点击 PlayerOpen-->StartPlay即可。

2.2 SmartPlayer.apk(android)
进入系统后，点击“输入urlID”，在弹出的对话框输入"123456"(也就是分配的账号)，点击开始播放即可，停止的话，点击停止播放即可。

2.3 Web播放

http://daniulive.com:8080/files/SmartPlayer1Stream/SmartPlayer.html

在输入框中，清除老的url，输入推流的url，如 rtmp://daniulive.com:1935/hls/stream123456（以推流端生成的URL为准）。


## 获取更多信息 ##

QQ群(大牛直播技术交流群)：499687479

商务合作：QQ：89030985 

