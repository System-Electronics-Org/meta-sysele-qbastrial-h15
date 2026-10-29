# swupdate checks the RSA-PSS signature of sw-description and the sha256 of every entry.
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI += "file://signed.cfg"
