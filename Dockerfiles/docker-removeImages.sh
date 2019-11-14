#!/bin/bash

IMAGE_REGEX=/$1/

docker images | awk $IMAGE_REGEX' {print $1":"$2; system("docker rmi -f "$1":"$2)}' -
