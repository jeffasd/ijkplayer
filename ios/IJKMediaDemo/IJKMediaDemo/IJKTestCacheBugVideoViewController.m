//
//  IJKTestCacheBugVideoViewController.m
//  IJKMediaDemo
//
//  Created by jeffasd on 2021/3/24.
//  Copyright © 2021 bilibili. All rights reserved.
//

#import "IJKTestCacheBugVideoViewController.h"
#import "IJKPlayerVideoCacheTools.h"
#import "IJKMediaControl.h"

@interface IJKTestCacheBugVideoViewController ()

@property(nonatomic, strong) id<IJKMediaPlayback> playerOne;

@end

@implementation IJKTestCacheBugVideoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    self.view.frame = [[UIScreen mainScreen] bounds];
    [super viewDidLoad];
    
    [self.player.view removeFromSuperview];
    
    [self startTestMutilPlayerPlayOneURL];
//    [self startTestStopAndShutdownPlayerImmediateNewPlayerPlayOneURL];
}

/// 测试释放播放器后立刻创建一个新的播放器,来播放同一个地址.
- (void)startTestStopAndShutdownPlayerImmediateNewPlayerPlayOneURL {
    [IJKPlayerVideoCacheTools CleanAllIJKPlayerVideoCache];
    [self setupPlayerWith:0];
    [self testAsyncStopAndNewSync];
}

/// 测试多个播放器同时播放同一个地址.
- (void)startTestMutilPlayerPlayOneURL {
    [self testTwoPlayerPlayOneVieoURL];
}

- (void)setupPlayerWith:(NSTimeInterval)time {
#ifdef DEBUG
    [IJKFFMoviePlayerController setLogReport:YES];
    [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_DEBUG];
#else
    [IJKFFMoviePlayerController setLogReport:NO];
    [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_INFO];
#endif
    
    IJKFFOptions *options = [IJKFFOptions optionsByDefault];
    
    {
        /// 精准seek
        [options setPlayerOptionIntValue:1 forKey:@"enable-accurate-seek"];
        
        /// 解决http播放不了
        // [_options setOptionIntValue:1 forKey:@"dns_cache_clear" ofCategory:kIJKFFOptionCategoryFormat];
        
        /// 最大缓冲大小 单位KB 256KB.
        // [_options setOptionIntValue:1024 * 1024 forKey: @"max-buffer-size" ofCategory: kIJKFFOptionCategoryPlayer];
        [options setOptionIntValue:1024 * 1024 forKey: @"max-buffer-size" ofCategory: kIJKFFOptionCategoryPlayer];
        /// [_options setOptionIntValue:1024 * 1024 forKey: @"max-buffer-size" ofCategory: kIJKFFOptionCategoryPlayer];
        /// [_options setOptionIntValue:1024 * 1024 * 30 forKey: @"max-buffer-size" ofCategory: kIJKFFOptionCategoryPlayer];
        
        /// 播放失败重连次数 不知为何大于1就直接播放失败,0和1没问题.
        [options setOptionIntValue:1 forKey: @"reconnect" ofCategory: kIJKFFOptionCategoryFormat];
        
        /// 设置播放器起播时间.
        [options setOptionIntValue:time * 1000 forKey: @"seek-at-start" ofCategory: kIJKFFOptionCategoryPlayer];
    }
    
    NSURL *enableCacheURL = [IJKPlayerVideoCacheTools setEnableVideoCacheWithOptions:options videoNetworkPath:self.url.absoluteString];
    self.player = [[IJKFFMoviePlayerController alloc] initWithContentURL:enableCacheURL withOptions:options];
    // self.player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.player.view.frame = self.view.bounds;
    self.player.scalingMode = IJKMPMovieScalingModeAspectFit;
    self.player.shouldAutoplay = YES;
    
    // self.view.autoresizesSubviews = YES;
    [self.view addSubview:self.player.view];
    [self.view addSubview:self.mediaControl];
    self.mediaControl.frame = self.view.bounds;
    
    self.mediaControl.delegatePlayer = self.player;
    
    [self.player prepareToPlay];
}

