# run_swupdate.sh calls swupdate with a public key only for the Hailo-10h, so on any other machine an update started
# from the running system (dual mode) would be refused by a swupdate that checks signatures. Give it the key everywhere.
RDEPENDS:${PN} += "swupdate-public-key"

do_install:append() {
    sed -i 's|^\(\s*\)swupdate -i "${F_LOCAL_FILENAME}" -l |\1swupdate -k /etc/swupdate-public.pem -i "${F_LOCAL_FILENAME}" -l |' ${D}${targetdir}/run_swupdate.sh
    grep -q 'swupdate -k /etc/swupdate-public.pem -i' ${D}${targetdir}/run_swupdate.sh || \
        bbfatal "run-swupdate-script: the swupdate call was not found, the -k edit did not apply"
}
