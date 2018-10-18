**视沃科技-大牛直播SDK <a href="http://www.daniulive.com" target="_blank">daniulive.com</a>**

始于2014年，国内外为数不多致力于极致体验的**超强全自研跨平台**(windows/android/iOS)**流媒体内核**，通过模块化自由组合，支持实时RTMP推流、RTMP/RTSP直播播放(**支持RTSP/RTMP H.265**)、实时录像、多路流媒体转发、音视频导播、动态视频合成、音频混音、互动直播、内置轻量级RTSP服务等，**比快更快**，业界**真正靠谱**的超低延迟直播SDK(1秒内，低延迟模式下200~400ms)。

适用于**在线教育、无纸化推屏/会议、智慧教室、直播答题、智能可视门禁对讲、智慧安防、智能家居、物联网、智能车载、传统硬件领域、[超低延迟娃娃机抓取播放方案](http://daniulive.com/index.php/2018/04/02/%E5%A6%82%E4%BD%95%E5%AE%9E%E7%8E%B0%E7%AE%80%E5%8D%95%E7%B2%97%E6%9A%B4%E9%9D%A0%E8%B0%B1%E7%9A%84%E7%9B%B4%E6%92%AD%E6%8A%93%E5%A8%83%E5%A8%83%E6%96%B9%E6%A1%88/)、媒体移动直播、应急指挥调度(针对保险、城管、交警、消防、公安等职能管理部门的单兵应急执法系统)、可视化购物、远程专家诊断、可视化巡检、(如电信/电力线路/铁路沿线/水利设施/油田/消防设施巡检)、移动视频安防监控，企业内训、金融在线直播室、微信直播、监控对接、活动现场直播、游戏直播、秀场直播**等场景。

[大牛直播SDK Demo界面展示](http://daniulive.com/index.php/2018/09/21/%E5%A4%A7%E7%89%9B%E7%9B%B4%E6%92%ADsdk-demo%E5%B1%95%E7%A4%BA/)

For English introduction, please [click here](https://github.com/daniulive/SmarterStreaming/wiki/English-version);

**大牛直播SDK可供个人学习之用，企业及商用需要经过授权**(授权请联系 QQ:**89030985** 或 **517631076** 手机:**130-7210-2209** 或 **135-6452-9354**)；

**[latest release note](http://daniulive.com/index.php/tag/release-note/)**

除此之外，大牛直播SDK播放端，支持**APICloud**和**React Native**二次封装，并且全平台支持**Unity3D**平台，也可能是Unity3D平台下首款**真正高稳定、超低延迟**的rtmp/rtsp直播播放器。

**[android/iOS播放器SDK(V2)APICloud调用说明](http://daniulive.com/index.php/2018/04/02/apicloud%E5%A6%82%E4%BD%95%E5%AF%B9%E6%8E%A5%E5%A4%A7%E7%89%9B%E7%9B%B4%E6%92%ADsdk/)**

**[windows/android/iOS播放器SDK(V2)Unity3D调用说明](http://web1712221406366.gz01.bdysite.com/wp-content/uploads/2018/06/视沃科技-大牛直播SDKV2Unity3D调用说明1.1.pdf)**

**[大牛直播SDK基于unity3d平台的rtmp/rtsp直播播放端SDK视频演示](http://web1712221406366.gz01.bdysite.com/wp-content/uploads/2018/05/unity3d-android-iOS.mp4)**

**[Unity3D-Windows播放端APP下载](http://web1712221406366.gz01.bdysite.com/wp-content/uploads/daniulive/Daniulive-Unity3D-Win-SmartPlayer-2018-09-04.zip)**

**[Unity3D-Android播放端APK下载](http://web1712221406366.gz01.bdysite.com/wp-content/uploads/2018/05/APKUnity3D-SmartPlayer-0530.zip)**


## 模块概览 ## 

<img src="http://web1712221406366.gz01.bdysite.com/wp-content/uploads/2018/06/框架图.png" alt="直播SDK模块" />

**Windows端**

- [x] [**RTMP直播推流SDK**](http://daniulive.com/index.php/2018/04/02/%E5%A4%A7%E7%89%9B%E7%9B%B4%E6%92%AD%E6%8E%A8%E6%B5%81sdk/) rtmp推送SDK(支持同时推多路url)；

- [x] [**RTMP/RTSP直播播放器SDK**](http://daniulive.com/index.php/2018/04/02/%E5%A4%A7%E7%89%9B%E7%9B%B4%E6%92%ADrtmp-rtsp%E6%92%AD%E6%94%BE%E5%99%A8sdk/) 业内首屈一指的rtmp/rtsp超低延迟直播播放器SDK(**支持RTMP H.265扩展播放**);

- [x] [**Unity3D RTMP/RTSP直播播放器SDK**](http://daniulive.com/index.php/2018/06/04/%E5%A4%A7%E7%89%9B%E7%9B%B4%E6%92%ADsdk-unity3d%E7%9B%B4%E6%92%AD%E6%92%AD%E6%94%BE%E5%99%A8sdk/) **业内首家**Windows支持Unity3D的超低延迟RTMP/RTSP直播播放器SDK，支持快照、录像、实时静音、view旋转、快速切换URL等特性;

- [x] [**RTMP/RTSP多路流媒体转发SDK**](http://daniulive.com/index.php/2018/04/04/%E5%A4%9A%E8%B7%AF%E6%B5%81%E5%AA%92%E4%BD%93%E8%BD%AC%E5%8F%91sdk/) 支持同时**多路拉取rtmp/rtsp流/本地flv文件，并分别转发到服务器**，支持转发过程中，拉取的rtsp/rtmp或本地flv文件实时内容切换，业内为数不多**支持RTSP/RTMP H.265拉流转发**的SDK(提供配套RTMP扩展H.265服务器)；

- [x] [**轻量级RTSP服务SDK**](http://daniulive.com/index.php/2018/06/22/%E8%BD%BB%E9%87%8F%E7%BA%A7rtsp%E6%9C%8D%E5%8A%A1sdk/) 为满足内网无纸化/电子教室等内网超低延迟需求，避免让用户配置单独的服务器，大牛直播SDK在推送端支持轻量级RTSP服务SDK，推送端SDK支持的功能，内置轻量级RTSP服务SDK后，功能继续支持；

- [x] [**导播SDK**](http://daniulive.com/index.php/2018/06/23/%E5%A4%A7%E7%89%9B%E7%9B%B4%E6%92%AD%E5%AF%BC%E6%92%ADsdk/) 数据源：1. rtmp/rtsp音视频流；2. 本地屏幕/摄像头/音频数据；3.本地flv文件；**多路流合成一路**实时导播推送；

- [x] [**录像SDK**](http://daniulive.com/index.php/2018/04/04/%E5%A4%A7%E7%89%9B%E7%9B%B4%E6%92%AD%E5%BD%95%E5%83%8Fsdk/) 支持拉取rtmp/rtsp流实时**录像**模块/实时**快照**功能，支持纯音频、纯视频、音视频录制模式，支持音频(PCMU/PCMA,Speex等)**转AAC**后再录像，业内为数不多的支持**RTSP/RTMP H.265录制到MP4文件**的录像SDK；

- [x] [**互动SDK**] Windows一对一互动(可windows与windows/android互动)；

- [x] [**连麦SDK**](http://daniulive.com/index.php/2018/06/23/%E5%A4%A7%E7%89%9B%E7%9B%B4%E6%92%AD%E8%BF%9E%E9%BA%A6sdk/) 以标准协议为基础，完美支持Windows连麦；

- [x] [**点播播放器SDK**] 支持本地flv文件播放(支持获取flv文件的duration(时长)；支持显示当前播放位置；支持开始播放或播放过程中seek(跳转播放位置)，**也许是行业内seek最快的flv点播播放器**)；

- [x] [**SEI扩展数据发送/接收SDK**](http://daniulive.com/index.php/2018/07/10/%E5%A4%A7%E7%89%9B%E7%9B%B4%E6%92%ADsei%E6%89%A9%E5%B1%95%E6%95%B0%E6%8D%AE%E5%8F%91%E9%80%81-%E6%8E%A5%E6%94%B6sdk/) 支持推送端通过H.264 SEI信息扩展，实时传输文本/二进制数据信息(如实时字幕/时间戳/题目分发/公告广播等)，播放端做相应解析和回显；

- [x] [**视频处理SDK**](http://daniulive.com/index.php/2018/09/21/%E9%9F%B3%E9%A2%91%E9%87%87%E9%9B%86%E5%A4%84%E7%90%86sdk/) 屏幕/多摄像头/水印/遮挡区域多层自由合成模块；

- [x] [**音频处理SDK**](http://daniulive.com/index.php/2018/09/21/%E8%A7%86%E9%A2%91%E9%87%87%E9%9B%86%E5%A4%84%E7%90%86sdk/) 多路混音、回音消除、噪音抑制、自动增益、VAD检测模块；

**Android端**

- [x] [**RTMP直播推流端SDK**](http://daniulive.com/index.php/2018/04/02/%E5%A4%A7%E7%89%9B%E7%9B%B4%E6%92%AD%E6%8E%A8%E6%B5%81sdk/) Android屏幕、摄像头RTMP推流SDK;

- [x] [**RTMP/RTSP直播播放器SDK**](http://daniulive.com/index.php/2018/04/02/%E5%A4%A7%E7%89%9B%E7%9B%B4%E6%92%ADrtmp-rtsp%E6%92%AD%E6%94%BE%E5%99%A8sdk/) 业内首屈一指的rtmp/rtsp超低延迟直播播放器SDK(**支持RTMP H.265扩展播放**);

- [x] [**Unity3D RTMP/RTSP直播播放器SDK**](http://daniulive.com/index.php/2018/06/04/%E5%A4%A7%E7%89%9B%E7%9B%B4%E6%92%ADsdk-unity3d%E7%9B%B4%E6%92%AD%E6%92%AD%E6%94%BE%E5%99%A8sdk/) **业内首家**Android支持Unity3D的超低延迟RTMP/RTSP直播播放器SDK，支持快照、录像、实时静音、view旋转、快速切换URL等特性;

- [x] [**录像SDK**](http://daniulive.com/index.php/2018/04/04/%E5%A4%A7%E7%89%9B%E7%9B%B4%E6%92%AD%E5%BD%95%E5%83%8Fsdk/) 支持拉取rtmp/rtsp流实时**录像**模块/实时**快照**功能，支持纯音频、纯视频、音视频录制模式，支持音频(PCMU/PCMA,Speex等)**转AAC**后再录像，业内为数不多的支持**RTSP/RTMP H.265录制到MP4文件**的录像SDK；

- [x] [**RTMP/RTSP多路流媒体转发SDK**](http://daniulive.com/index.php/2018/04/04/%E5%A4%9A%E8%B7%AF%E6%B5%81%E5%AA%92%E4%BD%93%E8%BD%AC%E5%8F%91sdk/) 支持实时拉取的rtmp/rtsp流转发到指定rtmp url;

- [x] [**轻量级RTSP服务SDK**](http://daniulive.com/index.php/2018/06/22/%E8%BD%BB%E9%87%8F%E7%BA%A7rtsp%E6%9C%8D%E5%8A%A1sdk/) 为满足内网无纸化/电子教室等内网超低延迟需求，避免让用户配置单独的服务器，大牛直播SDK在推送端支持轻量级RTSP服务SDK，推送端SDK支持的功能，内置轻量级RTSP服务SDK后，功能继续支持；

- [x] [**互动SDK**] Android一对一互动(可android与windows/android/iOS互动)；

- [x] [**SEI扩展数据发送/接收SDK**](http://daniulive.com/index.php/2018/07/10/%E5%A4%A7%E7%89%9B%E7%9B%B4%E6%92%ADsei%E6%89%A9%E5%B1%95%E6%95%B0%E6%8D%AE%E5%8F%91%E9%80%81-%E6%8E%A5%E6%94%B6sdk/) 支持推送端通过H.264 SEI信息扩展，实时传输文本/二进制数据信息(如实时字幕/时间戳/题目分发/公告广播等)，播放端做相应解析和回显；

- [x] [**视频处理SDK**](http://daniulive.com/index.php/2018/09/21/%E9%9F%B3%E9%A2%91%E9%87%87%E9%9B%86%E5%A4%84%E7%90%86sdk/)Android文字水印、png图片水印；

- [x] [**音频处理SDK**](http://daniulive.com/index.php/2018/09/21/%E8%A7%86%E9%A2%91%E9%87%87%E9%9B%86%E5%A4%84%E7%90%86sdk/)Android回音消除、噪音抑制、自动增益、VAD检测模块；


**iOS端**

- [x] [**RTMP直播推流端SDK**](http://daniulive.com/index.php/2018/04/02/%E5%A4%A7%E7%89%9B%E7%9B%B4%E6%92%AD%E6%8E%A8%E6%B5%81sdk/) iOS屏幕(基于[ReplayKit](http://daniulive.com/index.php/2018/04/02/%E5%A6%82%E4%BD%95%E5%9F%BA%E4%BA%8Ereplaykit%E5%AE%9E%E7%8E%B0%E4%BD%8E%E5%BB%B6%E8%BF%9Frtmp%E6%8E%A8%E5%B1%8F/))、摄像头RTMP推流SDK;

- [x] [**RTMP/RTSP直播播放器SDK**](http://daniulive.com/index.php/2018/04/02/%E5%A4%A7%E7%89%9B%E7%9B%B4%E6%92%ADrtmp-rtsp%E6%92%AD%E6%94%BE%E5%99%A8sdk/) 业内首屈一指的rtmp/rtsp超低延迟直播播放器SDK(**支持RTMP H.265扩展播放**);

- [x] [**Unity3D RTMP/RTSP直播播放器SDK**](http://daniulive.com/index.php/2018/06/04/%E5%A4%A7%E7%89%9B%E7%9B%B4%E6%92%ADsdk-unity3d%E7%9B%B4%E6%92%AD%E6%92%AD%E6%94%BE%E5%99%A8sdk/) **业内首家**iOS支持Unity3D的超低延迟RTMP/RTSP直播播放器SDK，支持快照、录像、实时静音、view旋转、快速切换URL等特性;

- [x] [**录像SDK**](http://daniulive.com/index.php/2018/04/04/%E5%A4%A7%E7%89%9B%E7%9B%B4%E6%92%AD%E5%BD%95%E5%83%8Fsdk/) 支持拉取rtmp/rtsp流实时**录像**模块/实时**快照**功能，支持纯音频、纯视频、音视频录制模式，支持音频(PCMU/PCMA,Speex等)**转AAC**后再录像，业内为数不多的支持**RTSP/RTMP H.265录制到MP4文件**的录像SDK；

- [x] [**RTMP/RTSP多路流媒体转发SDK**](http://daniulive.com/index.php/2018/04/04/%E5%A4%9A%E8%B7%AF%E6%B5%81%E5%AA%92%E4%BD%93%E8%BD%AC%E5%8F%91sdk/) 支持实时拉取的rtmp/rtsp流转发到指定rtmp url;

- [x] [**轻量级RTSP服务SDK**](http://daniulive.com/index.php/2018/06/22/%E8%BD%BB%E9%87%8F%E7%BA%A7rtsp%E6%9C%8D%E5%8A%A1sdk/) 为满足内网无纸化/电子教室等内网超低延迟需求，避免让用户配置单独的服务器，大牛直播SDK在推送端支持轻量级RTSP服务SDK，推送端SDK支持的功能，内置轻量级RTSP服务SDK后，功能继续支持；

- [x] [**SEI扩展数据发送/接收SDK**](http://daniulive.com/index.php/2018/07/10/%E5%A4%A7%E7%89%9B%E7%9B%B4%E6%92%ADsei%E6%89%A9%E5%B1%95%E6%95%B0%E6%8D%AE%E5%8F%91%E9%80%81-%E6%8E%A5%E6%94%B6sdk/) 支持推送端通过H.264 SEI信息扩展，实时传输文本/二进制数据信息(如实时字幕/时间戳/题目分发/公告广播等)，播放端做相应解析和回显；

## 本地下载 ##

很多开发者反应，由于项目庞大，github下载整个工程很慢，我们已经把相关demo文件和使用说明，全部上传到QQ群共享：
- [x] 大牛直播精英群: [294891451](http://shang.qq.com/wpa/qunwpa?idkey=476a9cc05db0b2924530ccbbf4fae78fa485d39418ef79c8ab71b24a8fee8a48)
- [x] 大牛直播技术交流群: [499687479](http:////shang.qq.com/wpa/qunwpa?idkey=e7686f68a39bf1b95dc2ac3b775867efc7d3cbaf3596daf6e12bc1df21e1dc59)

或者直接从私有服务器下载(Windows提供C#/C++ demo, android提供android studio demo，iOS提供xcode demo)：

**大牛直播SDK相关demo本地下载**

- [x] [Windows demo测试程序] [Windows推送、播放、合成、导播、连麦Demo(32位)本地下载](http://web1712221406366.gz01.bdysite.com/wp-content/uploads/2018/10/windows-推送-播放版-2018-10-16.zip)

- [x] [Windows demo测试程序] [Windows推送、播放、合成、导播、连麦Demo(64位)本地下载](http://web1712221406366.gz01.bdysite.com/wp-content/uploads/2018/10/windows-推送-播放版64位-2018-10-16.zip)

- [x] [Windows C++ SDK demo工程代码] [Windows推流SDK(C++) Demo工程本地下载](http://web1712221406366.gz01.bdysite.com/wp-content/uploads/daniulive/WIN-PublisherSDK-CPP-Demo-2018-10-16.zip)

- [x] [Windows C++ SDK demo工程代码] [Windows播放器SDK(C++) Demo工程本地下载](http://web1712221406366.gz01.bdysite.com/wp-content/uploads/daniulive/WIN-PlayerSDK-CPP-Demo-2018-10-16.zip)

- [x] [Windows C++ SDK demo工程代码] [Windows混流SDK(C++) Demo工程本地下载](http://web1712221406366.gz01.bdysite.com/wp-content/uploads/daniulive/WIN-PlayerSDK-CPP-Demo-2018-10-16.zip)

- [x] [Windows C++ SDK demo工程代码] [Windows多路流媒体转发模块SDK(C++) Demo工程本地下载](http://web1712221406366.gz01.bdysite.com/wp-content/uploads/daniulive/WIN-RelaySDK-CPP-Demo-2018-10-16.zip)

- [x] [Windows C# SDK demo工程代码] [Windows C#版本推送SDK Demo工程本地下载](http://daniulive.com/wp-content/uploads/daniulive/WIN-PublisherSDK-CSharp-Demo-2018-09-06.zip)

- [x] [Windows C# SDK demo工程代码] [Windows C#版本播放SDK Demo工程本地下载](http://daniulive.com/wp-content/uploads/daniulive/WIN-PlayerSDK-CSharp-Demo-2018-09-06.zip)

- [x] [Windows C# SDK demo工程代码] [Windows C#多路流媒体转发模块SDK Demo工程本地下载](http://daniulive.com/wp-content/uploads/daniulive/WIN-RelaySDK-CSharp-demo-2018-09-06.zip)

- [x] [Android SDK demo工程代码] [**android推送、播放、转发、一对一互动、后台推摄像头/屏幕Demo(V2接口，建议采用)(Android Studio工程)**](http://web1712221406366.gz01.bdysite.com/wp-content/uploads/daniulive/Daniulive-Android-SDK(V2)-AndroidStudio-2018-10-18.zip)

- [x] [iOS SDK demo工程代码] [**iOS推送、播放、转发、录屏SDK(V2)本地下载**](http://web1712221406366.gz01.bdysite.com/wp-content/uploads/daniulive/Daniulive-SDK-iOS-2018-09-27.zip)

**NOTE:** Windows平台，以C++ SDK Demo为最新，C# Demo更新速度稍滞于C++ Demo。

## 大牛直播SDK集成和调用说明 ##

- [x] [**移动端SDK(V2)调用说明**](http://web1712221406366.gz01.bdysite.com/wp-content/uploads/2018/08/视沃科技-大牛直播移动端SDKV2调用说明2.8.pdf)

- [x] [**Windows SDK说明(以C#为例)**](http://web1712221406366.gz01.bdysite.com/wp-content/uploads/2018/09/视沃科技-Windows-SDK集成说明2.8.pdf)

- [x] [**windows/android/iOS播放器SDK(V2)Unity3D调用说明**](http://web1712221406366.gz01.bdysite.com/wp-content/uploads/2018/06/视沃科技-大牛直播SDKV2Unity3D调用说明1.1.pdf)

**大牛直播SDK Demo使用说明**

- [x] [大牛直播Windows RTMP推流端使用说明](http://daniulive.com/index.php/2018/04/15/%E5%A4%A7%E7%89%9B%E7%9B%B4%E6%92%ADsdk-windows%E6%8E%A8%E9%80%81%E7%AB%AF%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E/)

- [x] [大牛直播SDK-Windows RTMP/RTSP/本地FLV播放器使用说明](http://daniulive.com/index.php/2018/04/16/%E5%A4%A7%E7%89%9B%E7%9B%B4%E6%92%ADsdk-windows-rtmp-rtsp-%E6%9C%AC%E5%9C%B0flv%E6%92%AD%E6%94%BE%E5%99%A8%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E/)

- [x] [大牛直播跨平台多路RTSP/RTMP转RTMP推送SDK](http://daniulive.com/index.php/2018/04/04/%E5%A4%9A%E8%B7%AF%E6%B5%81%E5%AA%92%E4%BD%93%E8%BD%AC%E5%8F%91sdk/)

- [x] [大牛直播Android推流端使用说明](https://github.com/daniulive/SmarterStreaming/wiki/%E5%A4%A7%E7%89%9B%E7%9B%B4%E6%92%ADAndroid%E6%8E%A8%E6%B5%81%E7%AB%AF%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E)

- [x] [大牛直播Android后台推送摄像头、屏幕数据使用说明](https://github.com/daniulive/SmarterStreaming/wiki/%E5%A4%A7%E7%89%9B%E7%9B%B4%E6%92%ADAndroid%E5%90%8E%E5%8F%B0%E6%8E%A8%E9%80%81%E6%91%84%E5%83%8F%E5%A4%B4-%E5%B1%8F%E5%B9%95%E6%95%B0%E6%8D%AE%5D%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E)

- [x] [大牛直播Android播放器使用说明](https://github.com/daniulive/SmarterStreaming/wiki/%E5%A4%A7%E7%89%9B%E7%9B%B4%E6%92%ADAndroid%E6%92%AD%E6%94%BE%E5%99%A8%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E)

- [x] [大牛直播iOS推流端使用说明](https://github.com/daniulive/SmarterStreaming/wiki/%E5%A4%A7%E7%89%9B%E7%9B%B4%E6%92%ADiOS%E6%8E%A8%E6%B5%81%E7%AB%AF%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E)

- [x] [大牛直播 iOS端边推流边录像使用说明](https://github.com/daniulive/SmarterStreaming/wiki/%E5%A4%A7%E7%89%9B%E7%9B%B4%E6%92%AD-iOS%E7%AB%AF%E8%BE%B9%E6%8E%A8%E6%B5%81%E8%BE%B9%E5%BD%95%E5%83%8F%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E)

- [x] [大牛直播iOS推流端使用说明](https://github.com/daniulive/SmarterStreaming/wiki/%E5%A4%A7%E7%89%9B%E7%9B%B4%E6%92%ADiOS%E6%8E%A8%E6%B5%81%E7%AB%AF%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E)

- [x] [大牛直播iOS播放器使用说明](https://github.com/daniulive/SmarterStreaming/wiki/%E5%A4%A7%E7%89%9B%E7%9B%B4%E6%92%ADiOS%E6%92%AD%E6%94%BE%E5%99%A8%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E)

- [x] [大牛直播连麦使用说明(windows windows或windows与android/iOS)](https://github.com/daniulive/SmarterStreaming/wiki/%E5%A4%A7%E7%89%9B%E7%9B%B4%E6%92%AD%E8%BF%9E%E9%BA%A6%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E(windows-windows%E6%88%96windows%E4%B8%8Eandroid))

## 上层源码目录 ##

1. android推流 SmartPublisherV2
https://github.com/daniulive/SmarterStreaming/tree/master/SourceCode/AndroidStudio/SmartPublisherV2

2. android推流 SmartServicePublisherV2(后台service推送屏幕)
https://github.com/daniulive/SmarterStreaming/tree/master/SourceCode/AndroidStudio/SmartServicePublisherV2

3. android推流 SmartServiceCameraPublisherV2(后台service推送摄像头)
https://github.com/daniulive/SmarterStreaming/tree/master/SourceCode/AndroidStudio/SmartServiceCameraPublisherV2

4. android一对一回音消除 SmartEchoCancellationV2
https://github.com/daniulive/SmarterStreaming/tree/master/SourceCode/AndroidStudio/SmartEchoCancellationV2

5. android播放器 SmartPlayerV2:
https://github.com/daniulive/SmarterStreaming/tree/master/SourceCode/AndroidStudio/SmartPlayerV2

6. android转发-录像-播放三合一 SmartRelayDemoV2:
https://github.com/daniulive/SmarterStreaming/tree/master/SourceCode/AndroidStudio/SmartRelayDemoV2

7. iOS推流 SmartiOSPublisherV2:
https://github.com/daniulive/SmarterStreaming/tree/master/SourceCode/IOS/SmartiOSPublisherV2

8. iOS后台推屏 SmartiOSScreenPublisherV2:
https://github.com/daniulive/SmarterStreaming/tree/master/SourceCode/IOS/SmartiOSScreenPublisherV2

9. iOS播放器 SmartiOSPlayerV2:
https://github.com/daniulive/SmarterStreaming/tree/master/SourceCode/IOS/SmartiOSPlayerV2

10. iOS转发-录像-播放三合一 SmartiOSRelayDemoV2:
https://github.com/daniulive/SmarterStreaming/tree/master/SourceCode/IOS/SmartiOSRelayDemoV2


## 功能支持 ##
---
**1. Windows视频采集处理SDK**

1. 支持视频源
- [x] 支持Windows屏幕采集、**屏幕裁剪**、**特定窗口采集**、摄像头采集、扩展外部H.264数据对接；
2. 摄像头和屏幕合成
- [x] [摄像头和屏幕实时切换]支持推送过程中，摄像头和屏幕互相切换，单画面显示摄像头或屏幕；
- [x] [摄像头叠加到屏幕] 支持摄像头按照设置坐标，叠加到屏幕指定位置，并支持实时关闭叠加层；
- [x] [屏幕叠加到摄像头] 支持屏幕按照设定坐标，叠加到摄像头指定位置，并支持实时关闭叠加层；
3. 水印和透明度遮挡
- [x] [实时水印]支持**动态水印**设置，完美支持`文字水印、实时时间水印和图片水印`；
- [x] [透明度]可以设置透明度处理（设置遮盖）；
4. 对应Demo：
- [x] 测试程序：SmartPublisherDemo.exe；
- [x] C++工程：WIN-PublisherSDK-CPP-Demo；
- [x] C#工程：WIN-PublisherSDK-CSharp-Demo。
---

**2. Windows音频采集处理SDK**

1. 支持音频源
- [x] 支持Windows采集**麦克风**、**扬声器**和外部AAC, Speex WB, PCMA, PCMU数据接口输入；
2. 音频合成
- [x] [音频]支持扬声器和麦克风音频**混音输出**(同时选择“采集扬声器”和“采集麦克风”)；
3. 音频处理
- [x] 支持音频“端点检测（VAD）”，自适应码流，音频码流更节省；
- [x] 支持回音消除功能；
- [x] 支持噪音抑制功能；
- [x] 支持自动增益控制。
4. 对应Demo：
- [x] 测试程序：SmartPublisherDemo.exe；
- [x] C++工程：WIN-PublisherSDK-CPP-Demo；
- [x] C#工程：WIN-PublisherSDK-CSharp-Demo。
---

**3. Windows/Android/iOS RTMP直播推流SDK**

- [x] **Windows RTMP直播推流SDK涵盖“Windows视频采集处理SDK”功能**；
- [x] **Windows RTMP直播推流SDK涵盖“Windows音频采集处理SDK”功能**；
- [x] Windows RTMP直播推流SDK支持摄像头/屏幕/合成数据**实时预览**功能；
- [x] Windows/Android/iOS平台支持多分辨率、帧率、码率、gop间隔、编码profile和编码速度设置；
- [x] Android/iOS平台支持横竖屏推送；
- [x] Windows/Android/iOS平台`音视频`推送、`纯音频`推送、`纯视频`推送；
- [x] Android/iOS平台支持rtmp推送 live|record模式设置；
- [x] [录像SDK同步使用]Windows/Android/iOS平台真正靠谱的录像、推流分离模式，**支持推流过程中随时开启录像，录像过程中，随时推流；**
- [x] Android/iOS平台支持本地录像文件回放；
- [x] Android/iOS平台支持采集过程中，前后摄像头切换；
- [x] Windows/Android/iOS平台提供编码前(YUV/RGB)、编码后音视频(H.264/AAC/PCMA/PCMU)接口对接，方便AR/VR设备调用；
- [x] Windows平台外部PCM音频数据对接接口；
- [x] Android平台支持**输出编码后的H264数据到上层**，方便对接第三方平台(如GB28181)对接；
- [x] iOS平台自带基础美颜功能；
- [x] Android平台完美支持`文字水印、实时时间水印和图片水印`；
- [x] Windows/Android/iOS平台支持`推送端实时静音/取消静音`；
- [x] Android/iOS平台支持软、硬编码自适应；
- [x] Android平台支持后台service推送摄像头或屏幕(推送屏幕需要5.0+版本)；
- [x] iOS平台支持后台推送屏幕(基于ReplayKit，需要iOS 10.0+版本)；
- [x] android支持实时传递远端PCM数据，方便回音消除处理；
- [x] Windows/Android/iOS平台支持推送端镜像设置；
- [x] Windows平台支持摄像头水平反转、垂直反转、0°/90°/180°/270°旋转；
- [x] Windows/Android平台支持噪音抑制功能；
- [x] Windows/Android平台支持自动增益控制；
- [x] Windows/Android平台支持Speex推送、Speex编码质量设置；
- [x] Windows/Android/iOS平台支持推送或录像过程中，**随时快照**;
- [x] Windows/Android/iOS平台支持裁剪模式设置；
- [x] Windows/Android/iOS平台支持**多实例推送**；
- [x] Windows/Android/iOS平台直播推流SDK支持支持自建服务器(如Nginx、SRS)或CDN。

对应Demo：
- [x] Windows测试程序：SmartPublisherDemo.exe；
- [x] Windows C++工程：WIN-PublisherSDK-CPP-Demo；
- [x] Windows C#工程：WIN-PublisherSDK-CSharp-Demo；
- [x] Android工程：SmartPublisherV2；
- [x] iOS工程：SmartiOSPublisherV2。
---

**4. Windows/Android/iOS RTMP、RTSP直播播放器SDK**

- [x] Windows/Android/iOS平台高稳定、超低延迟的跨平台RTMP直播播放器；
- [x] Windows/Android/iOS平台高稳定、超低延迟的跨平台RTSP直播播放器；
- [x] Windows/Android/iOS平台完美支持**多实例**播放（如同时播放多路rtmp/rtsp流）；
- [x] Windows/Android/iOS平台支持**rtmp扩展H.265**播放；
- [x] Windows/Android/iOS平台支持RTSP TCP/UDP模式设置；
- [x] Windows/Android/iOS平台支持**RTSP TCP、UDP模式自动切换**；
- [x] Windows/Android/iOS平台支持rtsp超时时间设置；
- [x] Windows/Android/iOS平台支持上报rtsp 401事件；
- [x] Windows/Android/iOS平台支持buffer time设置；
- [x] Windows/Android/iOS平台支持**首屏秒开**模式；
- [x] Windows平台双击画面进入**全屏**模式；
- [x] Windows/Android/iOS平台视频支持H.264(RTMP/RTSP)/H.265(RTSP)，音频支持AAC/PCMA/PCMU和SPEEX(RTMP)播放；
- [x] Windows/Android/iOS平台支持**RTSP H.265**播放，并支持**RTSP H.265录制到MP4文件**；
- [x] Windows/Android/iOS平台均支持回调音视频数据(视频: H.264/YUV 音频：AAC/PCMA/PCMU/SPEEX)到上层；
- [x] Windows/Android/iOS平台支持自定义播放布局；
- [x] Android平台音视频多种render机制，视频支持普通Surface和GLSurface，音频支持audiotrack和opensl es；
- [x] Windows/Android/iOS平台支持播放过程中，'实时静音/取消静音';
- [x] Windows/Android/iOS平台支持播放端视频view实时旋转(0° 90° 180° 270°)、水平反转、垂直反转；
- [x] Windows/Android/iOS平台支持播放过程中快速切换URL；
- [x] [录像SDK同步使用]Windows/Android/iOS平台播放、录像完全隔离，同等配置的流，切换url依旧可以录制到同一个文件；
- [x] Windows/Android/iOS平台播放过程中，音视频信息改变后自适应；
- [x] Android/iOS平台支持软、硬解码，超低延迟、低资源占用播放rtsp/rtmp 1080p+；
- [x] Windows/Android/iOS平台支持播放/录像过程中，**随时快照**；
- [x] [Windows点播播放器]支持本地flv文件播放(支持获取flv文件的duration(时长)；支持显示当前播放位置；支持开始播放或播放过程中seek(跳转播放位置)，也许是行业内seek最快的flv点播播放器)；
- [x] Windows/Android/iOS平台支持类似于线上娃娃机等直播方案的超低延迟模式设置(公网200~400ms)。

对应Demo：
- [x] Windows测试程序：SmartPlayer.exe；
- [x] Windows C++工程：WIN-PlayerSDK-CPP-Demo；
- [x] Windows C#工程：WIN-PlayerSDK-CSharp-Demo；
- [x] Android工程：SmartPlayerV2；
- [x] iOS工程：SmartiOSPlayerV2。
---

**5. Windows/Android/iOS内置轻量级RTSP服务SDK**

- [x] 支持Windows/Android/iOS平台RTMP直播SDK除推送RTMP外的所有常规功能；
- [x] 音频编码：AAC；
- [x] 视频编码：H.264；
- [x] 内置服务协议：RTSP；
- [x] 支持RTSP端口设置；
- [x] 支持RTSP鉴权用户名、密码设置；
- [x] 支持获取当前RTSP服务会话连接数；
- [x] 支持同时创建多个内置RTSP服务。

对应Demo：
- [x] Windows测试程序：SmartPublisherDemo.exe；
- [x] Windows C++工程：WIN-PublisherSDK-CPP-Demo；
- [x] Windows C#工程：WIN-PublisherSDK-CSharp-Demo；
- [x] Android工程：SmartPublisherV2；
- [x] iOS工程：SmartiOSPublisherV2。
---

**6. Windows/Android/iOS转发SDK**

- [x] [拉流]支持拉取RTSP流；
- [x] [拉流]支持拉取RTMP流；
- [x] [预览]支持拉取到的RTMP/RTSP随时本地预览、关闭预览；
- [x] [拉流音频调节]支持拉取的RTMP/RTSP流静音；
- [x] [拉流音频转码]支持拉取的RTMP/RTSP的PCMA/PCMU/SPEEX音频格式**转AAC**后再转发到RTMP服务器；
- [x] [url切换]**支持转发过程中，拉取的RTMP/RTSP或本地FLV文件实时内容切换**；
- [x] [转发]超低延迟转发拉取的rtsp/rtmp流到rtmp server；
- [x] [HEVC]业内为数不多**支持RTSP/RTMP H.265转RTMP推送**的SDK(提供配套RTMP扩展H.265服务器)；

对应Demo：
- [x] Windows测试程序：SmartStreamRelayDemo.exe；
- [x] Windows C++工程：WIN-RelaySDK-CPP-Demo；
- [x] Windows C#工程：WIN-RelaySDK-CSharp-Demo；
- [x] Android工程：SmartRelayDemoV2；
- [x] iOS工程：SmartiOSRelayDemoV2。
---

**7. Windows导播SDK**

- [x] 支持拉取RTSP流；
- [x] 支持拉取RTMP流；
- [x] 支持本地采集到屏幕或摄像头数据，和远程拉取得RTSP或RTMP流做合成、混音输出；
- [x] 支持导播过程中，随时切断某一路音视频或音频；
- [x] 支持音频混音（同时选择“采集麦克风”+“采集扬声器”）。

对应Demo：
- [x] 测试程序：SmartMixStreamDemo.exe；
- [x] C++工程：WIN-MixStreamSDK-CPP-Demo；
---

**8. Windows/Android/iOS录像SDK**

- [x] 支持拉取RTSP流录像；
- [x] 支持拉取RTMP流录像；
- [x] 支持推送端同步录像；
- [x] 支持设置单个录像文件大小、录像路径等；
- [x] 支持音频(PCMU/PCMA,Speex等)转AAC后再录像；
- [x] 支持**RTSP H.265**录制到MP4文件；
- [x] 从开始录像，到录像结束均有event callback上来，网络堵塞、音视频同步均做了非常友好的处理。

对应Demo：
- [x] Windows测试程序：SmartPlayer.exe；
- [x] Windows C++工程：WIN-PlayerSDK-CPP-Demo；
- [x] Windows C#工程：WIN-PlayerSDK-CSharp-Demo；
- [x] 测试程序：SmartPublisherDemo.exe；
- [x] C++工程：WIN-PublisherSDK-CPP-Demo；
- [x] C#工程：WIN-PublisherSDK-CSharp-Demo。
- [x] Android工程：SmartPlayerV2；
- [x] iOS工程：SmartiOSPlayerV2；
- [x] Android工程：SmartPublisherV2；
- [x] iOS工程：SmartiOSPublisherV2。
---

## 编译注意事项 ##

* 编译时找不到 libSmartPlayerSDK.a 时，请先到 SmartiOSPlayer/SmartiOSPlayer/libs 目录, 解压libSmartPlayerSDK.zip.
* 编译时找不到 libSmartPublisherSDK.a 时，请先到 SmartiOSPublisher/SmartiOSPublisher/libs 目录, 解压libSmartPublisherSDK.zip.
* 未授权版本，限制app-name，如果需要集成到自己工程里面调试，可以用以下名字：
 ```
android推送端：SmartPublisherSDKDemo
android后台Service推送：SmartServicePublisherSDKDemo
android一对一互动：SmartEchoCancellation
android播放器：SmartPlayerSDKDemo
iOS推送端：SmartiOSPublisher
iOS转发端：SmartiOSRelayDemo
iOS播放器：SmartiOSPlayer
 ```
* 集成到自己工程，如何改名字（以推送端为例）：

 ```
android：strings.xml：
<string name="app_name">SmartPublisherSDKDemo</string>
 ```

 ```
 iOS：Info.plist-->右键Open As-->Source Code，添加或者编辑
 <key>CFBundleName</key>	
 <string>SmartiOSPublisher</string>
 ```

## 联系我们 ##

[点击查看联系方式](http://daniulive.com/index.php/%E8%81%94%E7%B3%BB/)

**QQ交流群：**

大牛直播SDK技术交流群1：[499687479](http:////shang.qq.com/wpa/qunwpa?idkey=e7686f68a39bf1b95dc2ac3b775867efc7d3cbaf3596daf6e12bc1df21e1dc59)

大牛直播SDK技术交流群2：[294891451](http://shang.qq.com/wpa/qunwpa?idkey=476a9cc05db0b2924530ccbbf4fae78fa485d39418ef79c8ab71b24a8fee8a48)
