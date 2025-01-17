#!/usr/bin/env bash
set -euo pipefail

COMMAND=$(basename "${0}" .sh)

while [[ $# -gt 0 ]]; do
    ARGUMENT="${1}"
    case $ARGUMENT in
        -h|--help)
            break
        ;;
        *)
            break
        ;;
    esac
done

if [[ -z "${PROJECT_NAME}" ]]; then
    echo "no configuration file provided: not found"
    exit 0                
fi

$MAIN_DOCKER_COMPOSE_COMMAND $MAIN_DOCKER_COMPOSE_OPTIONS ${PROJECT_NAME:+--project-name $PROJECT_NAME} exec app php $COMMAND $@