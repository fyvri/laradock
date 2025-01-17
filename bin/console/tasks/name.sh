#!/usr/bin/env bash
set -euo pipefail

clean_name() {
    local NAME="${1}"
    NAME=$(echo "${NAME}" | sed 's/[^a-zA-Z0-9_-]/-/g')
    NAME=$(echo "${NAME}" | sed 's/_/-/g')
    NAME=$(echo "${NAME}" | sed 's/-\+/-/g')
    NAME=$(echo "${NAME}" | sed 's/^[^a-zA-Z0-9]*//;s/[^a-zA-Z0-9]*$//')

    echo "${NAME}"
}