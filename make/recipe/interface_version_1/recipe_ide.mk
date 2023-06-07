################################################################################
# \file recipe_ide.mk
#
# \brief
# This make file defines the IDE export variables and target.
#
################################################################################
# \copyright
# Copyright 2022-2023 Cypress Semiconductor Corporation
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

include $(MTB_TOOLS__RECIPE_DIR)/make/recipe/interface_version_1/recipe_ide_common.mk

MTB_RECIPE__IDE_SUPPORTED:=eclipse vscode uvision5 ewarm8

ifeq ($(filter vscode,$(MAKECMDGOALS)),vscode)
$(MTB_RECIPE__IDE_RECIPE_DATA_FILE)_vscode:
	$(MTB_NOISE)echo "s|&&DEVICE&&|$(DEVICE)|g;" > $(MTB_RECIPE__IDE_RECIPE_DATA_FILE);\
	echo "s|&&_MTB_RECIPE__XRES_AVAILABLE&&|$(_MTB_RECIPE__XRES_AVAILABLE)|g;" >> $(MTB_RECIPE__IDE_RECIPE_DATA_FILE);\
	echo "s|&&_MTB_RECIPE__RESET_CONFIG&&|$(_MTB_RECIPE__RESET_CONFIG)|g;" >> $(MTB_RECIPE__IDE_RECIPE_DATA_FILE);
endif

ifeq ($(filter eclipse,$(MAKECMDGOALS)),eclipse)
eclipse_textdata_file:
	$(call mtb__file_append,$(MTB_RECIPE__IDE_RECIPE_DATA_FILE),&&_MTB_RECIPE__OPENOCD_OTHER_RUN_CMD&&=$(_MTB_RECIPE__OPENOCD_OTHER_RUN_CMD_ECLIPSE))
	$(call mtb__file_append,$(MTB_RECIPE__IDE_RECIPE_DATA_FILE),&&_MTB_RECIPE__JLINK_CFG_PROGRAM&&=$(DEVICE))
	$(call mtb__file_append,$(MTB_RECIPE__IDE_RECIPE_DATA_FILE),&&_MTB_RECIPE__JLINK_CFG_DEBUG&&=$(DEVICE))
	$(call mtb__file_append,$(MTB_RECIPE__IDE_RECIPE_DATA_FILE),&&_MTB_RECIPE__JLINK_CFG_ATTACH&&=$(_MTB_RECIPE__JLINK_DEVICE_CFG_ATTACH))
	$(call mtb__file_append,$(MTB_RECIPE__IDE_RECIPE_DATA_FILE),&&_MTB_RECIPE__XRES_AVAILABLE&&=$(_MTB_RECIPE__XRES_AVAILABLE))
	$(call mtb__file_append,$(MTB_RECIPE__IDE_RECIPE_DATA_FILE),&&_MTB_RECIPE__RESET_CONFIG&&=$(_MTB_RECIPE__RESET_CONFIG))

_MTB_ECLIPSE_TEMPLATE_RECIPE_SEARCH:=$(MTB_TOOLS__RECIPE_DIR)/make/scripts/interface_version_1/eclipse
_MTB_ECLIPSE_TEMPLATE_RECIPE_APP_SEARCH:=$(MTB_TOOLS__RECIPE_DIR)/make/scripts/interface_version_1/eclipse/Application

eclipse_recipe_metadata_file:
	$(call mtb__file_append,$(MTB_RECIPE__IDE_RECIPE_METADATA_FILE),RECIPE_TEMPLATE=$(_MTB_ECLIPSE_TEMPLATE_RECIPE_SEARCH))
	$(call mtb__file_append,$(MTB_RECIPE__IDE_RECIPE_METADATA_FILE),RECIPE_APP_TEMPLATE=$(_MTB_ECLIPSE_TEMPLATE_RECIPE_APP_SEARCH))
	$(call mtb__file_append,$(MTB_RECIPE__IDE_RECIPE_METADATA_FILE),PROJECT_UUID=&&PROJECT_UUID&&)

endif

ewarm8_recipe_data_file:
	$(call mtb__file_write,$(MTB_RECIPE__IDE_RECIPE_DATA_FILE),$(DEVICE))

ewarm8: ewarm8_recipe_data_file

_MTB_RECIPE__CMSIS_ARCH_NAME:=CAT2_DFP
_MTB_RECIPE__CMSIS_VENDOR_NAME:=Infineon
_MTB_RECIPE__CMSIS_VENDOR_ID:=7

# Define _MTB_RECIPE__CMSIS_PNAME for export into uVision
ifeq ($(MTB_RECIPE__CORE),CM0)
_MTB_RECIPE__CMSIS_PNAME:=Cortex-M0
else ifeq ($(MTB_RECIPE__CORE),CM0P)
_MTB_RECIPE__CMSIS_PNAME:=Cortex-M0p
else
_MTB_RECIPE__CMSIS_PNAME:=
endif

_MTB_RECIPE__CMSIS_LDFLAGS:=

uvision5_recipe_data_file:
	$(call mtb__file_write,$(MTB_RECIPE__IDE_RECIPE_DATA_FILE),$(_MTB_RECIPE__CMSIS_ARCH_NAME))
	$(call mtb__file_append,$(MTB_RECIPE__IDE_RECIPE_DATA_FILE),$(_MTB_RECIPE__CMSIS_VENDOR_NAME))
	$(call mtb__file_append,$(MTB_RECIPE__IDE_RECIPE_DATA_FILE),$(_MTB_RECIPE__CMSIS_VENDOR_ID))
	$(call mtb__file_append,$(MTB_RECIPE__IDE_RECIPE_DATA_FILE),$(_MTB_RECIPE__CMSIS_PNAME))
	$(call mtb__file_append,$(MTB_RECIPE__IDE_RECIPE_DATA_FILE),$(_MTB_RECIPE__CMSIS_LDFLAGS))

uvision5: uvision5_recipe_data_file
