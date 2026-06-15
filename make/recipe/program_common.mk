################################################################################
# \file program_common.mk
#
# \brief
# Common variables and targets for program.mk
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

################################################################################
# QSPI programming flags
# NOTE: These flags are also used to generate IDE launch config
################################################################################

# get the path of design.cyqspi file
_MTB_RECIPE__QSPI_CONFIG_FILE:=$(filter %.cyqspi,$(CY_SEARCH_ALL_FILES))
ifeq ($(_MTB_RECIPE__QSPI_CONFIG_FILE),)
_MTB_RECIPE__QSPI_CONFIG_FILE:=$(call mtb_core__rwildcard,$(SEARCH_TARGET_$(TARGET)),%.cyqspi)
endif

ifneq ($(words $(_MTB_RECIPE__QSPI_CONFIG_FILE)),1)
ifneq ($(words $(_MTB_RECIPE__QSPI_CONFIG_FILE)),0)
$(warning Multiple .cyqspi files found: $(_MTB_RECIPE__QSPI_CONFIG_FILE) -- using the first. If a different .cyqspi file is required, remove the extra .cyqspi files)
 _MTB_RECIPE__QSPI_CONFIG_FILE:=$(word 1,$(_MTB_RECIPE__QSPI_CONFIG_FILE))
endif
endif

ifeq ($(_MTB_RECIPE__QSPI_CONFIG_FILE),)
_MTB_RECIPE__OPENOCD_QSPI_CFG_PATH:=
_MTB_RECIPE__OPENOCD_QSPI_CFG_PATH_WITH_FLAG:=
_MTB_RECIPE__OPENOCD_QSPI_CFG_PATH_APPLICATION_WITH_FLAG:=
else
_MTB_RECIPE__OPENOCD_QSPI_CFG_PATH:=$(call mtb__get_dir,$(_MTB_RECIPE__QSPI_CONFIG_FILE))/GeneratedSource
_MTB_RECIPE__OPENOCD_QSPI_CFG_PATH_WITH_FLAG:=-s &quot;$(_MTB_RECIPE__OPENOCD_QSPI_CFG_PATH)&quot;&\#13;&\#10;
_MTB_RECIPE__OPENOCD_QSPI_CFG_PATH_APPLICATION_WITH_FLAG:=-s &quot;$(patsubst $(call mtb_path_normalize,$(MTB_TOOLS__PRJ_DIR)/..)/%,%,$(call mtb_path_normalize,$(_MTB_RECIPE__OPENOCD_QSPI_CFG_PATH)))&quot;&\#13;&\#10;
endif
_MTB_RECIPE__OPENOCD_QSPI_CFG_PATH_APPLICATION:=$(patsubst $(call mtb_path_normalize,$(MTB_TOOLS__PRJ_DIR)/..)/%,%,$(call mtb_path_normalize,$(_MTB_RECIPE__OPENOCD_QSPI_CFG_PATH)))

_MTB_RECIPE__OPENOCD_SCRIPTS=-s $(CY_TOOL_openocd_scripts_SCRIPT_ABS)

ifneq ($(MTB_PROBE_FREQUENCY_KHZ),)
_MTB_RECIPE__OPENOCD_PROBE_FREQUENCY:=adapter speed $(MTB_PROBE_FREQUENCY_KHZ);
endif

_MTB_RECIPE__OPENOCD_INTERFACE=source [find interface/kitprog3.cfg];
_MTB_RECIPE__OPENOCD_TARGET_SOURCE=source [find target/$(_MTB_RECIPE__OPENOCD_DEVICE_CFG)];

_MTB_RECIPE__OPENOCD_TARGET=$(_MTB_RECIPE__OPENOCD_TARGET_SOURCE)$(_MTB_RECIPE__OPENOCD_PROBE_FREQUENCY)
ifeq ($(_MTB_RECIPE__OPENOCD_QSPI_CFG_PATH),)
_MTB_RECIPE__OPENOCD_QSPI=
else ifneq ($(_MTB_RECIPE__NO_QSPI),)
_MTB_RECIPE__OPENOCD_QSPI=
else
_MTB_RECIPE__OPENOCD_QSPI=-s $(_MTB_RECIPE__OPENOCD_QSPI_CFG_PATH)
endif

