#! /usr/bin/env bash

# Rissu Project (C) 2024
# Script for CI and partial for Local Build.
# Contributor: Rissu <farisjihadih@outlook.com>

export RSUPATH="$(pwd)/Rissu"

make_a_config() {
	RAND="$RSUPATH/bin/random6"
	chmod +x $RAND

	mk_config() {
		page_one() {
			clear
			echo "			1"
			echo "## Assign a name for your Kernel: (example: MyKernel)"
			echo "Rules: No space (example: My Kernel <- Wrong)!"
			echo "Default: MyKernel"
			read -p "> " TMP_LOCAL_ENV_KERN_STRINGS		
			if [ -z $TMP_LOCAL_ENV_KERN_STRINGS ]; then
				export KERNEL_STRINGS="MyKernel";
			else
				export KERNEL_STRINGS=$TMP_LOCAL_ENV_KERN_STRINGS
			fi
		}
		page_one;
		
		page_two() {
			clear
			echo "			2"
			echo "## Include KernelSU? ##"
			echo "Info: KernelSU is a kernel-based root for Android. an alternative to Magisk rooting."
			echo "Options: true, false"
			echo "Default: false"
			read -p "> " TMP_LOCAL_ENV_KSU_SUPPORT
			if [[ $TMP_LOCAL_ENV_KSU_SUPPORT = 'true' ]]; then
				export KSU_STATE="true"
			elif [[ $TMP_LOCAL_ENV_KSU_SUPPORT = 'false' ]] || [ -z $TMP_LOCAL_ENV_KSU_SUPPORT ]; then
				export KSU_STATE="false"
			elif [[ $TMP_LOCAL_ENV_KSU_SUPPORT != 'false' ]] || [[ $TMP_LOCAL_ENV_KSU_SUPPORT != 'true' ]]; then
				page_two;
			fi
		}
		page_two;
		
		if [[ $KSU_STATE = 'true' ]]; then
			page_three() {
				clear
				echo "			3"
				echo "## KernelSU branch ##"
				echo "Select KernelSU branch: dev, stable"
				echo "Default: stable"
				read -p "> " TMP_LOCAL_ENV_KSU_BRANCH
				if [[ $TMP_LOCAL_ENV_KSU_BRANCH = 'stable' ]] || [ -z $TMP_LOCAL_ENV_KSU_BRANCH ]; then
					export KSU_BRANCH="stable"
				elif [[ $TMP_LOCAL_ENV_KSU_BRANCH = 'dev' ]]; then
					export KSU_BRANCH="dev"
				elif [[ $TMP_LOCAL_ENV_KSU_BRANCH != 'dev' ]] || [[ $TMP_LOCAL_ENV_KSU_BRANCH != 'stable' ]]; then
					page_three;
				fi
			}
			page_three;
		fi
		
		page_four() {
			clear
			echo "			4"
			echo "## SELinux state ##"
			echo "Select SELinux state: permissive, enforcing"
			echo "Default: enforcing"
			read -p "> " TMP_LOCAL_ENV_SELINUX_STATE
			if [[ $TMP_LOCAL_ENV_SELINUX_STATE = 'enforcing' ]] || [ -z $TMP_LOCAL_ENV_SELINUX_STATE ]; then
				export SELINUX_STATE="false"
			elif [[ $TMP_LOCAL_ENV_SELINUX_STATE = 'permissive' ]]; then
				export SELINUX_STATE="true"
			elif [[ $TMP_LOCAL_ENV_SELINUX_STATE != 'permissive' ]] || [[ $TMP_LOCAL_ENV_SELINUX_STATE != 'enforcing' ]]; then
				page_four;
			fi
		}
		page_four;
		
		page_five() {
			clear
			echo "			5"
			echo "## Assign a revision for your Kernel: (example: 4)"
			echo "- [i] You can skip this"
			read -p "> " TMP_LOCAL_ENV_REVISION
			if [ ! -z $TMP_LOCAL_ENV_REVISION ]; then
				export REV="`echo r$TMP_LOCAL_ENV_REVISION`"
			else
				export REV=$($RAND)
			fi
		}
		page_five;
	}

	summary() {
		clear
		echo "";
		echo " ##########################################"
		echo " # Name: $KERNEL_STRINGS"
		echo " # Revision: $REV"
		if [[ $KSU_STATE = 'true' ]]; then
			echo " # KSU: $KSU_STATE"
			echo " # KSU Branch: $KSU_BRANCH"
		fi
		echo " # SELinux Permissive: $SELINUX_STATE"
		echo " ##########################################"
	}

	mk_config;
	summary;
	echo "";
	read -p "- Is this configuration right to you? (y/n): " GO_BUILD
	if [[ $GO_BUILD = 'y' ]] || [[ $GO_BUILD = 'Y' ]]; then
		pre_build_stage;
	elif [[ $GO_BUILD = 'N' ]] || [[ $GO_BUILD = 'n' ]]; then
		mk_config;
	else
		echo "Illegal options! abort."
		exit 1;
	fi
}

