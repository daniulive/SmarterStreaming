//
//  RecorderView.m
//  SmartPublisherSDK
//
//  GitHub: https://github.com/daniulive/SmarterStreaming
//  website: https://www.daniulive.com
//
//  Created by daniulive on 16/3/24.
//  Copyright © 2014~2019 daniulive. All rights reserved.
//

#import "RecorderView.h"
#import "PlayVideoView.h"
#import "ConvertTime.h"
#import "ViewController.h"

@interface RecorderView ()
{
    PlayVideoView   *player_view_;
    UIProgressView  *progressView;      //进度条
    
    UIButton        *deleteButton;
    UIButton        *playPauseButton;
    UIButton        *selButton;
    UIButton        *retButton;         //返回按钮
    
    UILabel         *currentTimeLabel;
    UILabel         *totalTimeLabel;
    
    CGFloat         screenWidth;
    CGFloat         screenHeight;
    
    NSString        *dirBasePath;       //document路径
    UIPickerView    *mypickerView;
    NSMutableArray  *dirArray;
    
    NSObject        *timeObserver;
}

@end

@implementation RecorderView


#pragma mark - Init
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - release
- (void)dealloc {
    NSLog(@"Run into RecorderView dealloc..");
    [self viewWillDisappear];
    [self removeVideoTimerObserver];
}

- (void)loadView
{
    // If you create your views manually, you MUST override this method and use it to create your views.
    // If you use Interface Builder to create your views, then you must NOT override this method.
    
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    self.view.backgroundColor = [UIColor whiteColor];
    
    //当前屏幕宽高
    screenWidth  = CGRectGetWidth([UIScreen mainScreen].bounds);
    screenHeight  = CGRectGetHeight([UIScreen mainScreen].bounds);
    
    player_view_ = [[PlayVideoView alloc]initWithFrame:CGRectMake(0, 30, screenWidth, screenHeight/2)];
    
    [self.view addSubview:player_view_];
    
    currentTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, screenHeight/2 + 60, 50, 15)];
    
    if(progressView == nil){
        progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(70, screenHeight/2 + 65, screenWidth - 140, 15)];
    }
    
    totalTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth - 70, screenHeight/2 + 60, 50, 15)];

    [self.view addSubview:progressView];
    
    [self.view addSubview:currentTimeLabel];
    
    [self.view addSubview:totalTimeLabel];
    
    dirArray = [[NSMutableArray alloc]init];
    
    mypickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0f, screenHeight/2 + 100, screenWidth,screenHeight/2 - 100)];
    mypickerView.delegate = self;  //指定Delegate
    mypickerView.showsSelectionIndicator = YES; //显示选中框
    
    [self.view addSubview:mypickerView];
    
    deleteButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [deleteButton addTarget:self action:@selector(deleteButton:) forControlEvents:UIControlEventTouchUpInside];
    [deleteButton setFrame:CGRectMake(20, screenHeight - 50, 100, 50)];
    [deleteButton setTitle:@"删除全部文件" forState:UIControlStateNormal];
    deleteButton.backgroundColor = [UIColor clearColor];
    [self.view addSubview:deleteButton];
    
    playPauseButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [playPauseButton addTarget:self action:@selector(playPauseButton:) forControlEvents:UIControlEventTouchUpInside];
    [playPauseButton setFrame:CGRectMake(screenWidth/2 - 50, screenHeight - 50, 50, 50)];
    [playPauseButton setTitle:@"暂停" forState:UIControlStateNormal];
    playPauseButton.backgroundColor = [UIColor clearColor];
    [self.view addSubview:playPauseButton];
    
    selButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [selButton addTarget:self action:@selector(selectButton:) forControlEvents:UIControlEventTouchUpInside];
    [selButton setFrame:CGRectMake(screenWidth/2 + 20, screenHeight - 50, 50, 50)];
    [selButton setTitle:@"回放" forState:UIControlStateNormal];
    selButton.backgroundColor = [UIColor clearColor];
    [self.view addSubview:selButton];
    
    retButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [retButton addTarget:self action:@selector(retButton:) forControlEvents:UIControlEventTouchUpInside];
    [retButton setFrame:CGRectMake(screenWidth - 50, screenHeight - 50, 50, 50)];
    [retButton setTitle:@"返回" forState:UIControlStateNormal];
    retButton.backgroundColor = [UIColor clearColor];
    [self.view addSubview:retButton];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *dirPath =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    dirBasePath = [dirPath objectAtIndex:0]; //获得Document系统文件目录路径
    
    NSDirectoryEnumerator *direnum = [fileManager enumeratorAtPath:dirBasePath ]; //遍历目录
    
    NSMutableArray *files = [NSMutableArray arrayWithCapacity:20];
    files = [[NSMutableArray alloc] init];
    NSString *fileName;
    
    while((fileName = [direnum nextObject]))
    {
        if([[fileName pathExtension] isEqualToString:@"mp4"])
        {  //遍历条件
            [files addObject:fileName];

            [dirArray addObject:[[NSURL URLWithString:fileName] absoluteString]];
            
            NSLog(@"dirArray: %@", dirArray);
            
        }  
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)deleteButton:(id)sender
{
    NSString *extension = @"mp4";
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:documentsDirectory error:NULL];
    NSEnumerator *e = [contents objectEnumerator];
    NSString *filename;
    while ((filename = [e nextObject]))
    {
        if ([[filename pathExtension] isEqualToString:extension]) {
            
            [fileManager removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:filename] error:NULL];
        }
    }
    
    //返回主页面
    ViewController * viewCtler =[[ViewController alloc] init];
    [self presentViewController:viewCtler animated:YES completion:nil];
}

