#!/usr/bin/env bash

time greenbone-nvt-sync --rsync
sleep 15
time greenbone-certdata-sync
sleep 15
time greenbone-scapdata-sync > /dev/null
