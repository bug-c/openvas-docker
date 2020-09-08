#!/usr/bin/env bash

time greenbone-nvt-sync --rsync > /dev/null
sleep 15
time greenbone-certdata-sync > /dev/null
sleep 15
time greenbone-scapdata-sync > /dev/null
