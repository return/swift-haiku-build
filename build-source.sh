#!/bin/bash

clone_option=$1

extra_args=""

patch_folder="swift-upstream"

# Latest working swift tag.
tag="swift-5.9-RELEASE"

# Determine the clone depth from user input.
case $clone_option in
  shallow)
     extra_args="-b $tag --depth=1" ;;
  full)
     tag="main"
     extra_args="-b $tag" ;;
# Clang and LLVM both use the stable branch.
  update)
# Update all repositories
     tag="main" ;;
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
fi

# Test if the swift directory exists.
if [ -d "./swift" ]; then
  echo "The swift directory already exists, not cloning."
else
  git clone https://github.com/apple/swift $extra_args swift
fi

./swift/utils/update-checkout \
    --clone \
    --config 'build.config' \
    --skip-history \
    --skip-tags \
    --tag $tag \
    --skip-repository swift \
    -j 4

cd swift
patch -p1 < ../$patch_folder/swift-haiku-swift.patch
cd ..
cd llvm-project
git reset --hard
if [[ $1 == update ]]; then
	git checkout stable
else
	git checkout $tag
fi
patch -p1 < ../$patch_folder/swift-haiku-llvm.patch
cd ..
./build-script.sh -j$(sysinfo -cpu | grep -c -F 'CPU #')