ifneq ($(MTB_PROBE_SERIAL),)
_MTB_RECIPE__OPENOCD_PROBE_SERIAL:=adapter serial $(MTB_PROBE_SERIAL);
_MTB_RECIPE__JLINK_PROBE_SERIAL:=-USB $(MTB_PROBE_SERIAL)
endif

_MTB_RECIPE__PROBE_INTERFACE:=swd
ifneq ($(MTB_PROBE_INTERFACE),)
_MTB_RECIPE__PROBE_INTERFACE:=$(MTB_PROBE_INTERFACE)
endif

ifeq ($(MTB_PROBE_INTERFACE),jtag)
_MTB_RECIPE__JLINK_JTAG_CONF=-JTAGConf -1,-1
endif

ifneq ($(MTB_ERASE_EXT_MEM),)
_MTB_RECIPE__OPENOCD_ERASE_EXT_MEM=$(_MTB_RECIPE__OPENOCD_QSPI)
_MTB_RECIPE__JLINK_ENABLE_EXT_MEM_ERASE:=exec EnableEraseAllFlashBanks
endif

ifeq ($(_MTB_RECIPE__PROGRAM_INTERFACE_SUBDIR), JLink)
_MTB_RECIPE__GDB_SERVER=$(MTB_CORE__JLINK_GDB_EXE)
_MTB_RECIPE__PROGRAM_ERASE_TOOL=$(MTB_CORE__JLINK_EXE)
_MTB_RECIPE__ERASE_ARGS=-AutoConnect 1 -ExitOnError 1 -NoGui 1 $(_MTB_RECIPE__JLINK_PROBE_SERIAL) -Device $(_MTB_RECIPE__JLINK_DEVICE_CFG_PROGRAM) -If $(_MTB_RECIPE__PROBE_INTERFACE) $(_MTB_RECIPE__JLINK_JTAG_CONF) -Speed auto -CommandFile $(MTB_TOOLS__OUTPUT_CONFIG_DIR)/erase.jlink
_MTB_RECIPE__PROGRAM_ARGS=-AutoConnect 1 -ExitOnError 1 -NoGui 1 $(_MTB_RECIPE__JLINK_PROBE_SERIAL) -Device $(_MTB_RECIPE__JLINK_DEVICE_CFG_PROGRAM) -If $(_MTB_RECIPE__PROBE_INTERFACE) $(_MTB_RECIPE__JLINK_JTAG_CONF) -Speed auto -CommandFile $(MTB_TOOLS__OUTPUT_CONFIG_DIR)/program.jlink
_MTB_RECIPE__DEBUG_ARGS=$(_MTB_RECIPE__JLINK_DEBUG_ARGS)
else
_MTB_RECIPE__GDB_SERVER=$(CY_TOOL_openocd_EXE_ABS)
_MTB_RECIPE__PROGRAM_ERASE_TOOL=$(CY_TOOL_openocd_EXE_ABS)
_MTB_RECIPE__ERASE_ARGS=$(_MTB_RECIPE__OPENOCD_ERASE_ARGS)
_MTB_RECIPE__PROGRAM_ARGS=$(_MTB_RECIPE__OPENOCD_PROGRAM_ARGS)
_MTB_RECIPE__DEBUG_ARGS=$(_MTB_RECIPE__OPENOCD_DEBUG_ARGS)
endif

