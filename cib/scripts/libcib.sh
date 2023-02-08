#!/bin/bash
#
# Cib custom library

# shellcheck disable=SC1091

# Load Generic Libraries
. /cib/scripts/liblog.sh

# Constants
BOLD='\033[1m'

# Functions

########################
# Print the welcome page
# Globals:
#   DISABLE_WELCOME_MESSAGE
#   CIB_APP_NAME
# Arguments:
#   None
# Returns:
#   None
#########################
print_welcome_page() {
    if [[ -z "${DISABLE_WELCOME_MESSAGE:-}" ]]; then
        if [[ -n "$CIB_APP_NAME" ]]; then
            print_image_welcome_page
        fi
    fi
}

########################
# Print the welcome page for a Cib Docker image
# Globals:
#   CIB_APP_NAME
# Arguments:
#   None
# Returns:
#   None
#########################
print_image_welcome_page() {
    log ""
    log "${BOLD}Welcome to the Cib ${CIB_APP_NAME} container${RESET}"
    log ""
}

