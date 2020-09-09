#!/bin/bash

docker run -d -p 80:80 --name openvas openvas

echo "Waiting for startup to complete..."
until docker logs openvas | grep -E 'It seems like your OpenVAS-9 installation is'; do
  echo .
  sleep 5
done

if $(curl -k http://localhost:80/login/login.html | grep -q "Greenbone Security Assistant"); then
  echo "Greenbone started successfully!"
else
  echo "Greenbone couldn't be found. There's probably something wrong"
  exit 1
fi