- (void)setupPlayerWithOne:(NSTimeInterval)time {
#ifdef DEBUG
    [IJKFFMoviePlayerController setLogReport:YES];
    [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_DEBUG];
#else
    [IJKFFMoviePlayerController setLogReport:NO];
    [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_INFO];
#endif
    
    IJKFFOptions *options = [IJKFFOptions optionsByDefault];
    
    {
        /// 精准seek
        [options setPlayerOptionIntValue:1 forKey:@"enable-accurate-seek"];
        
        /// 解决http播放不了
        // [_options setOptionIntValue:1 forKey:@"dns_cache_clear" ofCategory:kIJKFFOptionCategoryFormat];
        
        /// 最大缓冲大小 单位KB 256KB.
        // [_options setOptionIntValue:1024 * 1024 forKey: @"max-buffer-size" ofCategory: kIJKFFOptionCategoryPlayer];
        [options setOptionIntValue:1024 * 1024 forKey: @"max-buffer-size" ofCategory: kIJKFFOptionCategoryPlayer];
        /// [_options setOptionIntValue:1024 * 1024 forKey: @"max-buffer-size" ofCategory: kIJKFFOptionCategoryPlayer];
        /// [_options setOptionIntValue:1024 * 1024 * 30 forKey: @"max-buffer-size" ofCategory: kIJKFFOptionCategoryPlayer];
        
        /// 播放失败重连次数 不知为何大于1就直接播放失败,0和1没问题.
        [options setOptionIntValue:1 forKey: @"reconnect" ofCategory: kIJKFFOptionCategoryFormat];
        
        /// 设置播放器起播时间.
        [options setOptionIntValue:time * 1000 forKey: @"seek-at-start" ofCategory: kIJKFFOptionCategoryPlayer];
    }
    
    NSURL *enableCacheURL = [IJKPlayerVideoCacheTools setEnableVideoCacheWithOptions:options videoNetworkPath:self.url.absoluteString];
    self.playerOne = [[IJKFFMoviePlayerController alloc] initWithContentURL:enableCacheURL withOptions:options];
    // self.playerOne.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.playerOne.view.frame = self.view.bounds;
    self.playerOne.scalingMode = IJKMPMovieScalingModeAspectFit;
    self.playerOne.shouldAutoplay = YES;
    
    [self.view addSubview:self.playerOne.view];
    self.playerOne.view.frame = CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, 100);
    [self.playerOne prepareToPlay];
}

// 必现视频花屏跳帧等.
- (void)testTwoPlayerPlayOneVieoURL {
    [IJKPlayerVideoCacheTools CleanAllIJKPlayerVideoCache];
    
    [self setupPlayerWith:8];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setupPlayerWithOne:16];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((5 + 4) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.playerOne shutdown];
        self.playerOne = nil;
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((6+4) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.player shutdown];
        self.player = nil;
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((7+5) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setupPlayerWith:0];
    });
}

/// 必现视频花屏 关键帧被覆盖. 或者视频出现一大段跳帧例如从6秒直接跳到22秒.
- (void)testAsyncStopAndNewSync {
    __weak typeof(self)weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf __test:12];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf __test:26];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf __test:34];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf __test:12];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [weakSelf __test:56];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [weakSelf __test:25];
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                [weakSelf __test:47];
                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                    [weakSelf __test:7];
                                    //                                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                    //                                        [weakSelf __test:13];
                                    //                                    });
                                });
                            });
                        });
                    });
                });
            });
            
        });
    });
}

- (void)__test:(NSTimeInterval)time {
    [self.player.view removeFromSuperview];
    [self.mediaControl removeFromSuperview];
    [self.player shutdown];
    self.player = nil;
    [self setupPlayerWith:time];
}

@end
