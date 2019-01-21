#!/usr/bin/env bash

# ------------------------------------------------------------------------ Main

ENV_FILE=".env"

if [ ! -f ${ENV_FILE} ]; then
  echo "[Error] Could not find environment file '${ENV_FILE}'..."
  exit 1
fi

set -o allexport
source ${ENV_FILE}
set +o allexport

echo "[Info] ---------- Bootstrapping data directories in '${DOCKER_DATA}' ----------"
echo ""

echo -n "[Info] NGINX proxy: Copying bootstrap configuration..."
cp -r setup/templates/proxy/* ${DOCKER_DATA}/proxy
mv ${DOCKER_DATA}/proxy/vhost.d/artifactory.vhost.tmpl ${DOCKER_DATA}/proxy/vhost.d/${ARTIFACTORY_HOSTNAME}
[ $? -eq 0 ] && echo "[OK]" || echo "[ERROR]"

echo -n "[Info] Xray: Copying bootstrap configuration..."
cp -r setup/templates/xray/home/* ${DOCKER_DATA}/xray/home
envsubst < setup/templates/xray/home/config/xray_config.yaml > ${DOCKER_DATA}/xray/home/config/xray_config.yaml
[ $? -eq 0 ] && echo "[OK]" || echo "[ERROR]"

echo -n "[Info] Xray: Creating Xray user in MongoDB..."
docker-compose up -d xray-mongodb &> /dev/null
cat setup/lib/02.1-xray-create-mongo-users | docker-compose exec -T xray-mongodb mongo  &> /dev/null
docker-compose stop xray-mongodb  &> /dev/null
[ $? -eq 0 ] && echo "[OK]" || echo "[ERROR]"

echo ""
echo "[Info] ---------- Successfully bootstrapped data directories in '${DOCKER_DATA}' ----------"
