//
//  IJKPlayerVideoCacheTools.h
//  IJKMediaDemo
//
//  Created by jeffasd on 2021/3/24.
//  Copyright © 2021 bilibili. All rights reserved.
//

#import <Foundation/Foundation.h>
@class IJKFFOptions;

@interface IJKPlayerVideoCacheTools : NSObject

+ (void)CleanAllIJKPlayerVideoCache;
+ (nullable NSURL*)setEnableVideoCacheWithOptions:(nullable IJKFFOptions *)options videoNetworkPath:(nullable NSString *)videoNetworkPath;

@end
