#!/bin/bash

echo "Setup"

cd $(dirname $0)
mkdir -p logs images

docker build -t openvas .

./test.sh

if [ $? -eq 1 ]; then
    echo "Test failure. Look in log to debug."
    exit 1
fi

echo "Test Complete!"