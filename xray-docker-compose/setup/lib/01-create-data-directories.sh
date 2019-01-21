#!/usr/bin/env bash

# ------------------------------------------------------------------- Functions

create_directory() {
  if [ $# -ne 1 ]; then
    echo "[Error] ${FUNCNAME[0]}: Missing parameter"
  else
    local directory=${1}

    echo -n "[Info] Creating directory '${directory}'..."
    mkdir -p "${directory}"
    [ $? -eq 0 ] && echo "[OK]" || echo "[ERROR]"
  fi
}

# ------------------------------------------------------------------------ Main

ENV_FILE=".env"

if [ ! -f ${ENV_FILE} ]; then
  echo "[Error] Could not find environment file '${ENV_FILE}'..."
  exit 1
fi

source ${ENV_FILE}

echo "[Info] ---------- Creating data directories in '${DOCKER_DATA}' ----------"
echo ""

create_directory "${DOCKER_DATA}/artifactory/home"
create_directory "${DOCKER_DATA}/jenkins/home"
create_directory "${DOCKER_DATA}/proxy/conf.d"
create_directory "${DOCKER_DATA}/proxy/vhost.d"
create_directory "${DOCKER_DATA}/xray/home/config"
create_directory "${DOCKER_DATA}/xray/home/ha"
create_directory "${DOCKER_DATA}/xray/mongodb/configdb"
create_directory "${DOCKER_DATA}/xray/mongodb/db"
create_directory "${DOCKER_DATA}/xray/mongodb/logs"
create_directory "${DOCKER_DATA}/xray/postgres"
create_directory "${DOCKER_DATA}/xray/rabbitmq"

echo ""
echo "[Info] ---------- Successfully created data directories in '${DOCKER_DATA}' ----------"
