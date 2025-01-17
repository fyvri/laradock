#!/usr/bin/env bash
set -euo pipefail

get_config() {
    if [[ ! -f "${MAIN_DIRECTORY}/${MAIN_CONFIG}" ]]; then
        exit 0
    fi

    local key="${1}"
    grep -oP "(?<=^${key}:).*" "${MAIN_DIRECTORY}/${MAIN_CONFIG}" | awk '{print $1}' | sed 's/"//g'
}