#!/bin/bash
#
# 切记：需与nginx.conf中配置的值保持一致

# Environment configuration for nginx

# The values for all environment variables will be set in the below order of precedence
# 1. Custom environment variables defined below after Cib defaults
# 2. Constants defined in this file (environment variables with no default), i.e. CIB_ROOT_DIR
# 3. Environment variables overridden via external files using *_FILE variables (see below)
# 4. Environment variables set externally (i.e. current Bash context/Dockerfile/userdata)

# Load logging library
# shellcheck disable=SC1090,SC1091
. /cib/scripts/liblog.sh

export CIB_ROOT_DIR="/cib"
export CIB_VOLUME_DIR="/cib_volume"

# Logging configuration
export MODULE="${MODULE:-nginx}"
export CIB_DEBUG="${CIB_DEBUG:-false}"

# 从文件中加载环境变量
# By setting an environment variable matching *_FILE to a file path, the prefixed environment
# variable will be overridden with the value specified in that file
nginx_env_vars=(
    UEMP_NAMESPACE
    UEMP_PROFILE
    # NGINX_HTTP_PORT_NUMBER
    # NGINX_HTTPS_PORT_NUMBER
    # NGINX_ENABLE_ABSOLUTE_REDIRECT
    # NGINX_ENABLE_PORT_IN_REDIRECT
)
for env_var in "${nginx_env_vars[@]}"; do
    file_env_var="${env_var}_FILE"
    if [[ -n "${!file_env_var:-}" ]]; then
        if [[ -r "${!file_env_var:-}" ]]; then
            export "${env_var}=$(< "${!file_env_var}")"
            unset "${file_env_var}"
        else
            warn "Skipping export of '${env_var}'. '${!file_env_var:-}' is not readable."
        fi
    fi
done
unset nginx_env_vars
export WEB_SERVER_TYPE="nginx"

# Paths
export NGINX_BASE_DIR="${CIB_ROOT_DIR}/nginx"
# export NGINX_VOLUME_DIR="${CIB_VOLUME_DIR}/nginx"     # 不再使用了
export NGINX_SBIN_DIR="${NGINX_BASE_DIR}/sbin"          # 与默认路径相同
export NGINX_CONF_DIR="${NGINX_BASE_DIR}/conf"          # 与默认路径相同
export NGINX_HTDOCS_DIR="${NGINX_BASE_DIR}/html"        # 与默认路径相同
export NGINX_TMP_DIR="${NGINX_BASE_DIR}/tmp"            # 需与nginx.conf中的5个temp_path保持一致
export NGINX_LOGS_DIR="${NGINX_BASE_DIR}/logs"
export NGINX_SERVER_BLOCKS_DIR="${NGINX_CONF_DIR}/server_blocks"    # TODO 需要考虑删除掉
export NGINX_INITSCRIPTS_DIR="/docker-entrypoint-initdb.d"
export NGINX_CONF_FILE="${NGINX_CONF_DIR}/nginx.conf"   
export NGINX_PID_FILE="${NGINX_TMP_DIR}/nginx.pid"      # 需与nginx.conf中的pid配置参数相同
export PATH="${NGINX_SBIN_DIR}:${PATH}"

# System users (when running with a privileged user)
export CIB_USER="cib"
export WEB_SERVER_DAEMON_USER="$CIB_USER"
export CIB_GROUP="cib"
export WEB_SERVER_DAEMON_GROUP="$CIB_GROUP"
export NGINX_DEFAULT_HTTP_PORT_NUMBER="8080"
export WEB_SERVER_DEFAULT_HTTP_PORT_NUMBER="$NGINX_DEFAULT_HTTP_PORT_NUMBER" # only used at build time
export NGINX_DEFAULT_HTTPS_PORT_NUMBER="8443"
export WEB_SERVER_DEFAULT_HTTPS_PORT_NUMBER="$NGINX_DEFAULT_HTTPS_PORT_NUMBER" # only used at build time

# NGINX configuration
export UEMP_NAMESPACE="${UEMP_NAMESPACE:-}"
UEMP_PROFILE=$(echo "${UEMP_NAMESPACE}"|cut -d'-' -f2-) # 默认为第1个 “-”号，后面的所有内容，都是profile；G047L0-a-b，那么a-b就是profile的值
export UEMP_PROFILE="${UEMP_PROFILE}:-"
# export NGINX_HTTP_PORT_NUMBER="${NGINX_HTTP_PORT_NUMBER:-}"
# export WEB_SERVER_HTTP_PORT_NUMBER="$NGINX_HTTP_PORT_NUMBER"
# export NGINX_HTTPS_PORT_NUMBER="${NGINX_HTTPS_PORT_NUMBER:-}"
# export WEB_SERVER_HTTPS_PORT_NUMBER="$NGINX_HTTPS_PORT_NUMBER"
# export NGINX_ENABLE_ABSOLUTE_REDIRECT="${NGINX_ENABLE_ABSOLUTE_REDIRECT:-no}"
# export NGINX_ENABLE_PORT_IN_REDIRECT="${NGINX_ENABLE_PORT_IN_REDIRECT:-no}"

# Custom environment variables may be defined below
