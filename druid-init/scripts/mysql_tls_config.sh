#!/bin/bash

druid_metadata_storage_tls_crt="/tmp/metadata/tls.crt"
druid_metadata_storage_tls_key="/tmp/metadata/tls.key"
druid_metadata_storage_ca_crt="/tmp/metadata/ca.crt"

# Check if all required files exist
if [[ ! -f druid_metadata_storage_tls_crt || ! -f druid_metadata_storage_tls_key || ! -f druid_metadata_storage_ca_crt ]]; then
  echo "Error: One or more required files (tls.crt, tls.key, ca.crt of metadata storage) are missing."
  exit 1
fi

# Keystore name and password (replace with your desired values)
KEYSTORE_NAME=metadatakeystore.jks
KEYSTORE_PASSWORD=password

# Import the private key into a PKCS12 keystore
openssl pkcs12 -export -inkey druid_metadata_storage_tls_key -in druid_metadata_storage_tls_crt -out keystore.p12 -certfile  -CAfile druid_metadata_storage_ca_crt -password pass:out:KEYSTORE_PASSWORD

# Convert the PKCS12 keystore to JKS format
keytool -importkeystore -srckeystore keystore.p12 -srcstorepass pass:out:KEYSTORE_PASSWORD -destkeystore $KEYSTORE_NAME -deststorepass pass:$KEYSTORE_PASSWORD

# Clean up the temporary PKCS12 keystore
rm keystore.p12

echo "JKS keystore created successfully: $KEYSTORE_NAME"