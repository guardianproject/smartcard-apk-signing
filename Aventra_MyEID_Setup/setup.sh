#!/bin/sh

set -e # stop on error

run_pkcs15_init () {
    pkcs15-init --options-file pkcs15-init-options-file-pins --options-file $1
}

pinfile=pkcs15-init-options-file-pins
if [ ! -e $pinfile ]; then
    echo "Edit $pinfile to put in the PINs you want to set:"
    touch $pinfile
    chmod 0600 $pinfile
    echo "pin 123456" >> $pinfile
    echo "puk 123456" >> $pinfile
    echo "so-pin 12345678" >> $pinfile
    echo "so-puk 12345678" >> $pinfile
    exit
fi

run_pkcs15_init 0.pkcs15-init-options-file-erase-card
run_pkcs15_init 1.pkcs15-init-options-file-create-pkcs15
run_pkcs15_init 2.pkcs15-init-options-file-store-pin-signing
run_pkcs15_init 3.pkcs15-init-options-file-store-pin-encryption
run_pkcs15_init 4.pkcs15-init-options-file-finalize

echo "next generate a key with ./gen.sh then ./finalize.sh"
