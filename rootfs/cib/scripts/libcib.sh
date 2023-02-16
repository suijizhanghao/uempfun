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
# Print the welcome page for a Cib Docker image，此处统一打印各种基础信息
# Globals:
#   CIB_APP_NAME
#   APP_VERSION
# Arguments:
#   None
# Returns:
#   None
#########################
print_image_welcome_page() {
    print_vars() {
        local var
        for var in "$@" ;do
            echo -n "${var}=${!var} "
        done
    }
    log ""
    log "${BOLD}Welcome to the Cib ${CIB_APP_NAME} container${RESET}"
    log "关键变量打印：$(print_vars UEMP_NAMESPACE UEMP_PROFILE)"
    log ""
}

