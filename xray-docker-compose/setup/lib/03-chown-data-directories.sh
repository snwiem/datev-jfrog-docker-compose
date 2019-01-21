#!/usr/bin/env bash

ENV_FILE=".env"

if [ ! -f ${ENV_FILE} ]; then
  echo "[Error] Could not find environment file '${ENV_FILE}'..."
  exit 1
fi

source ${ENV_FILE}

echo "[Info] ---------- Setting permissions for directories in '${DOCKER_DATA}' ----------"
echo ""

echo -n "[Info] Setting permissions for directory '${DOCKER_DATA}/artifactory/home'..."
chown -R ${ARTIFACTORY_UID}:${ARTIFACTORY_GID} ${DOCKER_DATA}/artifactory/home
[ $? -eq 0 ] && echo "[OK]" || echo "[ERROR]"

echo -n "[Info] Setting permissions for directory '${DOCKER_DATA}/xray/home'..."
chown -R ${XRAY_UID}:${XRAY_GID} ${DOCKER_DATA}/xray/home
[ $? -eq 0 ] && echo "[OK]" || echo "[ERROR]"

echo -n "[Info] Setting permissions for directory '${DOCKER_DATA}/xray/mongodb'..."
chown -R ${XRAY_MONGODB_UID}:${XRAY_MONGODB_GID} ${DOCKER_DATA}/xray/mongodb
[ $? -eq 0 ] && echo "[OK]" || echo "[ERROR]"

echo -n "[Info] Setting permissions for directory '${DOCKER_DATA}/jenkins/home'..."
chown -R ${JENKINS_UID}:${JENKINS_GID} ${DOCKER_DATA}/jenkins/home
[ $? -eq 0 ] && echo "[OK]" || echo "[ERROR]"

echo ""
echo "[Info] ---------- Successfully set permissions for directories in '${DOCKER_DATA}' ----------"
