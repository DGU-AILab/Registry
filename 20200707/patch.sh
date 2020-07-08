#!/bin/bash 

if [ "$#" -le 0 ]; then
	echo "You should input server number" 
	exit 1
fi

SSH_PORT=`expr 7070 + $1`
EXTRA_PORT1=`expr 7000 + $1`
EXTRA_PORT2=`expr 7010 + $1`
EXTRA_PORT3=`expr 7020 + $1`
EXTRA_PORT4=`expr 7030 + $1`
EXTRA_PORT5=`expr 7040 + $1`
EXTRA_PORT6=`expr 7050 + $1`
PATCH_CODE=$2 
PATCH_DIR=/home/4whomtbts/patch/$PATCH_CODE
AIMASTER_PATH=/home/aimaster
ENV_PATH=$AIMASTER_PATH/lab_storage/environment.yml
sudo docker exec -it aitf2 conda env export -n aienv -f $ENV_PATH

echo "PORT => $SSH_PORT"
echo "PATCH_CODE => $PATCH_CODE"
echo "PATCH_DIR=> $PATCH_DIR" 

cd $PATCH_DIR

echo "############# Dockerfile Build start #############"
sudo docker build --tag aitf:$2 .
sudo docker rm -f aitf
#sudo docker commit -m "$PATCH_CODE patch" aitf2 aitf:$PATCH_CODE
echo "############# Commit complete #############"
sudo docker stop aitf2
echo "############# Stop previous container #############"
sudo docker run -d --gpus all \
	   -p 8080:8080 \
	   -p $SSH_PORT:22 \
	   -p $EXTRA_PORT1:$EXTRA_PORT1 \
	   -p $EXTRA_PORT2:$EXTRA_PORT2 \
	   -p $EXTRA_PORT3:$EXTRA_PORT3 \
	   -p $EXTRA_PORT4:$EXTRA_PORT4 \
	   -p $EXTRA_PORT5:$EXTRA_PORT5 \
	   -p $EXTRA_PORT6:$EXTRA_PORT6 \
	   -it --runtime=nvidia --privileged \
	   --shm-size=2g \
	   --mount type=bind,source="/home/tako$1/tako$1-data",target=/home/aimaster/lab_storage \
	   --name aitf aitf:$PATCH_CODE
echo "############# New container run complete #############"
#sudo docker exec -it aitf apt-get update
#sudo docker exec -it aitf apt-get install -y ssh

#echo "############# Install ssh complete #############"
sudo docker cp $PATCH_DIR/sshd_config aitf:/etc/ssh/sshd_config
sudo docker exec -it aitf sudo service ssh start
sudo docker exec -it aitf echo $(sudo service ssh status)
#sudo docker exec -it aitf sudo ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime
sudo docker exec -it aitf sudo sed -i '/root:x:0:0:root:\/root:\/bin\/bash/c\root:x:0:0:root:\/root:\/sbin\/nologin\/'
echo "############# Start to execute migrate conda env #############"
sudo docker exec -it aitf conda env create --force -n aienv -f $ENV_PATH

echo "@@@@@@@@@@@ Start juypter service @@@@@@@@@@@@"
sudo docker exec -it aitf /home/aimaster/init.sh

echo "@@@@@@@@@@@ $PATCH_CODE path complete @@@@@@@@@@@@"
