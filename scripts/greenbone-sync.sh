#!/usr/bin/env bash

greenbone-nvt-sync --rsync > /dev/null
sleep 15
greenbone-certdata-sync > /dev/null
sleep 15
greenbone-scapdata-sync > /dev/null
