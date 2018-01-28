#!/bin/bash

clone_option=$1

extra_args=""

# Specific to LLVM libraries
extra_args_stable=""

patch_folder="swift-upstream"

# Latest working swift tag.
tag="swift-DEVELOPMENT-SNAPSHOT-2018-01-26-a"

# Determine the clone depth from user input.
case $clone_option in
  shallow)
     extra_args="-b $tag --depth=1"
     extra_args_stable = extra_args;;
  full)
     tag="master"
     extra_args="-b $tag"
# Clang and LLVM both use the stable branch.
     extra_args_stable="stable";;
  update)
# Update all repositories
     tag="master"
     extra_args_stable="stable";;
  *)

     echo $"Usage: $0 {shallow|full|update}"
     exit 1
esac

set -e

# Use only clang/clang++ to build the toolchain.
if [[ "$(uname -s)" == Haiku ]]; then
  export HOST_CC="/bin/clang"
  export HOST_CXX="/bin/clang++"
else
  export HOST_CC="/usr/bin/clang"
  export HOST_CXX="/usr/bin/clang++"
fi

# Perform a rebase of all repositories.
if [[ $1 == update ]]; then
  echo "Updating swift repositories."
  cd swift
  git reset --hard
  git pull https://github.com/apple/swift $tag --rebase
  cd ..
  cd clang
  git reset --hard
  git pull https://github.com/apple/swift-clang $extra_args_stable --rebase
  cd ..
  cd llvm
  git reset --hard
  git pull https://github.com/apple/swift-llvm $extra_args_stable --rebase
  cd ..
  cd cmark
  git pull https://github.com/apple/swift-cmark $tag --rebase
  cd ..
  cd compiler-rt
  git pull https://github.com/apple/swift-compiler-rt $extra_args_stable --rebase
  cd ..
  exit 0
fi

# Test if the swift directory exists.
if [ -d "./swift" ]; then
  echo "The swift directory already exists, not cloning."
else
  git clone https://github.com/apple/swift $extra_args swift
fi

# Test if the clang directory exists.
if [ -d "./clang" ]; then
  echo "The clang directory already exists, not cloning."
else
  git clone https://github.com/apple/swift-clang -b $extra_args_stable clang
fi

# Test if the llvm directory exists.
if [ -d "./llvm" ]; then
  echo "The llvm directory already exists, not cloning."
else
  git clone https://github.com/apple/swift-llvm -b $extra_args_stable llvm
fi

# Test if the cmark directory exists.
if [ -d "./cmark" ]; then
  echo "The cmark directory already exists, not cloning."
else
  git clone https://github.com/apple/swift-cmark -b master cmark
fi

# Test if the compiler-rt directory exists.
if [ -d "./compiler-rt" ]; then
  echo "The compiler-rt directory already exists, not cloning."
else
  git clone https://github.com/apple/swift-compiler-rt -b $extra_args_stable compiler-rt
fi

cd swift
git reset --hard
git checkout $tag
patch -p1 < ../$patch_folder/swift-haiku-swift.patch
patch -p1 < ../$patch_folder/swift-metadata-cache-fix.patch
cd ..
cd llvm
git reset --hard
git checkout stable
patch -p1 < ../$patch_folder/swift-haiku-llvm.patch
cd ..
cd clang
git reset --hard
git checkout stable
patch -p1 < ../$patch_folder/swift-haiku-clang.patch
cd ..

build-script.sh