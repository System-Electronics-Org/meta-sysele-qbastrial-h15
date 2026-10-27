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
automatic boot from eMMC afterwards. `kas/qbastrial-h15.yml` and `.github/workflows/build.yml` build it in CI;
the workflow has not run yet.

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

## Updates over the air (SWU)

The image carries `/etc/run_swupdate.sh` (Hailo's launcher). `run_swupdate.sh -b -s <server> -r <file>.swu` stores the
server, asks the SCU for a remote update and reboots; U-Boot then boots `swupdate-image` from RAM, which downloads the SWU
over TFTP and installs it on the eMMC. Nothing has to be typed on a console.

What this layer changes for that to work on the Astrial H15:

- `bootmenu_0` checks `boot_image_mode` and boots `swupdate-image` on a remote update. The base layer lacks that line.
- The SWU defaults to `mmcblk1` (the eMMC). The base layer falls back to `mmcblk0` (the SD slot).
- The SWU is Hailo's complete one (partitioning, SCU bootloader, slot A and slot B with their firmware copies in the
  SPI-NOR), with the sha256 of every entry added: swupdate requires it as soon as it checks signatures.
- swupdate checks the signature of `sw-description` (RSA-PSS) and the sha256 of every entry. The public key is installed as
  `/etc/swupdate-public.pem` in both the system and `swupdate-image`, and `run_swupdate.sh` passes it in dual (A/B) mode as
  well; an unsigned, altered or wrongly signed SWU is refused.

First installation of a board: `fw_setenv swupdate_update_modes init-partitions-dual,init-scu-bl,copy-a,copy-b`, then
`run_swupdate.sh -b -s <server> -r <file>.swu`. Later updates from the running system: `run_swupdate.sh -b -d -s <server> -r
<file>.swu`, which writes the other slot and makes it the next one to boot.

## Fall back to the other slot

The SCU bootloader can switch to another image when one does not come up (Hailo OS User Guide 1.12.0, chapter 8): it retries
the same image `boot_max_retries` times, each ending in a watchdog reset, then boots the next descriptor. Hailo's configuration
files list a single image and set `boot_max_retries` to `0xFF`, which turns the switch off, so a slot that boots and never comes
up stays there. This layer turns it on:

- `scu_bl_cfg_a` lists slot A first and slot B second, `scu_bl_cfg_b` the other way round, three retries each. `set_sw_image.sh`
  copies these files, so after an update the new slot is the first choice and the old one the fallback.
- `watchdog.open_timeout` (60 s) is added to the kernel command line of the eMMC boot only. Without it the kernel keeps feeding
  the watchdog U-Boot started, and a slot without a working user space waits forever. `swupdate-image` does not get it: it runs for
  minutes without opening the watchdog.
- The `watchdog` daemon starts at S98 and keeps `/dev/watchdog` fed.
- `hailo_linux_init.sh` moves from S50 to S99. It writes `boot_success_ap_software`, and the SCU bootloader does not count a boot
  after that flag as failed: with the flag set at S50, a slot that died later was reset forever without a fallback.
- `qba-slot-sync` (S98) compares the configuration in the SPI-NOR with the one the image ships for the slot that booted and
  rewrites it when they differ: after a fallback, or after an update made by an image whose configuration had no fallback.

The configuration is not authenticated by the secure boot chain (Hailo OS User Guide), so whoever can write the SPI-NOR can change
which slot starts.

The SWU is signed at build time with the key in `QBA_SWU_PRIVATE_KEY` (a path to an RSA private key, never part of this
repository). The matching public key is read from `QBA_SECURE_ASSETS_DIR/swupdate-public.pem`. Without a signing key the SWU is
built unsigned, and the images refuse it.

Not covered: the secure boot chain verifies SPL, U-Boot and the `fitImage`, not the root file system or `swupdate-image`. A
signed SWU stops unauthorised remote updates; it does not protect against someone who can write the eMMC.

## CI

`.github/workflows/build.yml` runs on a manual dispatch or on a tag `vX.Y.Z`. It clones `meta-sysele-astrial-h15` at the
commit pinned in `BASE_LAYER_REF`, checks the secure boot key first (valid RSA key, expected modulus), builds with kas
and, on a tag, publishes the release. The secure boot key comes from the repository secret `HAILO_CUSTOMER_KEYPAIR`, the SWU
signing key from `SWU_SIGNING_KEY` (a separate RSA key; the run stops in seconds if either is missing or not a valid key). There is no
`pull_request` trigger, so a fork cannot reach the secret.
