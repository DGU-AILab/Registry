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
JUPYTER_PORT=`expr 7060 + $1`
PATCH_CODE=$2 
PATCH_DIR=/home/4whomtbts/patch/$PATCH_CODE
AIMASTER_PATH=/home/aimaster
ENV_PATH=$AIMASTER_PATH/lab_storage/environment.yml
CONTAINER_NAME=aitf$PATCH_CODE
sudo docker exec -it aitf2 conda env export -n aienv -f $ENV_PATH

echo "PORT => $SSH_PORT"
echo "PATCH_CODE => $PATCH_CODE"
echo "PATCH_DIR=> $PATCH_DIR" 

cd $PATCH_DIR

echo "############# Dockerfile Build start #############"
#sudo docker rm -f aitf
#sudo docker commit -m "$PATCH_CODE patch" aitf2 aitf:$PATCH_CODE
echo "############# Commit complete #############"
echo "############# Stop previous container #############"
sudo docker run -d --gpus all \
	   -p 9098:22 \
	   -p 3390:3389 \
	   --ipc=host \
	   -it --runtime=nvidia \
	   --cap-add=SYS_ADMIN \
	   --shm-size=10g \
	   --mount type=bind,source="/home/tako$1/tako$1-data",target=/home/aimaster/lab_storage \
	   --name aitf$PATCH_CODE aitf:20200707
echo "############# New container run complete #############"
#sudo docker exec -it aitf apt-get update
#sudo docker exec -it aitf apt-get install -y ssh

#echo "############# Install ssh complete #############"
sudo docker cp $PATCH_DIR/sshd_config aitf:/etc/ssh/sshd_config
sudo docker exec -it $CONTAINER_NAME sudo service ssh start
sudo docker exec -it $CONTAINER_NAME echo $(sudo service ssh status)
#sudo docker exec -it aitf sudo ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime
sudo docker exec -it $CONTAINER_NAME sudo sed -i '/root:x:0:0:root:\/root:\/bin\/bash/c\root:x:0:0:root:\/root:\/sbin\/nologin\/' /etc/passwd
echo "############# Start to execute migrate conda env #############"
sudo docker exec -it $CONTAINER_NAME conda env create --force -n aienv -f $ENV_PATH

echo "@@@@@@@@@@@ Start juypter service @@@@@@@@@@@@"
sudo docker exec -it $CONTAINER_NAME /home/aimaster/init.sh

echo "@@@@@@@@@@@ $PATCH_CODE path complete @@@@@@@@@@@@"
