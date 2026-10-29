# swupdate-image checks the SWU against the public key.
RDEPENDS:${PN} += "swupdate-public-key"

do_install:append() {
    sed -i 's|swupdate -i |swupdate -k /etc/swupdate-public.pem -i |' ${D}${base_sbindir}/init
    grep -q 'swupdate -k /etc/swupdate-public.pem -i ' ${D}${base_sbindir}/init || \
        bbfatal "initscripts-hailo-swupdate: swupdate call not found, -k not applied"
}
