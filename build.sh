#! /bin/sh

set -x

SOURCE_DIR=`pwd`
BUILD_DIR=${BUILD_DIR:-./build}
BUILD_TYPE=${BUILD_TYPE:-debug}

ln -sf $BUILD_DIR/compile_commands.json

mkdir -p $BUILD_DIR \
    && cd $BUILD_DIR \
    && cmake \
             -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
             -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
             $SOURCE_DIR \
    && make $*

