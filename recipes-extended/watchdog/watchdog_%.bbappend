# Somebody has to open /dev/watchdog and keep it fed, otherwise watchdog.open_timeout (set in the U-Boot bootargs of the
# eMMC boot) resets a perfectly good system 60 seconds after the kernel started: the kernel only feeds a watchdog that
# U-Boot left running until someone opens the device, and nothing in the image did. Measured on an A slot that reached
# its login prompt every time and was reset every time.
#
# The daemon starts at the end on purpose (S98, and hailo_linux_init.sh follows at S99). Everything that starts before
# it has to be up within the open timeout, which makes the timeout the limit on how long a slot may take to come up
# before the SCU bootloader counts it as a failed boot.
INITSCRIPT_PARAMS:${PN} = "start 98 2 3 4 5 . stop 85 0 6 ."
