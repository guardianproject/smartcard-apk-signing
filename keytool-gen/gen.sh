#!/bin/sh

keytool -genkey -v -keystore 123456.keystore -alias testkey -keyalg RSA -keysize 2048 -sigalg SHA1withRSA -dname "cn=Test,ou=Test,c=CA" -validity 10000

keytool -v -importkeystore -srckeystore 123456.keystore -srcstoretype JKS -destkeystore 123456.p12 -deststoretype PKCS12
