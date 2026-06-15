################################################################################
# \file defines.mk
#
# \brief
# Defines, needed for the PSOC(TM) 4 build recipe.
#
################################################################################
# \copyright
# Copyright (c) 2018-2026, Infineon Technologies AG, or an affiliate of
# Infineon Technologies AG. All rights reserved.
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

include $(MTB_TOOLS__RECIPE_DIR)/make/recipe/defines_common.mk

################################################################################
# General
################################################################################
_MTB_RECIPE__PROGRAM_INTERFACE_SUPPORTED:=KitProg3 JLink
_MTB_RECIPE__DEBUG_INTERFACE_SUPPORTED:=swd
_MTB_RECIPE__DEFAULT_DEBUG_INTERFACE:=swd

#
# Compatibility interface for this recipe make
#
MTB_RECIPE__INTERFACE_VERSION:=2
MTB_RECIPE__EXPORT_INTERFACES:=1 2 3 4 5

MTB_RECIPE__NINJA_SUPPORT:=1 2

#
# List the supported toolchains
#
ifdef CY_SUPPORTED_TOOLCHAINS
MTB_SUPPORTED_TOOLCHAINS?=$(CY_SUPPORTED_TOOLCHAINS)
else
MTB_SUPPORTED_TOOLCHAINS?=GCC_ARM IAR ARM LLVM_ARM
endif

# For BWC with Makefiles that do anything with CY_SUPPORTED_TOOLCHAINS
CY_SUPPORTED_TOOLCHAINS:=$(MTB_SUPPORTED_TOOLCHAINS)

_MTB_RECIPE__START_FLASH:=0x00000000

#
# Architecture specifics
#
_MTB_RECIPE__OPENOCD_CHIP_NAME:=psoc4
_MTB_RECIPE__OPENOCD_DEVICE_CFG:=infineon/psoc4.cfg
_MTB_RECIPE__OPENOCD_OTHER_RUN_CMD?=mon psoc4 reset_halt
_MTB_RECIPE__OPENOCD_OTHER_RUN_CMD_ECLIPSE?=$(_MTB_RECIPE__OPENOCD_OTHER_RUN_CMD)&\#13;&\#10;
_MTB_RECIPE__JLINK_DEVICE_CFG_ATTACH:=Cortex-M0
_MTB_RECIPE__XRES_AVAILABLE:=1
_MTB_RECIPE__RESET_CONFIG:=reset_config srst_only

ifeq (CCG3PA,$(_MTB_RECIPE__DEVICE_DIE))
_MTB_RECIPE__XRES_AVAILABLE:=0
_MTB_RECIPE__RESET_CONFIG:=$(_MTB_RECIPE__OPENOCD_CHIP_NAME).cpu cortex_m reset_config sysresetreq
endif

ifeq (PAG2S,$(_MTB_RECIPE__DEVICE_DIE))
_MTB_RECIPE__OPENOCD_DEVICE_CFG:=infineon/pag2s.cfg
_MTB_RECIPE__OPENOCD_CHIP_NAME:=pag2s
endif

################################################################################
# Eclipse IDE — OpenOCD (KitProg3) overrides for PSoC 4
# PSoC 4 uses .cpu OpenOCD target suffix, PSOC4_USE_ACQUIRE instead of
# ENABLE_ACQUIRE / transport select, and a different run-command sequence.
################################################################################

# OpenOCD target core suffix for PSoC 4
_MTB_RECIPE__OPENOCD_DEBUG_TARGET_CORE:=cpu

# Debug
_MTB_RECIPE__ECLIPSE_OPENOCD_DEBUG_SECOND_RESET_TYPE=halt
_MTB_RECIPE__ECLIPSE_OPENOCD_DEBUG_GDB_CLIENT_OTHER_COMMANDS=set mem inaccessible-by-default off
_MTB_RECIPE__ECLIPSE_OPENOCD_DEBUG_OTHER_RUN_COMMANDS=$(_MTB_RECIPE__OPENOCD_OTHER_RUN_CMD_ECLIPSE)flushregs&\#13;&\#10;mon gdb_sync&\#13;&\#10;stepi

_MTB_RECIPE__ECLIPSE_OPENOCD_DEBUG_PRE_TARGET_COMMANDS=-c $(_MTB_RECIPE__ECLIPSE_QUOT)set PSOC4_USE_ACQUIRE $(_MTB_RECIPE__XRES_AVAILABLE)$(_MTB_RECIPE__ECLIPSE_QUOT)$(_MTB_RECIPE__ECLIPSE_NEWLINE)
_MTB_RECIPE__ECLIPSE_OPENOCD_DEBUG_PRE_TARGET_COMMANDS+=$(_MTB_RECIPE__ECLIPSE_OPENOCD_PROBE_SERIAL_CMD)

_MTB_RECIPE__ECLIPSE_OPENOCD_DEBUG_POST_TARGET_COMMANDS=-c $(_MTB_RECIPE__ECLIPSE_QUOT)$(_MTB_RECIPE__OPENOCD_CHIP_NAME).$(_MTB_RECIPE__OPENOCD_DEBUG_TARGET_CORE) configure -rtos auto -rtos-wipe-on-reset-halt 1$(_MTB_RECIPE__ECLIPSE_QUOT)$(_MTB_RECIPE__ECLIPSE_NEWLINE)
_MTB_RECIPE__ECLIPSE_OPENOCD_DEBUG_POST_TARGET_COMMANDS+=-c $(_MTB_RECIPE__ECLIPSE_QUOT)init; reset init;$(_MTB_RECIPE__OPENOCD_PROBE_FREQUENCY)$(_MTB_RECIPE__ECLIPSE_QUOT)