- (IBAction)playPauseButton:(id)sender
{
    
    if (player_view_.player.rate > 0 && !player_view_.player.error)
    {
        //正在播放
        [player_view_.player pause];
        [playPauseButton setTitle:@"恢复" forState:UIControlStateNormal];
    }
    else
    {
        //停止状态
        [player_view_.player play];
        [playPauseButton setTitle:@"暂停" forState:UIControlStateNormal];
    }
}

- (IBAction)retButton:(id)sender
{
    if (player_view_.player.rate > 0 && !player_view_.player.error)
    {
        //正在播放
        [player_view_.player pause];
    }
    
    [self viewWillDisappear];
    [self removeVideoTimerObserver];
    
    //返回主页面
    ViewController * viewCtler =[[ViewController alloc] init];
    [self presentViewController:viewCtler animated:YES completion:nil];
}

- (IBAction)selectButton:(id)sender
{
    [self viewWillDisappear];
    [self removeVideoTimerObserver];
    
    if ([dirArray count] == 0)
    {
        NSLog(@"no recorder file..");
        return;
    }
    
    [playPauseButton setTitle:@"暂停" forState:UIControlStateNormal];
        
    NSInteger row = [mypickerView selectedRowInComponent:0];
        
    NSString * fileName = [dirArray objectAtIndex:row];
    
    NSString *fullPath = [NSString stringWithFormat:@"%@/%@", dirBasePath, fileName];
        
    AVPlayer * player = [AVPlayer playerWithURL:[NSURL fileURLWithPath:fullPath]];
        
    player_view_.player = player;
    player_view_.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [player_view_.player seekToTime:kCMTimeZero];
        
    [player_view_.player play];
        
    [player addObserver:self forKeyPath:@"status" options:0 context:0];
    
    timeObserver = [player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time)
    {
        CMTime currentTime = player_view_.player.currentTime;
        CMTime totalTime = player_view_.player.currentItem.duration;
            
        currentTimeLabel.text = [NSString convertTime:CMTimeGetSeconds(currentTime)];
        totalTimeLabel.text = [NSString convertTime:CMTimeGetSeconds(totalTime)];
            
        CGFloat progress = CMTimeGetSeconds(currentTime)/CMTimeGetSeconds(totalTime);
        //NSLog(@"%.2f",progress);
        progressView.progress = progress;
        //NSLog(@"%d",(int)(CMTimeGetSeconds(totalTime) - CMTimeGetSeconds(currentTime)));
    }];
        
        NSLog(@"[selectButton]selected URL: %@", fullPath);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if(player_view_.player.status == AVPlayerStatusFailed){
        
    }else if(player_view_.player.status == AVPlayerStatusReadyToPlay){
        
    }
}

-(UIView *)pickerView:(UIPickerView *)pickerView
          titleForRow:(NSInteger)row
         forComponent:(NSInteger)component
{
    
    return [dirArray objectAtIndex:row];
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [dirArray count];
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (void)viewWillDisappear
{
    NSLog(@"viewWillDisappear..");
    if(player_view_ && player_view_.player)
    {
        [player_view_.player removeObserver:self forKeyPath:@"status" context:0];
    }
}

- (void)removeVideoTimerObserver {
    NSLog(@"%@",NSStringFromSelector(_cmd));
    [player_view_.player removeTimeObserver:timeObserver];
}

@end

