SUMMARY = "Public key swupdate verifies the signature of an SWU with"
DESCRIPTION = "Installs /etc/swupdate-public.pem. The file comes from QBA_SECURE_ASSETS_DIR when it is set, so a \
test key never has to be committed; the matching private key stays with whoever builds the release."
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
