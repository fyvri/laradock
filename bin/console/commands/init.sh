#!/usr/bin/env bash
set -euo pipefail

COMMAND=$(basename "${0}" .sh)

usage() {
    DESC="COMMAND_DESC_${COMMAND}"
    echo "Usage:  ${MAIN_BASENAME} ${COMMAND} [OPTION]"
    echo ""
    echo "${!DESC}"
    echo ""
    echo "Options:"
    echo "      --php string   Specify the PHP version (e.g., 5.6, 7.4, 8.1, etc)"
    echo "      --port int     Set the app port (default: 8000)"
}

NO_INTERACTION=false
PROJECT_PORT=""
PHP_VERSION=""
CURRENT_DIRECTORY="$(pwd)"

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
        --php)
            PHP_VERSION="${2}"
            shift 2
        ;;
        --port)
            PROJECT_PORT="${2}"
            shift 2
        ;;
        *)
            echo "unknown flag: ${ARGUMENT}"
            exit 0
        ;;
    esac
done

if [[ ! -d "${CURRENT_DIRECTORY}" ]]; then
    echo "no such file or directory: ${CURRENT_DIRECTORY}"
    exit 0
fi

if [[ ! -f "composer.json" ]]; then
    echo "no such file: composer.json"
    exit 0
fi

