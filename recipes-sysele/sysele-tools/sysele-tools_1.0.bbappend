# QBAstrial: the product is the QBAstrial H15, built on the Astrial H15 SoM. Only the name in the
# banner changes; MACHINE stays astrial-h15 because that is the real Yocto machine.
do_install:append() {
    sed -i 's/^  Astrial H15 - System Electronics$/  QBAstrial H15 - System Electronics/' \
        ${D}${SYSELE_DIR}/share/build-info
}
