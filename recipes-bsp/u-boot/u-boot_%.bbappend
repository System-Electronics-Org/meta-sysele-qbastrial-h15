# QBAstrial: U-Boot console on UART0 (SoC uart0 at 0x108000) instead of UART1 (0x109000).
#
# The first programming of the SPI-NOR goes through the mask ROM, which only speaks on UART1.
# From the first boot on, U-Boot and Linux talk on UART0. The UART is chosen by the U-Boot DTB
# (chosen/stdout-path points to the node labelled "serial"), which the SPL reads too.
#
# The files of meta-sysele-bsp are copied into ${S} by its do_configure:prepend, so the edits
# below run after the copy and change those copies.

# Seconds the kernel waits for user space to open /dev/watchdog. A healthy image opens it in a few seconds (watchdogd).
QBA_WATCHDOG_OPEN_TIMEOUT ?= "60"

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

    # The Autodetect entry of this machine lacks the check that every other Hailo configuration has:
    # when the SCU reports a remote update (boot_image_mode = 1, set by /etc/run_swupdate.sh) the
    # board must boot swupdate-image. Without it the official OTA launch just boots Linux again.
    if ! grep -q 'boot_image_mode' ${S}/include/configs/astrial-h15.h; then
        sed -i '/"bootmenu_0=Autodetect=" \\/a\        "if test ${boot_image_mode} = 1; then run boot_swupdate_mmc; exit 1; fi; " \\' \
            ${S}/include/configs/astrial-h15.h
    fi

    # A slot whose user space never starts must end in a reset, so that the SCU bootloader can count it and fall back.
    # The kernel keeps feeding the watchdog U-Boot started until somebody opens /dev/watchdog; the open timeout makes
    # it stop. Only the eMMC boot gets it: swupdate-image runs for minutes without opening the watchdog on purpose.
    if ! grep -q 'watchdog.open_timeout' ${S}/include/configs/hailo1x_common.h; then
        sed -i 's|\(root=/dev/mmcblk${device_num}p${mmc_rootfs_partition}\)|\1 watchdog.open_timeout=${QBA_WATCHDOG_OPEN_TIMEOUT}|' \
            ${S}/include/configs/hailo1x_common.h
        grep -q 'watchdog.open_timeout' ${S}/include/configs/hailo1x_common.h || \
            bbfatal "u-boot: the bootargs_mmc line was not found, the watchdog edit did not apply"
    fi
}
