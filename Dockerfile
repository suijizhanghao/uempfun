FROM centos:7

ARG TARGETARCH

LABEL cib.uemp.image.authors="uemp" \
      cib.uemp.image.description="由uemp打包的nginx镜像" \
      cib.uemp.image.title="nginx" \
      cib.uemp.image.version="1.23.3"

ENV HOME="/" \
    OS_ARCH="${TARGETARCH:-amd64}" \
    OS_FLAVOUR="Kylin-V10-SP2" \
    OS_NAME="linux"

COPY . /

SHELL ["/bin/bash", "-o", "pipefail", "-c"]



# Install required system packages and dependencies
RUN install_packages ca-certificates curl libcrypt1 libgeoip1 libpcre3 libssl1.1 procps zlib1g
RUN mkdir -p /tmp/cib/pkg/cache/ && cd /tmp/cib/pkg/cache/ && \
    COMPONENTS=( \
      "render-template-1.0.5-0-linux-${OS_ARCH}-debian-11" \
      "nginx-1.23.3-1-linux-${OS_ARCH}-debian-11" \
      "gosu-1.16.0-1-linux-${OS_ARCH}-debian-11" \
    ) && \
    for COMPONENT in "${COMPONENTS[@]}"; do \
      if [ ! -f "${COMPONENT}.tar.gz" ]; then \
        curl -SsLf "https://downloads.bitnami.com/files/stacksmith/${COMPONENT}.tar.gz" -O ; \
        curl -SsLf "https://downloads.bitnami.com/files/stacksmith/${COMPONENT}.tar.gz.sha256" -O ; \
      fi && \
      sha256sum -c "${COMPONENT}.tar.gz.sha256" && \
      tar -zxf "${COMPONENT}.tar.gz" -C /cib --strip-components=2 --no-same-owner --wildcards '*/files' && \
      rm -rf "${COMPONENT}".tar.gz{,.sha256} ; \
    done
RUN apt-get autoremove --purge -y curl && \
    apt-get update && apt-get upgrade -y && \
    apt-get clean && rm -rf /var/lib/apt/lists /var/cache/apt/archives
RUN chmod g+rwX /cib
RUN ln -sf /dev/stdout /cib/nginx/logs/access.log
RUN ln -sf /dev/stderr /cib/nginx/logs/error.log

COPY rootfs /
RUN /cib/scripts/nginx/postunpack.sh

ENV APP_VERSION="1.23.3" \
    CIB_APP_NAME="nginx" \
    NGINX_HTTPS_PORT_NUMBER="" \
    NGINX_HTTP_PORT_NUMBER="" \
    PATH="/cib/scripts/bin:/cib/scripts/nginx/bin:/cib/nginx/sbin:$PATH"

EXPOSE 8080 8443

WORKDIR /app
USER 1001
ENTRYPOINT [ "/cib/scripts/nginx/entrypoint.sh" ]
CMD [ "/cib/scripts/nginx/run.sh" ]
