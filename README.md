# Swift on Haiku - Google Summer of Code Documentation

This gist documents the progress made on porting Swift to Haiku and has detailed instructions on building the toolchain from source.

Also, the sub-projects listed below show the progress of what has been completed so far in the Google Summer of Code (GSoC) period and their current statuses displayed below: _(Excludes swift-llvm and swift-clang)_

_Please note that this is subject to frequent revisions and this information could be outdated._

# Current Status

### Swift
* Completed:
	* Patches have been sent for review. 
	* Compiler (swiftc) builds on Haiku and programs.
	* Swift programs can be interpreted/compiled on Haiku.
	* Standard library (stdlib) builds on Haiku. 
	* Experimental REPL is available on Haiku.
	* Haiku recipe for swift 3 is available at [HaikuPorts](https://github.com/haikuports/haikuports/pull/1383).
* Incomplete:
	* Some tests have been partially ported [WIP].
		*
		* 
	* Enabling libdispatch to be built with the build-script.
	* Building SourceKit for Haiku.

### Swift-corelibs-foundation
* Completed:
	* Initial support for Haiku is available.
* Incomplete:
	* Testing Foundation. 

### Swift-corelibs-libdispatch
* Completed:
	* Initial support for Haiku is available.
* Incomplete:
	* Implementing Haiku-specific functionality. 
	* Testing libdispatch.

### Swift-cmark

* Builds without any patches needed.

### swift-llbuild

* Requires \<spawn.h\> functions to be implemented.  

### swift-lldb

* Requires LLDB to be ported to Haiku.

### swift-package-manager
* Requires Foundation / libdispatch and swift-llbuild.

# Building Swift on Haiku

* System Requirements:
	* Haiku 64 bit on hrev51281 or later running bare-metal or in a VirtualBox install 
	* A multi-core computer (4 - 16 cores)	
	* Release Build:
		* 4GB of RAM bare metal install / 8GB on VM install
		* 16GB+ HDD space.
	* Debug Build:
		* 16GB+ of RAM bare metal (A VM install is too slow.)
		* 30GB+ HDD space.

* Software Requirements:
	* LLVM / Clang _(llvm-4.0.1-2, llvm-clang-4.0.1-2)_
	* libedit _(libedit\_2015\_03\_21\_3.1-6)_
	* CMake _(cmake-3.8.2-1)_
	* Ninja _(ninja-1.6.0-1)_
	* libuuid _(libuuid-1.0.3-4)_
	* Python 2 _(python-2.7.13-3)_
	* libxml2 _(libxml2-2.9.3-5)_
	* libsqlite3 _(libsqlite-3.19.2.0-1)_
	* libexecinfo _(libexecinfo-1.1.3)_
	* libicu _(icu-57.1.2)_
	
## Building with Haikuporter

The easiest way to build Swift on Haiku is to use the haikuporter tool to automate the build process and to download the required dependencies listed above.

Setting up haikuporter can be done by following the tutorial under **Setting Up HaikuPorts** hosted on the [wiki](https://github.com/haikuports/haikuports/wiki#setting-up-haikuports).

Once you have setup haikuporter and cloned the ports tree, building swift is as simple as pasting this one-liner in the Terminal:

`haikuporter swift_lang --get-dependencies -G --no-source-packages -j16`

This will build the latest version of Swift though. If you want to build a specific version, then you must pass in the absolute recipe name with the version you want. e.g:

`haikuporter swift_lang-3.1 --get-dependencies -G --no-source-packages -j16`

That's it!

## Building from source manually

This section should be useful to those who wish to develop or to continue fixing stability issues in the swift port. These instructions assume you are running a recent x86_64 nightly. 32 bit Haiku is not supported.
	
1. Download the dependencies via `pkgman`.

	`pkgman install llvm llvm_clang ninja cmake libedit_devel python icu_devel libexecinfo_devel sqlite3_devel gcc_syslibs_devel curl_devel git` 

2. Create a folder to store the swift toolchain:

	`mkdir swift-build && cd swift-build`

3. Clone the `swift-haiku-build` repository: 

	 `git clone https://github.com/return/swift-haiku-build`

4. Once this is done, the repository comes with three scripts and two folders containing patch files. 
  *  `build-source.sh` - Clones the Swift 4 toolchain from apple/swift and applies platform patches for Haiku support.
  *  `build-source-3.1.sh` - Uses the Swift 3.1 port from my GSoC toolchain forks and builds the toolchain from source. 
  *  `build-script.sh` - The build script commands used to configure and build swift itself.

You can start the build process by just executing it:


<center>
`sh ./build-source.sh`
</center>

**_This script is meant to be run on Haiku. Building it on other systems may also work, but could fail to compile (Especially the Swift 3.1 port)_**

 Build the toolchain with this script below, depending if you want a Debug or Release version:


### Release Build

```
./swift/utils/build-script -R --extra-cmake-options='DLLVM_ENABLE_ASSERTIONS=TRUE \ -DCMAKE_SKIP_RPATH=FALSE \
-DLLVM_ENABLE_RTTI=ON \ -DLLVM_TARGETS_TO_BUILD=X86 \ -DLLVM_ENABLE_THREADS=ON \ -DCMAKE_C_FLAGS=-fPIC \ -DCMAKE_CXX_FLAGS=-fPIC' \
--stdlib-deployment-targets=haiku-x86_64 \ -j8
```

### Debug Build

Building a debug version of Swift (with LLVM even in release mode) will take as much as ~30GB
of disk space! You would need to also build with **-j1** when linking debug symbols as using multiple threads, will allocate more memory and exhaust your RAM space quickly when linking occurs.

Follow steps 1-3 and right after the `--stdlib-deployment-targets` argument, append `--debug-swift` to debug the Swift compiler or for debugging the standard library `--debug-swift-stdlib`.

```
 ./swift/utils/build-script -R --extra-cmake-options='-DLLVM_ENABLE_ASSERTIONS=TRUE \
 -DCMAKE_SKIP_RPATH=FALSE -DLLVM_ENABLE_RTTI=ON -DLLVM_TARGETS_TO_BUILD=X86 \
 -DLLVM_ENABLE_THREADS=ON -DCMAKE_C_FLAGS=-fPIC -DCMAKE_CXX_FLAGS=-fPIC' \
 --stdlib-deployment-targets=haiku-x86_64 --debug-swift \
 --debug-swift-stdlib -j1

```

# Developing on the Swift Port

Further development of the swift port is done in various branches in my forks, and knowing where to start can be very confusing or daunting for some. I'll try to explain the branch structure and where all the patches are for this project. This assumes that you are using the forked repositories from [return/swift](https://github.com/return) rather than Apples.

Each repository has the available branches which are as follows:

* swift-3.1-haiku (Deals with Swift 3.1)

* swift-4-haiku-support (Deals with Swift 4.)

* swift-4-haiku-support-upstream (Deals with upstream Swift.)

* swift-4-haiku-support-upstream-1 (Temporary branch which will be removed once merged.)

### Patches for Swift 3.1 support:

Patches related to improving Swift 3.1 for Haiku live on `swift-3.1-haiku`. This branch is also used for building the swift-3.1 recipe at HaikuPorts. If you intend to improve version 3.1 You should switch your branch to `swift-3.1-haiku` like the following structure below:


| Swift               | LLVM                | Clang               | Foundation         | LibDispatch        |  CMark            |
| --------------------| ------------------- | ------------------- | ------------------ | -------------------|-------------------|
| **swift-3.1-haiku** | **swift-3.1-haiku** | **swift-3.1-haiku** | **swift-3.1-haiku**| **swift-3.1-haiku**|**swift-3.1-haiku**|

_Patches for other repositories not included in the table should be branched out from `swift-3.1-branch` as that is the final release branch for swift 3.1._

### Patches for Swift 4 support:

Patches related to improving Swift 4 on Haiku live on `swift-4-haiku-support`. It also serves at the branch for building the swift-4 recipe at HaikuPorts.  If you intend to improve the Swift 4 port for packaging at HaikuPorts, you should switch your branch to `swift-4-haiku-support` similar to the structure above. Or you can


### Patches for upstream Swift:

`swift-n-haiku-support-upstream` (Where n is the version of swift) is meant for sending Haiku related patches to the upstream repositories. A temporary variant of this branch `swift-4-haiku-support-upstream-1` was used in [PR #11583](https://github.com/apple/swift/pull/11583) for initial support and the workarounds in `swift-4-haiku-support` and  `swift-3.1-haiku` have been removed in both the 'haiku-support-upstream' branches. 

Any patches meant for upstreaming Haiku support _must not_ cause unexpected failures when running tests on other platforms, so please test your changes and be careful when upstreaming!

# Testing

Running tests is similar to the guide mentioned in this [document](https://github.com/apple/swift/blob/master/docs/Testing.md), however the exception here is that these tests don't build position-independent executables by default which clang on Haiku requires. Therefore an extra flag must be passed to the build script to enable -fPIC when linking occurs.

For a list of tests that have failed, they are documented in this [gist](https://gist.github.com/return/6af6bbf84fa507d9ad6043fb593942b7)

### Running the test suite:

The test-suite by appending '-t' for normal tests run via the following command:

`./swift/utils/build-script -R -t ...`

This will test the toolchain and at the end will print the list of failed tests and 
give you a XML representation of the detailed results.

*(Last changed: August 29th 2017)*