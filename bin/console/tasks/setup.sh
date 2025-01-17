#!/usr/bin/env bash
set -euo pipefail

source $TASKS_DIR/name.sh
TEMP_PROJECT_NAME="$(clean_name "$(basename "${CURRENT_DIRECTORY}")")"
while true; do
    if [[ -z "${PROJECT_NAME}" ]]; then
        read -p "Project name [${TEMP_PROJECT_NAME}]: " PROJECT_NAME
    fi

    if [[ -z "${PROJECT_NAME}" ]]; then
        PROJECT_NAME="${TEMP_PROJECT_NAME}"
        continue
    elif [[ "${PROJECT_NAME}" =~ [^a-zA-Z0-9-] ]]; then
        echo "Project name contains invalid characters."
        PROJECT_NAME=""
    elif echo "$(${MAIN_DOCKER_COMPOSE_COMMAND} ls --all || true)" | grep -q "${PROJECT_NAME}  "; then
        echo "Project name is already."
        PROJECT_NAME=""
    else
        break
    fi  
done

while true; do
    if [[ -z "${PROJECT_PORT}" ]]; then
        read -p "Port [8000]: " PROJECT_PORT
        if [[ -z "${PROJECT_PORT}" ]]; then
            PROJECT_PORT=8000
        fi
    fi

    if [[ "${PROJECT_PORT}" =~ ^[0-9]+$ ]] && [[ "${PROJECT_PORT}" -ge 1 ]] && [[ "${PROJECT_PORT}" -le 65535 ]]; then
        if ss -tuln | grep ":${PROJECT_PORT} " > /dev/null; then
            echo "Port ${PROJECT_PORT} is already."
            PROJECT_PORT=""
        else
            break
        fi
    else
        echo "Please enter the correct port."
        PROJECT_PORT=""
    fi
done

while true; do
    if [[ -z "${PHP_VERSION}" ]]; then
        read -p "PHP version [7.4/8.0/...]: " PHP_VERSION
    fi

    if [[ -z "${PHP_VERSION}" ]]; then
        continue
    elif [[ "${PHP_VERSION}" =~ [^a-zA-Z0-9.-] ]]; then
        echo "PHP version contains invalid characters."
        PHP_VERSION=""
    else
        break
    fi
done

MAIN_DOCKER_COMPOSE_OPTION_FILES="--file ${CURRENT_DIRECTORY}/${MAIN_DIRECTORY}/${MAIN_COMPOSE_FILE}"
if compgen -G "${CURRENT_DIRECTORY}/${MAIN_DIRECTORY}/custom/*.docker-compose.yml" > /dev/null; then
    for FILE in "${CURRENT_DIRECTORY}/${MAIN_DIRECTORY}/custom"/*.docker-compose.yml; do
        BASENAME=$(basename $FILE)
        MAIN_DOCKER_COMPOSE_OPTION_FILES="${MAIN_DOCKER_COMPOSE_OPTION_FILES} --file ${CURRENT_DIRECTORY}/${MAIN_DIRECTORY}/custom/${BASENAME}"
    done
fi

set -a
MAIN_UID="$(id -u)"
MAIN_GID="$(id -g)"
MAIN_PROJECT_NAME="${PROJECT_NAME}"
MAIN_PROJECT_PORT="${PROJECT_PORT}"
MAIN_PHP_VERSION="${PHP_VERSION}"
set +a