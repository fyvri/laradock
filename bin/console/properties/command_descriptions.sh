#!/usr/bin/env bash
set -euo pipefail

COMMAND_DESC_artisan="Execute artisan commands"
COMMAND_DESC_build="Build or rebuild services"
COMMAND_DESC_clean="Stop and remove all projects (images, containers, volumes and networks)"
COMMAND_DESC_composer="Execute composer commands"
COMMAND_DESC_compose="Build images and run containers in the background"
COMMAND_DESC_config="Parse, resolve and render compose file in canonical format"
COMMAND_DESC_container="Manage containers"
COMMAND_DESC_convert="${COMMAND_DESC_config}"
COMMAND_DESC_image="Manage images"
COMMAND_DESC_init="Initialize ${MAIN_NAME} setup or reinitialize an existing one"
COMMAND_DESC_network="Manage networks"
COMMAND_DESC_reboot="Restart all services"
COMMAND_DESC_run="Run a one-off command on a service"
COMMAND_DESC_shutdown="Stop all services"
COMMAND_DESC_startup="Start all services"
COMMAND_DESC_up="Create and start containers"
COMMAND_DESC_volume="Manage volumes"