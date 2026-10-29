# Banner name; MACHINE stays astrial-h15.
do_install:append() {
    sed -i 's/^  Astrial H15 - System Electronics$/  QBAstrial H15 - System Electronics/' \
        ${D}${SYSELE_DIR}/share/build-info
}