# Generate command files required by JLink tool for programming/erasing
jlink_generate:
	$(MTB__NOISE)sed "s|&&PROG_FILE&&|$(_MTB_RECIPE__OPENOCD_PROGRAM_IMG)|g;" $(MTB_TOOLS__RECIPE_DIR)/make/scripts/program.jlink > $(MTB_TOOLS__OUTPUT_CONFIG_DIR)/program.jlink
	$(MTB__NOISE)sed "s|&&ERASE_OPTION&&|$(_MTB_RECIPE_JLINK_CMDFILE_ERASE)|g;" $(MTB_TOOLS__OUTPUT_CONFIG_DIR)/program.jlink > $(MTB_TOOLS__OUTPUT_CONFIG_DIR)/_program.jlink
	$(MTB__NOISE)sed "s|&&SECOND_PROG_FILE&&|$(_MTB_RECIPE__OPENOCD_ADDITIONAL_IMG)|g;" $(MTB_TOOLS__OUTPUT_CONFIG_DIR)/_program.jlink > $(MTB_TOOLS__OUTPUT_CONFIG_DIR)/program.jlink
	$(MTB__NOISE)sed "s|&&_MTB_RECIPE__JLINK_ENABLE_EXT_MEM_ERASE&&|$(_MTB_RECIPE__JLINK_ENABLE_EXT_MEM_ERASE)|g;" $(MTB_TOOLS__RECIPE_DIR)/make/scripts/erase.jlink > $(MTB_TOOLS__OUTPUT_CONFIG_DIR)/erase.jlink
	$(MTB__NOISE)if [ -z "$(_MTB_RECIPE__JLINK_ERASE_EXT_MEM)" ]; then \
		sed -e 's/&&_MTB_RECIPE__JLINK_ERASE_EXT_MEM&&//' $(MTB_TOOLS__OUTPUT_CONFIG_DIR)/erase.jlink > $(MTB_TOOLS__OUTPUT_CONFIG_DIR)/_erase.jlink; \
	else \
		sed -e '/&&_MTB_RECIPE__JLINK_ERASE_EXT_MEM&&/r /dev/stdin' $(MTB_TOOLS__OUTPUT_CONFIG_DIR)/erase.jlink <<< "$(_MTB_RECIPE__JLINK_ERASE_EXT_MEM)" > $(MTB_TOOLS__OUTPUT_CONFIG_DIR)/_erase.jlink; \
		sed -i -e '/&&_MTB_RECIPE__JLINK_ERASE_EXT_MEM&&/d' $(MTB_TOOLS__OUTPUT_CONFIG_DIR)/_erase.jlink; \
		sed -i -e 's/|/\n/g' $(MTB_TOOLS__OUTPUT_CONFIG_DIR)/_erase.jlink; \
	fi
	$(MTB__NOISE)mv -f $(MTB_TOOLS__OUTPUT_CONFIG_DIR)/_erase.jlink $(MTB_TOOLS__OUTPUT_CONFIG_DIR)/erase.jlink

jlink_path_check:
ifeq ($(LIBNAME),)
	$(MTB__NOISE)echo;\
	if [ -z "$(_MTB_RECIPE__PROGRAM_ERASE_TOOL)" ]; then\
		echo "ERROR: Location of J-Link is not set. Use the MTB_JLINK_DIR variable to set the location of the J-Link directory.";\
		echo;\
		exit 1;\
	fi
endif

erase: erase_$(_MTB_RECIPE__PROGRAM_INTERFACE_SUBDIR)

_MTB_RECIPE__ERASING_TARGET_MSG?="Erasing target device..."
erase_$(_MTB_RECIPE__PROGRAM_INTERFACE_SUBDIR): debug_interface_check
	$(MTB__NOISE)echo;\
	echo $(_MTB_RECIPE__ERASING_TARGET_MSG);\
	"$(_MTB_RECIPE__PROGRAM_ERASE_TOOL)" $(_MTB_RECIPE__ERASE_ARGS)

program_proj: program_$(_MTB_RECIPE__PROGRAM_INTERFACE_SUBDIR)

program_$(_MTB_RECIPE__PROGRAM_INTERFACE_SUBDIR): build_proj memcalc

program_JLink qprogram_JLink: jlink_generate jlink_path_check
erase_JLink: jlink_generate

qprogram_proj: qprogram_$(_MTB_RECIPE__PROGRAM_INTERFACE_SUBDIR)

program_$(_MTB_RECIPE__PROGRAM_INTERFACE_SUBDIR) qprogram_$(_MTB_RECIPE__PROGRAM_INTERFACE_SUBDIR): debug_interface_check jlink_generate
ifeq ($(LIBNAME),)
	$(MTB__NOISE)echo;\
	"$(_MTB_RECIPE__PROGRAM_ERASE_TOOL)" $(_MTB_RECIPE__PROGRAM_ARGS)
else
	$(MTB__NOISE)echo "Library application detected. Skip programming... ";\
	echo
endif

debug: program_proj qdebug_$(_MTB_RECIPE__PROGRAM_INTERFACE_SUBDIR)

