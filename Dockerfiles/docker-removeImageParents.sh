#!/bin/bash

PARENT_FOUND=1
IMAGE=$1
PARENTS=$IMAGE

while [ $PARENT_FOUND ]
do
  PARENT_FOUND=$(docker inspect $IMAGE | jq -r .[0].Parent)
  echo $IMAGE Parent = $PARENT_FOUND
  PARENTS="$PARENT_FOUND $PARENTS"
  IMAGE=$PARENT_FOUND
done

echo $PARENTS

for i in $PARENTS
do
  docker rmi $i
done
