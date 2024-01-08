#!/bin/bash

set -x
# Set the directory where Druid configuration files are located
druid_config_dir="/opt/druid/conf"

# Temporary directory for merging configuration files, does not have any actual affect
druid_config_dir_temp="/tmp/config/default-config/*"

# Set the directory where Druid Operator Configuration files are located
druid_operator_config_common="/tmp/config/operator-config/common.runtime.properties"
druid_operator_config_coordinators="/tmp/config/operator-config/coordinators.properties"
druid_operator_config_historicals="/tmp/config/operator-config/historicals.properties"
druid_operator_config_middleManagers="/tmp/config/operator-config/middleManagers.properties"
druid_operator_config_brokers="/tmp/config/operator-config/brokers.properties"
druid_operator_config_routers="/tmp/config/operator-config/routers.properties"
druid_temp_merged_config="/tmp/config/temp-config.properties"

# Set the directory where Druid Custom Configuration files are located
druid_custom_config_common="/tmp/config/custom-config/common.runtime.properties"
druid_custom_config_coordinators="/tmp/config/custom-config/coordinators.properties"
druid_custom_config_overlords="/tmp/config/custom-config/overlords.properties"
druid_custom_config_historicals="/tmp/config/custom-config/historicals.properties"
druid_custom_config_middleManagers="/tmp/config/custom-config/middleManagers.properties"
druid_custom_config_brokers="/tmp/config/custom-config/brokers.properties"
druid_custom_config_routers="/tmp/config/custom-config/routers.properties"

# Set the directory where Druid Default Configuration files are located
druid_default_config_common="/tmp/config/default-config/druid/cluster/_common/common.runtime.properties"
druid_default_config_coordinators_overlords="/tmp/config/default-config/druid/cluster/master/coordinator-overlord/runtime.properties"
druid_default_config_historicals="/tmp/config/default-config/druid/cluster/data/historical/runtime.properties"
druid_default_config_middleManagers="/tmp/config/default-config/druid/cluster/data/middleManager/runtime.properties"
druid_default_config_brokers="/tmp/config/default-config/druid/cluster/query/broker/runtime.properties"
druid_default_config_routers="/tmp/config/default-config/druid/cluster/query/router/runtime.properties"


# Copies the files necessary for using 'mysql' as metadata storage in the apt directory
function configure_mysql_metadata_storage() {
  cp -r /tmp/extensions/mysql-metadata-storage/mysql-connector-java-5.1.49.jar /opt/druid/extensions/mysql-metadata-storage/mysql-connector-java-5.1.49.jar
  cp -r /tmp/extensions/mysql-metadata-storage/mysql-metadata-storage-25.0.0.jar /opt/druid/extensions/mysql-metadata-storage/mysql-metadata-storage-25.0.0.jar
}
configure_mysql_metadata_storage

# Removes comments and empty lines from a file.
# Sorts the file in alphabetical order.
# Arguments -> A properties file
function remove_comments_and_sort() {
  sed -i '/^#/d;/^$/d' $1
  sort -o $1 $1
}

# Merge operator config with default config and place in the default config
function merge_default_and_operator_config() {
  touch $druid_temp_merged_config
  echo "" > $druid_default_config_coordinators_overlords

  /tmp/scripts/merge_config_properties.sh $druid_operator_config_common $druid_default_config_common $druid_temp_merged_config
  /tmp/scripts/merge_config_properties.sh $druid_operator_config_coordinators $druid_default_config_coordinators_overlords $druid_temp_merged_config
  /tmp/scripts/merge_config_properties.sh $druid_operator_config_historicals $druid_default_config_historicals $druid_temp_merged_config
  /tmp/scripts/merge_config_properties.sh $druid_operator_config_middleManagers $druid_default_config_middleManagers $druid_temp_merged_config
  /tmp/scripts/merge_config_properties.sh $druid_operator_config_brokers $druid_default_config_brokers $druid_temp_merged_config
  /tmp/scripts/merge_config_properties.sh $druid_operator_config_routers $druid_default_config_routers $druid_temp_merged_config

  remove_comments_and_sort $druid_default_config_common
  remove_comments_and_sort $druid_default_config_coordinators_overlords
  remove_comments_and_sort $druid_default_config_historicals
  remove_comments_and_sort $druid_default_config_middleManagers
  remove_comments_and_sort $druid_default_config_brokers
  remove_comments_and_sort $druid_default_config_routers
}
merge_default_and_operator_config

# Merge custom config with default config and place in the default config
function merge_default_and_custom_config() {
  /tmp/scripts/merge_config_properties.sh $druid_custom_config_common $druid_default_config_common $druid_temp_merged_config
  /tmp/scripts/merge_config_properties.sh $druid_custom_config_coordinators $druid_default_config_coordinators_overlords $druid_temp_merged_config
  /tmp/scripts/merge_config_properties.sh $druid_custom_config_overlords $druid_default_config_coordinators_overlords $druid_temp_merged_config
  /tmp/scripts/merge_config_properties.sh $druid_custom_config_historicals $druid_default_config_historicals $druid_temp_merged_config
  /tmp/scripts/merge_config_properties.sh $druid_custom_config_middleManagers $druid_default_config_middleManagers $druid_temp_merged_config
  /tmp/scripts/merge_config_properties.sh $druid_custom_config_brokers $druid_default_config_brokers $druid_temp_merged_config
  /tmp/scripts/merge_config_properties.sh $druid_custom_config_routers $druid_default_config_routers $druid_temp_merged_config


  remove_comments_and_sort $druid_default_config_common
  remove_comments_and_sort $druid_default_config_coordinators_overlords
  remove_comments_and_sort $druid_default_config_historicals
  remove_comments_and_sort $druid_default_config_middleManagers
  remove_comments_and_sort $druid_default_config_brokers
  remove_comments_and_sort $druid_default_config_routers
}
merge_default_and_custom_config

function place_config_files() {
  cp -r $druid_config_dir_temp $druid_config_dir
}
place_config_files