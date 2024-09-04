#!/bin/bash

#
# Rissu's kernel build script.
# > Warning: LLVM testing!
#

# COLORS SHEET
RED='\e[1;31m'
YELLOW='\e[1;33m'
NC='\e[0m'

pr_err() {
	echo -e "${RED}[E] $@${NC}";
	exit 1;
}
pr_warn() {
	echo -e "${YELLOW}[W] $@${NC}";
}
pr_info() {
	echo "[I] $@";
}


if [ -d /rsuntk ]; then
	pr_info "Rissu environment detected."
	export CROSS_COMPILE=/rsuntk/env/google/bin/aarch64-linux-android-
	export PATH=/rsuntk/env/clang-13/bin:$PATH
 	export DEFCONFIG="rsuntk_defconfig"
else
	if [ -z $CROSS_COMPILE ]; then
		pr_err "Invalid empty variable for \$CROSS_COMPILE"
	fi
	if [ -z $PATH ]; then
		pr_err "Invalid empty variable for \$PATH"
	fi
	if [ -z $DEFCONFIG ]; then
		pr_warn "Empty variable for \$DEFCONFIG, using rsuntk_defconfig as default."
		DEFCONFIG="rsuntk_defconfig"
	fi
fi

export KERNEL_OUT=$(pwd)/out

export ARCH=arm64
export ANDROID_MAJOR_VERSION=t
export PLATFORM_VERSION=13

DATE=$(date +'%Y%m%d%H%M%S')
IMAGE="$KERNEL_OUT/arch/$ARCH/boot/Image"
RES="$(pwd)/result"

# Build!

__mk_defconfig() {
	make -C $(pwd) --jobs $(nproc --all) LLVM=1 O=$KERNEL_OUT CC=clang LD=ld.lld $DEFCONFIG
}
__mk_kernel() {
	make -C $(pwd) --jobs $(nproc --all) LLVM=1 O=$KERNEL_OUT CC=clang LD=ld.lld
}

if [ ! -z $1 ]; then
	__mk_defconfig;
else
	mk_defconfig_kernel() {
		__mk_defconfig;
		__mk_kernel;
	}
fi

if [ -d $KERNEL_OUT ]; then
	pr_warn "An out/ folder detected, Do you wants dirty builds?"
	read -p "" OPT;
	
	if [ $OPT = 'y' ] || [ $OPT = 'Y' ]; then
		__mk_kernel;
	else
		rm -rR out;
		mk_defconfig_kernel;
	fi
else
	mk_defconfig_kernel;
fi

if [ -e $IMAGE ]; then
	echo "";
	pr_info "Build done."
	
	# printout Image properties
	echo "";
	pr_info "/proc/version:";
	strings $IMAGE | grep "Linux version";
	echo "";
	pr_info "Size (bytes):";
	du -b $IMAGE;
	echo "";
	
	mkdir $RES
	
	mv $KERNEL_OUT/arch/$ARCH/boot/Image $RES

	# zip it!
	zip_name="kernel-a12s_artifacts-`echo $DATE`.zip"
	cd result
	pr_info "Assembling build artifacts in zip file .."
	zip -6 -r "$zip_name" *
	cd ..
	mv $RES/$zip_name $(pwd)

	if [ -e $(pwd)/$zip_name ]; then
		pr_info "Zip created. file: $(pwd)/$zip_name"
		pr_info "Cleaning out/ dir .."
		rm -rR out -f;
		pr_info "Done!"
		if [ -d $RES ]; then
			pr_info "Cleaning result/ dir .."
			rm -rf $RES
		fi
	else
		pr_warn "Failed to create zip."
	fi
else
	pr_err "Build error."
fi
