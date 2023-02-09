FROM centos:centos7.9.2009  AS build_base

ARG NGINX_VERSION
COPY rootfs /

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN /cib/scripts/nginx/install.sh ${NGINX_VERSION}

RUN /cib/scripts/nginx/postunpack.sh

###################################
FROM centos:centos7.9.2009 

ARG NGINX_VERSION

LABEL cib.uemp.image.authors="uemp" \
      cib.uemp.image.description="由uemp打包的nginx镜像" \
      cib.uemp.image.title="nginx" \
      cib.uemp.image.version="1.23.3"

ENV HOME="/cib" \
    OS_ARCH="amd64" \
    OS_FLAVOUR="Kylin-V10-SP2" \
    OS_NAME="linux" \
    APP_VERSION="${NGINX_VERSION}" \
    CIB_APP_NAME="nginx" \
    NGINX_HTTPS_PORT_NUMBER="" \
    NGINX_HTTP_PORT_NUMBER="" \
    PATH="/cib/scripts/bin:/cib/scripts/nginx/bin:/cib/nginx/sbin:$PATH"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

COPY --from=build_base /cib /
COPY --from=build_base /home/cib /home

RUN groupadd -g 1004 cib && \
    useradd -u 1004 -d /home/cib -m -s /bin/bash -g cib cib && \
    chown -R cib:cib /cib /home/cib && \
    chmod -R 775 /cib && \
    chmod 775 /home/cib
RUN ln -sf /dev/stdout /cib/nginx/logs/access.log
RUN ln -sf /dev/stderr /cib/nginx/logs/error.log

EXPOSE 8443 9010
WORKDIR /cib
USER cib:cib
ENTRYPOINT [ "/cib/scripts/nginx/entrypoint.sh" ]
# 所有的run.sh都是在前台执行，由container启动时执行；与之对应的start.sh是登录到shell后，再人工执行的，会再后台执行
CMD [ "/cib/scripts/nginx/run.sh" ]