qdebug qdebug_$(_MTB_RECIPE__PROGRAM_INTERFACE_SUBDIR): qprogram_proj debug_interface_check
ifeq ($(LIBNAME),)
	$(MTB__NOISE)echo;\
	echo ==============================================================================;\
	echo "Instruction:";\
	echo "Open a separate shell and run the attach target (make attach)";\
	echo "to start the GDB client. Then use the GDB commands to debug.";\
	echo ==============================================================================;\
	echo;\
	echo "Opening GDB port ... ";\
	"$(_MTB_RECIPE__GDB_SERVER)" $(_MTB_RECIPE__DEBUG_ARGS)
else
	$(MTB__NOISE)echo "Library application detected. Skip debug... ";\
	echo
endif

attach: debug_interface_check
	$(MTB__NOISE)echo;\
	echo "Starting GDB Client... ";\
	$(MTB_TOOLCHAIN_GCC_ARM__GDB) $(_MTB_RECIPE__OPENOCD_SYMBOL_IMG) -x $(_MTB_RECIPE__GDB_ARGS)

################################################################################
# Advanced KitProg3 Programming (mtb-programmer)
################################################################################

# 1) Default: project hex file (includes _MTB_RECIPE__PROG_FILE_SUFFIX for recipes
#    that post-process into a .final.hex, e.g. CYW20829)
_MTB_RECIPE__ADVANCED_PROGRAM_HEX_FILE:=$(MTB_RECIPE__LAST_CONFIG_DIR)/$(APPNAME)$(_MTB_RECIPE__PROG_FILE_SUFFIX).$(MTB_RECIPE__SUFFIX_PROGRAM)

# 2) Override with combiner-signer hex if available
_MTB_RECIPE__ADVANCED_PROGRAM_CS_IDX:=$(lastword $(MTB_COMBINE_SIGN_$(notdir $(realpath $(MTB_TOOLS__PRJ_DIR)))_HEX_FILES))
ifneq ($(MTB_COMBINE_SIGN_$(_MTB_RECIPE__ADVANCED_PROGRAM_CS_IDX)_HEX_PATH),)
_MTB_RECIPE__ADVANCED_PROGRAM_HEX_FILE:=$(MTB_COMBINE_SIGN_$(_MTB_RECIPE__ADVANCED_PROGRAM_CS_IDX)_HEX_PATH)
endif

# 3) Multi-core application programming: always use combined HEX image
ifneq ($(_MTB_RECIPE__APP_HEX_FILE),)
_MTB_RECIPE__ADVANCED_PROGRAM_HEX_FILE:=$(_MTB_RECIPE__APP_HEX_FILE)
endif

# 4) Use custom HEX image when PROG_FILE was provided by the user
ifneq ($(PROG_FILE),)
_MTB_RECIPE__ADVANCED_PROGRAM_HEX_FILE:=$(PROG_FILE)
endif

advanced_program:
ifneq (KitProg3,$(_MTB_RECIPE__PROGRAM_INTERFACE_SUBDIR))
	$(error The advanced_program target requires the KitProg3 interface. \
	Current interface is "$(_MTB_RECIPE__PROGRAM_INTERFACE_SUBDIR)". \
	Set BSP_PROGRAM_INTERFACE=KitProg3 or use the "program" target instead)
endif
ifeq ($(LIBNAME),)
	$(MTB__NOISE)echo;\
	echo "Programming target device with mtb-programmer...";\
	"$(CY_TOOL_mtb-programmer_EXE_ABS)" \
		--serial "$(MTB_PROBE_SERIAL)" \
		--hexfile "$(call mtb__path_normalize,$(_MTB_RECIPE__ADVANCED_PROGRAM_HEX_FILE))" \
		--mpn $(DEVICE) \
		$(_MTB_RECIPE__ADVANCED_PROGRAM_EXTRA_ARGS) \
		$(MTB__JOB_BACKGROUND)
else
	$(MTB__NOISE)echo "Library application detected. Skip programming... ";\
	echo
endif

.PHONY: erase program program_proj
.PHONY: qprogram qprogram_proj debug qdebug attach advanced_program
.PHONY: erase_$(_MTB_RECIPE__PROGRAM_INTERFACE_SUBDIR) jlink_generate program_$(_MTB_RECIPE__PROGRAM_INTERFACE_SUBDIR)
.PHONY: qprogram_$(_MTB_RECIPE__PROGRAM_INTERFACE_SUBDIR) debug_$(_MTB_RECIPE__PROGRAM_INTERFACE_SUBDIR) qdebug_$(_MTB_RECIPE__PROGRAM_INTERFACE_SUBDIR)
