SUMMARY = "Public key swupdate verifies the SWU signature with"
DESCRIPTION = "Installs /etc/swupdate-public.pem, taken from QBA_SECURE_ASSETS_DIR."
LICENSE = "CLOSED"

FILESEXTRAPATHS:prepend := "${@d.getVar('QBA_SECURE_ASSETS_DIR') + ':' if d.getVar('QBA_SECURE_ASSETS_DIR') else ''}"
SRC_URI = "file://swupdate-public.pem"

S = "${WORKDIR}"

inherit allarch

do_install() {
    install -d ${D}${sysconfdir}
    install -m 0644 ${WORKDIR}/swupdate-public.pem ${D}${sysconfdir}/swupdate-public.pem
}

FILES:${PN} = "${sysconfdir}/swupdate-public.pem"
