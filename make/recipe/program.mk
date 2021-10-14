################################################################################
# \file program.mk
#
# \brief
# This make file is called recursively and is used to build the
# resoures file system. It is expected to be run from the example directory.
#
################################################################################
# \copyright
# Copyright 2018-2021 Cypress Semiconductor Corporation
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

include $(CY_INTERNAL_BASELIB_PATH)/make/recipe/program_common.mk

CY_GDB_ARGS=$(CY_INTERNAL_BASELIB_PATH)/make/scripts/gdbinit

ifeq ($(TOOLCHAIN),A_Clang)
CY_OPENOCD_PROGRAM_IMG=$(CY_CONFIG_DIR)/$(APPNAME).bin $(TOOLCHAIN_VECT_BASE_CM0P)
else
CY_OPENOCD_SYMBOL_IMG=$(CY_CONFIG_DIR)/$(APPNAME).$(CY_TOOLCHAIN_SUFFIX_TARGET)
CY_OPENOCD_PROGRAM_IMG=$(CY_CONFIG_DIR)/$(APPNAME).$(CY_TOOLCHAIN_SUFFIX_PROGRAM)
endif

CY_OPENOCD_ARGS=$(CY_OPENOCD_INTERFACE); $(CY_OPENOCD_TARGET);

CY_OPENOCD_ERASE=init; reset init; flash erase_sector 0 0 last; exit;
CY_OPENOCD_PROGRAM=program $(CY_OPENOCD_PROGRAM_IMG) verify reset exit;
CY_OPENOCD_DEBUG=$(CY_OPENOCD_CHIP_NAME).cpu configure -rtos auto -rtos-wipe-on-reset-halt 1; init; reset init;

CY_OPENOCD_ERASE_ARGS=$(CY_OPENOCD_SCRIPTS) -c \
					"set PSOC4_USE_MEM_AP 1; $(CY_OPENOCD_ARGS) $(CY_OPENOCD_ERASE)"
CY_OPENOCD_PROGRAM_ARGS=$(CY_OPENOCD_SCRIPTS) -c \
					"$(CY_OPENOCD_ARGS) $(CY_OPENOCD_PROGRAM)"
CY_OPENOCD_DEBUG_ARGS=$(CY_OPENOCD_SCRIPTS) -c \
					"$(CY_OPENOCD_ARGS) $(CY_OPENOCD_DEBUG)"
