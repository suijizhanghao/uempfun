#!/bin/bash

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purposes

# Load libraries
. /cib/scripts/libnginx.sh
. /cib/scripts/liblog.sh

# Load NGINX environment
. /cib/scripts/nginx-env.sh

info "** Reloading NGINX configuration **"
exec "${NGINX_SBIN_DIR}/nginx" -s reload
