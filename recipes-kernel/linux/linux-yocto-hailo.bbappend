# Linux console on UART0 (ttyS0) and no display.

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
}
