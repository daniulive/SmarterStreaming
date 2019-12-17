//
//  SampleHandler.m
//  DaniuliveExt
//
//  Created by ni on 2018/3/26.
//  Copyright © 2018年 daniulive. All rights reserved.
//

#import "SampleHandler.h"
#import <VideoToolbox/VideoToolbox.h>
#import "mach/mach.h"

#import "SmartPublisherSDK.h"
#import "nt_event_define.h"

static BOOL s_headPhoneIn;
typedef enum : NSUInteger {
    Mic_Unknown,
    Mic_Enable,
    Mic_Disable,
} MicState;
static MicState s_isMicEnable;

NSString *publisher_url_;

BOOL is_pushing_rtmp_ = NO;

SmartPublisherSDK *_smart_publisher_sdk;      //推流SDK API

@interface SampleHandler()<SmartPublisherDelegate>
@end

//  To handle samples with a subclass of RPBroadcastSampleHandler set the following in the extension's Info.plist file:
//  - RPBroadcastProcessMode should be set to RPBroadcastProcessModeSampleBuffer
//  - NSExtensionPrincipalClass should be set to this class

@implementation SampleHandler{
}

#pragma mark - RPBroadcastSampleHandler

- (instancetype) init {
    self = [super init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(routeChanged:)
                                                 name:AVAudioSessionRouteChangeNotification
                                               object:nil];
    
    return self;
}

- (void)dealloc {
    NSLog(@"[SampleHandler]dealloc....");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)routeChanged:(NSNotification *)notification {
    NSInteger routeChangeReason = [notification.userInfo[AVAudioSessionRouteChangeReasonKey] integerValue];
    if (routeChangeReason == AVAudioSessionRouteChangeReasonOldDeviceUnavailable) {
        s_headPhoneIn = NO;
    }
    if (routeChangeReason == AVAudioSessionRouteChangeReasonNewDeviceAvailable) {
        s_headPhoneIn = YES;
    }
}

- (void)checkHeadphone {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    for (AVAudioSessionPortDescription *dp in session.currentRoute.outputs) {
        if ([dp.portType isEqualToString:AVAudioSessionPortHeadphones]) {
            s_headPhoneIn = YES;
            return;
        }
    }
    s_headPhoneIn = NO;
    s_isMicEnable = Mic_Unknown;
}

- (void)broadcastStartedWithSetupInfo:(NSDictionary<NSString *,NSObject *> *)setupInfo {
    // User has requested to start the broadcast. Setup info from the UI extension will be supplied.
    NSLog(@"[SampleHandler]broadcastStartedWithSetupInfo++");

    //默认设定个推送url 也可以通过上述代码读取UI层设定的
    publisher_url_ = @"rtmp://player.daniulive.com:1935/hls/stream2";;
    
    [self checkHeadphone];
    
    if([self InitPublisher])
    {
        [self StartPublisher];
    }
    
    NSLog(@"[SampleHandler]broadcastStartedWithSetupInfo--");
}

- (void)broadcastPaused {
    NSLog(@"[SampleHandler]broadcastPaused....");
}

- (void)broadcastResumed {
    NSLog(@"[SampleHandler]broadcastResumed....");
}

- (void)broadcastFinished {
    NSLog(@"[SampleHandler]broadcastFinished....");
    
    if([self StopPublisher])
    {
        [self UnInitPublisher];
    }
}

- (void)finishBroadcastWithError:(NSError *)error
{
    NSLog(@"[SampleHandler]finishBroadcastWithError....");
    
    if([self StopPublisher])
    {
        [self UnInitPublisher];
    }
}

- (CGFloat)GetCurUsedMemoryInMB{
    vm_size_t memory = GetCurUsedMemory();
    return memory / 1024.0 / 1024.0;
}

vm_size_t GetCurUsedMemory(void)
{
    task_vm_info_data_t vmInfo;
    mach_msg_type_number_t count = TASK_VM_INFO_COUNT;
    if(task_info(mach_task_self(), TASK_VM_INFO, (task_info_t) &vmInfo, &count) != KERN_SUCCESS) {
        return 0;
    }
    return (double)vmInfo.phys_footprint;
}

