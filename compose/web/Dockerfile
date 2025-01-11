ARG LARADOCK_UID=1000
ARG LARADOCK_GID=1000
ARG LARADOCK_APP_PORT=8000

FROM nginx:stable-alpine

ARG LARADOCK_UID
ARG LARADOCK_GID
ARG LARADOCK_APP_PORT

WORKDIR /var/www/html
RUN \
    addgroup -g ${LARADOCK_GID} laradock && \
    adduser -u ${LARADOCK_UID} -G laradock -D laradock

COPY ./compose/web/nginx/nginx.conf     /etc/nginx/
COPY ./compose/web/nginx/default.conf   /etc/nginx/conf.d/

WORKDIR /var/www/html/_scripts
COPY ./compose/web/scripts/* ./
RUN \
    if [ -f "./web.sh" ]; then  \
        chmod +x "./web.sh"  && \
        ./web.sh;               \
    fi

WORKDIR /var/www/html
RUN \
    rm -rf /var/www/html/_scripts

EXPOSE ${LARADOCK_APP_PORT}