#!/usr/bin/env bash
set -euo pipefail

COMMAND=$(basename "${0}" .sh)

usage() {
    DESC="COMMAND_DESC_${COMMAND}"
    echo "Usage:  ${MAIN_BASENAME} ${COMMAND} [OPTIONS]"
    echo ""
    echo "${!DESC}"
    echo ""
    echo "Options:"
    echo "      --dry-run       Execute command in dry run mode"
    echo "  -t, --timeout int   Specify a shutdown timeout in seconds"
}

NO_INTERACTION=false

while [[ $# -gt 0 ]]; do
    ARGUMENT="${1}"
    case "${ARGUMENT}" in
        -h|--help)
            usage
            exit 1
        ;;
        -y|--yes)
            NO_INTERACTION=true
            shift
        ;;
        *)
            break
        ;;
    esac
done

PROJECTS="$($MAIN_DOCKER_COMMAND container ls --all --filter "name=^$MAIN_NAME.")"
echo "$PROJECTS"
echo ""
if [[ $(echo "$PROJECTS" | wc -l) = 1 ]]; then
    echo "Process canceled. The project is not available."
    exit 0
fi

IS_DRY_RUN=""
if echo "${@}" | grep -Eq -- "(--dry-run)"; then
    IS_DRY_RUN=true
fi

if [[ $NO_INTERACTION == false && $IS_DRY_RUN != true ]]; then
    read -p "Are you sure you want to shutdown all services? [Y/n]: " CONFIRMATION
    CONFIRMATION=$(echo "${CONFIRMATION:0:1}" | tr '[:upper:]' '[:lower:]') 
    if [[ ! -z "${CONFIRMATION}" && ! "${CONFIRMATION}" =~ ^[Yy]$ ]]; then
        echo "Process canceled. The script is stopped."
        exit 1
    fi
    echo ""
fi

$MAIN_DOCKER_COMPOSE_COMMAND ls --all | grep "/${MAIN_DIRECTORY}/${MAIN_COMPOSE_FILE}" | awk '{print $1}' | while IFS= read -r PROJECT_NAME; do
    $MAIN_DOCKER_COMPOSE_COMMAND $MAIN_DOCKER_COMPOSE_OPTIONS ${PROJECT_NAME:+--project-name $PROJECT_NAME} stop $@
    echo ""
done