source [find interface/kitprog3.cfg]
source [find target/&&_MTB_RECIPE__OPEN_OCD_FILE&&]
${_TARGETNAME} configure -rtos auto -rtos-wipe-on-reset-halt 1
