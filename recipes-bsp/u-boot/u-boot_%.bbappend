# U-Boot console on UART0 (0x108000) instead of UART1 (0x109000).
# The UART is the one the node labelled "serial" of the U-Boot DTB describes; the SPL reads it too.

# Seconds the kernel waits for user space to open /dev/watchdog on the eMMC boot.
QBA_WATCHDOG_OPEN_TIMEOUT ?= "60"

do_configure:append() {
    if ! grep -q 'QBAstrial: console on UART0' ${S}/arch/arm/dts/astrial-h15.dts; then
        cat >> ${S}/arch/arm/dts/astrial-h15.dts <<'DTS'

/* QBAstrial: console on UART0 */
&serial {
    reg = <0 0x00108000 0 0x1000>;
};
DTS
    fi

    # BOOTARGS_BASE is guarded by #ifndef in hailo1x_common.h: define it before the include.
    if ! grep -q 'define BOOTARGS_BASE' ${S}/include/configs/astrial-h15.h; then
        sed -i '/#include "hailo15_common.h"/i #define BOOTARGS_BASE "console=ttyS0,${baudrate}n8 quiet loglevel=3 rootwait"\n' \
            ${S}/include/configs/astrial-h15.h
    fi

    # A slot whose user space does not start ends in a watchdog reset, which the SCU bootloader counts.
    # Only the eMMC boot gets the parameter: swupdate-image does not open the watchdog.
    if ! grep -q 'watchdog.open_timeout' ${S}/include/configs/hailo1x_common.h; then
        sed -i 's|\(root=/dev/mmcblk${device_num}p${mmc_rootfs_partition}\)|\1 watchdog.open_timeout=${QBA_WATCHDOG_OPEN_TIMEOUT}|' \
            ${S}/include/configs/hailo1x_common.h
        grep -q 'watchdog.open_timeout' ${S}/include/configs/hailo1x_common.h || \
            bbfatal "u-boot: bootargs_mmc not found, watchdog.open_timeout not applied"
    fi
}
