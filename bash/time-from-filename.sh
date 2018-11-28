#!bin/bash

DIR=$1

for f in { ls DIR }
do
  unparsed=${ sed '/\d{8}[-_]\d{6}/' $f }
  echo $unparsed
done
