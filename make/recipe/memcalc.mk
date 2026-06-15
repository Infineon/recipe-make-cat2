################################################################################
# \file memcalc.mk
#
# \brief
# Defines the public facing build targets common to all recipes and includes
# the core makefiles.
#
################################################################################
# \copyright
# Copyright (c) 2025-2026, Infineon Technologies AG, or an affiliate of
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

# memcalc version
_MTB_RECIPE__MEMREPORT_VERSIONS_SUPPORTED:=$(filter $(MTB_RECIPE__MEMREPORT_SUPPORT),$(CY_TOOL_memory_report_SUPPORTED_INTERFACES))
_MTB_RECIPE__MEMREPORT_VERSION:=$(lastword $(strip $(_MTB_RECIPE__MEMREPORT_VERSIONS_SUPPORTED)))

ifeq (,$(_MTB_RECIPE__MEMREPORT_VERSION))
ifeq (,$(_MTB_RECIPE__NOT_SUPPORT_LEGACY_MEMCALC))

ifeq ($(TOOLCHAIN),A_Clang)
_MTB_RECIPE__GEN_READELF=
_MTB_RECIPE__MEMORY_CAL=
else
ifeq ($(TOOLCHAIN),LLVM_ARM)
_MTB_RECIPE__READELF=$(MTB_TOOLCHAIN_LLVM_ARM__READELF)
else
_MTB_RECIPE__READELF=$(MTB_TOOLCHAIN_GCC_ARM__READELF)
endif
_MTB_RECIPE__GEN_READELF=$(_MTB_RECIPE__READELF) -Sl $(_MTB_RECIPE__TARG_FILE) > $(MTB_TOOLS__OUTPUT_CONFIG_DIR)/$(APPNAME).readelf
_MTB_RECIPE__MEM_CALC=\
	bash --norc --noprofile\
	$(MTB_TOOLS__CORE_DIR)/make/scripts/memcalc.bash\
	$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/$(APPNAME).readelf\
	$(_MTB_RECIPE__DEVICE_FLASH_KB)\
	$(_MTB_RECIPE__START_FLASH)
endif

_MTB_RECIPE__MEMCALC_CACHE=$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/memcalc_cache.txt

ifeq ($(LIBNAME),)
$(_MTB_RECIPE__MEMCALC_CACHE): $(_MTB_RECIPE__TARG_FILE) | app
	$(MTB__NOISE)echo Calculating memory consumption: $(DEVICE) $(TOOLCHAIN) $(MTB_TOOLCHAIN_OPTIMIZATION)
	$(MTB__NOISE)echo
	$(MTB__NOISE)$(_MTB_RECIPE__GEN_READELF)
	$(MTB__NOISE)$(_MTB_RECIPE__MEM_CALC) > $@
	$(MTB__NOISE)echo

memcalc: $(_MTB_RECIPE__MEMCALC_CACHE)
	$(MTB__NOISE)LC_ALL=C sed -e 's/\xC2\xA0/ /g' $(_MTB_RECIPE__MEMCALC_CACHE)
else
memcalc:
	@:
endif

endif #ifneq (,$(_MTB_RECIPE__NOT_SUPPORT_LEGACY_MEMCALC))
else #ifeq (,$(_MTB_RECIPE__MEMREPORT_VERSION))

ifeq (PROJECT,$(MTB_TYPE))
_MTB_RECIPE__MEMREPORT_OUT_DIR:=$(_MTB_RECIPE__APP_HEX_DIR)
else
_MTB_RECIPE__MEMREPORT_OUT_DIR:=$(MTB_TOOLS__OUTPUT_CONFIG_DIR)
endif
_MTB_RECIPE__MEMREPORT_USAGE_OUT:=$(_MTB_RECIPE__MEMREPORT_OUT_DIR)/memreport.txt
_MTB_RECIPE__MEMREPORT_JSON_OUT:=$(_MTB_RECIPE__MEMREPORT_OUT_DIR)/memreport.json

# whether memcalc should run at the end of project build or application build. If non-empty, then run at project build time.
_MTB_RECIPE__MEMCALC_PRJ_DEP:=

ifneq (,$(MTB_IDE__TARG_FILE))
# build within an IDE, so run memcalc at project build time.
_MTB_RECIPE__MEMCALC_PRJ_DEP:=1
endif
ifeq (,$(MTB_APPLICATION_SUBPROJECTS))
# building a single project directly with build_proj, so run memcalc at project build time.
_MTB_RECIPE__MEMCALC_PRJ_DEP:=1
endif

