#! /usr/bin/env bash

# Rissu Project (C) 2024

# This build script contributor:
# Rissu <farisjihadih@outlook.com>

########################
## Export these flags ##
########################
ID=$(./rsuntk/bin/gen_id)
display_summary() {
	echo "";
	echo "**** Summary ****"
	echo "";
	echo REVISION: $REV
	echo LOCALVERSION: $LOCALVERSION
	echo USE_KSU: $KSU
	echo USE_PERMISSIVE: $SELINUX_STATE
	echo "";
	echo "";
	sleep 4
}
display_summary;

exports() {
	export ARCH=arm64
	export ANDROID_MAJOR_VERSION=t
	export PLATFORM_VERSION=13
	export KCFLAGS=-w
	export CONFIG_SECTION_MISMATCH_WARN_ONLY=y
	export gen_id="$rsudir/bin/gen_id" ## gen_id: generate unique id for the kernel_strings
	## I added these lines, for you that might not sure or something....
	## but, i rather choose to edit these variable on the Makefile itself.
	export CC="$(pwd)/toolchains/clang/bin/clang";
	export CROSS_COMPILE="$(pwd)/toolchains/google/bin/aarch64-linux-android-"
}

PROC_NUM=$(nproc --all);
MIN_PROCESSOR_CORES="2";
CPU=$(lscpu | grep -i 'model name' | cut -d ':' -f 2 | sed 's/^[[:space:]]*//')
rsudir="$(pwd)/rsuntk" ## rissu's path
bold=$(tput bold)
normal=$(tput sgr0)

if [[ $SELINUX_STATE = 'y' ]] || [[ $SELINUX_STATE = 'Y' ]] || [[ $SELINUX_STATE = 'Yes' ]] || [[ $SELINUX_STATE = 'yes' ]] || [[ $SELINUX_STATE = 'YES' ]]; then
	IS_PERMISSIVE=y
else
	IS_PERMISSIVE=n
fi

if [[ $KSU = 'y' ]] || [[ $KSU = 'Y' ]] || [[ $KSU = 'Yes' ]] || [[ $KSU = 'yes' ]] || [[ $KSU = 'YES' ]]; then
	rm $(pwd)/KernelSU
	curl -LSs "https://raw.githubusercontent.com/tiann/KernelSU/main/kernel/setup.sh" | bash -
fi

if [[ $KSU = 'y' ]] || [[ $KSU = 'Y' ]] || [[ $KSU = 'Yes' ]] || [[ $KSU = 'yes' ]] || [[ $KSU = 'YES' ]]; then
	if [ -d $(pwd)/KernelSU ]; then
		KSU_TAGS=$(cd KernelSU && git describe --tags)
		export KSU_LINE="$KSU_TAGS"
		if [ -z $REV ]; then
			REAL_REV=$(echo $ID);
			export RSU="(ksu: $KSU_LINE), (rsuntk@rsuprjkt: tunf kernel, id: $REAL_REV), (rebased, maintained and upstreamed by @RissuDesu)"
		else
			REAL_REV=$(echo $REV);
			export RSU="(ksu: $KSU_LINE), (rsuntk@rsuprjkt: tunf kernel, rev: $REAL_REV), (rebased, maintained and upstreamed by @RissuDesu)"
		fi
	fi
else
	if [ -z $REV ]; then
		REAL_REV=$(echo $ID);
		export RSU="(rsuntk@rsuprjkt: tunf kernel, id: $REAL_REV), (rebased, maintained and upstreamed by @RissuDesu)"
	else
		REAL_REV=$(echo $REV);
		export RSU="(rsuntk@rsuprjkt: tunf kernel, rev: $REAL_REV), (rebased, maintained and upstreamed by @RissuDesu)"
	fi
fi

if [[ $IS_PERMISSIVE = 'y' ]]; then
	export PERM_FLAGS="y"
	export ENF_FLAGS="n"
else
	export PERM_FLAGS="n"
	export ENF_FLAGS="y"
fi

create_boot() { # make a flashable boot.img/tar, so we don't need custom AnyKernel3
	# Spit out.. a variable!
	mgsk="$rsudir/bin/magiskboot" ## magiskboot: for un/repack boot.img
	outdir="../out" ## out path
	stock_boot="$rsudir/A127FXXU9DWE4.tar.xz" ## stock boot.img: A127FXXU9DWE4
	
	chmod +x $mgsk ## giving magiskboot executable permission
	chmod +x $gen_id
	
	# Format
	DATE=$(date +'%Y%m%d%H%M%S');
	BOOT_FMT="TragicHorizon-r$(echo $REV)_$(echo $DATE).img"
	TAR_FMT="TragicHorizon-r$(echo $REV)_$(echo $DATE).tar"
	
	cd $rsudir ## switch to rissu's path
	rsu_banner() {
printf "
  _____  _               
 |  __ \(_)              
 | |__) |_ ___ ___ _   _
 |  _  /| / __/ __| | | |
 | | \ \| \__ \__ \ |_| |
 |_|  \_\_|___/___/\__,_|

- Boot file: $rsuntk/boot.img
";                 
	}
	rsu_banner;
	# The cores are in here! Below this line
	if [ ! -f $mgsk ]; then
		echo "";
		echo "- Failed to execute magiskboot. is the file exist?"
		echo "";
		cd ..
		exit 1;
	else
		echo "";
		echo "- Unpacking stock boot ...."
		echo "";
		
		tar -xf $stock_boot -C $rsudir
		$mgsk unpack $rsudir/boot.img 2>/dev/null
		rm $rsudir/kernel

		## cross-checking if the out dir, image files do exist
		if [ ! -d $outdir ] && [ ! -f $outdir/arch/$ARCH/boot/Image ] && [ ! -f $outdir/arch/$ARCH/boot/Image.gz ]; then
			echo "- Kernel build is failed? No such required files or directory";
			exit 1;
		else	
			cp $outdir/arch/$ARCH/boot/Image $rsudir/kernel
		fi
		
		echo "- Repacking patched boot"
		
		$mgsk repack $rsudir/boot.img 2>/dev/null
		rm $rsudir/boot.img ## remove the stock boot.img
		mv $rsudir/new-boot.img $rsudir/boot.img ## rename the patched boot.img
		tar -cf $TAR_FMT boot.img ## make it odin flashable
		mv $rsudir/boot.img $rsudir/$BOOT_FMT ## rename the patched boot.img
		
		echo "";
		echo "- Done!";
		echo "- Output file: $BOOT_FMT"
		echo "";
		
		echo "";
		echo "- Cleaning things up ..."
		echo "";
		
		rm $rsudir/kernel && rm $rsudir/dtb
		if [ -f $rsudir/ramdisk.cpio ]; then
			rm $rsudir/ramdisk.cpio
		fi
		
		cd ..
	fi
}

