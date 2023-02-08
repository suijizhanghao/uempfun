#!/bin/bash

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purposes

# Load libraries
. /cib/scripts/libos.sh
. /cib/scripts/libfs.sh
. /cib/scripts/libnginx.sh

# Load NGINX environment variables
. /cib/scripts/nginx-env.sh

# Ensure NGINX environment variables settings are valid
nginx_validate

# Ensure NGINX is stopped when this script ends
trap "nginx_stop" EXIT

# Ensure NGINX daemon user exists when running as 'root'
am_i_root && ensure_user_exists "$NGINX_DAEMON_USER" --group "$NGINX_DAEMON_GROUP"

# Run init scripts
nginx_custom_init_scripts

# Fix logging issue when running as root
! am_i_root || chmod o+w "$(readlink /dev/stdout)" "$(readlink /dev/stderr)"

# Configure HTTPS port number
if [[ -n "${NGINX_HTTPS_PORT_NUMBER:-}" ]] && [[ ! -f "${NGINX_SERVER_BLOCKS_DIR}/default-https-server-block.conf" ]] && is_dir_empty "${NGINX_SERVER_BLOCKS_DIR}"; then
    cp "${CIB_ROOT_DIR}/scripts/nginx/server_blocks/default-https-server-block.conf" "${NGINX_SERVER_BLOCKS_DIR}/default-https-server-block.conf"
fi

# Initialize NGINX
nginx_initialize

