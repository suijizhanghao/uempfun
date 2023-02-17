FROM centos:centos7.9.2009  AS build_base

# 测试命令
# docker rm -f t1; docker image rm -f cib-nginx:v0.1 ;
# docker build --build-arg NGINX_VERSION=1.23.3 -t cib-nginx:v0.1  .;docker images
# docker run -itd --name t1 cib-nginx:v0.1  或者 docker run -itd --name t1 cib-nginx:v0.1 /bin/bash
# docker logs t1
# docker exec -it t1 /bin/bash

ARG NGINX_VERSION
RUN rm /etc/yum.repos.d/*
COPY rootfs /

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN  chmod -R 775 /cib && /cib/scripts/nginx/install.sh ${NGINX_VERSION}

# RUN /cib/scripts/nginx/postunpack.sh  # postunpack.sh的内容已经都删除完毕了，暂时不需要这个了

###################################
FROM centos:centos7.9.2009

ARG NGINX_VERSION

LABEL cib.uemp.image.authors="uemp" \
      cib.uemp.image.description="由uemp打包的nginx镜像" \
      cib.uemp.image.title="nginx" \
      cib.uemp.image.version="1.23.3"

ENV HOME="/home/cib" \
    OS_ARCH="amd64" \
    OS_FLAVOUR="Kylin-V10-SP2" \
    OS_NAME="linux" \
    APP_VERSION="${NGINX_VERSION}" \
    CIB_APP_NAME="nginx" \
    PATH="/cib/common/bin:/cib/scripts/bin:/cib/scripts/nginx/bin:/cib/nginx/sbin:$PATH"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

WORKDIR /cib
COPY --from=build_base /cib .

RUN ls -l /
RUN groupadd -g 1004 cib && \
    useradd -u 1004 -d /home/cib -m -s /bin/bash -g cib cib && \
    chown -R cib:cib /cib /home/cib && \
    chmod -R 775 /cib && \
    chmod 775 /home/cib \
    groupadd -g 1002 cxwh && useradd -u 1002 -d /home/cxwh -m -s /bin/bash -g cxwh cxwh && \
    chmod -R cxwh:cxwh /home/cxwh && chmod -R 775 /home/cxwh
# RUN ln -sf /dev/stdout /cib/nginx/logs/access.log
# RUN ln -sf /dev/stderr /cib/nginx/logs/error.log

EXPOSE 8443 9010

USER cib:cib
ENTRYPOINT [ "/cib/scripts/nginx/entrypoint.sh" ]
# 所有的run.sh都是在前台执行，由container启动时执行；与之对应的start.sh是登录到shell后，再人工执行的，会再后台执行
CMD [ "/cib/scripts/nginx/run.sh" ]
