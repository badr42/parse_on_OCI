#!/bin/bash
 

pass=$1

echo "waiting for the network set up to complete"
sleep 10




#get ip dig +short myip.opendns.com @resolver1.opendns.com
myip=$(dig +short myip.opendns.com @resolver1.opendns.com)


DEBIAN_FRONTEND=noninteractive

# Allow the firewall
sudo iptables -P INPUT ACCEPT
sudo iptables -P OUTPUT ACCEPT
sudo iptables -P FORWARD ACCEPT
sudo iptables -F

# DEBIAN_FRONTEND=noninteractive sudo apt update
# DEBIAN_FRONTEND=noninteractive sudo  apt upgrade -y
# DEBIAN_FRONTEND=noninteractive sudo apt install -y vim


wget https://raw.githubusercontent.com/badr42/parse_on_OCI/main/config.json
wget https://raw.githubusercontent.com/badr42/parse_on_OCI/main/parse-dashboard-config.json


##install mongo

sudo curl -fsSL https://www.mongodb.org/static/pgp/server-6.0.asc|sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/mongodb-6.gpg 

sudo echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu $(lsb_release -cs)/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list

DEBIAN_FRONTEND=noninteractive sudo apt update -y
DEBIAN_FRONTEND=noninteractive sudo apt install mongodb-org -y
DEBIAN_FRONTEND=noninteractive sudo systemctl enable --now mongod
DEBIAN_FRONTEND=noninteractive sudo systemctl start mongod
#systemctl status mongod

#mongod --version


###install nodejs
# sudo apt-get update
# sudo su - 
sudo curl -sL https://deb.nodesource.com/setup_lts.x | sudo bash -
DEBIAN_FRONTEND=noninteractive sudo apt install nodejs -y
DEBIAN_FRONTEND=noninteractive sudo apt install npm -y

curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | sudo tee /usr/share/keyrings/yarnkey.gpg >/dev/null
echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

sudo apt-get update && sudo apt-get install yarn
DEBIAN_FRONTEND=noninteractive sudo npm install -g yarn


#node --version




sleep 5

##install parse
sudo yarn global add parse-server
#nano config.json  //replace with curl



#nohup parse-server config.json &

#create service
wget https://raw.githubusercontent.com/badr42/parse_on_OCI/main/parse.server.service
sudo mv parse.server.service /etc/systemd/system/parse.server.service


sudo systemctl start parse.server.service

#systemctl status parse.server.service
sudo systemctl enable parse.server.service


sleep 5
##dashboard

sudo yarn global add parse-dashboard

wget https://raw.githubusercontent.com/badr42/parse_on_OCI/main/parse.server.dashboard.service
sudo mv parse.server.service /etc/systemd/system/parse.server.dashboard.service


#nano parse-dashboard-config.json  //replace with curl

sed -i "s/localhost/$myip/g" /home/ubuntu/parse-dashboard-config.json
sed -i "s/parserpass/$pass/g" /home/ubuntu/parse-dashboard-config.json

#start dashboard
#nohup parse-dashboard --dev --config parse-dashboard-config.json &
#ss -ant | grep 4040

##nano parse.server.dashboard.service  //replace with curl /etc/systemd/system/

sudo systemctl daemon-reload


sudo systemctl start parse.server.service


sudo systemctl stop parse.server.dashboard.service
sudo systemctl start parse.server.dashboard.service
sudo systemctl enable parse.server.dashboard.service


echo "Completed setup"
