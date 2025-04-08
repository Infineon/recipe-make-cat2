################################################################################
# \file defines.mk
#
# \brief
# Defines, needed for the PSOC(TM) 4 build recipe.
#
################################################################################
# \copyright
# (c) 2018-2025, Cypress Semiconductor Corporation (an Infineon company)
# or an affiliate of Cypress Semiconductor Corporation. All rights reserved.
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
# Compactibility interface for this recipe make
#
MTB_RECIPE__INTERFACE_VERSION:=2
MTB_RECIPE__EXPORT_INTERFACES:=1 2 3 4

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
# Architecure specifics
#
_MTB_RECIPE__OPENOCD_CHIP_NAME:=psoc4
_MTB_RECIPE__OPENOCD_DEVICE_CFG:=psoc4.cfg
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
_MTB_RECIPE__OPENOCD_DEVICE_CFG:=pag2s.cfg
_MTB_RECIPE__OPENOCD_CHIP_NAME:=pag2s
endif
