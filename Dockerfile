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

LABEL org.opencontainers.image.title="OracleXE" \
    org.opencontainers.image.description="Oracle XE embeded DB" \
    org.opencontainers.image.vendor="Marcelo Ochoa" \
    com.docker.desktop.extension.api.version=">= 0.2.3" \
    com.docker.extension.screenshots="[{\"alt\":\"Initial Screen\", \"url\":\"https://raw.githubusercontent.com/marcelo-ochoa/oraclexe-docker-extension/main/screenshot1.png\"}, {\"alt\":\"Add Server\", \"url\":\"https://raw.githubusercontent.com/marcelo-ochoa/oraclexe-docker-extension/main/screenshot2.png\"}]" \
    com.docker.extension.publisher-url="https://github.com/marcelo-ochoa/oraclexe-docker-extension" \
    com.docker.extension.additional-urls="[{\"title\":\"Documentation\",\"url\":\"https://github.com/marcelo-ochoa/oraclexe-docker-extension/blob/main/README.md\"}, {\"title\":\"License\",\"url\":\"https://github.com/marcelo-ochoa/oraclexe-docker-extension/blob/main/LICENSE\"}]" \
    com.docker.extension.detailed-description="Docker Extension for using Oracle XE embeded" \
    com.docker.extension.changelog="https://github.com/marcelo-ochoa/oraclexe-docker-extension/blob/main/CHANGELOG.md" \
    com.docker.desktop.extension.icon="https://raw.githubusercontent.com/marcelo-ochoa/oraclexe-docker-extension/main/favicon.ico"

COPY oraclexe.svg .
COPY screenshot1.png .
COPY screenshot2.png .
COPY metadata.json .
COPY docker-compose.yml .

COPY --from=client-builder /app/client/dist ui

CMD [ "sleep", "infinity" ]
