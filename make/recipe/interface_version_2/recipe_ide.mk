################################################################################
# \file recipe_ide.mk
#
# \brief
# This make file defines the IDE export variables and target.
#
################################################################################
# \copyright
# (c) 2022-2025, Cypress Semiconductor Corporation (an Infineon company)
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

##############################################
# General
##############################################
MTB_RECIPE__IDE_SUPPORTED:=eclipse vscode uvision5 ewarm8
include $(MTB_TOOLS__RECIPE_DIR)/make/recipe/interface_version_2/recipe_ide_common.mk

##############################################
# Eclipse VSCode
##############################################
_MTB_RECIPE__IDE_TEXT_DATA_FILE=$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/recipe_ide_text_data.txt
_MTB_RECIPE__IDE_TEMPLATE_META_DATA_FILE:=$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/recipe_ide_template_meta_data.txt

##############################################
# Eclipse
##############################################
eclipse_generate: recipe_eclipse_text_replacement_data_file recipe_eclipse_meta_replacement_data_file
eclipse_generate: MTB_CORE__EXPORT_CMDLINE += -textdata $(_MTB_RECIPE__IDE_TEXT_DATA_FILE)  -metadata $(_MTB_RECIPE__IDE_TEMPLATE_META_DATA_FILE)

recipe_eclipse_meta_replacement_data_file:
	$(call mtb__file_write,$(_MTB_RECIPE__IDE_TEMPLATE_META_DATA_FILE),TEMPLATE_REPLACE=$(_MTB_RECIPE__IDE_TEMPLATE_DIR)/eclipse/$(_MTB_RECIPE__PROGRAM_INTERFACE_SUBDIR)=.mtbLaunchConfigs)
	$(call mtb__file_append,$(_MTB_RECIPE__IDE_TEMPLATE_META_DATA_FILE),UUID=&&PROJECT_UUID&&)

recipe_eclipse_text_replacement_data_file:
	$(call mtb__file_write,$(_MTB_RECIPE__IDE_TEXT_DATA_FILE),&&_MTB_RECIPE__OPENOCD_OTHER_RUN_CMD&&=$(_MTB_RECIPE__OPENOCD_OTHER_RUN_CMD_ECLIPSE))
	$(call mtb__file_append,$(_MTB_RECIPE__IDE_TEXT_DATA_FILE),&&_MTB_RECIPE__JLINK_CFG_PROGRAM&&=$(DEVICE))
	$(call mtb__file_append,$(_MTB_RECIPE__IDE_TEXT_DATA_FILE),&&_MTB_RECIPE__JLINK_CFG_DEBUG&&=$(DEVICE))
	$(call mtb__file_append,$(_MTB_RECIPE__IDE_TEXT_DATA_FILE),&&_MTB_RECIPE__JLINK_CFG_ATTACH&&=$(_MTB_RECIPE__JLINK_DEVICE_CFG_ATTACH))
	$(call mtb__file_append,$(_MTB_RECIPE__IDE_TEXT_DATA_FILE),&&_MTB_RECIPE__XRES_AVAILABLE&&=$(_MTB_RECIPE__XRES_AVAILABLE))
	$(call mtb__file_append,$(_MTB_RECIPE__IDE_TEXT_DATA_FILE),&&_MTB_RECIPE__RESET_CONFIG&&=$(_MTB_RECIPE__RESET_CONFIG))

.PHONY: recipe_eclipse_text_replacement_data_file recipe_eclipse_meta_replacement_data_file

##############################################
# VSCode
##############################################
vscode_generate: recipe_vscode_text_replacement_data_file recipe_vscode_meta_replacement_data_file
vscode_generate: MTB_CORE__EXPORT_CMDLINE += -textdata $(_MTB_RECIPE__IDE_TEXT_DATA_FILE)  -metadata $(_MTB_RECIPE__IDE_TEMPLATE_META_DATA_FILE)

