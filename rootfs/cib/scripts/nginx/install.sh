#!/bin/bash

# shellcheck disable=SC1091
set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purposes

# Load libraries
. /cib/scripts/libnginx.sh
. /cib/scripts/libfs.sh

# Load NGINX environment variables
. /cib/scripts/nginx-env.sh

# shellcheck disable=SC1091

# Ensure non-root user has write permissions on a set of directories
for dir in "$NGINX_VOLUME_DIR" "$NGINX_CONF_DIR" "$NGINX_INITSCRIPTS_DIR" "$NGINX_SERVER_BLOCKS_DIR" "${NGINX_CONF_DIR}/cib" "$NGINX_LOGS_DIR" "$NGINX_TMP_DIR"; do
    ensure_dir_exists "$dir"
    chmod -R g+rwX "$dir"
done

yum install -y gcc gcc-c++ make tar unzip

nginx_version="${1:?nginx_version is required}"

work_path=/tmp/nginx-install
ensure_dir_exists ${work_path}
chmod -R g+rwX  ${work_path}

NGINX_SOURCE="nginx-${NGINX_VERSION}.tar.gz"
ZLIB_SOURCE="zlib-1.2.13.tar.gz"
PCRE_SOURCE="pcre-8.45.tar.gz"
cd ${work_path}

set +o errexit
[ -f "${NGINX_SOURCE}" ] || curl -SsLf "https://downloads.bitnami.com/files/stacksmith/${NGINX_SOURCE}" -O 
tar -zxf ${NGINX_SOURCE} -C ${work_path}

[ -f "${ZLIB_SOURCE}" ] || curl -SsLf "https://downloads.bitnami.com/files/stacksmith/${ZLIB_SOURCE}" -O 
tar -zxf ${ZLIB_SOURCE} -C ${work_path}

[ -f "${PCRE_SOURCE}" ] || curl -SsLf "https://downloads.bitnami.com/files/stacksmith/${PCRE_SOURCE}" -O 
tar -zxf ${PCRE_SOURCE} -C ${work_path}
set -o errexit


cd nginx-${NGINX_VERSION}
./configure --prefix=${NGINX_BASE_DIR}  --with-http_stub_status_module \
            --with-zlib=../$(echo ${ZLIB_SOURCE}|sed 's/\.tar\.gz//') \
            --with-pcre=../$(echo ${PCRE_SOURCE}|sed 's/\.tar\.gz//')
make && make install

info "nginx编译结束，将执行测试" 

${NGINX_BASE_DIR}/sbin/nginx -t

