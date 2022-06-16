FROM node:17.7-alpine3.14 AS client-builder
WORKDIR /app/client
# cache packages in layer
COPY client/package.json /app/client/package.json
COPY client/yarn.lock /app/client/yarn.lock
ARG TARGETARCH
RUN yarn config set cache-folder /usr/local/share/.cache/yarn-${TARGETARCH}
RUN --mount=type=cache,target=/usr/local/share/.cache/yarn-${TARGETARCH} yarn
# install
COPY client /app/client
RUN --mount=type=cache,target=/usr/local/share/.cache/yarn-${TARGETARCH} yarn build

FROM alpine:3.15

LABEL org.opencontainers.image.title="OracleXE 21c embedded RDBMS"
LABEL org.opencontainers.image.description="Docker Extension for using Oracle XE 21c embedded RDBMS including EM Express monitoring tool"
LABEL org.opencontainers.image.vendor="Marcelo Ochoa"
LABEL com.docker.desktop.extension.api.version=">= 0.2.3"
LABEL com.docker.extension.screenshots="[{\"alt\":\"Initial Screen\", \"url\":\"https://raw.githubusercontent.com/marcelo-ochoa/oraclexe-docker-extension/main/screenshot1.png\"},\
    {\"alt\":\"EM Express Main Page\", \"url\":\"https://raw.githubusercontent.com/marcelo-ochoa/oraclexe-docker-extension/main/screenshot2.png\"},\
    {\"alt\":\"Performance Hub\", \"url\":\"https://raw.githubusercontent.com/marcelo-ochoa/oraclexe-docker-extension/main/screenshot3.png\"},\
    {\"alt\":\"Real-time SQL Monitoring\", \"url\":\"https://raw.githubusercontent.com/marcelo-ochoa/oraclexe-docker-extension/main/screenshot4.png\"},\
    {\"alt\":\"Tablespace\", \"url\":\"https://raw.githubusercontent.com/marcelo-ochoa/oraclexe-docker-extension/main/screenshot5.png\"}]"
LABEL com.docker.extension.publisher-url="https://github.com/marcelo-ochoa/oraclexe-docker-extension"
LABEL com.docker.extension.additional-urls="[{\"title\":\"Documentation\",\"url\":\"https://github.com/marcelo-ochoa/oraclexe-docker-extension/blob/main/README.md\"},\
    {\"title\":\"License\",\"url\":\"https://github.com/marcelo-ochoa/oraclexe-docker-extension/blob/main/LICENSE\"}]"
LABEL com.docker.extension.detailed-description="Oracle Database Express Edition (XE) is the ideal way to get started. \
    It is the same powerful Oracle Database that enterprises rely on worldwide, packaged as simple Docker Desktop Extension, ease-of-use, and a full-featured experience."
LABEL com.docker.extension.changelog="See full <a href=\"https://github.com/marcelo-ochoa/oraclexe-docker-extension/blob/main/CHANGELOG.md\">change log</a>"
LABEL com.docker.desktop.extension.icon="https://raw.githubusercontent.com/marcelo-ochoa/oraclexe-docker-extension/main/favicon.ico"

COPY favicon.ico oraclexe.svg screenshot1.png screenshot2.png screenshot3.png screenshot4.png screenshot5.png metadata.json docker-compose.yml ./

COPY --from=client-builder /app/client/dist ui

CMD [ "sleep", "infinity" ]
