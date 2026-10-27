# SCU bootloader configuration with a fallback image.
#
# Hailo's scu_bl_cfg_a.json and scu_bl_cfg_b.json describe a single image and set boot_max_retries to 0xFF, which turns
# the switch to another image off (OS User Guide 1.12.0, chapter 8). A slot that starts and never comes up then stays
# there for good. Here the second descriptor is the other slot and the SCU bootloader gives up on the first one after
# three boots that end in a watchdog reset. set_sw_image.sh copies these files to the SPI-NOR, so after an update the
# new slot is the first choice and the old one is the fallback.
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
