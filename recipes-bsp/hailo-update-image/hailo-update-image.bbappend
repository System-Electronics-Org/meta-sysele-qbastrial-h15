# The sw-description falls back to mmcblk0 (the SD slot) for every machine that does not override it. The eMMC
# of the Astrial H15 is mmcblk1, so an update started by /etc/run_swupdate.sh, which passes no device on the
# kernel command line, would write to the wrong disk.
SWUPDATE_DEFAULT_FILESYSTEM_DEVICE:astrial-h15 = "mmcblk1"

# QBAstrial ships one kind of update: rootfs and fitImage, slot A. The SPI-NOR is programmed once through the
# mask ROM and is not touched by an OTA, so the SCU, U-Boot and environment images of the Hailo SWU are left out
# of the package. The sw-description here also carries the sha256 of every entry, which swupdate requires as
# soon as it checks signatures.
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI = " \
    file://sw-description \
    file://resize_fs.sh \
    "
SWUPDATE_IMAGES = "fitImage ${HAILO_TARGET}"

# Signature of sw-description. QBA_SWU_PRIVATE_KEY is set by whoever builds (local.conf or the CI secret); it
# never lives in this layer. Without it the SWU is built unsigned, and a swupdate that checks signatures will
# refuse it, which is the safe way round.
QBA_SWU_PRIVATE_KEY ?= ""
# := so that THISDIR is the directory of this file, not of the last file parsed when python() runs.
QBA_SWU_SIGN_DIR := "${THISDIR}/files"
# qba_sign_swu.sh is run in place by SWUPDATE_SIGN_TOOL. It is not in SRC_URI on purpose: everything in SRC_URI
# is packed into the SWU.
python () {
    key = d.getVar('QBA_SWU_PRIVATE_KEY')
    if key:
        d.setVar('SWUPDATE_SIGNING', 'CUSTOM')
        d.setVar('SWUPDATE_SIGN_TOOL', '%s/qba_sign_swu.sh %s %s' % (
            d.getVar('QBA_SWU_SIGN_DIR'), key, d.expand('${WORKDIR}/hailo-update-image')))
    else:
        bb.warn('QBA_SWU_PRIVATE_KEY is not set: hailo-update-image is built without a signature')
}
