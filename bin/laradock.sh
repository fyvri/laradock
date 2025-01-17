#!/usr/bin/env bash
set -euo pipefail

resolve_absolute_dir()
{
    SOURCE="${BASH_SOURCE[0]}"
    while [[ -h "$SOURCE" ]]; do
        DIR="$( cd -P "$( dirname ${SOURCE} )" && pwd )"
        SOURCE="$(readlink ${SOURCE})"
        [[ ${SOURCE} != /* ]] && SOURCE="${DIR}/${SOURCE}"
    done
    ABSOLUTE_BIN_PATH="$( cd -P "$( dirname ${SOURCE} )" && pwd )"
    ABSOLUTE_PATH="${ABSOLUTE_BIN_PATH%/*}"
}

init_dirs()
{
    resolve_absolute_dir
    export ROOT_DIR="${ABSOLUTE_PATH}"
    export COMMANDS_DIR="${ABSOLUTE_BIN_PATH}/console/commands"
    export TASKS_DIR="${ABSOLUTE_BIN_PATH}/console/tasks"
    export PROPERTIES_DIR="${ABSOLUTE_BIN_PATH}/console/properties"
    export TMP_DIR="/tmp"
}

usage()
{
    echo "Usage:  ${MAIN_BASENAME} [OPTIONS] COMMAND"
    echo ""
    echo "Define and run multi-container applications with ${MAIN_NAME}"
    echo ""
    echo "Options:"
    echo "${DOCKER_OPTIONS}"
    echo ""

    echo "Commands:"
	OUTPUTS=""
	for FILE in "${COMMANDS_DIR}"/*.sh;	do
        BASENAME=$(basename ${FILE})
        NAME=${BASENAME%.sh}
        DESC_PROPERTY="COMMAND_DESC_${NAME//-/_}"
        DESC="${!DESC_PROPERTY:-}"
        echo "$(printf "  %-11s %s" ${NAME} "${DESC}")"
	done
    echo ""

    echo "Additional Commands:"
    echo "${DOCKER_COMMANDS}"

    if [[ ! -z "${@}" ]]; then
        echo ""
        echo "Run '${MAIN_BASENAME} COMMAND --help' for more information on a command."
        echo "unknown ${MAIN_BASENAME} command: "${@}""
    fi
}

init_dirs
source ${TASKS_DIR}/banner.sh
source ${TASKS_DIR}/load_properties.sh

DOCKER_HELP="$(${MAIN_DOCKER_COMPOSE_COMMAND} --help)"
DOCKER_OPTIONS=$(echo "${DOCKER_HELP}"  | sed -n '/Options:/,/^$/ { /Options:/d; p }' | grep -v -e "--file" -e "--project-directory" -e "the path of the")
DOCKER_COMMANDS=$(echo "${DOCKER_HELP}" | sed -n '/Commands:/,/^$/ { /Commands:/d; p }')
export MAIN_BASENAME=$(basename ${0})

if [[ "$#" == 0 ]] || [[ "${1}" =~ ^(-h|--help|help)$ ]]; then
    banner
    usage
    exit 1
fi

OPTIONS=""
COMMAND=""
while [[ $# -gt 0 ]]; do
    ARGUMENT="${1}"
    COMMAND_BASENAME="$ARGUMENT.sh"
    export OPTIONS=${OPTIONS}
    if [[ -f "${COMMANDS_DIR}/${COMMAND_BASENAME}" ]]; then
        shift
        banner

        source $TASKS_DIR/option.sh
        parse_options $OPTIONS
        if [[ $ARGUMENT =~ (init) ]] && ! echo "${OPTIONS}" | grep -Eq -- "( -p | --project-name )"; then
            PROJECT_NAME=""
        fi

        $COMMANDS_DIR/$COMMAND_BASENAME $@
        exit 1
    elif [[ -f "${COMMANDS_DIR}/additional/${COMMAND_BASENAME}" ]]; then
        shift
        banner

        if [[ $ARGUMENT = "ls" ]] && echo "${@}" | grep -Eq -- "(-h|--help)"; then
            $MAIN_DOCKER_COMPOSE_COMMAND $OPTIONS $ARGUMENT --help | sed "s/$MAIN_DOCKER_COMPOSE_COMMAND/$MAIN_BASENAME/g" | sed "1d"
            exit 1
        fi

        source $TASKS_DIR/option.sh
        parse_options $OPTIONS
        $COMMANDS_DIR/additional/$COMMAND_BASENAME $@
        exit 1
    elif [[ "${ARGUMENT}" == -* ]] && echo "${DOCKER_OPTIONS}" | grep -Eq -- "(  $ARGUMENT,| $ARGUMENT )"; then
        if [[ -z "${COMMAND}" ]]; then
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
            break
        fi
    elif echo "${DOCKER_COMMANDS}" | grep -Pq "  $ARGUMENT  "; then
        COMMAND=$ARGUMENT
        shift 1
        break
    else
        break
    fi
done

banner
if [[ -z "${COMMAND}" ]]; then
    usage "${@}"
    exit 0
fi

source $TASKS_DIR/option.sh
parse_options $OPTIONS

if echo "${@}" | grep -Eq -- "(-h|--help)"; then
    $MAIN_DOCKER_COMPOSE_COMMAND $OPTIONS ${PROJECT_NAME:+--project-name $PROJECT_NAME} $COMMAND --help | sed "s/${MAIN_DOCKER_COMPOSE_COMMAND}/${MAIN_BASENAME}/g" | sed "1d"
    exit 1
fi

$MAIN_DOCKER_COMPOSE_COMMAND $OPTIONS ${PROJECT_NAME:+--project-name $PROJECT_NAME} $COMMAND $@