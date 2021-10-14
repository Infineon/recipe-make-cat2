################################################################################
# \file defines.mk
#
# \brief
# Defines, needed for the PSoC 4 build recipe.
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

include $(CY_INTERNAL_BASELIB_PATH)/make/recipe/defines_common.mk


################################################################################
# General
################################################################################

#
# List the supported toolchains
#
CY_SUPPORTED_TOOLCHAINS=GCC_ARM IAR ARM

#
# Define the default core
#
ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_M0)))
CORE=CM0
else
CORE=CM0P
endif
CY_START_FLASH=0x00000000
CY_START_SRAM=0x20000000

#
# Architecure specifics
#
CY_OPENOCD_CHIP_NAME=psoc4
CY_OPENOCD_DEVICE_CFG=psoc4.cfg
CY_OPENOCD_OTHER_RUN_CMD?=mon psoc4 reset_halt
CY_OPENOCD_OTHER_RUN_CMD_ECLIPSE?=$(CY_OPENOCD_OTHER_RUN_CMD)\&\#13;\&\#10;
CY_JLINK_DEVICE_CFG_ATTACH=Cortex-M0
CY_XRES_AVAILABLE=1
CY_RESET_CONFIG=reset_config srst_only

ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_DIE_PSOC4AS1)))
CY_PSOC_DIE_NAME=PSoC4AS1
else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_DIE_PSOC4AS2)))
CY_PSOC_DIE_NAME=PSoC4AS2
else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_DIE_PSOC4AS3)))
CY_PSOC_DIE_NAME=PSoC4AS3
else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_DIE_PSOC4AMC)))
CY_PSOC_DIE_NAME=PSoC4AMC
else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_DIE_PSOC4AS4)))
CY_PSOC_DIE_NAME=PSoC4AS4
else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_DIE_CCG3PA)))
CY_PSOC_DIE_NAME=CCG3PA
CY_XRES_AVAILABLE=0
CY_RESET_CONFIG=$(CY_OPENOCD_CHIP_NAME).cpu cortex_m reset_config sysresetreq
else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_DIE_CCG6)))
CY_PSOC_DIE_NAME=CCG6
else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_DIE_CCG3)))
CY_PSOC_DIE_NAME=CCG3
else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_DIE_PMG1S3)))
CY_PSOC_DIE_NAME=PMG1S3
else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_DIE_CCG7D)))
CY_PSOC_DIE_NAME=CCG7D
else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_DIE_CCG7S)))
CY_PSOC_DIE_NAME=CCG7S
else
$(call CY_MACRO_ERROR,Incorrect part number $(DEVICE). Check DEVICE variable.)
endif

#
# Flash memory specifics
#
ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_FLASH_KB_16)))
CY_MEMORY_FLASH=16384
else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_FLASH_KB_32)))
CY_MEMORY_FLASH=32768
else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_FLASH_KB_64)))
CY_MEMORY_FLASH=65536
else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_FLASH_KB_128)))
CY_MEMORY_FLASH=131072
else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_FLASH_KB_256)))
CY_MEMORY_FLASH=262144
else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_FLASH_KB_384)))
CY_MEMORY_FLASH=393216
else
$(call CY_MACRO_ERROR,No Flash memory size defined for $(DEVICE))
endif

#
# SRAM memory specifics
#
ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_SRAM_KB_2)))
CY_MEMORY_SRAM=2048
else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_SRAM_KB_4)))
CY_MEMORY_SRAM=4096
else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_SRAM_KB_8)))
CY_MEMORY_SRAM=8192
else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_SRAM_KB_12)))
CY_MEMORY_SRAM=12288
else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_SRAM_KB_16)))
CY_MEMORY_SRAM=16384
else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_SRAM_KB_32)))
CY_MEMORY_SRAM=32768
else
$(call CY_MACRO_ERROR,No SRAM memory size defined for $(DEVICE))
endif

# Architecture specifics
CY_MACRO_STARTUP_CALC=$(strip \
	$(if $(findstring $(1),$(CY_DEVICES_WITH_DIE_PSOC4AS1)),\
	psoc4000s,\
	$(if $(findstring $(1),$(CY_DEVICES_WITH_DIE_PSOC4AS2)),\
	psoc4100s,\
	$(if $(findstring $(1),$(CY_DEVICES_WITH_DIE_PSOC4AS3)),\
	psoc4100sp,\
	$(if $(findstring $(1),$(CY_DEVICES_WITH_DIE_PSOC4AMC)),\
	psoc4100sp256kb,\
	$(if $(findstring $(1),$(CY_DEVICES_WITH_DIE_PSOC4AS4)),\
	psoc4100smax,\
	$(if $(findstring $(1),$(CY_DEVICES_WITH_DIE_CCG3PA)),\
	pmg1s0,\
	$(if $(findstring $(1),$(CY_DEVICES_WITH_DIE_CCG6)),\
	pmg1s1,\
	$(if $(findstring $(1),$(CY_DEVICES_WITH_DIE_CCG3)),\
	pmg1s2,\
	$(if $(findstring $(1),$(CY_DEVICES_WITH_DIE_PMG1S3)),\
	pmg1s3,\
	$(if $(findstring $(1),$(CY_DEVICES_WITH_DIE_CCG7D)),\
	ccg7d,\
	$(if $(findstring $(1),$(CY_DEVICES_WITH_DIE_CCG7S)),\
	ccg7s,\
	))))))))))))

