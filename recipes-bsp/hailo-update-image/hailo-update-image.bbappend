# sw-description: Hailo's, with the sha256 of every entry (required once swupdate checks signatures).
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

# Signing key of the SWU, set by the build (local.conf or CI). Without it the SWU is unsigned and the images refuse it.
QBA_SWU_PRIVATE_KEY ?= ""
# Not part of SRC_URI: everything in SRC_URI is packed into the SWU.
QBA_SWU_SIGN_DIR := "${THISDIR}/files"

python () {
    key = d.getVar('QBA_SWU_PRIVATE_KEY')
    if key:
        d.setVar('SWUPDATE_SIGNING', 'CUSTOM')
        d.setVar('SWUPDATE_SIGN_TOOL', '%s/qba_sign_swu.sh %s %s' % (
            d.getVar('QBA_SWU_SIGN_DIR'), key, d.expand('${WORKDIR}/hailo-update-image')))
    else:
        bb.warn('QBA_SWU_PRIVATE_KEY is not set: hailo-update-image is built unsigned')
}