ifneq (,$(_MTB_RECIPE__MEMCALC_PRJ_DEP))
# In project build context run the memory report before signing and combining.
# In this context unless all project have been built at least once signing and combine can fail.
# Still want to display memory report for the current project.
sign_combine_check_inputs memcalc : application_memcalc
application_memcalc : $(_MTB_RECIPE__TARG_DEPENDENCY_FILE) | app
# Just building the current project with build_proj or in an IDE. In this case run memory report on the current project's elf file.
ifneq (,$(MTB_IDE__TARG_FILE))
_MTB_RECIPE__MEMREPORT_ELF_FILES:=$(call mtb__path_normalize,$(MTB_IDE__TARG_FILE))
_MTB_RECIPE__MEMREPORT_PROJECT_ELF_PAIRS:=$(notdir $(basename $(call mtb__path_normalize,$(MTB_IDE__TARG_FILE))))=$(call mtb__path_normalize,$(MTB_IDE__TARG_FILE))
else
ifeq (COMBINED,$(MTB_TYPE))
_MTB_RECIPE__MEMREPORT_ELF_FILES:=$(_MTB_RECIPE__LAST_CONFIG_TARG_FILE)
_MTB_RECIPE__MEMREPORT_PROJECT_ELF_PAIRS:=$(APPNAME)=$(_MTB_RECIPE__LAST_CONFIG_TARG_FILE)
# Ensure the ELF copy to last_config/ completes before memreport reads it (parallel build safety).
application_memcalc : $(_MTB_RECIPE__LAST_CONFIG_PROG_FILE)
else
_MTB_RECIPE__MEMREPORT_ELF_FILES:=$(_MTB_RECIPE__PRJ_HEX_DIR)/$(_MTB_RECIPE__PROJECT_DIR_NAME).$(MTB_RECIPE__SUFFIX_TARGET)
_MTB_RECIPE__MEMREPORT_PROJECT_ELF_PAIRS:=$(_MTB_RECIPE__PROJECT_DIR_NAME)=$(_MTB_RECIPE__PRJ_HEX_DIR)/$(_MTB_RECIPE__PROJECT_DIR_NAME).$(MTB_RECIPE__SUFFIX_TARGET)
# Ensure the ELF copy to project_hex/ completes before memreport reads it (parallel build safety).
ifeq ($(_MTB_RECIPE__PROMOTE),true)
application_memcalc : $(_MTB_RECIPE__COPIED_PROJECT_PROG_FILE)
endif
endif #ifneq (COMBINED,$(MTB_TYPE))
endif #ifneq (,$(MTB_IDE__TARG_FILE))
else #ifneq (,$(_MTB_RECIPE__MEMCALC_PRJ_DEP))
# Building the application. In this case run memory report on the entire application.
application_postbuild: application_memcalc
_MTB_RECIPE__MEMREPORT_ELF_FILES:=$(foreach project,$(MTB_APPLICATION_SUBPROJECTS),$(_MTB_RECIPE__PRJ_HEX_DIR)/$(project).$(MTB_RECIPE__SUFFIX_TARGET))
_MTB_RECIPE__MEMREPORT_PROJECT_ELF_PAIRS:=$(foreach project,$(MTB_APPLICATION_SUBPROJECTS),$(project)=$(_MTB_RECIPE__PRJ_HEX_DIR)/$(project).$(MTB_RECIPE__SUFFIX_TARGET))
ifeq ($(COMBINE_SIGN_JSON),)
application_memcalc: $(_MTB_RECIPE__APP_HEX_FILE)
else
application_memcalc: sign_combine
endif #ifeq ($(COMBINE_SIGN_JSON),)

endif #ifneq (,$(_MTB_RECIPE__MEMCALC_PRJ_DEP))


ifneq (,$(_MTB_RECIPE__START_FLASH))
ifneq (,$(_MTB_RECIPE__DEVICE_FLASH_KB))
_MTB_RECIPE__MEMCALC_LEGACY_ARGS+=--legacy_memory FLASH,$(_MTB_RECIPE__START_FLASH),$(_MTB_RECIPE__DEVICE_FLASH_KB)
endif
endif

ifneq ($(filter 2,$(_MTB_RECIPE__MEMREPORT_VERSION)),)
_MTB_RECIPE__MEMREPORT_ELF_ARGS=$(foreach p,$(_MTB_RECIPE__MEMREPORT_PROJECT_ELF_PAIRS),--project_elf "$(p)")
else
_MTB_RECIPE__MEMREPORT_ELF_ARGS=$(foreach f,$(_MTB_RECIPE__MEMREPORT_ELF_FILES),--elf "$(f)")
endif

application_memcalc:
ifneq (,$(_MTB_RECIPE__MEMREPORT_ELF_FILES))
# Check that all input ELF files exist; if any are missing, skip memory report but do not fail build
	$(MTB__NOISE)missing_files="$(strip $(foreach f,$(_MTB_RECIPE__MEMREPORT_ELF_FILES),$(if $(wildcard $(f)),,$(call mtb__path_normalize,$(f)))))"; \
	if [ -n "$$missing_files" ]; then \
		echo "NOTE: Skipping memory report; missing .elf artifact(s): $$missing_files. Some projects may be libraries that only emit .a artifacts."; \
	else \
		mkdir -p "$(_MTB_RECIPE__MEMREPORT_OUT_DIR)" || { echo "Error: failed to create memreport output dir: $(_MTB_RECIPE__MEMREPORT_OUT_DIR)"; exit 1; }; \
		$(CY_TOOL_memory_report_EXE_ABS) --bsp_dir "$(SEARCH_TARGET_$(TARGET))" $(_MTB_RECIPE__MEMREPORT_ELF_ARGS) --out_usage "$(_MTB_RECIPE__MEMREPORT_USAGE_OUT)" --out_json "$(_MTB_RECIPE__MEMREPORT_JSON_OUT)" $(_MTB_RECIPE__MEMCALC_LEGACY_ARGS); \
		LC_ALL=C sed -e 's/\xC2\xA0/ /g' "$(_MTB_RECIPE__MEMREPORT_USAGE_OUT)"; \
	fi
endif #ifneq (,$(_MTB_RECIPE__MEMREPORT_ELF_FILES))

endif #ifeq (,$(_MTB_RECIPE__MEMREPORT_VERSION))

.PHONY: application_memcalc memcalc
