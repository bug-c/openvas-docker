#!/usr/bin/env bash

if [ "$SKIP_SYNC" == "false"  ]; then
    greenbone-nvt-sync --rsync
    sleep 15
    greenbone-certdata-sync
    sleep 15
    greenbone-scapdata-sync
fi