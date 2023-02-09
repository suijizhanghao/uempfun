#!/bin/bash

# 个人观点：使用/bin/bash，可能会比/bin/sh获得更大的自由度，可能会好一些

# shellcheck disable=SC1091

set -o errexit      # 如果一个命令、函数、代码段以非零状态退出，则立即退出
set -o nounset      # 变量为空时，则返回一个错误值
set -o pipefail     # 管道命令返回值为最后一个命令的值；当前配置下：管道命令中任意一个返回值不是0，则整个管道返回值就不是0
# set -o xtrace     # 等同于 -x

# Load libraries
. /cib/scripts/libcib.sh
. /cib/scripts/libnginx.sh

# Load NGINX environment variables
. /cib/scripts/nginx-env.sh

print_welcome_page

if [[ "$1" = "/cib/scripts/nginx/run.sh" ]]; then
    info "** Starting NGINX setup **"
    # setup.sh只是做了一层拦截，然后来修改nginx的各种参数；如果直接登录容器，然后直接执行run.sh也是可以启动的，但是拦截的就没有了。
    /cib/scripts/nginx/setup.sh
    info "** NGINX setup finished! **"
fi

echo ""
exec "$@"
