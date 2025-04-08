source [find interface/kitprog3.cfg]
&&_MTB_RECIPE__VSCODE_OPENOCD_PROBE_SERIAL_CMD&&
source [find target/&&_MTB_RECIPE__OPEN_OCD_FILE&&]
${_TARGETNAME} configure -rtos auto -rtos-wipe-on-reset-halt 1
