//
//  ijkurlmap.cpp
//  IJKMediaPlayer
//
//  Created by jeffasd on 2021/3/21.
//  Copyright © 2021 bilibili. All rights reserved.
//

#include <string>
#include <map>
#include <libgen.h>

using namespace std;

typedef map<string, int> IjkURLMap;

extern "C" void* ijk_url_map_create();
extern "C" void ijk_url_map_put(void *data, char *key, int value);
extern "C" int ijk_url_map_get(void *data, char *key);

void* ijk_url_map_create() {
    IjkURLMap *data = new IjkURLMap();
    return data;
}

void ijk_url_map_put(void *data, char *key, int value) {
    string key_string = basename(key);
    if (key_string.size() <= 0) {
        return;
    }
    IjkURLMap *map_data = reinterpret_cast<IjkURLMap *>(data);
    if (!map_data)
        return;
    (*map_data)[key_string] = value;
}

int ijk_url_map_get(void *data, char *key) {
    IjkURLMap *map_data = reinterpret_cast<IjkURLMap *>(data);
    if (!map_data)
        return -1;

    string key_string = basename(key);;
    if (key_string.size() <= 0) {
        return -1;
    }
    IjkURLMap::iterator it = map_data->find(key_string);
    if (it != map_data->end()) {
        return it->second;
    }
    return -1;
}