#
# linker scripts
#

CY_MACRO_LINKER_CALC=$(strip \
	$(if $(findstring $(1),$(CY_DEVICES_WITH_DIE_CCG3PA)),\
	pmg1s0,\
	$(if $(findstring $(1),$(CY_DEVICES_WITH_DIE_CCG6)),\
	pmg1s1,\
	$(if $(findstring $(1),$(CY_DEVICES_WITH_DIE_CCG3)),\
	pmg1s2,\
	$(if $(findstring $(1),$(CY_DEVICES_WITH_DIE_PMG1S3)),\
	pmg1s3,\
	$(if $(findstring $(1),$(CY_DEVICES_WITH_DIE_CCG7D)),\
	ccg7d,\
	$(if $(findstring $(1),$(CY_DEVICES_WITH_DIE_CCG7S)),\
	ccg7s,\
	$(if $(findstring $(1),$(CY_DEVICES_WITH_FLASH_KB_16)),\
	$(if $(findstring $(1),$(CY_DEVICES_WITH_SRAM_KB_4)),\
	cy8c4xx4,\
	$(if $(findstring CY8C47,$(1)),\
	cy8c47x4,cy8c40x4)),\
	$(if $(findstring $(1),$(CY_DEVICES_WITH_FLASH_KB_32)),\
	cy8c4xx5,\
	$(if $(findstring $(1),$(CY_DEVICES_WITH_FLASH_KB_64)),\
	$(if $(findstring $(1),$(CY_DEVICES_WITH_SRAM_KB_8)),\
	cy8c4xx6,cy8c45x6),\
	$(if $(findstring $(1),$(CY_DEVICES_WITH_FLASH_KB_128)),\
	$(if $(findstring $(1),$(CY_DEVICES_WITH_SRAM_KB_16)),\
	cy8c4xx7,cy8c45x7),\
	$(if $(findstring $(1),$(CY_DEVICES_WITH_FLASH_KB_256)),\
	cy8c4xx8,\
	$(if $(findstring $(1),$(CY_DEVICES_WITH_FLASH_KB_384)),\
	cy8c4xx9,\
	)))))))))))))

CY_STARTUP=$(call CY_MACRO_STARTUP_CALC,$(DEVICE))
CY_LINKER_SCRIPT_NAME=$(call CY_MACRO_LINKER_CALC,$(DEVICE))
ifeq ($(CY_LINKER_SCRIPT_NAME),)
$(call CY_MACRO_ERROR,Could not resolve device series for linker script)
endif

#
# QSPI
#
CY_QSPI_CMSIS_FLM_FILE_NAME=CY8C4xxx.FLM
CY_QSPI_IAR_FLM_FILE_NAME=FlashCY8C4xxx.out

################################################################################
# BSP generation
################################################################################

DEVICE_GEN?=$(DEVICE)

CY_BSP_STARTUP=$(call CY_MACRO_STARTUP_CALC,$(DEVICE_GEN))
CY_BSP_LINKER_SCRIPT=$(call CY_MACRO_LINKER_CALC,$(DEVICE_GEN))

# Paths
CY_BSP_TEMPLATES_DIR=$(CY_CONDITIONAL_DEVICESUPPORT_PATH)/devices/COMPONENT_CAT2/templates/COMPONENT_MTB
ifeq ($(wildcard $(CY_BSP_TEMPLATES_DIR)),)
CY_BSP_TEMPLATES_DIR=$(CY_CONDITIONAL_DEVICESUPPORT_PATH)/devices/templates/COMPONENT_MTB
endif
CY_TEMPLATES_DIR=$(CY_BSP_TEMPLATES_DIR)
CY_BSP_DESTINATION_ABSOLUTE=$(abspath $(CY_TARGET_GEN_DIR))

ifeq ($(strip $(CY_BSP_LINKER_SCRIPT) $(CY_BSP_STARTUP)),)
CY_BSP_TEMPLATES_CMD=echo "Could not locate template linker scripts and startup files for DEVICE $(DEVICE_GEN). Skipping update...";
endif

