# The hostname (and the prompt, root@qbastrialh15) of this product.
# meta-sysele-bsp writes "astrialh15" to /etc/hostname in do_install:append; ours runs after it.
hostname:pn-base-files = "qbastrialh15"

do_install:append() {
    echo "qbastrialh15" > ${D}${sysconfdir}/hostname
}
