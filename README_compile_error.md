
ijkplayer android mac 下 编译

在 Mac 上的“终端”中使用环境变量
查看全部环境变量配置
$ env

jeffasddeMacBook-Pro:ndk-bundle xxx$ cat /Users/xxx/Library/Android/sdk/ndk-bundle/source.properties
Pkg.Desc = Android NDK
Pkg.Revision = 19.1.5304403


./compile-ffmpeg.sh all
执行编译终止于：ERROR：Failed to create toolchain

tools/do-compile-ffmpeg.s：43行给定的android api版本是9,改为 
FF_ANDROID_PLATFORM=android-16

ijkplayer requires dynamic R_X86_64_PC32 reloc against 'ff_M24A' 
/Users/xxx/Downloads/ijkplayer_fix_cache/ijkplayer_android/android/contrib/build/ffmpeg-x86_64/toolchain/bin/../lib/gcc/x86_64-linux-android/4.9.x/../../../../x86_64-linux-android/bin/ld: error: libavcodec/h264_cabac.o: requires dynamic R_X86_64_PC32 reloc against 'ff_h264_cabac_tables' which may overflow at runtime; recompile with -fPIC
/Users/xxx/Downloads/ijkplayer_fix_cache/ijkplayer_android/android/contrib/build/ffmpeg-x86_64/toolchain/bin/../lib/gcc/x86_64-linux-android/4.9.x/../../../../x86_64-linux-android/bin/ld: error: libavcodec/hevc_cabac.o: requires dynamic R_X86_64_PC32 reloc against 'ff_h264_cabac_tables' which may overflow at runtime; recompile with -fPIC
/Users/xxx/Downloads/ijkplayer_fix_cache/ijkplayer_android/android/contrib/build/ffmpeg-x86_64/toolchain/bin/../lib/gcc/x86_64-linux-android/4.9.x/../../../../x86_64-linux-android/bin/ld: error: libavcodec/x86/fft.o: requires dynamic R_X86_64_PC32 reloc against 'ff_cos_32' which may overflow at runtime; recompile with -fPIC

https://my.oschina.net/u/145591/blog/792486
这个信息，其中R_X86_64_PC32为相对地址重定位，并非动态链接所用，怀疑是否是此问题。因为自测模拟程序中并没有.rela.text此段。
在编译ffmpeg时加入--disable-asm选项可以修正这个问题，使ff_h264_cabac_tables可重定位。


/Users/xxx/Library/Android/sdk/ndk-bundle/build/core/setup-toolchain.mk:52: *** Android NDK: Invalid NDK_TOOLCHAIN_VERSION value: 4.9. GCC is no longer supported. See https://android.googlesource.com/platform/ndk/+/master/docs/ClangMigration.md.    .  Stop.
/Users/xxx/Downloads/ijkplayer_fix_cache/ijkplayer_android/android
NDK_TOOLCHAIN_VERSION=4.9

找到Application.mk文件，更改APP_STL指定的值为“c++_static”，如下这样操作即可！
如果是：
APP_STL := stlport_static
或者是：
APP_STL := gnustl_shared

都改成

APP_STL := c++_static
删除Application.mk文件中的NDK_TOOLCHAIN_VERSION=4.9


jeffasddeMacBook-Pro:android xxx$ cd /Users/xxx/Downloads/ijkplayer_fix_cache/ijkplayer_android/android/
jeffasddeMacBook-Pro:android xxx$ ./compile-ijk.sh 
profiler build: NO
Android NDK: android-9 is unsupported. Using minimum supported version android-16.    
Android NDK: WARNING: APP_PLATFORM android-16 is higher than android:minSdkVersion 9 in /Users/xxx/Downloads/ijkplayer_fix_cache/ijkplayer_android/android/ijkplayer/ijkplayer-armv7a/src/main/AndroidManifest.xml. NDK binaries will *not* be compatible with devices older than android-16. See https://android.googlesource.com/platform/ndk/+/master/docs/user/common_problems.md for more information.    
/Users/xxx/Library/Android/sdk/ndk-bundle/build/core/add-application.mk:178: *** Android NDK: APP_STL stlport_static is no longer supported. Please switch to either c++_static or c++_shared. See https://developer.android.com/ndk/guides/cpp-support.html for more information.    .  Stop.


error: unknown warning option '-Wno-psabi' [-Werror,-Wunknown-warning-option]
make: *** [/Users/xxx/Downloads/ijkplayer_fix_cache/ijkplayer/android/ijkplayer/ijkplayer-arm64/src/main/obj/local/arm64-v8a/objs/cpufeatures/cpu-features.o] Error 1
make: *** Waiting for unfinished jobs....

# 修改 $ /Users/xxx/Library/Android/sdk/ndk-bundle/sources/android/cpufeatures/Android.mk 下的 LOCAL_CFLAGS := -Wall -Wextra -Werror -> LOCAL_CFLAGS := -Wall -Wextra 否则编译时链接cpu-features.o后报 psabi 错误,原因是cpu-features把警告当错误对待了.

# 替换cpufeatures/Android.mk下的LOCAL_CFLAGS := -Wall -Wextra -Werror -> LOCAL_CFLAGS := -Wall -Wextra
sed -i "_saved" -E $'s/ \x2dWerror//g' $ANDROID_NDK/sources/android/cpufeatures/Android.mk


