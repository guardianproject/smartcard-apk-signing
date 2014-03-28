#!/bin/sh

## PKCS#11 via opensc
/usr/bin/jarsigner -verbose \
    -providerClass sun.security.pkcs11.SunPKCS11 \
    -providerArg opensc-java.cfg \
    -providerName SunPKCS11-OpenSC \
    -keystore NONE -storetype PKCS11 \
    $@ \

#    -J-Djava.security.debug=sunpkcs11
