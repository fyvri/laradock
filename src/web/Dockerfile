ARG MAIN_DIRECTORY=".laradock"
ARG MAIN_UID="1000"
ARG MAIN_GID="1000"
ARG MAIN_PROJECT_PORT="8000"

FROM nginx:stable-alpine

ARG MAIN_DIRECTORY
ARG MAIN_UID
ARG MAIN_GID
ARG MAIN_PROJECT_PORT

WORKDIR /tmp
RUN \
    addgroup -g ${MAIN_GID} laradock && \
    adduser -u ${MAIN_UID} -G laradock -D laradock

COPY ./${MAIN_DIRECTORY}/web/nginx/nginx.conf   /etc/nginx/
COPY ./${MAIN_DIRECTORY}/web/nginx/default.conf /etc/nginx/conf.d/

WORKDIR /tmp
COPY ./${MAIN_DIRECTORY}/web/scripts/* ./
RUN \
    if [ -f "./web.sh" ]; then  \
        chmod +x "./web.sh"  && \
        ./web.sh;               \
    fi

WORKDIR /var/www/html
RUN rm -rf \
    /tmp/*                          \
    /usr/share/nginx/html/*.md      \
    /usr/share/nginx/html/*.txt     \
    /var/cache/apk/*                \
    /var/tmp/*

EXPOSE ${MAIN_PROJECT_PORT}