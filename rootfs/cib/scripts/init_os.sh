#!/bin/bash
#
# 对操作系统做一些初始化操作

set -o errexit
set -o nounset
set -o pipefail

# shellcheck disable=SC1091
. /cib/scripts/libos.sh

/cib/common/bin/install_packages passwd openssl openssh-server openssh-clients

mkdir -p /var/run/sshd/

# 2 修改配置
vim /etc/ssh/sshd_config +39
##  大概在  38 - 45 行之间，修改或添加如下三个配置
PermitRootLogin yes
RSAAuthentication yes
PubkeyAuthentication yes 

# 3 sshd 服务的启停
## 3.1 启动
systemctl start sshd.service
##  3.2 查看 sshd 服务状态
systemctl status sshd
## 3.3 停止
systemctl start sshd.service

# 4 设置为开机自启
systemctl enable sshd.service

# 【可跳过】5 生成ssh的密钥和公钥
# ssh-keygen -t rsa

# 6 查看 SSH 服务
lsof -i:22

# 7 设置 root 密码（2020）
passwd

# 8 通过 ssh 访问容器
ssh root@bigdata