- (void)processSampleBuffer:(CMSampleBufferRef)sampleBuffer
                   withType:(RPSampleBufferType)sampleBufferType {
    
    CGFloat cur_memory = [self GetCurUsedMemoryInMB];
    
    if( cur_memory > 20.0f)
    {
        //NSLog(@"processSampleBuffer cur: %.2fM", cur_memory);
        return;
    }
        
    switch (sampleBufferType) {
        case RPSampleBufferTypeVideo:
            {
                if (!CMSampleBufferIsValid(sampleBuffer))
                    return;
                
                NSInteger rotation_degress = 0;
                //11.1以上支持自动旋转
    #ifdef __IPHONE_11_1
                if (UIDevice.currentDevice.systemVersion.floatValue > 11.1) {
                    CGImagePropertyOrientation orientation = ((__bridge NSNumber*)CMGetAttachment(sampleBuffer, (__bridge CFStringRef)RPVideoSampleOrientationKey , NULL)).unsignedIntValue;
                    
                    //NSLog(@"cur org: %d", orientation);
                    
                    switch (orientation)
                    {
                        //竖屏
                        case kCGImagePropertyOrientationUp:{
                            rotation_degress = 0;
                        }
                            break;
                        case kCGImagePropertyOrientationDown:{
                            rotation_degress = 180;
                            break;
                        }
                        case kCGImagePropertyOrientationLeft: {
                            //静音键那边向上 所需转90度
                            rotation_degress = 90;
                        }
                            break;
                        case kCGImagePropertyOrientationRight:{
                            //关机键那边向上 所需转270
                            rotation_degress = 270;
                        }
                            break;
                        default:
                            break;
                    }
                }
    #endif
                
                //NSLog(@"RPSampleBufferTypeVideo");
                if(_smart_publisher_sdk)
                {
                    //[_smart_publisher_sdk SmartPublisherPostVideoSampleBuffer:sampleBuffer];
                    [_smart_publisher_sdk SmartPublisherPostVideoSampleBufferV2:sampleBuffer rotateDegress:rotation_degress];
                }
                
                //NSLog(@"video ts:%.2f", CMTimeGetSeconds(CMSampleBufferGetPresentationTimeStamp(sampleBuffer)));
            }
            break;
        case RPSampleBufferTypeAudioApp:
            //NSLog(@"RPSampleBufferTypeAudioApp");
            if (CMSampleBufferDataIsReady(sampleBuffer) != NO)
            {
                if(_smart_publisher_sdk)
                {
                    NSInteger type = 2;
                    [_smart_publisher_sdk SmartPublisherPostAudioSampleBuffer:sampleBuffer inputType:type];
                }
            }
            //NSLog(@"App ts:%.2f", CMTimeGetSeconds(CMSampleBufferGetPresentationTimeStamp(sampleBuffer)));
            
            break;
        case RPSampleBufferTypeAudioMic:
            //NSLog(@"RPSampleBufferTypeAudioMic");
            if(_smart_publisher_sdk)
            {
                NSInteger type = 1;
                [_smart_publisher_sdk SmartPublisherPostAudioSampleBuffer:sampleBuffer inputType:type];
            }
            //NSLog(@"Mic ts:%.2f", CMTimeGetSeconds(CMSampleBufferGetPresentationTimeStamp(sampleBuffer)));
            
            break;
        default:
            break;
    }
}

//推送端接口封装
-(bool)InitPublisher
{
    NSLog(@"InitPublisher++");
    
    if(is_pushing_rtmp_)
    {
        NSLog(@"InitPublisher, has already started rtmp pusher..");
        return false;
    }
    
    if(_smart_publisher_sdk != nil)
    {
        NSLog(@"InitPublisher, publisher() has inited before..");
        return true;
    }
    
    _smart_publisher_sdk = [[SmartPublisherSDK alloc] init];
    
    if (_smart_publisher_sdk == nil )
    {
        NSLog(@"_smart_publisher_sdk with nil..");
        return false;
    }
    
    if(_smart_publisher_sdk.delegate == nil)
    {
        _smart_publisher_sdk.delegate = self;
    }
    
    NSInteger audio_opt = 0;    //默认不推音频
    NSInteger video_opt = 3;
    
    if([_smart_publisher_sdk SmartPublisherInit:audio_opt video_opt:video_opt] != DANIULIVE_RETURN_OK)
    {
        NSLog(@"Call SmartPublisherInit failed..");
        
        _smart_publisher_sdk = nil;
        return false;
    }
    
    NSLog(@"InitPublisher--");
    return true;
}