IS_REINITIALIZED=""
TEMP_PROJECT_NAME="${CURRENT_DIRECTORY}"
TEMP_PROJECT_PORT="8000"
TEMP_PHP_VERSION="$(grep -oP '"php": "\K[^"]+' composer.json | grep -oE '[0-9]+\.[0-9]+' | sort -V | tail -n 1)"
if [[ -d "${CURRENT_DIRECTORY}/${MAIN_DIRECTORY}" ]]; then
    read -p "Are you sure you want to overwrite ${MAIN_DIRECTORY}? [Y/n]: " IS_REINITIALIZED
    IS_REINITIALIZED=$(echo "${IS_REINITIALIZED:0:1}" | tr '[:upper:]' '[:lower:]') 
    if [[ ! -z "${IS_REINITIALIZED}" && ! "${IS_REINITIALIZED}" =~ ^[Yy]$ ]]; then
        echo "Process canceled. The script is stopped."
        exit 1
    fi
    IS_REINITIALIZED=true

    source $TASKS_DIR/config.sh
    TEMP_PROJECT_NAME="$(get_config "PROJECT_NAME")"
    TEMP_PROJECT_PORT="$(get_config "PROJECT_PORT")"
    TEMP_PHP_VERSION="$(get_config "PHP_VERSION")"
fi
source $TASKS_DIR/name.sh
TEMP_PROJECT_NAME="$(clean_name "$(basename "${TEMP_PROJECT_NAME}")")"

if [[ $NO_INTERACTION == true ]]; then
    PROJECT_NAME="${TEMP_PROJECT_NAME}"
    PROJECT_PORT="${TEMP_PROJECT_PORT}"
    PHP_VERSION="${TEMP_PHP_VERSION}"
fi

if [[ ! -z $IS_REINITIALIZED ]]; then
    echo ""
fi

while true; do
    if [[ -z "${PROJECT_NAME}" ]]; then
        read -p "Project name [${TEMP_PROJECT_NAME}]: " PROJECT_NAME
    fi

    if [[ -z "${PROJECT_NAME}" ]]; then
        PROJECT_NAME="${TEMP_PROJECT_NAME}"
        continue
    elif [[ "${PROJECT_NAME}" =~ [^a-zA-Z0-9-] ]]; then
        echo "Project name contains invalid characters."
        PROJECT_NAME=""
    else
        break
    fi  
done

while true; do
    if [[ -z "${PROJECT_PORT}" ]]; then
        read -p "Port [${TEMP_PROJECT_PORT}]: " PROJECT_PORT
        if [[ -z "${PROJECT_PORT}" ]]; then
            PROJECT_PORT="${TEMP_PROJECT_PORT}"
        fi
    fi

    if [[ "${PROJECT_PORT}" =~ ^[0-9]+$ ]] && [[ "${PROJECT_PORT}" -ge 1 ]] && [[ "${PROJECT_PORT}" -le 65535 ]]; then
        break
    else
        echo "Please enter the correct port."
        PROJECT_PORT=""
    fi
done

while true; do
    if [[ -z "${PHP_VERSION}" ]]; then
        read -p "PHP version [${TEMP_PHP_VERSION:-"7.4/8.0/..."}]: " PHP_VERSION
    fi

    if [[ -z "${PHP_VERSION}" ]]; then
        PHP_VERSION="${TEMP_PHP_VERSION}"
        continue
    elif [[ "${PHP_VERSION}" =~ [^a-zA-Z0-9.-] ]]; then
        echo "PHP version contains invalid characters."
        PHP_VERSION=""
    else
        break
    fi
done

rm -rf "${TMP_DIR}/${MAIN_DIRECTORY}"
cp -r  "${ROOT_DIR}/${MAIN_COMPOSE_DIRECTORY}" "${TMP_DIR}/${MAIN_DIRECTORY}"

if [[ -d "${TMP_DIR}/${MAIN_DIRECTORY}/custom/" ]]; then
    if compgen -G "${TMP_DIR}/${MAIN_DIRECTORY}/custom/*.docker-compose.yml" > /dev/null; then
        for FILE in "${TMP_DIR}/${MAIN_DIRECTORY}/custom"/*.docker-compose.yml; do
            BASENAME=$(basename $FILE)
            if [[ $NO_INTERACTION == false ]]; then
                read -p "Are you sure you want to add ${BASENAME}? [Y/n]: " CONFIRMATION
                CONFIRMATION=$(echo "${CONFIRMATION:0:1}" | tr '[:upper:]' '[:lower:]')
                if [[ ! -z "${CONFIRMATION}" && ! "${CONFIRMATION}" =~ ^[Yy]$ ]]; then
                    rm -rf "${TMP_DIR}/${MAIN_DIRECTORY}/custom/${BASENAME}"
                fi
            fi
        done
    fi

    if ! find "${TMP_DIR}/${MAIN_DIRECTORY}/custom/" -name "*.docker-compose.yml" | grep -q .; then
        rm -rf "${TMP_DIR}/${MAIN_DIRECTORY}/custom/"/*
        rm -rf "${TMP_DIR}/${MAIN_DIRECTORY}/custom/"/.[!.]*
        rm -rf "${TMP_DIR}/${MAIN_DIRECTORY}/custom/"/..?*
        if [[ -f "${ROOT_DIR}/${MAIN_COMPOSE_DIRECTORY}/custom/README.md" ]]; then
            cp "${ROOT_DIR}/${MAIN_COMPOSE_DIRECTORY}/custom/README.md" "${TMP_DIR}/${MAIN_DIRECTORY}/custom/README.md"
        fi
    fi

    rm -rf "${TMP_DIR}/${MAIN_DIRECTORY}/custom/.gitignore"
    if [ -z "$(find "${TMP_DIR}/${MAIN_DIRECTORY}/custom/" -mindepth 1 -maxdepth 1)" ]; then
        rm -rf "${TMP_DIR}/${MAIN_DIRECTORY}/custom/"
    fi
fi

rm -rf "${TMP_DIR}/${MAIN_DIRECTORY}/app/scripts/.gitignore"
rm -rf "${TMP_DIR}/${MAIN_DIRECTORY}/web/scripts/.gitignore"

if [[ -f "${ROOT_DIR}/README.md" ]]; then
    cp "${ROOT_DIR}/README.md"  "${TMP_DIR}/${MAIN_DIRECTORY}/README.md"
    sed -i 's|\./src/|\./|g'    "${TMP_DIR}/${MAIN_DIRECTORY}/README.md"

    if [[ -f "${TMP_DIR}/${MAIN_DIRECTORY}/app/scripts/README.md" ]]; then
        sed -i 's|\.\./\.\./|\.\./|g' "${TMP_DIR}/${MAIN_DIRECTORY}/app/scripts/README.md"
    fi
    if [[ -f "${TMP_DIR}/${MAIN_DIRECTORY}/custom/README.md" ]]; then
        sed -i 's|\.\./\.\./|\.\./|g' "${TMP_DIR}/${MAIN_DIRECTORY}/custom/README.md"
    fi
    if [[ -f "${TMP_DIR}/${MAIN_DIRECTORY}/web/scripts/README.md" ]]; then
        sed -i 's|\.\./\.\./|\.\./|g' "${TMP_DIR}/${MAIN_DIRECTORY}/web/scripts/README.md"
    fi
fi

cat <<EOF > "${TMP_DIR}/${MAIN_DIRECTORY}/${MAIN_CONFIG}"
PROJECT_NAME: "${PROJECT_NAME}"
PROJECT_PORT: ${PROJECT_PORT}
PHP_VERSION: "${PHP_VERSION}"
EOF

rm -rf "${CURRENT_DIRECTORY}/${MAIN_DIRECTORY}"
mv     "${TMP_DIR}/${MAIN_DIRECTORY}" "${CURRENT_DIRECTORY}/${MAIN_DIRECTORY}"

echo ""
echo "$(echo $([[ "${IS_REINITIALIZED}" == true ]] && echo "Reinitialized" || echo "Initialized")) ${MAIN_NAME} in ${CURRENT_DIRECTORY}/${MAIN_DIRECTORY}/"