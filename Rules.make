# Paths and settings
TARGET_PRODUCT = x86vbox
ANDROID_ROOT   = $(OUT)/../../../..
BIONIC_LIBC    = $(ANDROID_ROOT)/bionic/libc
PRODUCT_OUT    = $(ANDROID_ROOT)/out/target/product/$(TARGET_PRODUCT)
CROSS_COMPILE  = \
    $(ANDROID_ROOT)/prebuilts/gcc/linux-x86/x86/x86_64-linux-android-4.9/bin/x86_64-linux-android-

ARCH_NAME = x86

# Tool names
AS            = $(CROSS_COMPILE)as
AR            = $(CROSS_COMPILE)ar
CC            = $(CROSS_COMPILE)gcc
CPP           = $(CC) -E
LD            = $(CROSS_COMPILE)ld
NM            = $(CROSS_COMPILE)nm
OBJCOPY       = $(CROSS_COMPILE)objcopy
OBJDUMP       = $(CROSS_COMPILE)objdump
RANLIB        = $(CROSS_COMPILE)ranlib
READELF       = $(CROSS_COMPILE)readelf
SIZE          = $(CROSS_COMPILE)size
STRINGS       = $(CROSS_COMPILE)strings
STRIP         = $(CROSS_COMPILE)strip

export AS AR CC CPP LD NM OBJCOPY OBJDUMP RANLIB READELF \
         SIZE STRINGS STRIP

# Build settings
IFLAGS = -I$(TOPDIR)/include -I$(TOPDIR)/include/netpbm
#DFLAGS = -g
OFLAGS = -O2
CFLAGS = -Wall -fno-short-enums $(IFLAGS) $(DFLAGS) $(OFLAGS) -m32 -fPIE

HEADER_OPS    = -I$(BIONIC_LIBC)/arch-$(ARCH_NAME)/include \
                -I$(BIONIC_LIBC)/include \
                -I$(BIONIC_LIBC)/kernel/uapi \
                -I$(BIONIC_LIBC)/kernel/uapi/asm-$(ARCH_NAME)
LDFLAGS       = -nostdlib -Wl,-dynamic-linker,/system/bin/linker \
                $(PRODUCT_OUT)/obj/lib/crtbegin_dynamic.o \
                $(PRODUCT_OUT)/obj/lib/crtend_android.o \
                -L$(PRODUCT_OUT)/obj/lib -lc -ldl -fPIE -pie

# Installation variables
EXEC_NAME     = $(TARGET)
INSTALL       = install
INSTALL_DIR   = $(PRODUCT_OUT)/system/bin

# Make rules

# install: $(EXEC_NAME)
#	test -d $(INSTALL_DIR) || $(INSTALL) -d -m 755 $(INSTALL_DIR)
#	$(INSTALL) -m 755 $(EXEC_NAME) $(INSTALL_DIR)


#-------------------------------------------------------------------------
HOSTCC = gcc

SRCS += $(wildcard *.c)
OBJS += $(subst .c,.o,$(SRCS))
HDRS += $(wildcard *.h)
HDRS += $(wildcard $(TOPDIR)/include/*.h)
SUBDIRS_CLEAN += $(addsuffix _clean_,$(SUBDIRS))

.PHONY:		all clean $(SUBDIRS) $(SUBDIRS_CLEAN)


all:		.depend $(TARGET) $(A_TARGET) $(HOST_TARGET)

$(SUBDIRS):
		$(MAKE) -C $@

$(TARGET):	$(OBJS) $(SUBDIRS)
		$(CC) -o $(TARGET) $(HEADER_OPS) $(filter $(OBJS), $^) $(LIBS)  $(LDFLAGS)

$(A_TARGET):	$(OBJS)
		$(AR) -rcs $(A_TARGET) $(OBJS)

$(HOST_TARGET):	$(SRCS)
		$(HOSTCC) -o $(HOST_TARGET) $(CFLAGS) $(SRCS) $(LIBS)


clean::		$(SUBDIRS_CLEAN)
		$(RM) $(TARGET) $(A_TARGET) $(HOST_TARGET) $(OBJS) .depend

$(SUBDIRS_CLEAN):
		$(MAKE) -C $(subst _clean_,,$@) clean


%.o:		%.c
		$(CC) -c $(CFLAGS) $(HEADER_OPS) -o $@ $<


ifeq ($(HOST_TARGET),)
DEPCC = $(CC)
else
DEPCC = $(HOSTCC)
endif

.depend:	$(SRCS) $(HDRS)
		$(DEPCC) -M $(CFLAGS) $(HEADER_OPS) $(SRCS) > .depend

ifneq ($(MAKECMDGOALS),clean)
-include .depend
endif

