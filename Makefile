# ****************************************************************************
#    Ledger App for Bitcoin
#    (c) 2021 Ledger SAS.
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
# ****************************************************************************

ifeq ($(BOLOS_SDK),)
$(error Environment variable BOLOS_SDK is not set)
endif

include $(BOLOS_SDK)/Makefile.defines

APP_PATH = ""
APP_LOAD_PARAMS  = --curve secp256k1
APP_LOAD_PARAMS += $(COMMON_LOAD_PARAMS)

APPVERSION_M = 0
APPVERSION_N = 0
APPVERSION_P = 1
APPVERSION   = "$(APPVERSION_M).$(APPVERSION_N).$(APPVERSION_P)"

# simplify for tests
ifndef COIN
COIN=bitcoin
endif

ifeq ($(COIN),bitcoin_testnet)
# Bitcoin testnet
DEFINES   += BIP44_COIN_TYPE=1 BIP44_COIN_TYPE_2=1 COIN_P2PKH_VERSION=111 COIN_P2SH_VERSION=196 COIN_FAMILY=1 COIN_COINID=\"Bitcoin\" COIN_COINID_HEADER=\"BITCOIN\" COIN_COLOR_HDR=0xFCB653 COIN_COLOR_DB=0xFEDBA9 COIN_COINID_NAME=\"Bitcoin\" COIN_COINID_SHORT=\"TEST\" COIN_NATIVE_SEGWIT_PREFIX=\"tb\" COIN_KIND=COIN_KIND_BITCOIN_TESTNET COIN_FLAGS=FLAG_SEGWIT_CHANGE_SUPPORT
DEFINES_LIB = USE_LIB_BITCOIN
APPNAME = "Bitcoin Test NEW"
# Flags: BOLOS_SETTINGS, GLOBAL_PIN, DERIVE_MASTER
APP_LOAD_FLAGS=--appFlags 0x250 --dep Bitcoin:$(APPVERSION)

APP_LOAD_PARAMS += --path $(APP_PATH)
else ifeq ($(COIN),bitcoin)
# Bitcoin mainnet
DEFINES   += BIP44_COIN_TYPE=0 BIP44_COIN_TYPE_2=0 COIN_P2PKH_VERSION=0 COIN_P2SH_VERSION=5 COIN_FAMILY=1 COIN_COINID=\"Bitcoin\" COIN_COINID_HEADER=\"BITCOIN\" COIN_COLOR_HDR=0xFCB653 COIN_COLOR_DB=0xFEDBA9 COIN_COINID_NAME=\"Bitcoin\" COIN_COINID_SHORT=\"BTC\" COIN_NATIVE_SEGWIT_PREFIX=\"bc\" COIN_KIND=COIN_KIND_BITCOIN COIN_FLAGS=FLAG_SEGWIT_CHANGE_SUPPORT
APPNAME = "Bitcoin NEW"
APP_LOAD_PARAMS += --path $(APP_PATH)
#Flags: LIBRARY, BOLOS_SETTINGS, GLOBAL_PIN, DERIVE_MASTER
APP_LOAD_FLAGS = --appFlags 0xa50
else
ifeq ($(filter clean,$(MAKECMDGOALS)),)
$(error Unsupported COIN - use bitcoin_testnet, bitcoin)
endif
endif

APP_LOAD_PARAMS += $(APP_LOAD_FLAGS)


ifeq ($(TARGET_NAME),TARGET_NANOX)
ICONNAME=icons/nanox_app_$(COIN).gif
else
ICONNAME=icons/nanos_app_$(COIN).gif
endif

all: default

# TODO: double check if all those flags are still relevant/needed (was copied from legacy app-bitcoin)

