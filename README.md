# meta-sysele-qbastrial-h15

Layer for the QBAstrial H15 smart camera, on top of `meta-sysele-astrial-h15` (collection `meta-sysele-bsp`).
It holds only the difference from the base layer. Collection `sysele-qba-bsp`, priority 11.

## Differences from the base layer

| Area | Change |
|---|---|
| Console | U-Boot (SPL included), kernel and getty on UART0 (`ttyS0`) |
| Display | none: DSI, DPI and panel nodes disabled, Waveshare trees and DSI tools removed |
| Identity | hostname `qbastrialh15`, banner `QBAstrial H15` |
| Update | signed SWU, A/B with fallback to the other slot |

The SPI-NOR is programmed once through the mask ROM on UART1; from the first boot on, U-Boot and Linux use UART0.

## Update

`/etc/run_swupdate.sh` fetches the SWU over TFTP and installs it without a console.

- First installation: `fw_setenv swupdate_update_modes init-partitions-dual,init-scu-bl,copy-a,copy-b`, then
  `run_swupdate.sh -b -s <server> -r <file>.swu`.
- Update: `run_swupdate.sh -b -d -s <server> -r <file>.swu` writes the other slot and boots it next.

The SWU is Hailo's, with the sha256 of every entry added. swupdate verifies the RSA-PSS signature of `sw-description`
and every hash with `/etc/swupdate-public.pem`, in the system and in `swupdate-image`. An unsigned, altered or
wrongly signed SWU is refused.

The SWU is signed at build time with `QBA_SWU_PRIVATE_KEY`, the path of an RSA private key. The public key is read
from `QBA_SECURE_ASSETS_DIR/swupdate-public.pem`. Without a key the SWU is unsigned and the images refuse it.

## Fallback to the other slot

The SCU bootloader boots the next descriptor after `boot_max_retries` boots that end in a watchdog reset.

- The configuration lists the target slot, the other slot and the target slot again, two boots each. `set_sw_image.sh`
  writes it, so after an update the new slot is first and the old one is the fallback.
- `watchdog.open_timeout` (60 s) is on the kernel command line of the eMMC boot. The `watchdog` daemon starts at S98 and
  feeds `/dev/watchdog`.
- `hailo_linux_init.sh` runs at S99 and sets `boot_success_ap_software` once the daemon is up.
- `qba-slot-sync` (S98) mounts the `/boot` of the booted slot. When the SPI-NOR configuration differs from the one of the
  booted slot, as after a fallback, it rewrites it and writes 99 to `boot_success_ap_software`, which resets the descriptor
  index the SCU keeps across warm resets.

The SCU bootloader configuration is not authenticated by the secure boot chain.

## Keys

Neither key is in this repository. `QBA_SECURE_ASSETS_DIR` holds `customer_keypair.pem` (secure boot) and
`swupdate-public.pem`.

## Build

```
bitbake u-boot u-boot-tfa-image
bitbake swupdate-image
bitbake core-image-hailo-dev
bitbake hailo-update-image
```

## CI

`.github/workflows/build.yml` runs on manual dispatch or on a tag `vX.Y.Z`. It pins `meta-sysele-astrial-h15` at
`BASE_LAYER_REF`, verifies the keys, builds with kas and, on a tag, publishes the release. Secrets:
`HAILO_CUSTOMER_KEYPAIR` (secure boot) and `SWU_SIGNING_KEY` (SWU signing). The run stops before the build if either is
missing or invalid.
