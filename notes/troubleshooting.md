# Document all the issues related to setup/build/toolchain/language stuff which can help you become the best "colleague to ask".

# Issue 1 [Linux]: pyOCD can't open the probe because your user doesn't have raw USB access to it. Fix with udev rules.
Solution:
  # Grab pyOCD's udev rules
  sudo curl -L https://raw.githubusercontent.com/pyocd/pyOCD/master/udev/49-stlinkv2-1.rules \
    -o /etc/udev/rules.d/49-stlinkv2-1.rules
  sudo curl -L https://raw.githubusercontent.com/pyocd/pyOCD/master/udev/49-stlinkv2.rules \
    -o /etc/udev/rules.d/49-stlinkv2.rules
  sudo curl -L https://raw.githubusercontent.com/pyocd/pyOCD/master/udev/49-stlinkv3.rules \
    -o /etc/udev/rules.d/49-stlinkv3.rules

  # Reload rules and re-trigger
  sudo udevadm control --reload
  sudo udevadm trigger

# Issue 2 [Keil-Studio]: debugger using cmsis instead of st-link
Solution:
  This happened after making minimal build environment (deleting default STM32 CubeMX, etc...).
  Change it in CMSIS -> Manage Solution Settings -> Debug Adapter.
  Changes are updated in csolution.yml.

# Issue 3 [Keil-Studio]: error cbuild2cmake: compiler registration environment variable missing, format: AC6_TOOLCHAIN_<major>_<minor>_<patch> in vscode cmsis
Solution:
  This happened after making minimal build environment (deleting default STM32 CubeMX, etc...).
  Configure relevant ARM license in "Configure Arm Tools Environment" under "Arm Compiler for Embedded".