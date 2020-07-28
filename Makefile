# Makefile for building the NIF
#
# Makefile targets:
#
# all/install   build and install the NIF
# clean         clean build products and intermediates
#
# Variables to override:
#
# MIX_APP_PATH  path to the build directory
#
# CC            C compiler
# CROSSCOMPILE	crosscompiler prefix, if any
# CFLAGS	compiler flags for compiling all C files
# ERL_CFLAGS	additional compiler flags for files using Erlang header files
# ERL_EI_INCLUDE_DIR include path to ei.h (Required for crosscompile)
# ERL_EI_LIBDIR path to libei.a (Required for crosscompile)
# LDFLAGS	linker flags for linking all binaries
# ERL_LDFLAGS	additional linker flags for projects referencing Erlang libraries

# MIX_APP_PATH ?= ./build/
VERSION = 0.3.10
# TARGET = ARMV8
PREFIX = $(MIX_APP_PATH)/priv
BUILD  = $(MIX_APP_PATH)/obj

ARCHIVE = "$(BUILD)/OpenBLAS.tar.gz"

TRIPLET = $(shell cc -dumpmachine)

TARGET_CFLAGS = $(shell src/detect_target.sh)
CFLAGS ?= -O2 -Wall -Wextra -Wno-unused-parameter -pedantic
CFLAGS += $(TARGET_CFLAGS)

$(info "**** MIX_ENV set to [$(MIX_ENV)] ****")

# Crosscompiled build
LDFLAGS += -fPIC -shared
CFLAGS += -fPIC

# nerves_toolchain_arm_unknown_linux_gnueabihf 
# nerves_toolchain_x86_64_unknown_linux_musl 
# nerves_toolchain_armv6_rpi_linux_gnueabi 
# nerves_toolchain_x86_64_unknown_linux_gnu 
# nerves_toolchain_armv5tejl_unknown_linux_musleabi 
# nerves_toolchain_mipsel_unknown_linux_musl 
# nerves_toolchain_aarch64_unknown_linux_gnu 
# nerves_toolchain_i586_unknown_linux_gnu"

# Check that we're on a supported build platform
ifeq ($(CROSSCOMPILE),)
    TARGET=
else
  # Crosscompiled build
  ifeq (arm,$(findstring arm,$(TRIPLET)))
    TARGET= TARGET=ARM7
  else ifeq (aarch64,$(findstring arm,$(TRIPLET)))
    TARGET= TARGET=ARM8
  else
      # Not found
    TARGET=ZEN
  endif
endif


calling_from_make:
	mix compile

all: $(PREFIX) $(BUILD) compile
	cd "$(BUILD)/OpenBLAS-$(VERSION)/" && make install PREFIX="$(PREFIX)/"

compile: $(ARCHIVE)
	echo MIX_APP_PATH: $(MIX_APP_PATH)
	# TODO: Debugging, remove
	env | sort > /tmp/env.openblas.log
	echo $(TARGET) >> /tmp/target.openblas.log

	tar -C "$(BUILD)/" -xvf "$(BUILD)/OpenBLAS.tar.gz" 
	cd "$(BUILD)/OpenBLAS-$(VERSION)/" && make $(TARGET) NO_LAPACKE=1 NOFORTRAN=1

$(ARCHIVE): 
	curl https://codeload.github.com/xianyi/OpenBLAS/tar.gz/v$(VERSION) -o "$(ARCHIVE)"

$(PREFIX) $(BUILD):
	echo MAKE: $@
	mkdir -p $@

clean:
	$(RM) $(NIF) $(OBJ)

.PHONY: all clean install