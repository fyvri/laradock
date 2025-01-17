#!/usr/bin/env bash
set -euo pipefail

MAIN_NAME="laradock"
MAIN_DIRECTORY=".laradock"
MAIN_CONFIG="config.yml"
MAIN_COMPOSE_DIRECTORY="src"
MAIN_COMPOSE_FILE="docker-compose.yml"
MAIN_DOCKER_COMMAND="docker"
MAIN_DOCKER_COMPOSE_COMMAND="${MAIN_DOCKER_COMMAND} compose"