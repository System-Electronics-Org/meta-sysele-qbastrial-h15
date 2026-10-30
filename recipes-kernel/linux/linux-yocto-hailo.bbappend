# Linux console on UART0 (ttyS0) and no display.

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

do_configure:append() {
    if ! grep -q 'QBAstrial: console on UART0' ${S}/arch/arm64/boot/dts/sysele/astrial-h15.dts; then
        cat >> ${S}/arch/arm64/boot/dts/sysele/astrial-h15.dts <<'DTS'

/* QBAstrial: console on UART0 */
/ {
    chosen {
        stdout-path = &serial0;
    };
};

/* QBAstrial: no display */
&panel_touch {
    status = "disabled";
};

&panel_lcd {
    status = "disabled";
};

&dsi0 {
    status = "disabled";
};

&dphy0 {
    status = "disabled";
};

&dpi0 {
    status = "disabled";
};
DTS
    fi

    # Hardware the QBAstrial does not have: one qba-dts-<name>.dtsi per piece, each with its own qba-<name>.cfg
    # for the kernel configuration, so that a piece can be put back on its own.
    for f in ${WORKDIR}/qba-dts-*.dtsi; do
        [ -f "$f" ] || continue
        if ! grep -q "$(basename $f)" ${S}/arch/arm64/boot/dts/sysele/astrial-h15.dts; then
            { echo; echo "/* $(basename $f) */"; cat "$f"; } >> ${S}/arch/arm64/boot/dts/sysele/astrial-h15.dts
        fi
    done
}

SRC_URI:append = " file://qba-dts-audio.dtsi file://qba-audio.cfg"

SRC_URI:append = " file://qba-pcie.cfg"

SRC_URI:append = " file://qba-dts-i2c-monitors.dtsi"

SRC_URI:append = " file://qba-dts-sdcard.dtsi"

SRC_URI:append = " file://qba-radios.cfg"

SRC_URI:append = " file://qba-display.cfg"