APP_OPTIM := release
APP_PLATFORM := android-21
APP_ABI := arm64-v8a
NDK_TOOLCHAIN_VERSION=clang
APP_PIE := false

APP_STL := c++_static

APP_CFLAGS := -O3 -Wall -pipe \
    -ffast-math \
    -fstrict-aliasing -Werror=strict-aliasing \
    -Wno-psabi -Wa,--noexecstack \
    -DANDROID -DNDEBUG


LOCAL_CFLAGS += -mfloat-abi=soft
endif
LOCAL_CFLAGS += -std=c99 /// 去掉
LOCAL_LDLIBS += -llog -landroid


ijkplayer/ijkplayer-arm64/src/main/jni/Application.mk
APP_STL := c++_static

/ijkmedia/ijkplayer/Android.mk
LOCAL_CPPFLAGS += -std=c++11


diff --git a/android/compile-ijk.sh b/android/compile-ijk.sh
index 95062ea4..514492aa 100755
--- a/android/compile-ijk.sh
+++ b/android/compile-ijk.sh
@@ -25,7 +25,8 @@ fi
 REQUEST_TARGET=$1
 REQUEST_SUB_CMD=$2
 ACT_ABI_32="armv5 armv7a x86"
-ACT_ABI_64="armv5 armv7a arm64 x86 x86_64"
+#ACT_ABI_64="armv5 armv7a arm64 x86 x86_64"
+ACT_ABI_64="arm64"



-FF_ACT_ARCHS_64="armv5 armv7a arm64 x86 x86_64"
+#FF_ACT_ARCHS_64="armv5 armv7a arm64 x86 x86_64"
+FF_ACT_ARCHS_64="arm64"

diff --git a/android/contrib/tools/do-compile-ffmpeg.sh b/android/contrib/tools/do-compile-ffmpeg.sh
index d6b3ba63..5a8cd5ec 100755
--- a/android/contrib/tools/do-compile-ffmpeg.sh
+++ b/android/contrib/tools/do-compile-ffmpeg.sh
@@ -40,7 +40,7 @@ fi
 
 
 FF_BUILD_ROOT=`pwd`
-FF_ANDROID_PLATFORM=android-9
+FF_ANDROID_PLATFORM=android-16

+++ b/android/ijkplayer/ijkplayer-arm64/src/main/jni/Application.mk
@@ -21,9 +21,11 @@ APP_OPTIM := release
 APP_PLATFORM := android-21
 APP_ABI := arm64-v8a
 NDK_TOOLCHAIN_VERSION=4.9
+NDK_TOOLCHAIN_VERSION=clang
 APP_PIE := false
 
-APP_STL := stlport_static
+# APP_STL := stlport_static
+APP_STL := c++_static
 
 APP_CFLAGS := -O3 -Wall -pipe \
     -ffast-math \
diff --git a/ijkmedia/ijkplayer/Android.mk b/ijkmedia/ijkplayer/Android.mk
index 552c1142..4eea439c 100644
--- a/ijkmedia/ijkplayer/Android.mk
+++ b/ijkmedia/ijkplayer/Android.mk
@@ -27,6 +27,7 @@ ifeq ($(TARGET_ARCH_ABI),armeabi-v7a)
 LOCAL_CFLAGS += -mfloat-abi=soft
 endif
 LOCAL_CFLAGS += -std=c99
+LOCAL_CPPFLAGS += -std=c++11

* C.项目中异常分析
    * 根据实际项目可知，当准备播放视频时，找不到libijkffmpeg.so这个库，导致直接崩溃。
* D.引发崩溃日志的流程分析
* F.解决办法
    * 报这个错误通常是so库加载失败，或者找不到准备执行的JNI方法：
        * 1.建议检查so在安装的过程中是否丢失，没有放入指定的目录下；
        * 2.调用loadLibrary时检查是否调用了正确的so文件名，并对其进行捕获，进行相应的处理，防止程序发生崩溃；
        * 3.检查下so的架构是否跟设备架构一至（如在64-bit架构下调用32-bit的so）。
    * 代码展示
* ndk {
*     //根据需要 自行选择添加的对应cpu类型的.so库。
*     //abiFilters 'armeabi', 'armeabi-v7a', 'arm64-v8a', 'x86', 'mips'
*     abiFilters 'armeabi-v7a'
* } 
build.gradle ijkplyaer-example
defaultConfig {
    applicationId "tv.danmaku.ijk.media.example"
    minSdkVersion 16
    targetSdkVersion rootProject.ext.targetSdkVersion
    versionCode rootProject.ext.versionCode
    versionName rootProject.ext.versionName

    ndk {
        abiFilters 'arm64-v8a'
    }

}

LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := cpufeatures
LOCAL_SRC_FILES := cpu-features.c
LOCAL_CFLAGS := -Wall -Wextra -Werror 
LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)
LOCAL_EXPORT_LDLIBS := -ldl
include $(BUILD_STATIC_LIBRARY)

sed -i "save" ’s/‘-Werror’/ ' Android.mkAndroid_saved.mk


ndk-bundle/sources/android/cpufeatures/Android.mk

ANDROID_NDK

https://blog.csdn.net/bikeytang/article/details/104303826
sed -i "sav" -E $'s/\x2dWerror//g' Android.mk


sed -i "_saved" -E $'s/ \x2dWerror//g' Android.mk


$ANDROID_NDK/sources/android/cpufeatures/Android.mk

