# meta-sysele-qbastrial-h15

Layer on top of `meta-sysele-astrial-h15` (collection `meta-sysele-bsp`) for the QBAstrial H15 product.
It only holds the difference from the base layer. Collection `sysele-qba-bsp`, priority 11.

## What it changes

| Where | What |
|---|---|
| U-Boot DTB | the node labelled `serial` moves from uart1 (0x109000) to uart0 (0x108000), SPL included |
| U-Boot `BOOTARGS_BASE` | `console=ttyS0` instead of `ttyS1` |
| Linux DTS | `chosen/stdout-path = &serial0` |
| `SERIAL_CONSOLES` | `115200;ttyS0`, so the getty is on ttyS0 |

The first programming of a blank SPI-NOR still goes through the mask ROM on UART1. After that, U-Boot
and Linux talk on UART0.

## Status

v0.0.0 builds and boots on an Astrial H15 board: SPL, U-Boot and the login on UART0, wic update over TFTP,
automatic boot from eMMC afterwards. Not yet wired into a kas file or a CI workflow.

## What v0.0.0 changes on top of `meta-sysele-astrial-h15` (`kirkstone`)

- Console on UART0 for U-Boot (SPL included), the kernel command line, the device tree and the login getty.
- Hostname `qbastrialh15`, so the prompt reads `root@qbastrialh15`.
- No display: `KERNEL_DEVICETREE` keeps only `sysele/astrial-h15.dtb`, the DSI/DPI/D-PHY and panel nodes are
  disabled, and the DSI test tools are left out of the image. The kernel DSI patches stay (inert).
- The banner reads `QBAstrial H15`. `BSP` shows `unreleased` on a local build; a tagged CI build exports
  `SYSELE_BSP_VERSION` with the tag name, as the base layer does.
- After "Update eMMC (wic) from TFTP" the board boots from eMMC instead of reopening the menu.
- The secure boot key pair is not in this repository. Set `QBA_SECURE_ASSETS_DIR` to a private directory
  that holds `customer_keypair.pem`.

Build order: `u-boot u-boot-tfa-image`, then `swupdate-image`, then `core-image-hailo-dev`, each as its own
`bitbake` command (the image needs `swupdate-image-*.ext4.gz` in the boot partition without declaring it).
