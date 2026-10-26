# QBAstrial: U-Boot console on UART0 (SoC uart0 at 0x108000) instead of UART1 (0x109000).
#
# The first programming of the SPI-NOR goes through the mask ROM, which only speaks on UART1.
# From the first boot on, U-Boot and Linux talk on UART0. The UART is chosen by the U-Boot DTB
# (chosen/stdout-path points to the node labelled "serial"), which the SPL reads too.
#
# The files of meta-sysele-bsp are copied into ${S} by its do_configure:prepend, so the edits
# below run after the copy and change those copies.

do_configure:append() {
    # DTB: the node labelled "serial" now describes uart0. u-boot,dm-spl stays on it.
    if ! grep -q 'QBAstrial: console on UART0' ${S}/arch/arm/dts/astrial-h15.dts; then
        cat >> ${S}/arch/arm/dts/astrial-h15.dts <<'DTS'

/* QBAstrial: console on UART0 */
&serial {
    reg = <0 0x00108000 0 0x1000>;
};
DTS
    fi

    # Kernel command line. BOOTARGS_BASE is guarded by #ifndef in hailo1x_common.h, so it
    # is defined before that header is included.
    if ! grep -q 'define BOOTARGS_BASE' ${S}/include/configs/astrial-h15.h; then
        sed -i '/#include "hailo15_common.h"/i #define BOOTARGS_BASE "console=ttyS0,${baudrate}n8 earlycon loglevel=8 rootwait debug"\n' \
            ${S}/include/configs/astrial-h15.h
    fi

    # No operator at the console after a wic update: boot straight into the new image instead of
    # reopening the menu, which has no timeout.
    sed -i 's|run update_wic_mmc1 && bootmenu -1|run update_wic_mmc1 \&\& run boot_mmc1|' \
        ${S}/include/configs/astrial-h15.h
}
