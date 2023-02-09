#!/bin/bash

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purposes

# Load libraries
. /cib/scripts/libnginx.sh
. /cib/scripts/liblog.sh

# Load NGINX environment variables
. /cib/scripts/nginx-env.sh

if is_nginx_running; then
    info "nginx is already running"
else
    info "nginx is not running"
fi
