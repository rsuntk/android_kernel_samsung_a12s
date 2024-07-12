#! /usr/bin/env bash

#
# Build script for A12s/M12
#

export PLATFORM_VERSION=13
export ANDROID_MAJOR_VERSION=t
export ARCH=arm64
export RSU_ENV=/rsuntk0
export CLANG_VERSION=11
export SHOW_TC_PATH=y

# Print out function
pr_info() {
	printf "[INFO] $@\n"
}
pr_err() {
	printf "[ERR] $@\n"
	exit 1;
}

if [ -d $RSU_ENV ]; then
	ENV=$RSU_ENV/env
	LLVM_PATH=$ENV/clang-$CLANG_VERSION/bin
	pr_info "Environment is Rissu. Detected /rsuntk mountpoint."
	__CC=$LLVM_PATH/clang
	__LD=$LLVM_PATH/ld.lld
	__CROSS_COMPILE=$ENV/google/bin/aarch64-linux-android-
	__CLANG_TRIPLE=aarch64-linux-gnu-
	
	# Rissu always use his defconfig
	__DEFCONFIG="rsuntk-a12snsxx_defconfig"
	
elif [ ! -z $ENV_IS_CI ]; then
	$ENV=$(pwd)/toolchains
	if [ ! -d $ENV ]; then
		pr_err "Unspecified toolchains path."
	fi
	pr_info "Environment is CI."
	__CC=$ENV/clang-$CLANG_VERSION/bin/clang
	__LD=$ENV/clang-$CLANG_VERSION/ld.lld
	__CROSS_COMPILE=$ENV/google/bin/aarch64-linux-android-
	__CLANG_TRIPLE=aarch64-linux-gnu-
	__DEFCONFIG=$GIT_ENV_DEFCONFIG
else
	# Fill it by yourself
	__CC=
	__LD=
	__CROSS_COMPILE=
	__CLANG_TRIPLE=
	__DEFCONFIG=
fi
	
make --no-silent --jobs $(nproc --all) CC=$__CC LD=$__LD CROSS_COMPILE=$__CROSS_COMPILE CLANG_TRIPLE=$__CLANG_TRIPLE -C $(pwd) O=$(pwd)/out ARCH=arm64 `echo $__DEFCONFIG`
export SHOW_TC_PATH=n
make --no-silent --jobs $(nproc --all) CC=$__CC LD=$__LD CROSS_COMPILE=$__CROSS_COMPILE CLANG_TRIPLE=$__CLANG_TRIPLE -C $(pwd) O=$(pwd)/out ARCH=arm64
