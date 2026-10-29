hostname:pn-base-files = "qbastrialh15"

do_install:append() {
    echo "qbastrialh15" > ${D}${sysconfdir}/hostname
}
