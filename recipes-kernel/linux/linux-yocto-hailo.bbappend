# QBAstrial: Linux console on UART0 (ttyS0, serial0), and no display.
#
# The board DTS is copied into ${S} by the do_configure:prepend of meta-sysele-bsp, so this
# runs after the copy. astrial-h15-ws101.dts includes astrial-h15.dts and follows it.

do_configure:append() {
    if ! grep -q 'QBAstrial: console on UART0' ${S}/arch/arm64/boot/dts/sysele/astrial-h15.dts; then
        cat >> ${S}/arch/arm64/boot/dts/sysele/astrial-h15.dts <<'DTS'

/* QBAstrial: console on UART0 */
/ {
    chosen {
        stdout-path = &serial0;
    };
};

/* QBAstrial: no display. The DSI path and the panel it was wired to are switched off. */
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
