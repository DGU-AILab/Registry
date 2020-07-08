#!/bin/bash

AIMASTER_PATH=/home/aimaster
ENV_PATH=$AIMASTER_PATH/lab_storage/environment.yml
sudo docker exec -it aitf2 conda env export -n aienv -f $ENV_PATH
sudo docker exec -it aitf conda env create -n aienv --f $ENV_PATH

