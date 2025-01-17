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
}

IS_DRY_RUN=""
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
        --dry-run)
            IS_DRY_RUN=true
            shift
        ;;
        *)
            echo "unknown flag: ${ARGUMENT}"
            exit 0
        ;;
    esac
done

echo "$(${MAIN_DOCKER_COMPOSE_COMMAND} ls --all | head -n 1)"
PROJECTS="$(${MAIN_DOCKER_COMPOSE_COMMAND} ls --all | grep "/${MAIN_DIRECTORY}/${MAIN_COMPOSE_FILE}" || true)"
if [[ -z "${PROJECTS}" ]]; then
    echo ""
    echo "Process canceled. The project is not available."
    exit 0
fi
echo "${PROJECTS}"
echo ""

if [[ $NO_INTERACTION == false && $IS_DRY_RUN != true ]]; then
    read -p "Are you sure want to stop and remove all projects (images, containers, volumes and networks)? [Y/n]: " CONFIRMATION
    CONFIRMATION=$(echo "${CONFIRMATION:0:1}" | tr '[:upper:]' '[:lower:]') 
    if [[ ! -z "${CONFIRMATION}" && ! "${CONFIRMATION}" =~ ^[Yy]$ ]]; then
        echo "Process canceled. The script is stopped."
        exit 1
    fi
    echo ""
fi

$MAIN_DOCKER_COMPOSE_COMMAND ls --all | grep "/${MAIN_DIRECTORY}/${MAIN_COMPOSE_FILE}" | awk '{print $1}' | while IFS= read -r PROJECT_NAME; do
    $MAIN_DOCKER_COMPOSE_COMMAND $MAIN_DOCKER_COMPOSE_OPTIONS ${PROJECT_NAME:+--project-name $PROJECT_NAME} down --remove-orphans --rmi local --volumes ${IS_DRY_RUN:+"--dry-run"}
    echo ""
done