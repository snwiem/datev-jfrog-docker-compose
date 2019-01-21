#!/bin/bash
# This file is for preparing all the needed files and directories on the host.

SCRIPT_DIR=$(dirname $0)
OS_NAME=$(uname)

error_exit () {
    echo; echo "ERROR: $1"; echo
    exit 1
}

create_directory() {
  if [ $# -ne 1 ]; then
    echo "[Error] ${FUNCNAME[0]}: Missing parameter"
  else
    local directory=${1}

    if [ ! -d ${directory} ]; then
        echo -n "[Info] Creating directory '${directory}'..."
        mkdir -p "${directory}"
        [ $? -eq 0 ] && echo "[OK]" || echo "[ERROR]"
    fi
  fi
}

set_permissions() {
    if [ $# -ne 3 ]; then
        echo "[Error] ${FUNCNAME[0]}: Missing parameters"
    else
        local directory=${1}
        local uid=${2}
        local gid=${3}

        if [ ! -d ${directory} ]; then
            echo "[Error] missing directory '${directory}'"
        else
            echo -n "[Info] Setting permissions for directory '${directory}'..."
            chown -R ${uid}:${gid} ${directory}
            [ $? -eq 0 ] && echo "[OK]" || echo "[ERROR]"
        fi
    fi
}


if [ "${OS_NAME}" = "Linux" ] && [ "$EUID" != 0 ]; then
    error_exit "This script must be run as root or with sudo"
fi

if [ ! -f ./.env ]; then
    error_exit ".env file does not exist in $SCRIPT_DIR"
fi

source ./.env

# -----
# Create directory structure for all docker-compose services
# -----
create_directory "${XRAY_MOUNT_ROOT}/proxy/conf.d"
create_directory "${XRAY_MOUNT_ROOT}/proxy/vhost.d"
create_directory "${XRAY_MOUNT_ROOT}/xray"
create_directory "${XRAY_MOUNT_ROOT}/artifactory"
create_directory "${XRAY_MOUNT_ROOT}/postgres"
create_directory "${XRAY_MOUNT_ROOT}/mongodb/configdb"
create_directory "${XRAY_MOUNT_ROOT}/mongodb/db"
create_directory "${XRAY_MOUNT_ROOT}/mongodb/logs"
create_directory "${XRAY_MOUNT_ROOT}/rabbitmq"

echo -n "[Info] NGINX proxy: Copying bootstrap configuration..."
cp -r conf/proxy/* ${XRAY_MOUNT_ROOT}/proxy \
    && mv ${XRAY_MOUNT_ROOT}/proxy/vhost.d/artifactory.vhost.tmpl ${XRAY_MOUNT_ROOT}/proxy/vhost.d/${ARTIFACTORY_HOSTNAME}
[ $? -eq 0 ] && echo "[OK]" || echo "[ERROR]"

echo -n "[Info] Xray: Copying bootstrap configuration..."
cp -r conf/xray/* ${XRAY_MOUNT_ROOT}/xray \
    && envsubst < conf/xray/config/xray_config.yaml > ${XRAY_MOUNT_ROOT}/xray/config/xray_config.yaml
[ $? -eq 0 ] && echo "[OK]" || echo "[ERROR]"

echo -n "[Info] Xray: Creating Xray user in MongoDB..."
docker-compose up -d mongodb &> /dev/null
cat conf/mongodb/scripts/create_users.js | docker-compose exec -T mongodb mongo  &> /dev/null
docker-compose stop mongodb  &> /dev/null
[ $? -eq 0 ] && echo "[OK]" || echo "[ERROR]"

set_permissions ${XRAY_MOUNT_ROOT}/xray ${XRAY_USER_ID} ${XRAY_USER_ID}
set_permissions ${XRAY_MOUNT_ROOT}/artifactory ${ARTIFACTORY_USER_ID} ${ARTIFACTORY_USER_ID}
set_permissions ${XRAY_MOUNT_ROOT}/mongodb ${XRAY_MONGODB_UID} ${XRAY_MONGODB_UID}

#if [ $(stat -c '%u' ${XRAY_MOUNT_ROOT}/xray) != "${XRAY_USER_ID}" ] || [ $(stat -c '%g' ${XRAY_MOUNT_ROOT}/xray) != "${XRAY_USER_ID}" ]; then
#    echo "Setting needed ownerships on ${XRAY_MOUNT_ROOT}/xray"
#    chown -R ${XRAY_USER_ID}:${XRAY_USER_ID} ${XRAY_MOUNT_ROOT}/xray || error_exit "Setting ownership of ${XRAY_MOUNT_ROOT}/xray to ${XRAY_USER_ID} failed"
#fi
#if [ $(stat -c '%u' ${XRAY_MOUNT_ROOT}/artifactory) != "${ARTIFACTORY_USER_ID}" ] || [ $(stat -c '%g' ${XRAY_MOUNT_ROOT}/artifactory) != "${ARTIFACTORY_USER_ID}" ]; then
#    echo "Setting needed ownerships on ${XRAY_MOUNT_ROOT}/artifactory"
#    chown -R ${ARTIFACTORY_USER_ID}:${ARTIFACTORY_USER_ID} ${XRAY_MOUNT_ROOT}/artifactory || error_exit "Setting ownership of ${XRAY_MOUNT_ROOT}/artifactory to ${ARTIFACTORY_USER_ID} failed"
#fi



