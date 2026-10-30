# Hailo's runtime package groups (the ones of core-image-hailo) instead of the -dev-pkg groups. The hailo-dev feature
# is off as well: it adds the -dev-pkg group of every package group installed.
IMAGE_FEATURES:remove = "hailo-dev"
QBA_DEV_PKG_GROUPS = "packagegroup-hailo-imaging-dev-pkg packagegroup-hailo-linux-dev-pkg packagegroup-hailo-dsp-dev-pkg packagegroup-hailo-media-library-dev-pkg"
IMAGE_INSTALL:remove = "${QBA_DEV_PKG_GROUPS}"
IMAGE_INSTALL:append = " packagegroup-hailo-imaging packagegroup-hailo-linux packagegroup-hailo-dsp packagegroup-hailo-media-library"

IMAGE_INSTALL:remove = "sysele-dsi-detection sysele-dsi-touch-test"

# swupdate verifies the SWU with this key; qba-slot-sync keeps the SCU bootloader configuration in step with
# the slot that booted; watchdog feeds /dev/watchdog.
IMAGE_INSTALL:append = " swupdate-public-key qba-slot-sync watchdog"

# Tools for whoever develops on the camera.
QBA_DEV_TOOLS = "gdb valgrind strace perf vim-tiny htop tmux tcpdump lsof rsync ethtool tree coreutils"
# Network name, time and the font that GStreamer text overlays draw with.
QBA_BASE_SERVICES = "ntp avahi-daemon libnss-mdns tzdata liberation-fonts"
# Perfetto tracing of the pipelines.
QBA_PROFILER = "perfetto libperfetto hailo-soc-profiler hailo-soc-profiler-service"
IMAGE_INSTALL:append = " ${QBA_DEV_TOOLS} ${QBA_BASE_SERVICES} ${QBA_PROFILER}"

# imaging-sub-system installs 235 MiB of debug files and static libraries under /lib. The package stays whole, for
# the SDK; the image drops them, and keeps every shared library, including the ISP modules in the subdirectories.
ROOTFS_POSTPROCESS_COMMAND += "qba_trim_imaging_lib;"
qba_trim_imaging_lib() {
    find ${IMAGE_ROOTFS}/lib -name .debug -type d -prune -exec rm -rf {} +
    find ${IMAGE_ROOTFS}/lib -name '*.a' -delete
}
