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
    
    NSLog(@"[DaniuliveExtSetupUI]userDidFinishSetup..");
}

- (void)userDidCancelSetup {
    // Tell ReplayKit that the extension was
    // cancelled by the user
    NSLog(@"[DaniuliveExtSetupUI]userDidCancelSetup..");
    
    NSError * err = [NSError errorWithDomain:@"com.daniulive.ios"
                                        code:-1
                                    userInfo:nil];
    [self.extensionContext cancelRequestWithError:err];
}

@end
