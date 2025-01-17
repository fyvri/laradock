#!/usr/bin/env bash
set -euo pipefail

COMMAND=$(basename "${0}" .sh)

usage() {
    DESC="COMMAND_DESC_${COMMAND}"
    echo "Usage:  ${MAIN_BASENAME} ${COMMAND} [OPTIONS] SERVICE [COMMAND] [ARGS...]"
    echo ""
    echo "${!DESC}"
    echo ""
    echo "Options:"
    echo "      --php string            Specify the PHP version (e.g., 5.6, 7.4, 8.1, etc)"
    echo "      --port int              Set the app port (default: 8000)"
    echo ""
    echo "Additional Options:"
    echo "${DOCKER_OPTIONS}"
}

source $TASKS_DIR/config.sh
PROJECT_NAME="${PROJECT_NAME:-"$(get_config "PROJECT_NAME")"}"
PROJECT_PORT="$(get_config "PROJECT_PORT")"
PHP_VERSION="$(get_config "PHP_VERSION")"
CURRENT_DIRECTORY="$(pwd)"
DOCKER_OPTIONS=$(echo "$(${MAIN_DOCKER_COMPOSE_COMMAND} ${COMMAND} --help)" | sed -n '/Options:/,/^$/ { /Options:/d; p }')
OPTIONS=""
IS_DRY_RUN=""
SERVICE_NAME=""

while [[ $# -gt 0 ]]; do
    ARGUMENT="${1}"
    case $ARGUMENT in
        -h|--help)
            usage
            exit 1
        ;;
        --php)
            PHP_VERSION="${2}"
            shift 2
        ;;
        --port)
            PROJECT_PORT="${2}"
            shift 2
        ;;
        --dry-run)
            IS_DRY_RUN=true
            shift

            OPTIONS="${OPTIONS} --dry-run "
        ;;
        *)
            if [[ "${ARGUMENT}" == -* ]] && echo "${DOCKER_OPTIONS}" | grep -Eq -- "(  ${ARGUMENT},| ${ARGUMENT} )"; then
                if [[ $# -ge 2 ]]; then
                    if [[ "${2}" != -* ]]; then
                        if echo "$ARGUMENT" | grep -Eq -- "(--name)"; then
                            SERVICE_NAME="${2}"
                            shift 2
                            continue
                        fi
                        OPTIONS="${OPTIONS} ${ARGUMENT} ${2} "
                        shift 2
                    else
                        OPTIONS="${OPTIONS} ${ARGUMENT} "
                        shift
                    fi
                else
                    OPTIONS="${OPTIONS} ${ARGUMENT} "
                    shift
                fi
            else
                break
            fi
        ;;
    esac
done

if [[ ! -d "${CURRENT_DIRECTORY}/${MAIN_DIRECTORY}" ]]; then
    echo "not found ${MAIN_DIRECTORY} (or any parent up to mount point /)"
    exit 0
fi

IS_WITH_OPTIONS_COMPLETED=false
if [[ ! -z "${PROJECT_NAME}" && ! -z "${PROJECT_PORT}" && ! -z "${PHP_VERSION}" ]]; then
    IS_WITH_OPTIONS_COMPLETED=true
fi

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
    else
        break
    fi
done

while true; do
    if [[ -z "${SERVICE_NAME}" ]]; then
        read -p "Service name: " SERVICE_NAME
    fi

    if [[ -z "${SERVICE_NAME}" ]]; then
        continue
    elif [[ "${SERVICE_NAME}" =~ [^a-zA-Z0-9-] ]]; then
        echo "Service name contains invalid characters."
        SERVICE_NAME=""
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
        break
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

$MAIN_DOCKER_COMPOSE_COMMAND \
    $MAIN_DOCKER_COMPOSE_OPTIONS \
    $MAIN_DOCKER_COMPOSE_OPTION_FILES \
    --project-name "${MAIN_PROJECT_NAME}" \
    $COMMAND --name "${MAIN_NAME}.${PROJECT_NAME}.${SERVICE_NAME}" ${IS_DRY_RUN:+"--dry-run"} $OPTIONS $@