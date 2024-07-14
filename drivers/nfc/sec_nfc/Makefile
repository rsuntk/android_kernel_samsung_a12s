# Makefile for sec_nfc

ccflags-y := -I$(srctree)/$(src)/inc/ -I$(srctree)/drivers/misc/tzdev/include/tzdev/

ccflags-$(CONFIG_NFC_DEBUG) += -DDEBUG

ifeq ($(CONFIG_SAMSUNG_NFC),m)
obj-$(CONFIG_SAMSUNG_NFC)		+= nfc_sec.o
nfc_sec-$(CONFIG_NFC_PN547_ESE_SUPPORT)	+= src/p61.o
nfc_sec-$(CONFIG_NFC_FEATURE_SN100U)	+= src/cold_reset.o
nfc_sec-$(CONFIG_SEC_NFC_LOGGER)	+= src/nfc_logger.o
nfc_sec-$(CONFIG_NFC_PN547)		+= src/pn547.o
else
obj-$(CONFIG_NFC_PN547)			+= src/pn547.o
obj-$(CONFIG_NFC_PN547_ESE_SUPPORT)	+= src/p61.o
obj-$(CONFIG_NFC_FEATURE_SN100U)	+= src/cold_reset.o
obj-$(CONFIG_SEC_NFC)			+= src/sec_nfc.o
obj-$(CONFIG_ESE_P3_LSI)		+= src/ese_p3.o
obj-$(CONFIG_SEC_NFC_LOGGER)		+= src/nfc_logger.o
endif
