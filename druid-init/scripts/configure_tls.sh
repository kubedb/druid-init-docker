#!/bin/bash

druid_metadata_storage_keystore="/opt/druid/ssl/metadata/keystore.jks"
druid_metadata_storage_keystore_p12="/opt/druid/ssl/metadata/keystore.p12"
druid_metadata_storage_tls_crt="/tmp/metadata-tls/tls.crt"
druid_metadata_storage_tls_key="/tmp/metadata-tls/tls.key"
druid_metadata_storage_ca_crt="/tmp/metadata-tls/ca.crt"

druid_metadata_storage_tls_crt_final="/opt/druid/ssl/metadata/tls.crt"
druid_metadata_storage_tls_der_final="/opt/druid/ssl/metadata/tls.der"
druid_metadata_storage_ca_crt_final="/opt/druid/ssl/metadata/ca.crt"

DRUID_METADATA_STORAGE_TYPE_MYSQL="MySQL"
DRUID_METADATA_STORAGE_TYPE_POSTGRESQL="PostgreSQL"

# Check if all required files exist
function check_cert_files() {
  if [[ ! -f "$druid_metadata_storage_tls_crt" || ! -f "$druid_metadata_storage_tls_key" || ! -f "$druid_metadata_storage_ca_crt" ]]; then
    echo "Error: One or more required files (tls.crt, tls.key, ca.crt of metadata storage) are missing."
    exit 1
  fi
}

# For mysql, keystore needs to be generated for druid to use
# Ref docs: https://druid.apache.org/docs/latest/development/extensions-core/mysql/#configuration
function update_mysql_tls() {
  check_cert_files
  # Keystore name and password
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

  echo "Keystore for MySQL Metadata Storage has been created successfully"
}

# For postgres, sslKey needs to be in PKCS-12 or in PKCS-8 DER format
# Ref docs:
#   https://druid.apache.org/docs/latest/development/extensions-core/postgresql/#configuration
#   https://jdbc.postgresql.org/documentation/use/#connecting-to-the-database
function update_postgres_tls() {
  check_cert_files

  openssl pkcs8 -topk8 -inform PEM -outform DER -in $druid_metadata_storage_tls_key -out $druid_metadata_storage_tls_der_final -nocrypt

  cp $druid_metadata_storage_tls_crt $druid_metadata_storage_tls_crt_final
  cp $druid_metadata_storage_ca_crt $druid_metadata_storage_ca_crt_final
}

function main() {
  # As /tmp/metadata-tls is Secret Mounted Volume, can not write there
  # So, creating a directory inside shared volume
  if [ "$DRUID_METADATA_STORAGE_TYPE" = "$DRUID_METADATA_STORAGE_TYPE_MYSQL" ]; then
      echo "Updating tls certificate directory for mysql"
      update_mysql_tls
  elif [ "$DRUID_METADATA_STORAGE_TYPE" = "$DRUID_METADATA_STORAGE_TYPE_POSTGRESQL" ]; then
    echo "Updating tls certificate directory for mysql"
    update_postgres_tls
  fi
}
main