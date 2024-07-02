#!/bin/bash

druid_metadata_storage_tls_crt="/tmp/metadata-tls/tls.crt"
druid_metadata_storage_tls_key="/tmp/metadata-tls/tls.key"
druid_metadata_storage_ca_crt="/tmp/metadata-tls/ca.crt"

DRUID_METADATA_STORAGE_TYPE_MYSQL="MySQL"
DRUID_METADATA_STORAGE_TYPE_PostgreSQL="PostgreSQL"

# Check if all required files exist
if [[ ! -f "$druid_metadata_storage_tls_crt" || ! -f "$druid_metadata_storage_tls_key" || ! -f "$druid_metadata_storage_ca_crt" ]]; then
  echo "Error: One or more required files (tls.crt, tls.key, ca.crt of metadata storage) are missing."
  exit 1
fi

function update_mysql_tls() {
  # Keystore name and password
  druid_metadata_storage_keystore="/opt/druid/conf/tls/metadata/metadatakeystore.jks"
  druid_metadata_storage_keystore_p12="/opt/druid/conf/metadata/tls/keystore.p12"
  KEYSTORE_PASSWORD=password


  # Import the private key into a PKCS12 keystore
  openssl pkcs12 -export -inkey "$druid_metadata_storage_tls_key" -in "$druid_metadata_storage_tls_crt" -out $druid_metadata_storage_keystore_p12 -certfile "$druid_metadata_storage_ca_crt" -password pass:"$KEYSTORE_PASSWORD"
  if [[ $? -ne 0 ]]; then
    echo "Error: Failed to create PKCS12 keystore."
    exit 1
  fi

  # Convert the PKCS12 keystore to JKS format
  keytool -importkeystore -srckeystore $druid_metadata_storage_keystore_p12 -srcstorepass "$KEYSTORE_PASSWORD" -destkeystore "$druid_metadata_storage_keystore" -deststorepass "$KEYSTORE_PASSWORD"
  if [[ $? -ne 0 ]]; then
    echo "Error: Failed to convert PKCS12 keystore to JKS format."
    exit 1
  fi

  echo "JKS keystore created successfully"
}

function update_postgres_tls() {
  druid_metadata_storage_tls_crt_final="/opt/druid/conf/tls/tls.crt"
  druid_metadata_storage_tls_key_final="/opt/druid/conf/tls/tls.key"
  druid_metadata_storage_ca_crt_final="/opt/druid/conf/tls/ca.crt"

  cp $druid_metadata_storage_tls_crt $druid_metadata_storage_tls_crt_final
  cp $druid_metadata_storage_tls_key $druid_metadata_storage_tls_key_final
  cp $druid_metadata_storage_ca_crt $druid_metadata_storage_ca_crt_final
}

function main() {
  # As /tmp/metadata-tls is Secret Mounted Volume, can not write there
  # So, creating a directory inside shared volume
  mkdir -p /opt/druid/conf/tls/metadata

  if [ "$DRUID_METADATA_STORAGE_TYPE" = "$DRUID_METADATA_STORAGE_TYPE_MYSQL" ]; then
      echo "Updating tls certificate directory for mysql"
      update_mysql_tls
  elif [ "$DRUID_METADATA_STORAGE_TYPE" = "$DRUID_METADATA_STORAGE_TYPE_PostgreSQL" ]; then
      echo "Updating tls certificate directory for postgres"
      update_postgres_tls
  fi
}
main