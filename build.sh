#! /usr/bin/env bash

# Rissu Project (C) 2024
# Unified script for CI and Local Build.
# Contributor: Rissu <farisjihadih@outlook.com>

# ci related
chmod +x $(pwd)/rsuntk/bin/random6
if [[ $IS_CI = "y" ]]; then
	export KERNEL_STRINGS="$GIT_LOCALVERSION"
	REV="$GIT_REVISION"
	if [ -z $REV ]; then
		KERNEL_REV_OR_ID=$(./rsuntk/bin/random6);
	else
		KERNEL_REV_OR_ID="r`echo $REV`"
	fi
	TAGS=$(git describe --tags --always)
	LAST_FIELD=$TAGS
	if [[ $KSU_STATE = "true" ]]; then
		FMT="`echo $KERNEL_STRINGS`-`echo $KERNEL_REV_OR_ID`-ksu-`echo $KSU_NUMBER`_`echo $LAST_FIELD`"
	else
		FMT="`echo $KERNEL_STRINGS`-`echo $KERNEL_REV_OR_ID`_`echo $LAST_FIELD`"
	fi
	if [[ $KSU_STATE = "true" ]]; then
		rm $(pwd)/KernelSU
		if [[ $KSU_BRANCH = "dev" ]]; then
			curl -LSs "https://raw.githubusercontent.com/tiann/KernelSU/main/kernel/setup.sh" | bash -s main
		else
			curl -LSs "https://raw.githubusercontent.com/tiann/KernelSU/main/kernel/setup.sh" | bash -
		fi
		VERSION_TAGS=$(cd KernelSU && git describe --tags)
		KSU_GIT_COMMIT=$(cd KernelSU && git rev-list --count HEAD)
		KSU_NUMBER=$(expr 10000 + $KSU_GIT_COMMIT + 200)
		FLAGS="CONFIG_KSU=y"
	fi
	if [[ $SELINUX_STATE = "true" ]]; then
		REAL_STATE="Permissive"
		export PERM_FLAGS="y"
		export ENF_FLAGS="n"
	else
		REAL_STATE="Enforcing"
		export PERM_FLAGS="n"
		export ENF_FLAGS="y"
	fi
else
	export KERNEL_STRINGS=$(cat local_config.cfg | grep -i 'KERNEL_NAME' | cut -d ':' -f 2 | sed 's/^[[:space:]]*//')
	PERMISSIVE_STATE=$(cat local_config.cfg | grep -i 'PERMISSIVE' | cut -d ':' -f 2 | sed 's/^[[:space:]]*//')
	KSU_STATE=$(cat local_config.cfg | grep -i 'KSU_STATE' | cut -d ':' -f 2 | sed 's/^[[:space:]]*//')
	KSU_BRANCH=$(cat local_config.cfg | grep -i 'KSU_BRANCH' | cut -d ':' -f 2 | sed 's/^[[:space:]]*//')
	REVISION=$(cat local_config.cfg | grep -i 'REVISION' | cut -d ':' -f 2 | sed 's/^[[:space:]]*//')
	REV=$REVISION
	if [ -z $REV ]; then
		KERNEL_REV_OR_ID=$(./rsuntk/bin/random6);
	else
		KERNEL_REV_OR_ID="r`echo $REV`"
	fi
	if [[ $PERMISSIVE_STATE = 'true' ]]; then
		REAL_STATE="Permissive"
		export PERM_FLAGS="y"
		export ENF_FLAGS="n"
	else
		REAL_STATE="Enforcing"
		export PERM_FLAGS="n"
		export ENF_FLAGS="y"
	fi
	if [[ $KSU_STATE = 'true' ]]; then
		if [[ $KSU_BRANCH = 'dev' ]]; then
			curl -LSs "https://raw.githubusercontent.com/tiann/KernelSU/main/kernel/setup.sh" | bash -s main
		else
			curl -LSs "https://raw.githubusercontent.com/tiann/KernelSU/main/kernel/setup.sh" | bash -
		fi
		VERSION_TAGS=$(cd KernelSU && git describe --tags)
		KSU_GIT_COMMIT=$(cd KernelSU && git rev-list --count HEAD)
		KSU_NUMBER=$(expr 10000 + $KSU_GIT_COMMIT + 200)
		FLAGS="CONFIG_KSU=y"
		LAST_FIELD="release";
		FMT="`echo $KERNEL_STRINGS`-`echo $KERNEL_REV_OR_ID`-ksu-`echo $KSU_NUMBER`_`echo $LAST_FIELD`"
	else
		LAST_FIELD="release";
		FMT="`echo $KERNEL_STRINGS`-`echo $KERNEL_REV_OR_ID`_`echo $LAST_FIELD`"
	fi
