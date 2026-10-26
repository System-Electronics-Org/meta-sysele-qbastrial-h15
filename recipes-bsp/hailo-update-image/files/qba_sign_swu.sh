#!/bin/sh
# Signs sw-description for swupdate (CONFIG_SIGALG_RSAPSS), called by the swupdate class as SWUPDATE_SIGN_TOOL.
#   $1  private key (PEM, RSA)
#   $2  directory that holds sw-description; sw-description.sig is written next to it
set -e
KEY="$1"
DIR="$2"
[ -f "$KEY" ] || { echo "qba_sign_swu: private key not found: $KEY" >&2; exit 1; }
[ -f "$DIR/sw-description" ] || { echo "qba_sign_swu: no sw-description in $DIR" >&2; exit 1; }
openssl dgst -sha256 -sign "$KEY" -sigopt rsa_padding_mode:pss -sigopt rsa_pss_saltlen:-1 \
    -out "$DIR/sw-description.sig" "$DIR/sw-description"
echo "qba_sign_swu: signed $DIR/sw-description"
