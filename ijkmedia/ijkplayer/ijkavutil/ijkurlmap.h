//
//  ijkurlmap.hpp
//  IJKMediaPlayer
//
//  Created by jeffasd on 2021/3/21.
//  Copyright © 2021 bilibili. All rights reserved.
//

#ifndef ijkurlmap_hpp
#define ijkurlmap_hpp

void* ijk_url_map_create();
void ijk_url_map_put(void *data, char *key, int value);
int ijk_url_map_get(void *data, char *key);

#endif /* ijkurlmap_hpp */