fi
if [[ $KSU_STATE = 'false' ]]; then
	export KSU_VER_STRINGS_STATE="unsupported"
	rm $(pwd)/KernelSU
else
	export KSU_VER_STRINGS_STATE="`echo $VERSION_TAGS`/`echo $KSU_NUMBER`"
fi
# global variable
export DEFCONFIG="rsuntk_defconfig"
export BINARY="A127FXXSADWK2"
export ARCH=arm64
export ANDROID_MAJOR_VERSION=t
export PLATFORM_VERSION=13
export RSUPATH="$(pwd)/rsuntk"
export MGSKBOOT="$RSUPATH/bin/magiskboot"
export GEN_RANDOM="$RSUPATH/bin/random"
export OEMBOOT="$RSUPATH/`echo $BINARY`.tar.xz"
export DATE="`date`"
export CC="$(pwd)/toolchains/clang/bin/clang"
export CROSS_COMPILE="$(pwd)/toolchains/google/bin/aarch64-linux-android-"
# local variable
OUTDIR="$(pwd)/out"
MIN_CORES="2"
CORES=$(nproc --all)
MAKE_SH="$(pwd)/make_cmd.sh"
TAR_FMT="$FMT.tar"
BOOT_FMT="$FMT.img"
if [ $CORES -gt $MIN_CORES ]; then
	THREADCOUNT="-j`echo $CORES`"
elif [ $CORES -lt $MIN_CORES ]; then
	THREADCOUNT="-j1"
else
	THREADCOUNT="-j`echo $MIN_CORES`"
fi
chmod +x $MGSKBOOT
chmod +x $GEN_RANDOM
print_summary() {
	echo "===== Summary =====";
	echo "STRINGS: $KERNEL_STRINGS";
	if [[ $KSU_STATE = "true" ]]; then
		echo "KERNELSU: $KSU_STATE"
		echo "KSU_BRANCH: $KSU_BRANCH"
	fi
	echo "SELINUX: $REAL_STATE"
	echo "";
}
print_summary;
printf "#! /usr/bin/env bash
# Temporary make commands!
make -C $(pwd) O=$(pwd)/out `echo $FLAGS` `echo $DEFCONFIG`
make -C $(pwd) O=$(pwd)/out `echo $FLAGS` `echo $THREADCOUNT`" > make_cmd.sh
make_boot() {
	cd $RSUPATH
	cat $RSUPATH/art.txt
	tar -xf $OEMBOOT -C $RSUPATH
	echo "";
	echo "- Unpacking boot"
	$MGSKBOOT unpack $RSUPATH/boot.img 2>/dev/null
	rm $RSUPATH/kernel
	cp $OUTDIR/arch/$ARCH/boot/Image $RSUPATH/kernel
	echo "- Repacking boot"
	$MGSKBOOT repack $RSUPATH/boot.img 2>/dev/null
	rm $RSUPATH/boot.img
	mv $RSUPATH/new-boot.img $RSUPATH/boot.img
	echo "- Compressing with lz4"
	lz4 -B6 --content-size boot.img boot.img.lz4
	echo "- Creating tarball file"
	tar -cf $TAR_FMT boot.img.lz4
	rm $RSUPATH/boot.img.lz4
	echo "- Creating boot file"
	echo "- Done!"
	echo "- Cleaning files"
	mv $RSUPATH/boot.img $RSUPATH/$BOOT_FMT
	rm $RSUPATH/kernel && rm $RSUPATH/dtb
	if [ -f $RSUPATH/ramdisk.cpio ]; then
		rm $RSUPATH/ramdisk.cpio
	fi
	cd ..
}
if [ -f $MAKE_SH ]; then
	bash $MAKE_SH
	rm $MAKE_SH
	if [ -f $OUTDIR/arch/$ARCH/boot/Image ] && [ -f $OUTDIR/arch/$ARCH/boot/Image.gz ] && [ -f $OUTDIR/vmlinux ]; then
		rm $OUTDIR/vmlinux
		rm $OUTDIR/vmlinux.o
		rm $OUTDIR/System.map
		rm $OUTDIR/.tmp_kallsyms1.o
		rm $OUTDIR/.tmp_kallsyms1.S
		rm $OUTDIR/.tmp_kallsyms2.o
		rm $OUTDIR/.tmp_kallsyms2.S
		rm $OUTDIR/.tmp_System.map
		rm $OUTDIR/.tmp_vmlinux1
		rm $OUTDIR/.tmp_vmlinux2
		BUILD_STATE=0
	else
		BUILD_STATE=1
	fi
	echo "Build state: $BUILD_STATE"
	if [[ $BUILD_STATE = '0' ]]; then
		echo "- Build completed. Creating boot.img"
		make_boot;
	else
		echo "- Build failed."
	fi
else
	echo "- Fatal, make_cmd.sh not found!"
	exit 1;
fi
