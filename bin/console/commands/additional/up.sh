#!/usr/bin/env bash
set -euo pipefail

COMMAND=$(basename "${0}" .sh)

usage() {
    DESC="COMMAND_DESC_${COMMAND}"
    echo "Usage:  ${MAIN_BASENAME} ${COMMAND} [OPTIONS] [SERVICE...]"
    echo ""
    echo "${!DESC}"
    echo ""
    echo "Options:"
    echo "      --php string                   Specify the PHP version (e.g., 5.6, 7.4, 8.1, etc)"
    echo "      --port int                     Set the app port (default: 8000)"
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
IS_DRY_RUN=""

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
        --dry-run)
            IS_DRY_RUN=true
            shift

            OPTIONS="${OPTIONS} --dry-run "
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

IS_WITH_OPTIONS_COMPLETED=false
if [[ ! -z "${PROJECT_NAME}" && ! -z "${PROJECT_PORT}" && ! -z "${PHP_VERSION}" ]]; then
    IS_WITH_OPTIONS_COMPLETED=true
fi

source $TASKS_DIR/setup.sh

if [[ $IS_WITH_OPTIONS_COMPLETED == false ]]; then
    echo ""
fi
echo "Confirmation!"
echo "   Name         : ${PROJECT_NAME}"
echo "   Port         : ${PROJECT_PORT}"
echo "   PHP Version  : ${PHP_VERSION}"
echo "   Compose File : ${MAIN_DIRECTORY}/${MAIN_COMPOSE_FILE}"
if [[ $IS_WITH_OPTIONS_COMPLETED == false || $(echo "${MAIN_DOCKER_COMPOSE_OPTION_FILES}" | grep -o -- "--file" | wc -l) -ge 2 ]]; then
    for FILE in "${MAIN_DOCKER_COMPOSE_OPTION_FILES#* --file}"; do
        echo "                  $(echo $FILE | sed "s|^${CURRENT_DIRECTORY}/||")"
    done
fi
echo ""

if [[ $NO_INTERACTION == false && $IS_DRY_RUN != true ]]; then
    read -p "Are you sure you want to continue? [Y/n]: " CONFIRMATION
    CONFIRMATION=$(echo "${CONFIRMATION:0:1}" | tr '[:upper:]' '[:lower:]') 
    if [[ ! -z "${CONFIRMATION}" && ! "${CONFIRMATION}" =~ ^[Yy]$ ]]; then
        echo "Process canceled. The script is stopped."
        exit 1
    fi
    echo "Continuing the installation..."
    echo ""
fi

$MAIN_DOCKER_COMPOSE_COMMAND \
    $MAIN_DOCKER_COMPOSE_OPTIONS \
    $MAIN_DOCKER_COMPOSE_OPTION_FILES \
    --project-name "${MAIN_PROJECT_NAME}" \
    $COMMAND $OPTIONS ${IS_DRY_RUN:+"--dry-run"}