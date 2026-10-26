# The customer key pair signs U-Boot and must never be in a repository. meta-sysele-bsp looks for it
# in its own files/ directory, where it is not committed. Point QBA_SECURE_ASSETS_DIR (local.conf,
# or the CI) at a private directory holding customer_keypair.pem and it is found there first.
QBA_SECURE_ASSETS_DIR ?= ""
FILESEXTRAPATHS:prepend := "${@d.getVar('QBA_SECURE_ASSETS_DIR') + ':' if d.getVar('QBA_SECURE_ASSETS_DIR') else ''}"
