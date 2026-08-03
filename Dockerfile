FROM --platform=$BUILDPLATFORM node:22-alpine AS client-builder
ARG SQLCL_VERSION=26.2
ARG SQLCL_MINOR=0
ARG SQLCL_PATCH=181
ARG SQLCL_BUILD=2110
WORKDIR /app/client
# https://www.oracle.com/database/sqldeveloper/technologies/sqlcl/download/
ADD https://download.oracle.com/otn_software/java/sqldeveloper/sqlcl-${SQLCL_VERSION}.${SQLCL_MINOR}.${SQLCL_PATCH}.${SQLCL_BUILD}.zip .
RUN unzip -d /opt sqlcl-${SQLCL_VERSION}.${SQLCL_MINOR}.${SQLCL_PATCH}.${SQLCL_BUILD}.zip
# cache packages in layer
COPY client/package.json client/package-lock.json /app/client/
RUN --mount=type=cache,target=/usr/src/app/.npm \
  npm set cache /usr/src/app/.npm && \
  npm ci
# install
COPY client /app/client
RUN npm run build

FROM golang:1.24-alpine AS builder
ENV CGO_ENABLED=0
WORKDIR /backend
COPY vm/go.* .
RUN --mount=type=cache,target=/go/pkg/mod \
  --mount=type=cache,target=/root/.cache/go-build \
  go mod download
COPY vm/. .
RUN --mount=type=cache,target=/go/pkg/mod \
  --mount=type=cache,target=/root/.cache/go-build \
  go build -trimpath -ldflags="-s -w" -o bin/service

FROM ghcr.io/graalvm/jdk-community:21-ol9
RUN set -eux \
  && if [ "$(arch)" == "x86_64" ]; then TTYD_PKG=ttyd.i686; fi \
  && if [ "$(arch)" == "aarch64" ]; then TTYD_PKG=ttyd.aarch64; fi \
  && curl -o /usr/bin/ttyd -L https://github.com/tsl0922/ttyd/releases/download/1.7.4/${TTYD_PKG} \
  && rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm && microdnf install -y tini unzip ncurses gzip findutils \
  && microdnf clean all && chmod +x /usr/bin/ttyd \
  && mkdir -p /home/sqlcl \
  && echo "HOME=/home/sqlcl;cd /home/sqlcl;/opt/sqlcl/bin/sql /nolog" > /home/sql.sh \
  && chown 1000:1000 /home/sqlcl /home/sql.sh \
  && chmod u+rwx /home/sql.sh \
  && echo "sqlcl:x:1000:1000:SQLcl:/home/sqlcl:/bin/bash" >> /etc/passwd \
  && echo "sqlcl:x:1000:sqlcl" >> /etc/group

LABEL org.opencontainers.image.title="OracleFree 23c embedded RDBMS - Faststart" \
  org.opencontainers.image.description="Docker Extension for using Oracle Free 23c embedded RDBMS including SQLcl tool" \
  org.opencontainers.image.vendor="Marcelo Ochoa" \
  com.docker.desktop.extension.api.version=">= 0.2.3" \
  com.docker.extension.categories="database" \
  com.docker.extension.screenshots="[{\"alt\":\"Initial Screen\", \"url\":\"https://raw.githubusercontent.com/marcelo-ochoa/oraclexe-docker-extension/oracle-free-23.26.2-faststart/docs/images/screenshot1.png\"},\
  {\"alt\":\"SQLcl - DDL generation\", \"url\":\"https://raw.githubusercontent.com/marcelo-ochoa/oraclexe-docker-extension/oracle-free-23.26.2-faststart/docs/images/screenshot2.png\"},\
  {\"alt\":\"SQLcl - SQL format XML\", \"url\":\"https://raw.githubusercontent.com/marcelo-ochoa/oraclexe-docker-extension/oracle-free-23.26.2-faststart/docs/images/screenshot3.png\"},\
  {\"alt\":\"SQLcl - Explain Plan\", \"url\":\"https://raw.githubusercontent.com/marcelo-ochoa/oraclexe-docker-extension/oracle-free-23.26.2-faststart/docs/images/screenshot4.png\"}]" \
  com.docker.extension.publisher-url="https://github.com/marcelo-ochoa/oraclexe-docker-extension/tree/oracle-free-23.26.2-faststart" \
  com.docker.extension.additional-urls="[{\"title\":\"Documentation\",\"url\":\"https://github.com/marcelo-ochoa/oraclexe-docker-extension/blob/oracle-free-23.26.2-faststart/README.md\"},\
  {\"title\":\"License\",\"url\":\"https://github.com/marcelo-ochoa/oraclexe-docker-extension/blob/oracle-free-23.26.2-faststart/LICENSE\"}]" \
  com.docker.extension.detailed-description="Oracle Database Developer Edition (Free) is the ideal way to get started. \
  It is the same powerful Oracle Database that enterprises rely on worldwide, packaged as simple Docker Desktop Extension, ease-of-use, and a full-featured experience." \
  com.docker.extension.changelog="See full <a href=\"https://github.com/marcelo-ochoa/oraclexe-docker-extension/blob/oracle-free-23.26.2-faststart/CHANGELOG.md\">change log</a>" \
  com.docker.desktop.extension.icon="https://raw.githubusercontent.com/marcelo-ochoa/oraclexe-docker-extension/oracle-free-23.26.2-faststart/client/public/favicon.ico"

COPY oraclefree.svg metadata.json docker-compose.yml /

COPY --from=client-builder /app/client/dist /ui
COPY --chown=1000:1000 --from=client-builder /opt/sqlcl /opt/sqlcl
# Install GraalJS into SQLcl lib folder to enable 'script' functionality in Java 21
RUN set -eux \
  && if [ "$(arch)" == "x86_64" ]; then ARCH=amd64; fi \
  && if [ "$(arch)" == "aarch64" ]; then ARCH=aarch64; fi \
  && GRAALJS_VERSION=25.0.2 \
  && curl -L -o /tmp/graaljs.tar.gz https://github.com/oracle/graaljs/releases/download/graal-${GRAALJS_VERSION}/graaljs-community-jvm-${GRAALJS_VERSION}-linux-${ARCH}.tar.gz \
  && tar -xzf /tmp/graaljs.tar.gz -C /tmp \
  && cp /tmp/graaljs-community-jvm-${GRAALJS_VERSION}-linux-${ARCH}/modules/*.jar /opt/sqlcl/lib/ \
  && rm -rf /tmp/graaljs*
COPY --from=builder /backend/bin/service /
COPY --chown=1000:1000 login.sql /home/sqlcl

ENTRYPOINT ["/usr/bin/tini", "--", "/service", "-socket", "/run/guest-services/oraclefree-docker-extension.sock"]
