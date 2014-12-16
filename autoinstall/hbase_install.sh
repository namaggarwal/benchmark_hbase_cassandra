#!/bin/bash
#Sets the configuration files for hbase-0.94.19

USER="naman"
NAMENODE="access0"

REGIONSERVERS="access0 access1 access2"
 
#Global Variables
HOME_DIR=/home/n/${USER}
HBASE_HOME=${HOME_DIR}/hbase-0.98.6.1-hadoop2
ZOOKEEPER_DATA_DIR=/tmp/naman/zookeeper_data
NAMENODE_PORT=9000
JAVA_HOME=/usr/java/jdk1.6.0_18/
  
#Change to the Config Directory
cd ${HBASE_HOME}/conf
 
 
#Set the common config
  
#################################HBase-Site.xml##########################

sed -i "24i<property>\n\
    <name>hbase.rootdir</name>\n\
    <value>hdfs://${NAMENODE}:${NAMENODE_PORT}/hbase</value>\n\
    <description>The directory shared by RegionServers.\n\
    </description>\n\
  </property>\n\
  <property>\n\
    <name>hbase.cluster.distributed</name>\n\
    <value>true</value>\n\
    <description>The mode the cluster will be in. Possible values are\n\
      false: standalone and pseudo-distributed setups with managed Zookeeper\n\
      true: fully-distributed with unmanaged Zookeeper Quorum (see hbase-env.sh)\n\
    </description>\n\
  </property>\n\
<property>\n\
<name>hbase.zookeeper.quorum</name>\n\
<value>${NAMENODE}</value>\n\
</property>\n\
<property>\n\
<name>hbase.zookeeper.property.dataDir</name>\n\
<value>${ZOOKEEPER_DATA_DIR}</value>\n\
</property>" hbase-site.xml
  
 
echo "HBase-Site Edited"


############################# Hbase-env.sh ##############################

sed -i "30iexport JAVA_HOME=${JAVA_HOME}" hbase-env.sh

sed -i "34iexport HBASE_CLASSPATH=${HBASE_HOME}/conf" hbase-env.sh

sed -i "119iexport HBASE_MANAGES_ZK=false" hbase-env.sh

echo "Hbase-env edited"


############################# REgion servers #############################

rm -f regionservers

for i in ${REGIONSERVERS[@]}
do

echo $i >> regionservers

done

echo "regionservers File Done "

echo "Setting Path variables"
 
echo "export HBASE_HOME=${HBASE_HOME}" >> /home/n/${USER}/.bash_profile


