#!/usr/bin/env bash
set -euo pipefail

COMMAND=$(basename "${0}" .sh)

$MAIN_DOCKER_COMPOSE_COMMAND $MAIN_DOCKER_COMPOSE_OPTIONS_FULL $COMMAND $@ | grep -e "CONFIG FILES" -e "/${MAIN_DIRECTORY}/${MAIN_COMPOSE_FILE}"