IMAGE_INSTALL:remove = "sysele-dsi-detection sysele-dsi-touch-test"

# swupdate verifies the SWU with this key; qba-slot-sync keeps the SCU bootloader configuration in step with
# the slot that booted; watchdog feeds /dev/watchdog.
IMAGE_INSTALL:append = " swupdate-public-key qba-slot-sync watchdog"
