#!/bin/sh

## PKCS#11 via opensc
/usr/bin/keytool -v \
    -providerClass sun.security.pkcs11.SunPKCS11 \
    -providerArg /home/hans/Desktop/smartcards/opensc-java.cfg \
    -providerName SunPKCS11-OpenSC \
    -keystore NONE -storetype PKCS11 \
    $@ \

#    -J-Djava.security.debug=sunpkcs11

## PCSC via pcscd
#/usr/bin/keytool -v \
#    -providerClass sun.security.smartcardio.SunPCSC \
#    -keystore NONE -storetype PCSC -list \

#    -J-Djava.security.debug=sunpkcs11
