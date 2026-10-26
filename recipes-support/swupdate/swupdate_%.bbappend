# swupdate that checks the signature of sw-description (RSA-PSS) and the sha256 of every image listed in it.
# Hailo builds this only for hailo10-usb-dongle (signed.cfg in meta-hailo-bsp-examples); the H15 build has
# CONFIG_SIGNED_IMAGES off, so any SWU is accepted.
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI += "file://signed.cfg"
