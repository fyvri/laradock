#!/usr/bin/env bash
set -euo pipefail

COMMAND=$(basename "${0}" .sh)

DOCKER_HELP="$($MAIN_DOCKER_COMMAND $COMMAND --help)"
DOCKER_HELP_COMMANDS=$(echo "${DOCKER_HELP}" | sed -n '/Commands:/,/^$/ { /Commands:/d; p }')
SUB_COMMAND=""
while [[ $# -gt 0 ]]; do
    ARGUMENT="${1}"
    if echo "${DOCKER_HELP_COMMANDS}" | grep -q "  ${ARGUMENT}  "; then
        SUB_COMMAND="${ARGUMENT}"
        shift 1
        break
    else
        break
    fi
done

if [[ -z "${SUB_COMMAND}" ]]; then
    $MAIN_DOCKER_COMMAND $COMMAND --help | sed "s|${MAIN_DOCKER_COMMAND} ${COMMAND}|${MAIN_BASENAME} ${COMMAND}|g" | sed "1d"
    exit 0
fi

if echo "${@}" | grep -Eq -- "(-h|--help)"; then
    $MAIN_DOCKER_COMMAND $COMMAND $SUB_COMMAND $@ | sed "s|${MAIN_DOCKER_COMMAND} ${COMMAND}|${MAIN_BASENAME} ${COMMAND}|g" | sed "1d"
    exit 1
fi

case $SUB_COMMAND in
    ls)
        $MAIN_DOCKER_COMMAND $COMMAND ls $@ | grep -e "IMAGE ID" -e "${MAIN_NAME}."
        exit 1
    ;;
esac

$MAIN_DOCKER_COMMAND $COMMAND $SUB_COMMAND $@ | sed "s|${MAIN_DOCKER_COMMAND} ${COMMAND}|${MAIN_BASENAME} ${COMMAND}|g"