# PSoC 4 GNU make Build System Release Notes
This repo provides the build recipe make files and scripts for building and programming PSoC 4 applications. Builds can be run either through a command-line interface (CLI) or through the Eclipse IDE for ModusToolbox.

### What's Included?
This release of the PSoC 4 GNU make build recipe includes complete support for building, programming, and debugging PSoC 4 application projects. It is expected that a code example contains a top level make file for itself and references a Board Support Package (BSP) that defines specific items, like the PSoC 4 part, for the target board. Supported functionality includes the following:

* Supported operations:
    * Build
    * Program
    * Debug
    * IDE Integration (Eclipse, VS Code, IAR, uVision)
* Supported toolchains:
    * GCC
    * IAR
    * ARM Compiler 6

This also includes the getlibs.bash script that can be used directly, or via the make target to download additional git repo based libraries for the application.

### What Changed?
#### v2.0.0
* Major version update. Significant changes to support ModusToolbox 3.0
* Dropped compatibility with core-make version 1.X and ModusToolbox tools version 2.X
* Added PSoC 4000T devices

#### v1.2.0
* Added CCG7D and CCG7S devices

#### v1.1.2
* Fixed a compatibility bug introduced with make vscode in core-make-1.8.0
* Added new devices

#### v1.1.1
* Fix an issue with make progtool

#### v1.1.0
* Added support for PMG1 devices
* Added lin configurator, and ez-pd configurator

#### v1.0.0
* Initial production release

#### v0.5.0
* Initial pre-production release

### Product/Asset Specific Instructions
Builds require that the ModusToolbox tools be installed on your machine. This comes with the ModusToolbox install. On Windows machines, it is recommended that CLI builds be executed using the Cygwin.bat located in ModusToolBox/tools\_x.y/modus-shell install directory. This guarantees a consistent shell environment for your builds.

To list the build options, run the "help" target by typing "make help" in CLI. For a verbose documentation on a specific subject type "make help CY\_HELP={variable/target}", where "variable" or "target" is one of the listed make variables or targets.

### Supported Software and Tools
This version of the PSoC 4 build system was validated for compatibility with the following Software and Tools:

| Software and Tools                        | Version |
| :---                                      | :----:  |
| ModusToolbox Software Environment         | 3.0     |
| GCC Compiler                              | 10.3    |
| IAR Compiler                              | 9.3     |
| ARM Compiler                              | 6.16    |

Minimum required ModusToolbox Software Environment: v3.0

### More information
* [Infineon GitHub](https://github.com/Infineon)
* [ModusToolbox](https://www.infineon.com/cms/en/design-support/tools/sdk/modustoolbox-software)

---
© Cypress Semiconductor Corporation, 2019-2022.

