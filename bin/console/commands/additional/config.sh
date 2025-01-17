#!/usr/bin/env bash
set -euo pipefail

COMMAND=$(basename "${0}" .sh)

usage() {
    DESC="COMMAND_DESC_${COMMAND}"
    echo "Usage:  ${MAIN_BASENAME} ${COMMAND} [OPTIONS] [SERVICE...]"
    echo ""
    echo "${!DESC}"
    echo ""
    echo "Aliases:"
    echo "  ${MAIN_BASENAME} config, ${MAIN_BASENAME} convert"
    echo ""
    echo "Options:" 
    echo "      --php string              Specify the PHP version (e.g., 5.6, 7.4, 8.1, etc)"
    echo "      --port int                Set the app port (default: 8000)"
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
NO_INTERACTION=false

while [[ $# -gt 0 ]]; do
    ARGUMENT="${1}"
    case $ARGUMENT in
        -h|--help)
            usage
            exit 1
        ;;
        -y|--yes)
            NO_INTERACTION=true
            shift
        ;;
        --php)
            PHP_VERSION="${2}"
            shift 2
        ;;
        --port)
            PROJECT_PORT="${2}"
            shift 2
        ;;
        *)
            if [[ "${ARGUMENT}" == -* ]] && echo "${DOCKER_OPTIONS}" | grep -Eq -- "(  ${ARGUMENT},| ${ARGUMENT} )"; then
                if [[ $# -ge 2 ]]; then
                    if [[ "${2}" != -* ]]; then
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
                echo "unknown flag: ${ARGUMENT}"
                exit 0
            fi
        ;;
    esac
done

if [[ ! -d "${CURRENT_DIRECTORY}/${MAIN_DIRECTORY}" ]]; then
    echo "not found ${MAIN_DIRECTORY} (or any parent up to mount point /)"
    exit 0
fi

source $TASKS_DIR/setup.sh

$MAIN_DOCKER_COMPOSE_COMMAND \
    $MAIN_DOCKER_COMPOSE_OPTIONS \
    $MAIN_DOCKER_COMPOSE_OPTION_FILES \
    --project-name "${MAIN_PROJECT_NAME}" \
    $COMMAND $OPTIONS