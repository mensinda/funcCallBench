#!/usr/bin/bash

set -ex

cd "$(dirname "$0")"

VERS=1.8.3
URL=https://github.com/google/benchmark/archive/refs/tags/v$VERS.tar.gz

CACHE=cache
GZ_FILE=$CACHE/benchmark-$VERS.tar.gz
GZ_HASH=6bc180a57d23d4d9515519f92b0c83d61b05b5bab188961f36ac7b06b0d9e9ce

[ ! -d benchmark ] && mkdir benchmark
pushd benchmark

[ ! -d $CACHE   ] && mkdir $CACHE
[ ! -f $GZ_FILE ] && curl $URL -L -o $GZ_FILE

# Check the file
echo "$GZ_HASH $GZ_FILE" | sha256sum -c --quiet

for i in benchmark-*; do
    rm -rf $i
done

tar -xf $GZ_FILE

pushd benchmark-$VERS

cmake -S . -B build -DBENCHMARK_DOWNLOAD_DEPENDENCIES=ON -DBENCHMARK_ENABLE_TESTING=OFF -DCMAKE_BUILD_TYPE=Release -G Ninja
cmake --build "build" --config Release

popd

[ -d lib     ] && rm -rf lib
[ -d include ] && rm -rf include

mkdir lib

cp -R benchmark-$VERS/build/src/*.a lib
cp -R benchmark-$VERS/include .
