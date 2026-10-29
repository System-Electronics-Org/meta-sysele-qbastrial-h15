# run_swupdate.sh passes the public key in dual mode only for the Hailo-10h; pass it on every machine.
RDEPENDS:${PN} += "swupdate-public-key"

do_install:append() {
    sed -i 's|^\(\s*\)swupdate -i "${F_LOCAL_FILENAME}" -l |\1swupdate -k /etc/swupdate-public.pem -i "${F_LOCAL_FILENAME}" -l |' ${D}${targetdir}/run_swupdate.sh
    grep -q 'swupdate -k /etc/swupdate-public.pem -i' ${D}${targetdir}/run_swupdate.sh || \
        bbfatal "run-swupdate-script: swupdate call not found, -k not applied"
}