# Command for searching files in the template directory
CY_BSP_SEARCH_FILES_CMD=\
	-name system_cat2* \
	-o -name *$(CY_BSP_STARTUP)\.* \
	-o -name *$(CY_BSP_LINKER_SCRIPT)\.*

# Command for searching old bsp template files in the template directory to backup
CY_SEARCH_FILES_CMD=
# system_cat2* is not in this list because it is same across all cat2 devices.
ifneq ($(CY_STARTUP),$(CY_BSP_STARTUP))
CY_SEARCH_FILES_CMD+=-name *$(CY_STARTUP)\.*
endif

ifneq ($(CY_LINKER_SCRIPT_NAME),$(CY_BSP_LINKER_SCRIPT))

ifneq ($(CY_SEARCH_FILES_CMD),)
CY_SEARCH_FILES_CMD+=-o
endif
CY_SEARCH_FILES_CMD+=-name *$(CY_LINKER_SCRIPT_NAME)\.*
endif

################################################################################
# Paths
################################################################################

# Paths used in program/debug
ifeq ($(CY_DEVICESUPPORT_PATH),)
CY_ECLIPSE_OPENOCD_SVD_PATH?=$$\{cy_prj_path\}/$(dir $(firstword $(CY_DEVICESUPPORT_SEARCH_PATH)))devices/svd/$(CY_STARTUP).svd
CY_VSCODE_OPENOCD_SVD_PATH?=$(dir $(firstword $(CY_DEVICESUPPORT_SEARCH_PATH)))devices/svd/$(CY_STARTUP).svd
else
CY_ECLIPSE_OPENOCD_SVD_PATH?=$$\{cy_prj_path\}/$(CY_DEVICESUPPORT_PATH)/devices/svd/$(CY_STARTUP).svd
CY_VSCODE_OPENOCD_SVD_PATH?=$(CY_DEVICESUPPORT_PATH)/devices/svd/$(CY_STARTUP).svd
endif

################################################################################
# IDE specifics
################################################################################

ifeq ($(filter vscode,$(MAKECMDGOALS)),vscode)
CY_VSCODE_ARGS+="s|&&DEVICE&&|$(DEVICE)|g;"\
				"s|&&CY_XRES_AVAILABLE&&|$(CY_XRES_AVAILABLE)|g;"\
				"s|&&CY_RESET_CONFIG&&|$(CY_RESET_CONFIG)|g;"
endif

ifeq ($(filter eclipse,$(MAKECMDGOALS)),eclipse)
CY_ECLIPSE_ARGS+="s|&&CY_OPENOCD_OTHER_RUN_CMD&&|$(CY_OPENOCD_OTHER_RUN_CMD_ECLIPSE)|g;"\
				"s|&&CY_JLINK_CFG_PROGRAM&&|$(DEVICE)|g;"\
				"s|&&CY_JLINK_CFG_DEBUG&&|$(DEVICE)|g;"\
				"s|&&CY_JLINK_CFG_ATTACH&&|$(CY_JLINK_DEVICE_CFG_ATTACH)|g;"\
				"s|&&CY_XRES_AVAILABLE&&|$(CY_XRES_AVAILABLE)|g;"\
				"s|&&CY_RESET_CONFIG&&|$(CY_RESET_CONFIG)|g;"
endif

CY_IAR_DEVICE_NAME=$(DEVICE)

CY_CMSIS_ARCH_NAME=PSoC4_DFP
CY_CMSIS_VENDOR_NAME=Cypress
CY_CMSIS_VENDOR_ID=19
CY_CMSIS_SPECIFY_CORE=1

################################################################################
# Tools specifics
################################################################################

modus_DEFAULT_TYPE+=device-configurator

# Check if device supports SmartIO
ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_DIE_PSOC4AS1)\
								$(CY_DEVICES_WITH_DIE_PSOC4AS2)\
								$(CY_DEVICES_WITH_DIE_PSOC4AS3)\
								$(CY_DEVICES_WITH_DIE_PSOC4AS4)\
								$(CY_DEVICES_WITH_DIE_PSOC4AMC)))
CY_SUPPORTED_TOOL_TYPES+=smartio-configurator
# PSoC 4 smartio also uses the .modus extension
modus_DEFAULT_TYPE+=smartio-configurator
endif

# PSoC 4 capsense-tuner shares its existence with capsense-configurator
CY_OPEN_NEWCFG_XML_TYPES+=capsense-tuner

CY_SUPPORTED_TOOL_TYPES+=\
	device-configurator\
	seglcd-configurator\
	dfuh-tool\
	lin-configurator
	
ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_USBPD)))
CY_SUPPORTED_TOOL_TYPES+=ez-pd-configurator
endif
