#!/bin/sh
#
# http://android-dls.com/wiki/index.php?title=Generating_Keys

openssl genrsa -out key.pem 2048
openssl req -new -key key.pem -out request.pem
openssl x509 -req -days 9999 -in request.pem -signkey key.pem -out certificate.pem

# http://rostislav-matl.blogspot.nl/2012/04/using-smart-card-as-keystore-in-java.html
openssl pkcs12 -export -out certificate.p12 -in certificate.pem -inkey key.pem

keytool -importkeystore -srckeystore openssl-gen/certificate.p12 -srcstoretype PKCS12 -destkeystore certificate.jkr -deststoretype JKS

#openssl pkcs8 -topk8 -outform DER -in key.pem -inform PEM -out key.pk8 -nocrypt
