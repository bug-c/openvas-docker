#!/usr/bin/env bash


if [[ -z "${SKIP_SYNC}" ]]; then
    echo "Skip sync."
else
    if [ "$(ls -A /usr/local/var/lib/openvas/plugins)" ]; then
      greenbone-nvt-sync --rsync
    else
      greenbone-nvt-sync --wget
    fi
    sleep 15
    greenbone-certdata-sync
    sleep 15
    greenbone-scapdata-sync
fi
