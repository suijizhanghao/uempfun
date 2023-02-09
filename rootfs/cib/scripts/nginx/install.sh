#!/bin/bash

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purposes

# Load libraries
. /cib/scripts/libnginx.sh
. /cib/scripts/libfs.sh

# Load NGINX environment variables
. /cib/scripts/nginx-env.sh

# Ensure non-root user has write permissions on a set of directories
for dir in "$NGINX_VOLUME_DIR" "$NGINX_CONF_DIR" "$NGINX_INITSCRIPTS_DIR" "$NGINX_SERVER_BLOCKS_DIR" "${NGINX_CONF_DIR}/cib" "$NGINX_LOGS_DIR" "$NGINX_TMP_DIR"; do
    ensure_dir_exists "$dir"
    chmod -R g+rwX "$dir"
done

# shellcheck disable=SC1091

yum install -y gcc gcc-c++ make tar unzip

nginx_version="${1:?nginx_version is required}"

work_path=/tmp/nginx-install
ensure_dir_exists "${work_path}"
chmod -R g+rwX  "${work_path}"
COMPONENTS=( \
      "nginx-${NGINX_VERSION}.tar.gz" \
      "zlib.xxxx.tar.gz" \
      "xxxxx.tar.gz" \
)
cd "${work_path}"
for COMPONENT in "${COMPONENTS[@]}"; do 
      curl -SsLf "https://downloads.bitnami.com/files/stacksmith/${COMPONENT}.tar.gz" -O 
done

tar -zxf nginx-${nginx_version}.tar.gz -C "${work_path}"