# Attach
_MTB_RECIPE__ECLIPSE_OPENOCD_ATTACH_DO_CONTINUE=true
_MTB_RECIPE__ECLIPSE_OPENOCD_ATTACH_GDB_CLIENT_OTHER_COMMANDS=set mem inaccessible-by-default off
_MTB_RECIPE__ECLIPSE_OPENOCD_ATTACH_OTHER_RUN_COMMANDS=flushregs&\#13;&\#10;mon gdb_sync&\#13;&\#10;stepi

_MTB_RECIPE__ECLIPSE_OPENOCD_ATTACH_PRE_TARGET_COMMANDS=-c $(_MTB_RECIPE__ECLIPSE_QUOT)set PSOC4_USE_ACQUIRE 0$(_MTB_RECIPE__ECLIPSE_QUOT)$(_MTB_RECIPE__ECLIPSE_NEWLINE)
_MTB_RECIPE__ECLIPSE_OPENOCD_ATTACH_PRE_TARGET_COMMANDS+=$(_MTB_RECIPE__ECLIPSE_OPENOCD_PROBE_SERIAL_CMD)

_MTB_RECIPE__ECLIPSE_OPENOCD_ATTACH_POST_TARGET_COMMANDS=-c $(_MTB_RECIPE__ECLIPSE_QUOT)$(_MTB_RECIPE__OPENOCD_CHIP_NAME).$(_MTB_RECIPE__OPENOCD_DEBUG_TARGET_CORE) configure -rtos auto -rtos-wipe-on-reset-halt 1$(_MTB_RECIPE__ECLIPSE_QUOT)

################################################################################
# Eclipse IDE — JLink overrides for PSoC 4
################################################################################

# JLink Debug
_MTB_RECIPE__ECLIPSE_JLINK_DEBUG_GDB_PORT_NUMBER:=2334
_MTB_RECIPE__ECLIPSE_JLINK_DEBUG_SWO_PORT_NUMBER:=2335
_MTB_RECIPE__ECLIPSE_JLINK_DEBUG_TELNET_PORT_NUMBER:=2336
_MTB_RECIPE__ECLIPSE_JLINK_DEBUG_FIRST_RESET_SPEED:=1000
_MTB_RECIPE__ECLIPSE_JLINK_DEBUG_FIRST_RESET_TYPE:=2
_MTB_RECIPE__ECLIPSE_JLINK_DEBUG_SECOND_RESET_TYPE:=2
_MTB_RECIPE__ECLIPSE_JLINK_DEBUG_INTERFACE_SPEED:=auto
_MTB_RECIPE__ECLIPSE_JLINK_DEBUG_GDB_CLIENT_OTHER_COMMANDS:=set mem inaccessible-by-default off
_MTB_RECIPE__ECLIPSE_JLINK_DEBUG_ALLOCATE_SEMIHOSTING_CONSOLE:=true
_MTB_RECIPE__ECLIPSE_JLINK_DEBUG_OTHER_RUN_COMMANDS:=monitor reset 0
_MTB_RECIPE__ECLIPSE_JLINK_DEBUG_LOAD_IMAGE:=true
_MTB_RECIPE__ECLIPSE_JLINK_DEBUG_GDB_SERVER_DEVICE_NAME=$(DEVICE)

# JLink Attach
_MTB_RECIPE__ECLIPSE_JLINK_ATTACH_GDB_PORT_NUMBER:=2334
_MTB_RECIPE__ECLIPSE_JLINK_ATTACH_SWO_PORT_NUMBER:=2335
_MTB_RECIPE__ECLIPSE_JLINK_ATTACH_TELNET_PORT_NUMBER:=2336
_MTB_RECIPE__ECLIPSE_JLINK_ATTACH_FIRST_RESET_TYPE:=2
_MTB_RECIPE__ECLIPSE_JLINK_ATTACH_GDB_CLIENT_OTHER_COMMANDS:=set mem inaccessible-by-default off
_MTB_RECIPE__ECLIPSE_JLINK_ATTACH_OTHER_RUN_COMMANDS:=
_MTB_RECIPE__ECLIPSE_JLINK_ATTACH_ATTR_BUILD_BEFORE_LAUNCH:=0
_MTB_RECIPE__ECLIPSE_JLINK_ATTACH_GDB_SERVER_DEVICE_NAME=$(_MTB_RECIPE__JLINK_DEVICE_CFG_ATTACH)
_MTB_RECIPE__ECLIPSE_JLINK_ATTACH_ENABLE_SEMIHOSTING:=false
_MTB_RECIPE__ECLIPSE_JLINK_ATTACH_ENABLE_SEMIHOSTING_GDB_CLIENT:=false
_MTB_RECIPE__ECLIPSE_JLINK_ATTACH_ENABLE_SEMIHOSTING_TELNET_CLIENT:=false
_MTB_RECIPE__ECLIPSE_JLINK_ATTACH_INTERFACE_SPEED:=auto
