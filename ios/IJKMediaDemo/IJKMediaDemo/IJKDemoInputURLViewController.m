/*
 * Copyright (C) 2015 Gdier
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "IJKDemoInputURLViewController.h"
#import "IJKMoviePlayerViewController.h"

@interface IJKDemoInputURLViewController () <UITextViewDelegate>

@property(nonatomic,strong) IBOutlet UITextView *textView;

@end

@implementation IJKDemoInputURLViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = @"Input URL";
        
        [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Play" style:UIBarButtonItemStyleDone target:self action:@selector(onClickPlayButton)]];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    /**
     keyframe_count = 56 GOP为56
     [mov,mp4,m4a,3gp,3g2,mj2 @ 0x7f8d5a80f400] All info found
     [mov,mp4,m4a,3gp,3g2,mj2 @ 0x7f8d5a80f400] stream 0: start_time: 0 duration: 279.44
     [mov,mp4,m4a,3gp,3g2,mj2 @ 0x7f8d5a80f400] stream 1: start_time: 0 duration: 279.381
     [mov,mp4,m4a,3gp,3g2,mj2 @ 0x7f8d5a80f400] format: start_time: 0 duration: 279.44 (estimate from stream) bitrate=1081 kb/s
     [mov,mp4,m4a,3gp,3g2,mj2 @ 0x7f8d5a80f400] After avformat_find_stream_info() pos: 148013 bytes read:170059 seeks:0 frames:18
     Input #0, mov,mp4,m4a,3gp,3g2,mj2, from 'http://vd3.bdstatic.com//mda-jc4pdpxket3t9apn//sc//mda-jc4pdpxket3t9apn.mp4':
       Metadata:
         major_brand     : isom
         minor_version   : 512
         compatible_brands: isomiso2avc1mp41
         encoder         : Multimedia Cloud Transcode (cloud.baidu.com)
       Duration: 00:04:39.44, start: 0.000000, bitrate: 1081 kb/s
       Stream #0:0(und), 1, 1/12800: Video: h264 (High), 1 reference frame (avc1 / 0x31637661), yuv420p(left), 1280x720, 0/1, 1012 kb/s, 25 fps, 25 tbr, 12800 tbn, 50 tbc (default)
         Metadata:
           handler_name    : VideoHandler
           vendor_id       : [0][0][0][0]
       Stream #0:1(und), 17, 1/44100: Audio: aac (LC) (mp4a / 0x6134706D), 44100 Hz, stereo, fltp, 64 kb/s (default)
         Metadata:
           handler_name    : SoundHandler
           vendor_id       : [0][0][0][0]
     [h264 @ 0x7f8d58808c00] nal_unit_type: 7(SPS), nal_ref_idc: 3
     [h264 @ 0x7f8d58808c00] nal_unit_type: 8(PPS), nal_ref_idc: 3
     [AVIOContext @ 0x7f8d58708f40] Statistics: 170059 bytes read, 0 seeks
     */
    self.textView.text = @"http://vd3.bdstatic.com//mda-jc4pdpxket3t9apn//sc//mda-jc4pdpxket3t9apn.mp4";
    self.textView.textColor = [UIColor darkGrayColor];
}

- (void)onClickPlayButton {
    NSURL *url = [NSURL URLWithString:self.textView.text];
    NSString *scheme = [[url scheme] lowercaseString];
    
    if ([scheme isEqualToString:@"http"]
        || [scheme isEqualToString:@"https"]
        || [scheme isEqualToString:@"rtmp"]) {
        
//        [IJKVideoViewController presentFromViewController:self withTitle:[NSString stringWithFormat:@"URL: %@", url] URL:url completion:^{
////            [self.navigationController popViewControllerAnimated:NO];
//        }];
        
        [IJKVideoViewController presentFromViewControllerTestVideoCacheBug:self withTitle:[NSString stringWithFormat:@"URL: %@", url] URL:url completion:^{
//            [self.navigationController popViewControllerAnimated:NO];
        }];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [self onClickPlayButton];
}

@end
