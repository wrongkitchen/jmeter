#!/bin/bash -e

JMETER_VERSION=5.3.0

docker build --tag="wrongkitchen/jmeter:${JMETER_VERSION}" .
docker build --tag="wrongkitchen/jmeter:vnc-${JMETER_VERSION}" -f ./vnc/Dockerfile .

docker push wrongkitchen/jmeter:${JMETER_VERSION}
docker push wrongkitchen/jmeter:vnc-${JMETER_VERSION}