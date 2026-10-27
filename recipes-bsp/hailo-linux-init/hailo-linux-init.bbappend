# hailo_linux_init.sh writes boot_success_ap_software = 1, which tells the SCU bootloader that this boot worked. Hailo
# starts it at S50, in the middle of the boot. A slot that dies after that point is reset by the watchdog and the SCU
# bootloader does not count it as a failed boot (it saw the success flag), so it never falls back: measured on an A slot
# that reached its login prompt every time and was reset every time, for more than five cycles with boot_max_retries = 3.
#
# Run it last, after the watchdog daemon (S98) is up. The flag then means "the system came up and something is feeding
# the watchdog". Anything that keeps the system from getting there leaves the flag at 0, and the boot is counted.
INITSCRIPT_PARAMS = "start 99 5 ."
