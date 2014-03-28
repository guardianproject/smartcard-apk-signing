#!/bin/sh
#
# https://dev.guardianproject.info/projects/bazaar/wiki/Improving_the_APK_Signing_Procedure
# https://guardianproject.info/2014/03/27/security-in-a-thumb-drive-the-promise-and-pain-of-hardware-security-modules-take-one

set -e # stop on error

if [ ! -x /usr/bin/srm ]; then
    echo "You need secure-delete aka srm:  sudo apt-get install secure-delete"
    exit
fi

if [ $# -ne 1 ] && [ $# -ne 2 ]; then
    echo "Usage: $0 \"CertDName\" [4096]"
    echo '  for example:'
    echo '  "/C=US/ST=New York/O=Guardian Project Test/CN=test.guardianproject.info/emailAddress=test@guardianproject.info"'
    exit
fi

# key size should be 4096 or 2048, default to 2048 since that is the best that
# most HSMs can handle
if [ ! -z $2 ] && [ $2 = 4096 ]; then
    keysize=4096
else
    keysize=2048
fi

test -e passin.txt && srm passin.txt
test -e passout.txt && srm passout.txt

touch passin.txt
chmod 0600 passin.txt
cat /dev/urandom | head -2 | tr -cd 'a-zA-Z0-9!@#$%^&*()_+-=\][\;\/\.\,' | cut -b4-30 > passin.txt
cp passin.txt passout.txt
chmod 0600 passin.txt passout.txt

echo Generating key, be patient...
openssl genrsa -out secretkey.pem -passout file:passout.txt -aes128 -rand /dev/urandom $keysize
openssl req -passin file:passin.txt -new -key secretkey.pem -out request.pem -subj "$1"
openssl x509 -passin file:passin.txt -req -days 9999 \
    -in request.pem -signkey secretkey.pem -out certificate.pem
openssl pkcs12 -export -out certificate.p12 -in certificate.pem -inkey secretkey.pem \
    -passin file:passin.txt -passout file:passout.txt

# output the public key to have handy for publishing
openssl rsa -in secretkey.pem -pubout -passin file:passin.txt -out publickey.pem

# if you want to generate a regular JKS keystore file on your local disk
#keytool -importkeystore \
#    -srckeystore certificate.p12 -srcstoretype PKCS12 -srcstorepass:file passin.txt \
#    -destkeystore certificate.jks -deststoretype JKS -deststorepass:file passout.txt

echo "Your HSM will prompt you for 'Security Officer' aka admin PIN, wait for it!"
keytool -v \
    -providerClass sun.security.pkcs11.SunPKCS11 \
    -providerArg ../opensc-java.cfg \
    -providerName SunPKCS11-OpenSC \
    -importkeystore \
    -srckeystore certificate.p12 -srcstoretype PKCS12 -srcstorepass:file passin.txt \
    -destkeystore NONE -deststoretype PKCS11

# print out fingerprints for reference
echo Key fingerprints for reference:
openssl x509 -in certificate.pem -noout -fingerprint -md5
openssl x509 -in certificate.pem -noout -fingerprint -sha1
openssl x509 -in certificate.pem -noout -fingerprint -sha256

echo "The public files are: certificate.pem publickey.pem request.pem"
echo "The secret files are: secretkey.pem certificate.p12 certificate.jkr"

echo -n "The passphrase for the secret files is: "
cat passin.txt
srm passin.txt passout.txt
