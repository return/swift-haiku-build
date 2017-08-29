#!/bin/bash

BUILD_DIR=`pwd`

version=$1
args=$#

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
  git clone https://github.com/return/swift -b swift-3.1-haiku --depth=1 swift
fi

# Test if the clang directory exists
if [ -d "./clang" ]; then
  echo "The clang directory already exists, not cloning"
else
  git clone https://github.com/return/swift-clang -b swift-3.1-haiku --depth=1 clang
fi

# Test if the llvm directory exists
if [ -d "./llvm" ]; then
  echo "The llvm directory already exists, not cloning"
else
  git clone https://github.com/return/swift-llvm -b swift-3.1-haiku --depth=1 llvm
fi

# Test if the cmark directory exists
if [ -d "./cmark" ]; then
  echo "The cmark directory already exists, not cloning"
else
  git clone https://github.com/return/swift-cmark -b swift-3.1-haiku --depth=1 cmark
fi

# Test if the compiler-rt directory exists
if [ -d "./compiler-rt" ]; then
  echo "The compiler-rt directory already exists, not cloning"
else
  git clone https://github.com/return/swift-compiler-rt -b swift-3.1-haiku --depth=1 compiler-rt
fi


#pushd swift
#git checkout $swift_branch
#patch -p1 < ../$patch_folder/swift-3.1-haiku-swift.patch
#popd
#pushd llvm
#git checkout $llvm_branch
#patch -p1 < ../$patch_folder/swift-3.1-haiku-llvm.patch
#popd
#pushd clang
#git checkout $clang_brach
#patch -p1 < ../$patch_folder/swift-3.1-haiku-clang.patch
#popd

./swift/utils/build-script -R --extra-cmake-options='-DLLVM_ENABLE_ASSERTIONS=TRUE \
-DCMAKE_SKIP_RPATH=FALSE -DLLVM_ENABLE_RTTI=ON -DLLVM_TARGETS_TO_BUILD=X86 \
-DLLVM_ENABLE_THREADS=ON -DCMAKE_C_FLAGS=-fPIC -DCMAKE_CXX_FLAGS=-fPIC' \
--stdlib-deployment-targets=haiku-x86_64 -j16

