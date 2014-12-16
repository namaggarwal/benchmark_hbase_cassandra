#!/bin/bash
#Sets the configuration files for zookeeper 3.x

#Usage <scriptname> user master

USER="naman"
NODE="access0"

#Global Variables

HOME_DIR=/home/n/${USER}
ZOOKEEPER_HOME=${HOME_DIR}/zookeeper-3.4.6
CLIENT_PORT=9000
ZOOKEEPER_DATA_DIR=/tmp/naman/zookeeper_data


#Goto config Dir
cd ${ZOOKEEPER_HOME}/conf


#Making zoo.cfg
echo "tickTime=2000
dataDir=${ZOOKEEPER_DATA_DIR}
clientPort=2181
initLimit=5
syncLimit=2
server.1=${NODE}:2888:3888" > zoo.cfg

echo "Making Data Directory"
mkdir -p ${ZOOKEEPER_DATA_DIR}

echo "export ZOOKEEPER_HOME=${ZOOKEEPER_HOME}" >> /home/n/${USER}/.bash_profile