DEFINES   += APPNAME=\"$(APPNAME)\"
DEFINES   += APPVERSION=\"$(APPVERSION)\"
DEFINES   += MAJOR_VERSION=$(APPVERSION_M) MINOR_VERSION=$(APPVERSION_N) PATCH_VERSION=$(APPVERSION_P)
DEFINES   += OS_IO_SEPROXYHAL IO_SEPROXYHAL_BUFFER_SIZE_B=300
DEFINES   += HAVE_BAGL HAVE_SPRINTF HAVE_SNPRINTF_FORMAT_U
DEFINES   += HAVE_IO_USB HAVE_L4_USBLIB IO_USB_MAX_ENDPOINTS=4 IO_HID_EP_LENGTH=64 HAVE_USB_APDU
DEFINES   += LEDGER_MAJOR_VERSION=$(APPVERSION_M) LEDGER_MINOR_VERSION=$(APPVERSION_N) LEDGER_PATCH_VERSION=$(APPVERSION_P) TCS_LOADER_PATCH_VERSION=0
DEFINES   += HAVE_UX_FLOW
# U2F
# TODO: what is this?
#DEFINES   += HAVE_U2F HAVE_IO_U2F
#DEFINES   += U2F_PROXY_MAGIC=\"BTC\"

DEFINES   += USB_SEGMENT_SIZE=64
DEFINES   += BLE_SEGMENT_SIZE=32 #max MTU, min 20

DEFINES   += HAVE_WEBUSB WEBUSB_URL_SIZE_B=0 WEBUSB_URL=""

DEFINES   += UNUSED\(x\)=\(void\)x
DEFINES   += APPVERSION=\"$(APPVERSION)\"

DEFINES += BLAKE_SDK

ifeq ($(TARGET_NAME),TARGET_NANOX)
DEFINES       += HAVE_BLE BLE_COMMAND_TIMEOUT_MS=2000
DEFINES       += HAVE_BLE_APDU # basic ledger apdu transport over BLE

DEFINES       += HAVE_GLO096
DEFINES       += HAVE_BAGL BAGL_WIDTH=128 BAGL_HEIGHT=64
DEFINES       += HAVE_BAGL_ELLIPSIS # long label truncation feature
DEFINES       += HAVE_BAGL_FONT_OPEN_SANS_REGULAR_11PX
DEFINES       += HAVE_BAGL_FONT_OPEN_SANS_EXTRABOLD_11PX
DEFINES       += HAVE_BAGL_FONT_OPEN_SANS_LIGHT_16PX
endif

# Enabling debug PRINTF
DEBUG:=0
ifneq ($(DEBUG),0)
        ifeq ($(TARGET_NAME),TARGET_NANOX)
                DEFINES   += HAVE_PRINTF PRINTF=mcu_usb_printf
        else
                DEFINES   += HAVE_PRINTF PRINTF=screen_printf
        endif
else
        DEFINES   += PRINTF\(...\)=
endif



ifneq ($(BOLOS_ENV),)
$(info BOLOS_ENV=$(BOLOS_ENV))
CLANGPATH := $(BOLOS_ENV)/clang-arm-fropi/bin/
GCCPATH   := $(BOLOS_ENV)/gcc-arm-none-eabi-5_3-2016q1/bin/
else
$(info BOLOS_ENV is not set: falling back to CLANGPATH and GCCPATH)
endif
ifeq ($(CLANGPATH),)
$(info CLANGPATH is not set: clang will be used from PATH)
endif
ifeq ($(GCCPATH),)
$(info GCCPATH is not set: arm-none-eabi-* will be used from PATH)
endif

CC      := $(CLANGPATH)clang
CFLAGS  += -O3 -Os
AS      := $(GCCPATH)arm-none-eabi-gcc
LD      := $(GCCPATH)arm-none-eabi-gcc
LDFLAGS += -O3 -Os
LDLIBS  += -lm -lgcc -lc

include $(BOLOS_SDK)/Makefile.glyphs

APP_SOURCE_PATH += src
SDK_SOURCE_PATH += lib_stusb lib_stusb_impl lib_ux

ifeq ($(TARGET_NAME),TARGET_NANOX)
    SDK_SOURCE_PATH += lib_blewbxx lib_blewbxx_impl
endif

load: all
	python -m ledgerblue.loadApp $(APP_LOAD_PARAMS)

load-offline: all
	python -m ledgerblue.loadApp $(APP_LOAD_PARAMS) --offline

delete:
	python -m ledgerblue.deleteApp $(COMMON_DELETE_PARAMS)

include $(BOLOS_SDK)/Makefile.rules

dep/%.d: %.c Makefile

listvariants:
	@echo VARIANTS COIN bitcoin_testnet bitcoin