#!/bin/bash

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purposes

# Load libraries
. /cib/scripts/liblog.sh
. /cib/scripts/libnginx.sh

# Load NGINX environment variables
. /cib/scripts/nginx-env.sh

info "** Starting NGINX **"
exec "${NGINX_SBIN_DIR}/nginx" -c "$NGINX_CONF_FILE" -g "daemon off;"
