# No display on this product: the DSI test tools stay out of the image.
IMAGE_INSTALL:remove = "sysele-dsi-detection sysele-dsi-touch-test"

# swupdate in the running system, as run_swupdate.sh uses it in dual (A/B) mode and for dry runs, verifies
# against this key.
IMAGE_INSTALL:append = " swupdate-public-key"

# Keep the SCU bootloader configuration in step with the slot that booted (after a fallback, or an update by an image
# whose configuration has no fallback).
IMAGE_INSTALL:append = " qba-slot-sync"

# User space feeds the AP watchdog (see recipes-extended/watchdog). Without it the open timeout in the bootargs resets a
# healthy slot.
IMAGE_INSTALL:append = " watchdog"
