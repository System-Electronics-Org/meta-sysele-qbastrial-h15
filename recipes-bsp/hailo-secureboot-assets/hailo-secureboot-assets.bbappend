# The customer key pair is never in a repository: QBA_SECURE_ASSETS_DIR points to the directory that holds
# customer_keypair.pem, and it is searched first.
QBA_SECURE_ASSETS_DIR ?= ""
FILESEXTRAPATHS:prepend := "${@d.getVar('QBA_SECURE_ASSETS_DIR') + ':' if d.getVar('QBA_SECURE_ASSETS_DIR') else ''}"
