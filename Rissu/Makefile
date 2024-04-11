# Rissu Project (C) 2024
# Make a new boot image

OEMBOOT := A127FXXSADWK2.tar.xz

# Make the variable first
PWD			:= $(shell pwd)
MAGISKBOOT 		:= $(PWD)/bin/magiskboot
LZ4			:= lz4
TAR			:= tar
BOOT_COMPRESSED		:= $(PWD)/$(OEMBOOT)
BOOT			:= $(PWD)/boot.img

MAGISKBOOT_UNPACK_ARGS	:= unpack
MAGISKBOOT_REPACK_ARGS	:= repack
LZ4_ARGS		:= -B6 --content-size
TAR_ARGS		:= -xf


unpack_boot:
	@echo "  TAR 		$(BOOT_COMPRESSED)"
	@$(TAR) $(TAR_ARGS) $(BOOT_COMPRESSED)
	@echo "  UNPACK	$(BOOT)"
	@$(MAGISKBOOT) $(MAGISKBOOT_UNPACK_ARGS) $(BOOT)
	
repack_boot:
	@echo "  MK_BOOT	$(BOOT)"
	@$(MAGISKBOOT) $(MAGISKBOOT_REPACK_ARGS) $(BOOT)
	@echo "  LZ4		$(BOOT)"
	@$(LZ4) $(LZ4_ARGS) boot.img boot.img.lz4
	
clean:
	@rm $(PWD)/kernel
	@rm $(PWD)/dtb
	@rm $(PWD)/ramdisk.cpio
	
	@echo "  CLEAN  $(PWD)/kernel"
	@echo "  CLEAN  $(PWD)/dtb"
	@echo "  CLEAN  $(PWD)/ramdisk.cpio"
