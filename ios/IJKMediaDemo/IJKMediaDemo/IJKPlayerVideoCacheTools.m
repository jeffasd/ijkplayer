//
//  IJKPlayerVideoCacheTools.m
//  IJKMediaDemo
//
//  Created by jeffasd on 2021/3/24.
//  Copyright © 2021 bilibili. All rights reserved.
//

#import "IJKPlayerVideoCacheTools.h"
#import "IJKMoviePlayerViewController.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation IJKPlayerVideoCacheTools

+ (void)CleanAllIJKPlayerVideoCache {
    NSString *dir = [self IJKVideoCacheDir];
    [[NSFileManager defaultManager] removeItemAtPath:dir error:nil];
    NSLog(@"CleanAllIJKPlayerVideoCache %@", dir);
}

+ (NSString *)IJKVideoCacheDir {
#warning 发包前 此代码代码缓存要改为真正的地址.
    // NSString *dir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *dir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    dir = [dir stringByAppendingPathComponent:@"IJKPlayerVideoCache"];
    BOOL isDirectory = NO;
    BOOL isExists = [[NSFileManager defaultManager] fileExistsAtPath:dir isDirectory:&isDirectory];
    if (!isExists || !isDirectory) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return dir;
}

+ (NSString *)videoCachePathWithVideoNetworkPath:(NSString *)videoNetworkPath {
    NSString *md5 = [self md5:videoNetworkPath];
    NSString *pathExtension = [videoNetworkPath pathExtension];
    NSString *name = [md5 stringByAppendingPathExtension:pathExtension];
    NSString *cachePath = [[self IJKVideoCacheDir] stringByAppendingPathComponent:name];
    return cachePath;
}

+ (NSString *)videoCacheMapPathWithVideoNetworkPath:(NSString *)videoNetworkPath {
    NSString *md5 = [self md5:videoNetworkPath];
    NSString *pathExtension = [videoNetworkPath pathExtension];
    NSString *extension = [pathExtension stringByAppendingString:@"_cache_mp"];
    NSString *name = [md5 stringByAppendingPathExtension:extension];
    NSString *cachePath = [[self IJKVideoCacheDir] stringByAppendingPathComponent:name];
    return cachePath;
}

+ (NSString *)md5:(NSString *)URLString {
    const char *value = [URLString UTF8String];
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH *2];
    for (NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++) {
        [outputString appendFormat:@"%02x", outputBuffer[count]];
    }
    return outputString;
}

+ (nullable NSURL*)setEnableVideoCacheWithOptions:(nullable IJKFFOptions *)options videoNetworkPath:(nullable NSString *)videoNetworkPath {
    if (options == nil || videoNetworkPath.length <= 0) {
        return nil;
    }
    
    if ([videoNetworkPath hasPrefix:@"ijkio:cache"]) {
        NSURL *enableCacheURL = [NSURL URLWithString:videoNetworkPath];
        return enableCacheURL;
    }
    
    NSString *cachePath = [self videoCachePathWithVideoNetworkPath:videoNetworkPath];
    NSString *cacheMapPath = [self videoCacheMapPathWithVideoNetworkPath:videoNetworkPath];
    [options setOptionValue:cachePath forKey:@"cache_file_path" ofCategory:kIJKFFOptionCategoryFormat];
    [options setOptionValue:cacheMapPath forKey:@"cache_map_path" ofCategory:kIJKFFOptionCategoryFormat];
    [options setOptionIntValue:1 forKey:@"parse_cache_map" ofCategory:kIJKFFOptionCategoryFormat];
    [options setOptionIntValue:1 forKey:@"auto_save_map" ofCategory:kIJKFFOptionCategoryFormat];
    NSLog(@"IJKPlayer videoNetworkPath: %@", cachePath);
    NSString *enableCachePath = nil;
    if ([videoNetworkPath.pathExtension isEqualToString:@"need_decode"]) {
        enableCachePath = [@"ijkio:cache:videodecode:ffio:" stringByAppendingString:videoNetworkPath];
    }else {
        enableCachePath = [@"ijkio:cache:ffio:" stringByAppendingString:videoNetworkPath];
    }
    NSURL *enableCacheURL = [NSURL URLWithString:enableCachePath];
    return enableCacheURL;
}

@end