build_krenol() {
	exports;
	echo "";
	echo "- Building configs ...";
	echo "Started @ `date`";
	echo "";
	make -C $(pwd) O=$(pwd)/out KCFLAGS=-w CONFIG_SECTION_MISMATCH_WARN_ONLY=y rsuntk_defconfig > /dev/null

	echo "";
	echo "- Building kernel ...";
	echo "Started @ `date`";
	echo "";


	if [[ $PROC_NUM -gt $MIN_PROCESSOR_CORES ]]; then
		echo ""
		echo "-- CPU: $CPU";
		echo "- Using $(nproc --all) cores.";
		echo "";
		
		if [[ $KSU = 'y' ]] || [[ $KSU = 'Y' ]] || [[ $KSU = 'Yes' ]] || [[ $KSU = 'yes' ]] || [[ $KSU = 'YES' ]]; then
			make -C $(pwd) O=$(pwd)/out KCFLAGS=-w CONFIG_SECTION_MISMATCH_WARN_ONLY=y CONFIG_KSU=y CONFIG_LOCALVERSION=-$(echo $LOCALVERSION) -j$(nproc --all)
		else
			make -C $(pwd) O=$(pwd)/out KCFLAGS=-w CONFIG_SECTION_MISMATCH_WARN_ONLY=y CONFIG_LOCALVERSION=-$(echo $LOCALVERSION) -j$(nproc --all)
		fi
	elif [[ $PROC_NUM -lt $MIN_PROCESSOR_CORES ]]; then
		echo ""
		echo "-- CPU: $CPU";
		echo "- Using 1 core.";
		echo "";
		if [[ $KSU = 'y' ]] || [[ $KSU = 'Y' ]] || [[ $KSU = 'Yes' ]] || [[ $KSU = 'yes' ]] || [[ $KSU = 'YES' ]]; then
			make -C $(pwd) O=$(pwd)/out KCFLAGS=-w CONFIG_SECTION_MISMATCH_WARN_ONLY=y CONFIG_KSU=y CONFIG_LOCALVERSION=-$(echo $LOCALVERSION)
		else
			make -C $(pwd) O=$(pwd)/out KCFLAGS=-w CONFIG_SECTION_MISMATCH_WARN_ONLY=y CONFIG_LOCALVERSION=-$(echo $LOCALVERSION)
		fi
	else
		echo ""
		echo "-- CPU: $CPU";
		echo "- Using $MIN_PROCESSOR_CORES cores.";
		echo "";
		if [[ $KSU = 'y' ]] || [[ $KSU = 'Y' ]] || [[ $KSU = 'Yes' ]] || [[ $KSU = 'yes' ]] || [[ $KSU = 'YES' ]]; then
			make -C $(pwd) O=$(pwd)/out KCFLAGS=-w CONFIG_SECTION_MISMATCH_WARN_ONLY=y CONFIG_KSU=y CONFIG_LOCALVERSION=-$(echo $LOCALVERSION) -j$(echo $MIN_PROCESSOR_CORES)
		else
			make -C $(pwd) O=$(pwd)/out KCFLAGS=-w CONFIG_SECTION_MISMATCH_WARN_ONLY=y CONFIG_LOCALVERSION=-$(echo $LOCALVERSION) -j$(echo $MIN_PROCESSOR_CORES)
		fi
	fi

	echo "";
	echo "- Cleaning ...";
	echo "";
	if [ -f $(pwd)/out/arch/arm64/boot/Image ] && [ -f $(pwd)/out/vmlinux.o ] && [ -f $(pwd)/out/vmlinux ]; then
		rm $(pwd)/out/vmlinux.o
		rm $(pwd)/out/vmlinux
		rm $(pwd)/out/.tmp_vmlinux1
		rm $(pwd)/out/.tmp_vmlinux2
		rm $(pwd)/out/System.map
		
		echo "";
		echo "- Clean success!"
		echo "`date`"
		echo "";
		create_boot;
	else
		echo "";
		echo "- Clean failed!";
		echo "`date`";
		echo "";
	fi
}

if [ ! -d $rsudir ]; then
	echo "";
	echo "- Warning! /rsuntk directory not found!";
	echo "- Kernel build may failed!";
	echo "";
	build_krenol;
else
	build_krenol;
fi
