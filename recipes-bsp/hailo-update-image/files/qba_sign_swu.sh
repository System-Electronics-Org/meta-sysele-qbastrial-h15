#!/bin/sh
# Signs sw-description (RSA-PSS). $1 private key, $2 directory of sw-description.
set -e
KEY="$1"
DIR="$2"
[ -f "$KEY" ] || { echo "qba_sign_swu: key not found: $KEY" >&2; exit 1; }
[ -f "$DIR/sw-description" ] || { echo "qba_sign_swu: no sw-description in $DIR" >&2; exit 1; }
openssl dgst -sha256 -sign "$KEY" -sigopt rsa_padding_mode:pss -sigopt rsa_pss_saltlen:-1 \
    -out "$DIR/sw-description.sig" "$DIR/sw-description"
