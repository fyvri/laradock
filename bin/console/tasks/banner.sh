#!/usr/bin/env bash
set -euo pipefail

set -a

banner() {
    printf "$COLOR_BLUE                                          \n"
    printf "______                 ____________       🐳 ______  \n"
    printf "___  /_____ _____________ ______  /_____________  /__\n"
    printf "__  /_  __ '/_  ___/  __ '/  __  /  __ \  ___/_  //_/\n"
    printf "_  / / /_/ /_  /   / /_/ // /_/ // /_/ / /__ _  ,<   \n"
    printf "/_/  \__^_/ /_/    \__^_/ \__,_/ \____/\___/ /_/|_|  \n"
    printf "$COLOR_RESET                                         \n"
}

set +a