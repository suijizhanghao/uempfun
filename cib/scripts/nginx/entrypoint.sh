#!/bin/bash

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purposes

# Load libraries
. /cib/scripts/libcib.sh
. /cib/scripts/libnginx.sh

# Load NGINX environment variables
. /cib/scripts/nginx-env.sh

print_welcome_page

if [[ "$1" = "/cib/scripts/nginx/run.sh" ]]; then
    info "** Starting NGINX setup **"
    /cib/scripts/nginx/setup.sh
    info "** NGINX setup finished! **"
fi

echo ""
exec "$@"