-(bool)StartPublisher
{
    NSLog(@"StartPublisher++");
    
    if ( _smart_publisher_sdk == nil )
    {
        NSLog(@"StartPublisher, publiher SDK with nil");
        return false;
    }
    
    [_smart_publisher_sdk SmartPublisherSetFPS:20];
    
    [_smart_publisher_sdk SmartPublisherSetVideoBitRate:1200 maxBitRate:2400];
    
    [_smart_publisher_sdk SmartPublisherSetGopInterval:60];
    
    CGFloat scale_rate = 0.6;
    [_smart_publisher_sdk SmartPublisherSetVideoSizeScaleRate:scale_rate];
    
    NSInteger encoderType = 1;
    Boolean isHwEncoder = YES;
    [_smart_publisher_sdk SmartPublisherSetVideoEncoderType:encoderType isHwEncoder:isHwEncoder];
    
    NSInteger run_mode = 1;
    [_smart_publisher_sdk SmartPublisherSetSDKRunMode:run_mode];
    
    NSInteger ret = [_smart_publisher_sdk SmartPublisherStartPublisher:publisher_url_];
    
    if(ret != DANIULIVE_RETURN_OK)
    {
        NSLog(@"Call SmartPublisherStartPublisher failed..ret:%ld", (long)ret);
        return false;
    }
    
    is_pushing_rtmp_ = YES;
    
    NSLog(@"StartPublisher--");
    return true;
}

-(bool)StopPublisher
{
    NSLog(@"StopPublisher++");
    
    if(!is_pushing_rtmp_)
    {
        NSLog(@"StopPublisher, not started..");
        return false;
    }
    
    if ( _smart_publisher_sdk == nil )
    {
        NSLog(@"StopPublisher, publiher SDK with nil");
        return false;
    }
    
    [_smart_publisher_sdk SmartPublisherStopPublisher];
    
    NSLog(@"StopPublisher--");
    return true;
}

-(bool)UnInitPublisher
{
    NSLog(@"UnInitPublisher++");
    if (_smart_publisher_sdk != nil)
    {
        [_smart_publisher_sdk SmartPublisherUnInit];
        _smart_publisher_sdk.delegate = nil;
        _smart_publisher_sdk = nil;
    }
    
    is_pushing_rtmp_ = NO;
    
    NSLog(@"UnInitPublisher--");
    return true;
}

- (NSInteger) handleSmartPublisherEvent:(NSInteger)nID param1:(unsigned long long)param1 param2:(unsigned long long)param2 param3:(NSString*)param3 param4:(NSString*)param4 pObj:(void *)pObj;
{
    if (nID == EVENT_DANIULIVE_ERC_PUBLISHER_STARTED) {
        NSLog(@"[event]开始推流..");
    }
    else if (nID == EVENT_DANIULIVE_ERC_PUBLISHER_CONNECTING)
    {
        NSLog(@"[event]连接中..");
    }
    else if (nID == EVENT_DANIULIVE_ERC_PUBLISHER_CONNECTION_FAILED)
    {
        NSLog(@"[event]连接失败..");
    }
    else if (nID == EVENT_DANIULIVE_ERC_PUBLISHER_CONNECTED)
    {
        NSLog(@"[event]已连接..");
    }
    else if (nID == EVENT_DANIULIVE_ERC_PUBLISHER_DISCONNECTED)
    {
        NSLog(@"[event]断开连接..");
    }
    else if (nID == EVENT_DANIULIVE_ERC_PUBLISHER_STOP)
    {
        NSLog(@"[event]停止推流..");
    }
    else if (nID == EVENT_DANIULIVE_ERC_PUBLISHER_RECORDER_START_NEW_FILE)
    {
        NSLog(@"[event]录像写入新文件..文件名: %@", param3);
    }
    else if (nID == EVENT_DANIULIVE_ERC_PUBLISHER_ONE_RECORDER_FILE_FINISHED)
    {
        NSLog(@"[event]一个录像文件完成..文件名: %@", param3);
    }
    else if (nID == EVENT_DANIULIVE_ERC_PUBLISHER_CAPTURE_IMAGE)
    {
        NSLog(@"[event]推送快照..");
    }
    else
        NSLog(@"[event]nID:%lx", (long)nID);
    
    return 0;
}

@end

