#!/bin/bash
sudo yum update -y
sudo amazon-linux-extras install docker -y
sudo systemctl enable docker
sudo service docker start

sudo docker run -d --name superset -p 8080:8088 tylerfowler/superset


sudo apt update
sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
sudo apt update
sudo apt install docker-ce -y
o="ExecStart=\/usr\/bin\/dockerd -H fd:\/\/ --containerd=\/run\/containerd\/containerd\.sock"
n="ExecStart=\/usr\/bin\/dockerd -H fd:\/\/ -H=tcp:\/\/0\.0\.0\.0:8088"
sudo sed -i -e "s/$o/$n/g" /lib/systemd/system/docker.service
sudo systemctl daemon-reload
sudo service docker restart