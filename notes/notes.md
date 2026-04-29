  # Issue: pyOCD can't open the probe because your user doesn't have raw USB access to it. Fix with udev rules.

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