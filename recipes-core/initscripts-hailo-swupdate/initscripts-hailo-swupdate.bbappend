# swupdate-image installs the SWU it downloads. With a signature-aware swupdate it has to be told which key to
# check against, otherwise every SWU is refused (or, with an older swupdate, accepted unchecked).
RDEPENDS:${PN} += "swupdate-public-key"

do_install:append() {
    sed -i 's|swupdate -i |swupdate -k /etc/swupdate-public.pem -i |' ${D}${base_sbindir}/init
    grep -q 'swupdate -k /etc/swupdate-public.pem -i ' ${D}${base_sbindir}/init || \
        bbfatal "initscripts-hailo-swupdate: the swupdate call was not found, the -k edit did not apply"
}
