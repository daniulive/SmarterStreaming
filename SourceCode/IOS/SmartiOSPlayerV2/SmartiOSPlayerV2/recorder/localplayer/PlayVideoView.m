//
//  PlayVideoView.m
//  SmartPublisherSDK
//
//  GitHub: https://github.com/daniulive/SmarterStreaming
//  website: http://www.daniulive.com
//
//  Created by daniulive on 16/3/24.
//  Copyright © 2015~2017 daniulive. All rights reserved.
//

#import "PlayVideoView.h"
@implementation PlayVideoView

+(Class)layerClass{
    return [AVPlayerLayer class];
}
- (AVPlayer*)player {
    return [(AVPlayerLayer *)[self layer] player];
}
- (void)setPlayer:(AVPlayer *)player {
    [(AVPlayerLayer *)[self layer] setPlayer:player];
}
- (AVPlayerLayer *)playerLayer{
    return (AVPlayerLayer *)self.layer;
}
@end
