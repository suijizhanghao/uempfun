#!/bin/bash

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purposes

# Load libraries
. /cib/scripts/libnginx.sh

# Load NGINX environment variables
. /cib/scripts/nginx-env.sh

/cib/scripts/nginx/stop.sh
/cib/scripts/nginx/start.sh
