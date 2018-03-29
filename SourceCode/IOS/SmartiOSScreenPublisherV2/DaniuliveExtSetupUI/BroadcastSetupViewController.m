//
//  BroadcastSetupViewController.m
//  DaniuliveExtSetupUI
//
//  Created by ni on 2018/3/26.
//  Copyright © 2018年 daniulive. All rights reserved.
//

#import "BroadcastSetupViewController.h"

@implementation BroadcastSetupViewController

- (void)viewDidLoad {
    _rtmpUrl.text = @"rtmp://player.daniulive.com:1935/hls/stream2";
}

- (IBAction)OnStartBtn:(id)sender {
    [self userDidFinishSetup];
}
- (IBAction)OnStopBtn:(id)sender {
    [self userDidCancelSetup];
}

// Called when the user has finished interacting with the view controller and a broadcast stream can start
- (void)userDidFinishSetup {
    // Broadcast url that will be returned to the application
    NSURL *broadcastURL = [NSURL URLWithString: _rtmpUrl.text];
    // Service specific broadcast data example which will be supplied to the process extension during broadcast
    NSString *endpointURL = _rtmpUrl.text;
    
    NSDictionary *setupInfo = @{@"endpointURL" : endpointURL};
    
    // Set broadcast settings
    RPBroadcastConfiguration *broadcastConfig = [[RPBroadcastConfiguration alloc] init];
    // Tell ReplayKit that the extension is finished setting up and can begin broadcasting
    [self.extensionContext completeRequestWithBroadcastURL:broadcastURL broadcastConfiguration:broadcastConfig setupInfo:setupInfo];
}

- (void)userDidCancelSetup {
    // Tell ReplayKit that the extension was
    // cancelled by the user
    NSError * err = [NSError errorWithDomain:@"com.daniulive.ios"
                                        code:-1
                                    userInfo:nil];
    [self.extensionContext cancelRequestWithError:err];
}

@end
