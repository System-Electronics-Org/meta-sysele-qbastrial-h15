SUMMARY = "Keep the SCU bootloader configuration in step with the slot that booted"
DESCRIPTION = "Rewrites the SCU bootloader configuration with set_sw_image.sh when it differs from the one of the slot that booted."
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://qba-slot-sync"
S = "${WORKDIR}"

RDEPENDS:${PN} += "run-swupdate-script"

inherit update-rc.d allarch

INITSCRIPT_NAME = "qba-slot-sync"
INITSCRIPT_PARAMS = "start 98 2 3 4 5 ."

do_install() {
    install -d ${D}${sysconfdir}/init.d
    install -m 0755 ${WORKDIR}/qba-slot-sync ${D}${sysconfdir}/init.d/qba-slot-sync
}
