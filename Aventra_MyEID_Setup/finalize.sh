#!/bin/sh

set -e # stop on error

run_pkcs15_init () {
    pkcs15-init --options-file pkcs15-init-options-file-pins --options-file $1
}

pinfile=pkcs15-init-options-file-pins
if [ ! -e $pinfile ]; then
    echo "Need PINs in $pinfile to finalize!"
    exit
fi
run_pkcs15_init 4.pkcs15-init-options-file-finalize

echo "Your HSM is ready for use! Put the secret key files someplace encrypted and safe!"
