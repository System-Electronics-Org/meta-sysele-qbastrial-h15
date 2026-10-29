# hailo_linux_init.sh sets boot_success_ap_software, which tells the SCU bootloader the boot worked.
# Run it last, after the watchdog daemon.
INITSCRIPT_PARAMS = "start 99 5 ."
