FROM --platform=$BUILDPLATFORM node:17.7-alpine3.14 AS client-builder
ARG SQLCL_VERSION=23.1
ARG SQLCL_MINOR=0
ARG SQLCL_PATCH=089
ARG SQLCL_BUILD=0929
WORKDIR /app/client
# https://www.oracle.com/database/sqldeveloper/technologies/sqlcl/download/
ADD sqlcl-${SQLCL_VERSION}.${SQLCL_MINOR}.${SQLCL_PATCH}.${SQLCL_BUILD}.zip .
RUN unzip -d /opt sqlcl-${SQLCL_VERSION}.${SQLCL_MINOR}.${SQLCL_PATCH}.${SQLCL_BUILD}.zip
# cache packages in layer
COPY client/package.json /app/client/package.json
COPY client/package-lock.json /app/client/package-lock.json
RUN --mount=type=cache,target=/usr/src/app/.npm \
    npm set cache /usr/src/app/.npm && \
    npm ci
# install
COPY client /app/client
RUN npm run build

FROM golang:1.17-alpine AS builder
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

FROM alpine:3.15
RUN apk update && apk add --no-cache ncurses bash ttyd tini openjdk17-jre && \
    mkdir -p /home/sqlcl && \
    echo "HOME=/home/sqlcl;cd /home/sqlcl;/opt/sqlcl/bin/sql /nolog" > /home/sql.sh && \
    chown 1000:1000 /home/sqlcl /home/sql.sh && \
    chmod u+rwx /home/sql.sh && \
    echo "sqlcl:x:1000:1000:SQLcl:/home/sqlcl:/bin/bash" >> /etc/passwd && \
    echo "sqlcl:x:1000:sqlcl" >> /etc/group

LABEL org.opencontainers.image.title="OracleFree 23c embedded RDBMS - Faststart"
LABEL org.opencontainers.image.description="Docker Extension for using Oracle Free 23c embedded RDBMS including SQLcl tool"
LABEL org.opencontainers.image.vendor="Marcelo Ochoa"
LABEL com.docker.desktop.extension.api.version=">= 0.2.3"
LABEL com.docker.extension.categories="database"
LABEL com.docker.extension.screenshots="[{\"alt\":\"Initial Screen\", \"url\":\"https://raw.githubusercontent.com/marcelo-ochoa/oraclexe-docker-extension/oracle-free-23.2.0-faststart/docs/images/screenshot1.png\"},\
    {\"alt\":\"SQLcl - DDL generation\", \"url\":\"https://raw.githubusercontent.com/marcelo-ochoa/oraclexe-docker-extension/oracle-free-23.2.0-faststart/docs/images/screenshot2.png\"},\
    {\"alt\":\"SQLcl - SQL format XML\", \"url\":\"https://raw.githubusercontent.com/marcelo-ochoa/oraclexe-docker-extension/oracle-free-23.2.0-faststart/docs/images/screenshot3.png\"},\
    {\"alt\":\"SQLcl - Explain Plan\", \"url\":\"https://raw.githubusercontent.com/marcelo-ochoa/oraclexe-docker-extension/oracle-free-23.2.0-faststart/docs/images/screenshot4.png\"}]"
LABEL com.docker.extension.publisher-url="https://github.com/marcelo-ochoa/oraclexe-docker-extension/tree/oracle-free-23.2.0-faststart"
LABEL com.docker.extension.additional-urls="[{\"title\":\"Documentation\",\"url\":\"https://github.com/marcelo-ochoa/oraclexe-docker-extension/blob/oracle-free-23.2.0-faststart/README.md\"},\
    {\"title\":\"License\",\"url\":\"https://github.com/marcelo-ochoa/oraclexe-docker-extension/blob/oracle-free-23.2.0-faststart/LICENSE\"}]"
LABEL com.docker.extension.detailed-description="Oracle Database Developer Edition (Free) is the ideal way to get started. \
    It is the same powerful Oracle Database that enterprises rely on worldwide, packaged as simple Docker Desktop Extension, ease-of-use, and a full-featured experience."
LABEL com.docker.extension.changelog="See full <a href=\"https://github.com/marcelo-ochoa/oraclexe-docker-extension/blob/oracle-free-23.2.0-faststart/CHANGELOG.md\">change log</a>"
LABEL com.docker.desktop.extension.icon="https://raw.githubusercontent.com/marcelo-ochoa/oraclexe-docker-extension/oracle-free-23.2.0-faststart/client/public/favicon.ico"

COPY oraclefree.svg metadata.json docker-compose.yml ./

COPY --from=client-builder /app/client/dist ui
COPY --from=client-builder /opt/sqlcl /opt/sqlcl
COPY --from=builder /backend/bin/service /
COPY --chown=1000:1000 login.sql /home/sqlcl

ENTRYPOINT ["/sbin/tini", "--", "/service", "-socket", "/run/guest-services/oraclefree-docker-extension.sock"]
