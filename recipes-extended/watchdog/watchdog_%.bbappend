# The daemon opens /dev/watchdog and keeps it fed; without it watchdog.open_timeout resets a healthy slot.
# It starts at S98, hailo_linux_init.sh at S99: a slot is confirmed once the daemon is up.
INITSCRIPT_PARAMS:${PN} = "start 98 2 3 4 5 . stop 85 0 6 ."
