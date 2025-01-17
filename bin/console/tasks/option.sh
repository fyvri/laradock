#!/usr/bin/env bash
set -euo pipefail

parse_options() {
    PROJECT_NAME=""
    MAIN_DOCKER_COMPOSE_OPTIONS=""
    MAIN_DOCKER_COMPOSE_OPTIONS_FULL="${@}"

    if [[ ! -z "${@}" ]]; then
        local DOCKER_HELP="$(${MAIN_DOCKER_COMPOSE_COMMAND} --help)"
        local DOCKER_OPTIONS=$(echo "${DOCKER_HELP}"  | sed -n '/Options:/,/^$/ { /Options:/d; p }' | grep -v -e "--file" -e "--project-directory" -e "the path of the")
        while [[ $# -gt 0 ]]; do
            local ARGUMENT="${1}"
            case $ARGUMENT in
                -p|--project-name)
                    PROJECT_NAME="${2}"
                    shift 2
                ;;
                -f|--file)
                    shift 2
                ;;
                *)
                    if [[ "${ARGUMENT}" == -* ]] && echo "${DOCKER_OPTIONS}" | grep -Eq -- "(  ${ARGUMENT},| ${ARGUMENT} )"; then
                        if [[ $# -ge 2 ]]; then
                            if [[ "${2}" != -* ]]; then
                                MAIN_DOCKER_COMPOSE_OPTIONS="$MAIN_DOCKER_COMPOSE_OPTIONS ${ARGUMENT} ${2} "
                                shift 2
                            else
                                MAIN_DOCKER_COMPOSE_OPTIONS="$MAIN_DOCKER_COMPOSE_OPTIONS ${ARGUMENT} "
                                shift
                            fi
                        else
                            MAIN_DOCKER_COMPOSE_OPTIONS="$MAIN_DOCKER_COMPOSE_OPTIONS ${ARGUMENT} "
                            shift
                        fi
                    else
                        if [[ $# -ge 2 ]]; then
                            if [[ "${2}" != -* ]]; then
                                shift 2
                            else
                                shift
                            fi
                        else
                            shift
                        fi
                    fi
                    ;;
            esac
        done
    fi

    source $TASKS_DIR/config.sh
    PROJECT_NAME="${PROJECT_NAME:-"$(get_config "PROJECT_NAME")"}"

    export PROJECT_NAME
    export MAIN_DOCKER_COMPOSE_OPTIONS
    export MAIN_DOCKER_COMPOSE_OPTIONS_FULL
}