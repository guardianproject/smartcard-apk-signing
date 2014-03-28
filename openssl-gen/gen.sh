#!/bin/sh
#
# http://android-dls.com/wiki/index.php?title=Generating_Keys

set -e
set -x

## DO THIS FIRST!
#touch passin.txt
#chmod 0600 passin.txt
#editor passin.txt
cp passin.txt passout.txt

#openssl genrsa -out secretkey.pem -passout file:passout.txt -aes128 -rand /dev/random 2048
openssl genrsa -out secretkey.pem -passout file:passout.txt -aes128 2048
openssl rsa -in secretkey.pem -pubout -passin file:passin.txt -out publickey.pem
openssl req -passin file:passin.txt -new -key secretkey.pem -out request.pem \
    -subj "/C=US/ST=New York/O=Guardian Project Test/CN=test.guardianproject.info/emailAddress=test@guardianproject.info"
openssl x509 -passin file:passin.txt -req -days 9999 \
    -in request.pem -signkey secretkey.pem -out certificate.pem

# http://rostislav-matl.blogspot.nl/2012/04/using-smart-card-as-keystore-in-java.html
openssl pkcs12 -export -out certificate.p12 -in certificate.pem -inkey secretkey.pem \
    -passin file:passin.txt -passout file:passout.txt

keytool -importkeystore \
    -srckeystore certificate.p12 -srcstoretype PKCS12 -srcstorepass:file passin.txt \
    -destkeystore certificate.jkr -deststoretype JKS -deststorepass:file passin.txt

keytool -v \
    -providerClass sun.security.pkcs11.SunPKCS11 \
    -providerArg /home/hans/Desktop/smartcards/opensc-java.cfg \
    -providerName SunPKCS11-OpenSC \
    -importkeystore \
    -srckeystore certificate.p12 -srcstoretype PKCS12 -srcstorepass:file passin.txt \
    -destkeystore NONE -deststoretype PKCS11