recipe_vscode_text_replacement_data_file:
	$(call mtb__file_write,$(_MTB_RECIPE__IDE_TEXT_DATA_FILE),&&DEVICE&&=$(DEVICE))
	$(call mtb__file_append,$(_MTB_RECIPE__IDE_TEXT_DATA_FILE),&&_MTB_RECIPE__XRES_AVAILABLE&&=$(_MTB_RECIPE__XRES_AVAILABLE))
	$(call mtb__file_append,$(_MTB_RECIPE__IDE_TEXT_DATA_FILE),&&_MTB_RECIPE__RESET_CONFIG&&=$(_MTB_RECIPE__RESET_CONFIG))

recipe_vscode_meta_replacement_data_file:
	$(call mtb__file_write,$(_MTB_RECIPE__IDE_TEMPLATE_META_DATA_FILE),TEMPLATE_REPLACE=$(_MTB_RECIPE__IDE_TEMPLATE_DIR)/vscode/$(_MTB_RECIPE__PROGRAM_INTERFACE_SUBDIR)=.)
	$(call mtb__file_append,$(_MTB_RECIPE__IDE_TEMPLATE_META_DATA_FILE),TEMPLATE_REPLACE=$(MTB_TOOLS__CORE_DIR)/make/scripts/interface_version_2/vscode/tasks.json=.vscode/tasks.json)

.PHONY: recipe_vscode_text_replacement_data_file recipe_vscode_meta_replacement_data_file 

##############################################
# EW UV
##############################################
_MTB_RECIPE__IDE_BUILD_DATA_FILE:=$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/recipe_ide_build_data.txt

ewarm8 uvision5: MTB_CORE__EXPORT_CMDLINE += -build_data $(_MTB_RECIPE__IDE_BUILD_DATA_FILE)
ewarm8 uvision5: recipe_ide_build_data_file

recipe_ide_build_data_file:
	$(call mtb__file_write,$(_MTB_RECIPE__IDE_BUILD_DATA_FILE),LINKER_SCRIPT=$(MTB_RECIPE__LINKER_SCRIPT))

.PHONY: recipe_ide_build_data_file

##############################################
# UV
##############################################
_MTB_RECIPE__CMSIS_ARCH_NAME:=CAT2_DFP
_MTB_RECIPE__CMSIS_VENDOR_NAME:=Infineon
_MTB_RECIPE__CMSIS_VENDOR_ID:=7
ifeq ($(MTB_RECIPE__CORE),CM0)
_MTB_RECIPE__CMSIS_PNAME:=Cortex-M0
else ifeq ($(MTB_RECIPE__CORE),CM0P)
_MTB_RECIPE__CMSIS_PNAME:=Cortex-M0p
else
_MTB_RECIPE__CMSIS_PNAME:=
endif
_MTB_RECIPE__IDE_DFP_DATA_FILE:=$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/recipe_ide_dfp_data.txt

uvision5: recipe_uvision5_dfp_data_file
uvision5: MTB_CORE__EXPORT_CMDLINE += -dfp_data $(_MTB_RECIPE__IDE_DFP_DATA_FILE)

recipe_uvision5_dfp_data_file:
	$(call mtb__file_write,$(_MTB_RECIPE__IDE_DFP_DATA_FILE),DEVICE=$(DEVICE))
	$(call mtb__file_append,$(_MTB_RECIPE__IDE_DFP_DATA_FILE),DFP_NAME=$(_MTB_RECIPE__CMSIS_ARCH_NAME))
	$(call mtb__file_append,$(_MTB_RECIPE__IDE_DFP_DATA_FILE),VENDOR_NAME=$(_MTB_RECIPE__CMSIS_VENDOR_NAME))
	$(call mtb__file_append,$(_MTB_RECIPE__IDE_DFP_DATA_FILE),VENDOR_ID=$(_MTB_RECIPE__CMSIS_VENDOR_ID))
	$(call mtb__file_append,$(_MTB_RECIPE__IDE_DFP_DATA_FILE),PNAME=$(_MTB_RECIPE__CMSIS_PNAME))

.PHONY: recipe_uvision5_dfp_data_file
