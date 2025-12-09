#!/bin/bash
# Build exiv2 .so for Android
set -e

NDK_PATH="${ANDROID_NDK_HOME:-${ANDROID_NDK:-${NDK_HOME:-$HOME/Library/Android/sdk/ndk/29.0.13113456}}}"
API_LEVEL=24
ARCHS="arm64-v8a armeabi-v7a x86_64"
OUTPUT_DIR="build-android-output"

echo "Using NDK: $NDK_PATH"

for arch in $ARCHS; do
    echo "Building $arch..."
    
    cmake -S . -B "build-android/$arch" \
        -DCMAKE_TOOLCHAIN_FILE="$NDK_PATH/build/cmake/android.toolchain.cmake" \
        -DANDROID_ABI="$arch" \
        -DANDROID_PLATFORM="android-$API_LEVEL" \
        -DANDROID_STL=c++_shared \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=ON \
        -DEXIV2_ENABLE_XMP=OFF \
        -DEXIV2_ENABLE_PNG=ON \
        -DEXIV2_ENABLE_NLS=OFF \
        -DEXIV2_ENABLE_WEBREADY=OFF \
        -DEXIV2_ENABLE_BROTLI=OFF \
        -DEXIV2_ENABLE_INIH=OFF \
        -DEXIV2_BUILD_SAMPLES=OFF \
        -DEXIV2_BUILD_EXIV2_COMMAND=OFF \
        -DEXIV2_BUILD_UNIT_TESTS=OFF \
        > /dev/null

    cmake --build "build-android/$arch" -j$(nproc 2>/dev/null || sysctl -n hw.ncpu)
    
    mkdir -p "$OUTPUT_DIR/$arch"
    cp "build-android/$arch/lib/libexiv2.so" "$OUTPUT_DIR/$arch/"
    echo "Done: $OUTPUT_DIR/$arch/libexiv2.so"
done

echo "Build complete!"
ls -lh $OUTPUT_DIR/*/libexiv2.so