DATE=$(date +'%Y%m%d%H%M%S')

pre_build_stage() {
	if [[ $ENV_IS_CI = 'true' ]]; then
		export KERNEL_STRINGS="$CI_ENV_LOCALVERSION"
		PRE_REV="${CI_ENV_REVISION//[^0-9]/}"
		if [ ! -z $CI_ENV_REVISION ]; then
			export REV="r`echo $PRE_REV`"
		else
			export REV="`echo $DATE`"
		fi
	fi
	
	## SELINUX
	if [[ $SELINUX_STATE = "true" ]]; then
		export REAL_STATE="Permissive"
		export PERM_FLAGS="y"
		export ENF_FLAGS="n"
	else
		export REAL_STATE="Enforcing"
		export PERM_FLAGS="n"
		export ENF_FLAGS="y"
	fi
	
	## KSU
	if [[ $KSU_STATE = "true" ]]; then
		if [ ! -d $(pwd)/KernelSU ]; then
			if [[ $KSU_BRANCH = "dev" ]]; then
				curl -LSs "https://raw.githubusercontent.com/tiann/KernelSU/main/kernel/setup.sh" | bash -s main
			else
				curl -LSs "https://raw.githubusercontent.com/tiann/KernelSU/main/kernel/setup.sh" | bash -
			fi
		fi
		export KSU_VERSION_TAGS=$(cd KernelSU && git describe --tags)
		export KSU_COMMIT_COUNT=$(cd KernelSU && git rev-list --count HEAD)
		export KSU_VERSION_NUMBER=$(expr 10000 + $KSU_COMMIT_COUNT + 200)
		
		FMT="`echo $KERNEL_STRINGS`-`echo $REV`-ksu-`echo $KSU_VERSION_NUMBER`_`echo $KSU_VERSION_TAGS`-`echo $REAL_STATE`"
		BUILD_FLAGS="CONFIG_KSU=y"
	else
		FMT="`echo $KERNEL_STRINGS`-`echo $REV`_`echo $REAL_STATE`-`echo $DATE`"
	fi
	
	# fixup! Fix ci upload filename
	TAR_FMT="$FMT.tar"
	BOOT_FMT="$FMT.img"
	ANYKERNEL3_FMT="`echo $FMT`_AnyKernel3.zip"

	if [[ $ENV_IS_CI = 'true' ]]; then
		CI_ANYKERNEL3_FMT="`echo $FMT`_AnyKernel3"
		echo $CI_ANYKERNEL3_FMT > zipfile_format.txt
		echo $FMT > file_format.txt
	fi
	
	if [[ $KSU_STATE = 'false' ]]; then
		if [ -d $(pwd)/KernelSU ]; then
			rm -rR $(pwd)/KernelSU -f
		fi
		export KSU_HARDCODE_STRINGS="unsupported"
	else
		export KSU_HARDCODE_STRINGS="`echo $KSU_VERSION_TAGS`/`echo $KSU_VERSION_NUMBER`"
	fi
}

# global variable
export DEFCONFIG="rsuntk_defconfig"
export ARCH=arm64
export ANDROID_MAJOR_VERSION=t
export PLATFORM_VERSION=13

# TOOLCHAINS
# Rissu use a custom mount point.
if [ ! -d /rsuntk ]; then
	export ANDROID_CC_PATH="$(pwd)/toolchains/google/bin"
	export LLVM_PATH="$(pwd)/toolchains/clang/bin"
	export GCC_PATH="$(pwd)/toolchains/gnu/bin"
else
	export ANDROID_CC_PATH="/rsuntk/env/google/bin"
	export LLVM_PATH="/rsuntk/env/clang-11/bin"
	export GCC_PATH="/rsuntk/env/gnu/bin"
fi
# FMT
export MGSKBOOT="$RSUPATH/bin/magiskboot"
export GEN_RANDOM="$RSUPATH/bin/random"
export OEMBOOT="$RSUPATH/data/stockboot.tar.xz"

# local variable
OUTDIR="$(pwd)/out"
MIN_CORES="2"
CORES=$(nproc --all)
MAKE_SH="$(pwd)/make_cmd.sh"
ANYKERNEL3="$RSUPATH/AnyKernel3"

