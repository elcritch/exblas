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
TARGET = ARMV8
PREFIX = $(MIX_APP_PATH)/priv
BUILD  = $(MIX_APP_PATH)/obj

TARGET_CFLAGS = $(shell src/detect_target.sh)
CFLAGS ?= -O2 -Wall -Wextra -Wno-unused-parameter -pedantic
CFLAGS += $(TARGET_CFLAGS)

$(info "**** MIX_ENV set to [$(MIX_ENV)] ****")

# Crosscompiled build
LDFLAGS += -fPIC -shared
CFLAGS += -fPIC

calling_from_make:
	mix compile

all: install

install: archive compile
	make install PREFIX=$(PREFIX)/

compile: $(PREFIX) $(BUILD) 
	echo MIX_APP_PATH: $(MIX_APP_PATH)
	env | sort > /tmp/env.openblas.log
	tar zxvf $(BUILD)/OpenBLAS.tar.gz
	mv $(BUILD)/OpenBLAS-*/ $(BUILD)/OpenBLAS/
	cd $(BUILD)/OpenBLAS/ && make TARGET=$(TARGET) NO_LAPACKE=1 NOFORTRAN=1

archive:
	curl https://codeload.github.com/xianyi/OpenBLAS/tar.gz/v0.3.10 -o $(BUILD)/OpenBLAS.tar.gz

$(PREFIX) $(BUILD):
	mkdir -p $@

clean:
	$(RM) $(NIF) $(OBJ)

.PHONY: all clean install