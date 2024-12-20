################################################################################
# \file program.mk
#
# \brief
# This make file is called recursively and is used to build the
# resoures file system. It is expected to be run from the example directory.
#
################################################################################
# \copyright
# Copyright 2018-2024 Cypress Semiconductor Corporation
# SPDX-License-Identifier: Apache-2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
################################################################################

ifeq ($(WHICHFILE),true)
$(info Processing $(lastword $(MAKEFILE_LIST)))
endif

include $(MTB_TOOLS__RECIPE_DIR)/make/recipe/program_common.mk

ifeq ($(_MTB_RECIPE__PROGRAM_INTERFACE_SUBDIR), JLink)
_MTB_RECIPE__GDB_ARGS=$(MTB_TOOLS__RECIPE_DIR)/make/scripts/gdbinit_jlink
else
_MTB_RECIPE__GDB_ARGS=$(MTB_TOOLS__RECIPE_DIR)/make/scripts/gdbinit
endif

ifeq ($(TOOLCHAIN),A_Clang)
_MTB_RECIPE__OPENOCD_PROGRAM_IMG=$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/$(APPNAME).bin $(TOOLCHAIN_VECT_BASE_CM4)
else
_MTB_RECIPE__OPENOCD_SYMBOL_IMG=$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/$(APPNAME).$(MTB_RECIPE__SUFFIX_TARGET)
_MTB_RECIPE__OPENOCD_PROGRAM_IMG=$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/$(APPNAME).$(MTB_RECIPE__SUFFIX_PROGRAM)
endif

# Multi-core application programming: always use combined HEX image
ifneq ($(_MTB_RECIPE__APP_HEX_FILE),)
_MTB_RECIPE__OPENOCD_PROGRAM_IMG=$(_MTB_RECIPE__APP_HEX_FILE)
endif

# Use custom HEX image when PROG_FILE was provided by the user
ifneq ($(PROG_FILE),)
_MTB_RECIPE__OPENOCD_PROGRAM_IMG=$(PROG_FILE)
endif

_MTB_RECIPE__OPENOCD_ARGS=$(_MTB_RECIPE__OPENOCD_INTERFACE); $(_MTB_RECIPE__OPENOCD_PROBE_SERIAL) $(_MTB_RECIPE__OPENOCD_TARGET);

_MTB_RECIPE__OPENOCD_ERASE=init; reset init; flash erase_sector 0 0 last; exit;
_MTB_RECIPE__OPENOCD_PROGRAM=program $(_MTB_RECIPE__OPENOCD_PROGRAM_IMG) verify; reset_config srst_only; reset run; psoc4.dap dpreg 0x04 0x00; shutdown;
_MTB_RECIPE__OPENOCD_DEBUG=$(_MTB_RECIPE__OPENOCD_CHIP_NAME).cpu configure -rtos auto -rtos-wipe-on-reset-halt 1; init; reset init;

_MTB_RECIPE__OPENOCD_ERASE_ARGS=$(_MTB_RECIPE__OPENOCD_SCRIPTS) -c \
					"set PSOC4_USE_MEM_AP 1; set PSOC4_USE_ACQUIRE $(_MTB_RECIPE__XRES_AVAILABLE); $(_MTB_RECIPE__OPENOCD_ARGS) $(_MTB_RECIPE__OPENOCD_ERASE)"
_MTB_RECIPE__OPENOCD_PROGRAM_ARGS=$(_MTB_RECIPE__OPENOCD_SCRIPTS) -c \
					"set PSOC4_USE_ACQUIRE $(_MTB_RECIPE__XRES_AVAILABLE); $(_MTB_RECIPE__OPENOCD_ARGS) $(_MTB_RECIPE__OPENOCD_PROGRAM)"
_MTB_RECIPE__OPENOCD_DEBUG_ARGS=$(_MTB_RECIPE__OPENOCD_SCRIPTS) -c \
					"set PSOC4_USE_ACQUIRE $(_MTB_RECIPE__XRES_AVAILABLE); $(_MTB_RECIPE__OPENOCD_ARGS) $(_MTB_RECIPE__OPENOCD_DEBUG)"

_MTB_RECIPE__JLINK_DEVICE_CFG_PROGRAM=$(DEVICE)
_MTB_RECIPE__JLINK_DEBUG_ARGS=-if $(_MTB_RECIPE__PROBE_INTERFACE) $(_MTB_RECIPE__JLINK_PROBE_SERIAL) -device $(DEVICE) -endian little -speed auto -port 2334 -swoport 2335 -telnetport 2336 -vd -ir -localhostonly 1 -singlerun -strict -timeout 0 -nogui