if [ $CORES -gt $MIN_CORES ]; then
	THREADCOUNT="-j`echo $CORES`"
elif [ $CORES -lt $MIN_CORES ]; then
	THREADCOUNT="-j1"
else
	THREADCOUNT="-j`echo $MIN_CORES`"
fi

chmod +x $MGSKBOOT
chmod +x $GEN_RANDOM

if [[ $ENV_IS_CI = 'true' ]]; then
summary() {
	pre_build_stage;
	clear
	echo "";
	echo " ##########################################"
	echo " # Name: $KERNEL_STRINGS"
	echo " # Revision: $REV"
	if [[ $KSU_STATE = 'true' ]]; then
		echo " # KSU: $KSU_STATE"
		echo " # KSU Branch: $KSU_BRANCH"
	fi
	echo " # SELinux Permissive: $SELINUX_STATE"
	echo " # Upload Gz: $GIT_UPLOAD_GZ"
	echo " # Upload img: $GIT_UPLOAD_UNCOMPRESSED_BOOT_IMG"
	echo " #########################################"
	echo "";
	echo "- Build started at `date`"
}
summary;
else
	make_a_config;
fi

printf "#! /usr/bin/env bash
# Temporary make commands!
make -C $(pwd) O=$(pwd)/out CONFIG_LOCALVERSION=\"-`echo $KERNEL_STRINGS`\" `echo $BUILD_FLAGS` `echo $DEFCONFIG`
make -C $(pwd) O=$(pwd)/out CONFIG_LOCALVERSION=\"-`echo $KERNEL_STRINGS`\" `echo $BUILD_FLAGS` `echo $THREADCOUNT`" > make_cmd.sh

make_boot() {
	cd $RSUPATH
	cat $RSUPATH/art.txt
	tar -xf $OEMBOOT -C $RSUPATH
	echo "";
	echo "- Unpacking boot"
	$MGSKBOOT unpack $RSUPATH/boot.img 2>/dev/null
	rm $RSUPATH/kernel
	cp $OUTDIR/arch/$ARCH/boot/Image $RSUPATH/kernel
	echo "- Creating AnyKernel3"
	bash $RSUPATH/mk_version
	cp $OUTDIR/arch/$ARCH/boot/Image $ANYKERNEL3
	zip -r $RSUPATH/$ANYKERNEL3_FMT $ANYKERNEL3
	echo "- Repacking boot"
	$MGSKBOOT repack $RSUPATH/boot.img 2>/dev/null
	rm $RSUPATH/boot.img
	mv $RSUPATH/new-boot.img $RSUPATH/boot.img
	echo "- Compressing with lz4"
	lz4 -B6 --content-size boot.img boot.img.lz4 2>/dev/null
	echo "- Creating tarball file"
	tar -cf $TAR_FMT boot.img.lz4
	rm $RSUPATH/boot.img.lz4
	echo "- Creating boot file"
	echo "- Compressing boot file"
	tar -cJf - boot.img | xz -9e -c - > $BOOT_FMT.tar.xz
	echo "- Done!"
	echo "- Cleaning files"
	if [[ $GIT_UPLOAD_UNCOMPRESSED_BOOT_IMG = "true" ]]; then
		mv $RSUPATH/boot.img $RSUPATH/$BOOT_FMT
	else
		rm $RSUPATH/boot.img
	fi
	rm $RSUPATH/kernel && rm $RSUPATH/dtb
	if [ -f $RSUPATH/ramdisk.cpio ]; then
		rm $RSUPATH/ramdisk.cpio
	fi
	cd ..
}

cleanups() {
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
}

if [ -f $MAKE_SH ]; then
	bash $MAKE_SH ## Execute make commands
	rm $MAKE_SH ## Remove it after it done.
	
	# We use vmlinux, Image, and Image.gz file as an build status indicator.
	# Because when build is completed, Image and vmlinux file will exist.
	if [ -f $OUTDIR/arch/$ARCH/boot/Image ] && [ -f $OUTDIR/vmlinux ]; then
		cleanups;
		BUILD_STATE=0
	else
		BUILD_STATE=1
	fi
	echo "- Build state: $BUILD_STATE"
	if [[ $BUILD_STATE = '0' ]]; then
		if [[ $GIT_UPLOAD_GZ = "true" ]]; then
			mv $OUTDIR/arch/arm64/boot/Image.gz $RSUPATH/Image.gz
		fi
		echo "- Build ended at `date`. Creating boot.img"
		make_boot;
	else
		echo "- Build ended at `date`. with status: $BUILD_STATE."
	fi
else
	echo "- Fatal, $MAKE_SH not found!"
	exit 1;
fi
