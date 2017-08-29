#!/bin/bash

BUILD_DIR=`pwd`

version=$1

args=$#

patch_folder="swift-4.0-patches"

# Swift 4 Tag
tag="swift-DEVELOPMENT-SNAPSHOT-2017-08-21-a"

set -e

if [[ "$(uname -s)" == Haiku ]]; then
  export HOST_CC="/bin/clang"
  export HOST_CXX="/bin/clang++"
else
  export HOST_CC="/usr/bin/clang"
  export HOST_CXX="/usr/bin/clang++"
fi


# Test if the these directory exists
if [ -d "./swift" ]; then
  echo "The swift directory already exists, not cloning"
else
  git clone https://github.com/apple/swift -b $tag --depth=1 swift
fi

# Test if the clang directory exists
if [ -d "./clang" ]; then
  echo "The clang directory already exists, not cloning"
else
  git clone https://github.com/apple/swift-clang -b $tag --depth=1 clang
fi

# Test if the llvm directory exists
if [ -d "./llvm" ]; then
  echo "The llvm directory already exists, not cloning"
else
  git clone https://github.com/apple/swift-llvm -b $tag --depth=1 llvm
fi

# Test if the cmark directory exists
if [ -d "./cmark" ]; then
  echo "The cmark directory already exists, not cloning"
else
  git clone https://github.com/apple/swift-cmark -b $tag --depth=1 cmark
fi

# Test if the compiler-rt directory exists
# Disable compiler-rt for now
#if [ -d "./compiler-rt" ]; then
#  echo "The compiler-rt directory already exists, not cloning"
#else
#  git clone https://github.com/apple/swift-compiler-rt -b $tag --depth=1 compiler-rt
#fi


pushd swift
git reset --hard
git checkout $tag
patch -p1 < ../$patch_folder/swift-4.0-haiku-swift.patch
popd
pushd llvm
git reset --hard
git checkout $tag
patch -p1 < ../$patch_folder/swift-4.0-haiku-llvm.patch
popd
pushd clang
git reset --hard
git checkout $tag
patch -p1 < ../$patch_folder/swift-4.0-haiku-clang.patch
popd

sh ./build-script.sh
