#!/usr/bin/env bash
set -euo pipefail

COMMAND=""
APP_NAME=""
APP_PATH=""
APP_PORT=""
PHP_VERSION=""
IS_PRODUCTION="yes"

print_banner() {
    echo "                                                     "
    echo "                                 🐳 v0.0.1           "
    echo "______                 ____________          ______  "
    echo "___  /_____ _____________ ______  /_____________  /__"
    echo "__  /_  __ '/_  ___/  __ '/  __  /  __ \  ___/_  //_/"
    echo "_  / / /_/ /_  /   / /_/ // /_/ // /_/ / /__ _  ,<   "
    echo "/_/  \__^_/ /_/    \__^_/ \__,_/ \____/\___/ /_/|_|  "
    echo "                                                     "
}

print_help() {
    print_banner

    echo "Usage:"
    echo "   $0 [command] [options...] <value> [--dev]"
    echo ""
    echo "Commands:"
    echo "   compose       : Compose 🚀"
    echo "   help          : Show this help message 📖"
    echo ""
    echo "Options:"
    echo "   -n, --name    : Set the image name"
    echo "   -p, --port    : Set the app port (default: 8000)"
    echo "   -i, --input   : Set the app directory name (e.g., awesome-laravel)"
    echo "       --php     : Specify the PHP version (e.g., 5.6, 7.4, 8.1, etc)"
    echo "       --dev     : Build image on development"
    echo ""
    echo "Examples:"
    echo "   ./laradock compose"
    echo "   ./laradock compose -n laradock-app -p 8000 -i my-app --php 7.4"
    echo "   ./laradock compose -n laradock-app -p 8000 -i my-app --php 7.2 --dev"
    echo ""
}

IS_WITH_OPTIONS=false
while [[ $# -gt 0 ]]; do
    if [[ "$1" == -* ]]; then
        IS_WITH_OPTIONS=true
    fi

    case "$1" in
        compose)
            COMMAND="$1"
            shift
        ;;
        help|-h|--help)
            print_help
            exit 0
        ;;
        -n|--name)
            APP_NAME="$2"
            shift 2
        ;;
        -p|--port)
            APP_PORT="$2"
            shift 2
        ;;
        -i|--input)
            APP_PATH="$2"
            shift 2
        ;;
        --php)
            PHP_VERSION="$2"
            shift 2
        ;;
        --dev)
            IS_PRODUCTION="no"
            shift
        ;;
        *)
            echo "Unknown argument: $1. Use '$0 help' for usage instructions."
            exit 1
        ;;
    esac
done

case $COMMAND in
    compose)
        COMMAND_DIRECTORY="./compose"
        ;;
    *)
        echo "Unknown command: $COMMAND. Use '$0 help' for usage instructions."
        exit 1
    ;;
esac

print_banner

if [ $IS_WITH_OPTIONS == false ]; then
    echo -n "Build image on production? [Y/n]: "
    read IS_PRODUCTION
fi
IS_PRODUCTION=$(echo ${IS_PRODUCTION:0:1} | tr '[:upper:]' '[:lower:]')
if [ -z "$IS_PRODUCTION" ] || [[  "$IS_PRODUCTION" =~ ^[y]$ ]]; then
    ENVIRONMENT="production"
    ENVIRONMENT_NAME=Production
else
    ENVIRONMENT="development"
    ENVIRONMENT_NAME=Development
fi

while true; do
    if [ -z "$APP_NAME" ]; then
        echo -n "App name: "
        read APP_NAME
    fi

    if [ -z "$APP_NAME" ]; then
        echo "App name does not exist."
        APP_NAME=""
    elif [[ "$APP_NAME" =~ [^a-zA-Z0-9_-] ]]; then
        echo "App name contains invalid characters."
        APP_NAME=""
    else
        break
    fi
done

while true; do
    if [ -z "$APP_PATH" ]; then
        echo -n "App Path: ./src/"
        read APP_PATH
        if [ -z "$APP_PATH" ]; then
            continue
        fi
    fi

    APP_PATH=$(echo "$APP_PATH" | sed 's|^~|'"$HOME"'|')
    if [ -d "$(pwd)/src/$APP_PATH" ]; then
        break
    else
        echo "Please enter the correct app path."
        APP_PATH=""
    fi
done

while true; do
    if [ -z "$APP_PORT" ]; then
        echo -n "Port [8000]: "
        read APP_PORT
        if [ -z "$APP_PORT" ]; then
            APP_PORT=8000
            break
        fi
    fi

    if [[ "$APP_PORT" =~ ^[0-9]+$ ]] && [ "$APP_PORT" -ge 1 ] && [ "$APP_PORT" -le 65535 ]; then
        if ss -tuln | grep ":$APP_PORT " > /dev/null; then
            echo "Port $APP_PORT is not available."
            APP_PORT=""
        else
            break
        fi
    else
        echo "Please enter the correct port."
        APP_PORT=""
    fi
done

while true; do
    if [ -z "$PHP_VERSION" ]; then
        echo -n "PHP version [7.4/8.0/...]: "
        read PHP_VERSION
    fi

    if [[ -z "$PHP_VERSION" ]]; then
        echo "PHP version does not exist."
        PHP_VERSION=""
    elif [[ "$PHP_VERSION" =~ [^a-zA-Z0-9.-] ]]; then
        echo "PHP version contains invalid characters."
        PHP_VERSION=""
    else
        break
    fi
done

echo ""
echo "Confirmation!"
echo "   Environment : $ENVIRONMENT_NAME"
echo "   Name        : $APP_NAME"
echo "   Path        : ./src/$APP_PATH"
echo "   Port        : $APP_PORT"
echo "   PHP Version : $PHP_VERSION"
echo ""

echo -n "Are you sure you want to continue? [Y/n]: "
read CONFIRMATION
CONFIRMATION=$(echo ${CONFIRMATION:0:1} | tr '[:upper:]' '[:lower:]') 
if [[ ! -z "$CONFIRMATION" && ! "$CONFIRMATION" =~ ^[Yy]$ ]]; then
    echo "Process canceled. The script is stopped."
    exit 1
fi

echo "Continuing the installation..."
echo ""

export LARADOCK_UID=$(id -u)
export LARADOCK_GID=$(id -g)
export LARADOCK_ENVIRONMENT=$ENVIRONMENT
export LARADOCK_APP_NAME=$APP_NAME
export LARADOCK_APP_PATH="../src/$APP_PATH"
export LARADOCK_APP_PORT=$APP_PORT
export LARADOCK_PHP_VERSION=$PHP_VERSION

docker compose --project-name $APP_NAME --file $COMMAND_DIRECTORY/docker-compose.yml up --build --force-recreate --detach
docker image prune -f > /dev/null 2>&1 || true

print_banner
(echo -e "CONTAINER ID\tNAMES\tIMAGE\tSTATUS\tPORTS" && docker ps -a --format "{{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}" | grep $APP_NAME | sort -k2,2 -k3,3) | column -t -s $'\t'
