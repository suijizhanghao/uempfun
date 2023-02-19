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

# UEMP_NAMESPACE从环境变量读取
export UEMP_NAMESPACE="${UEMP_NAMESPACE:-}" 
export UEMP_PROFILE="${UEMP_PROFILE:-}"
# 默认为第1个 “-”号，后面的所有内容，都是profile；G047L0-a-b，那么a-b就是profile的值
# 如果能约定好规则，那么可以使用 UEMP_PROFILE="${UEMP_NAMESPACE:8:1000}"来取得对应的值
[ -n "${UEMP_PROFILE}" ] || UEMP_PROFILE=$(echo "${UEMP_NAMESPACE}"|cut -d'-' -f2-) 
export UEMP_PROFILE

# 全局约定值
export CIB_ROOT_DIR="/cib"
export CIB_VOLUME_DIR="${CIB_ROOT_DIR}/cib_volume"

# Logging configuration
export MODULE="${MODULE:-nginx}"
export CIB_DEBUG="${CIB_DEBUG:-false}"

# 从文件中加载环境变量
# By setting an environment variable matching *_FILE to a file path, the prefixed environment
# variable will be overridden with the value specified in that file
nginx_env_vars=(
    A_KEY   # 在编排文件中传入 A_KEY_FILE环境变量，指向A_KEY的值的文件名
    # NGINX_HTTP_PORT_NUMBER
    # NGINX_HTTPS_PORT_NUMBER
    # NGINX_ENABLE_ABSOLUTE_REDIRECT
    # NGINX_ENABLE_PORT_IN_REDIRECT
)
# 先解析文件A_KEY_FILE的值，再解析文件"A_KEY_FILE-${UEMP_PROFILE}"的值，用以模拟springboot的profile
# 且必须生产文件存在时，才再判断其他profile是否存在；避免：生产没设置，而测试设置了，进而在测试通过但生产中出错
for env_var in "${nginx_env_vars[@]}"; do
    file_env_var="${env_var}_FILE"
    if [[ -n "${!file_env_var:-}" ]]; then
        if [[ -r "${!file_env_var:-}" ]]; then
            export "${env_var}=$(< "${!file_env_var}")"
            file_env_var_profile_file="${!file_env_var}.${UEMP_PROFILE}"
            if [[ -r "${file_env_var_profile_file}" ]]; then
                export "${env_var}=$(< "${file_env_var_profile_file}")"
            fi
            unset file_env_var_profile_file
            unset "${file_env_var}"
        else
            warn "Skipping export of '${env_var}'. '${!file_env_var:-}' is not readable."
        fi
    fi
done
unset nginx_env_vars
# 此时nginx_env_vars中的值，如果不是空的，都被export了
export WEB_SERVER_TYPE="nginx"

# Paths
export NGINX_BASE_DIR="${CIB_ROOT_DIR}/nginx"
export NGINX_VOLUME_DIR="${CIB_VOLUME_DIR}/nginx"       # 目前考虑不在使用，此处只是占位一下，如果再启用，另当他论@2023年02月16日15:17:03
export NGINX_SBIN_DIR="${NGINX_BASE_DIR}/sbin"          # 与默认路径相同
export NGINX_CONF_DIR="${NGINX_BASE_DIR}/conf"          # 与默认路径相同
export NGINX_HTDOCS_DIR="${NGINX_BASE_DIR}/html"        # 与默认路径相同
export NGINX_TMP_DIR="${NGINX_BASE_DIR}/tmp"            # 需与nginx.conf中的5个temp_path保持一致
export NGINX_LOGS_DIR="${NGINX_BASE_DIR}/logs"
export NGINX_SERVER_BLOCKS_DIR="${NGINX_CONF_DIR}/conf.d/server_blocks"
export NGINX_INITSCRIPTS_DIR="${CIB_ROOT_DIR}/docker-entrypoint-initdb.d"
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
# export NGINX_HTTP_PORT_NUMBER="${NGINX_HTTP_PORT_NUMBER:-}"
# export WEB_SERVER_HTTP_PORT_NUMBER="$NGINX_HTTP_PORT_NUMBER"
# export NGINX_HTTPS_PORT_NUMBER="${NGINX_HTTPS_PORT_NUMBER:-}"
# export WEB_SERVER_HTTPS_PORT_NUMBER="$NGINX_HTTPS_PORT_NUMBER"
# export NGINX_ENABLE_ABSOLUTE_REDIRECT="${NGINX_ENABLE_ABSOLUTE_REDIRECT:-no}"
# export NGINX_ENABLE_PORT_IN_REDIRECT="${NGINX_ENABLE_PORT_IN_REDIRECT:-no}"

# Custom environment variables may be defined below
# 对nginx配置文件进行profile判定
if [ -n "${UEMP_PROFILE}" ];then
    if [[ -f "${NGINX_CONF_DIR}/nginx.${UEMP_PROFILE}.conf" ]];then
        NGINX_CONF_FILE="${NGINX_CONF_DIR}/nginx.${UEMP_PROFILE}.conf"
    fi
fi

