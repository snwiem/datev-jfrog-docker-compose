#!/usr/bin/env bash

SCRIPT_DIR=$(dirname "${0}")

${SCRIPT_DIR}/lib/01-create-data-directories.sh
sudo ${SCRIPT_DIR}/lib/02-bootstrap-data-directories.sh
sudo ${SCRIPT_DIR}/lib/03-chown-data-directories.sh
