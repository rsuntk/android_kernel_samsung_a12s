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
export DATE=$(date +'%Y%m%d%H%M%S')

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
	ENV=$(pwd)/toolchains
	if [ ! -d $ENV ]; then
		pr_err "Unspecified toolchains path."
	fi
	pr_info "Environment is CI."
	__CC=$ENV/clang-$CLANG_VERSION/bin/clang
	__LD=$ENV/clang-$CLANG_VERSION/bin/ld.lld
	__CROSS_COMPILE=$ENV/google/bin/aarch64-linux-android-
	__CLANG_TRIPLE=aarch64-linux-gnu-
	__DEFCONFIG=$GIT_ENV_DEFCONFIG
	
	if [[ $KSU_STATE = 'true' ]]; then
		curl -LSs "https://raw.githubusercontent.com/rsuntk/KernelSU/main/kernel/setup.sh" | bash -s main
		
		# KernelSU/kernel/Makefile#22
		KSU_COMMIT_COUNT=$(cd KernelSU && git rev-list --count HEAD)
		export KSU_VERSION=$(expr 10200 + $KSU_COMMIT_COUNT)
		FMT="RsuCI-`echo $DEVICE_VARIANT`-KSU_`echo $KSU_NUM`-`echo $SELINUX_STATE`"
	else
		FMT="RsuCI-`echo $DEVICE_VARIANT`-`echo $SELINUX_STATE`"
	fi
	
	echo $FMT > zipfile_format.txt
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

if [ ! -z $ENV_IS_CI ]; then
	cd Rissu
	bash mk_version
	cd AnyKernel3
	zip -6 -r $(pwd)/Rissu/$FMT *
	cd ../..
fi
if [ ! -z $ENV_IS_CI ] && [[ $UPLOAD_GZ = 'true' ]]; then
	mv $(pwd)/out/arch/$ARCH/boot/Image.gz $(pwd)/Rissu/Image.gz
fi
