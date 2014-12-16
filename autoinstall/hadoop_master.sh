#/bin/bash
#Sets the configuration files for hadoop 2.x

NAMENODE=access0
SLAVES="access1 access2"
 
#Global Variables
HOME_DIR=/home/n/naman
USER_NAME=naman
HADOOP_HOME=${HOME_DIR}/hadoop-2.4.1
NAMENODE_PORT=9000
 

REPLICATION_FACTOR=1
NAMENODE_DIR=/tmp/naman/hadoop/yarn_data/hdfs/namenode
DATANODE_DIR=/tmp/naman/hadoop/yarn_data/hdfs/datanode
HADOOP_TMP_DIR=/tmp/naman/hadoop/hdfs_data
 
 
RESOURCE_TRACKER_PORT=8025
SCHEDULER_PORT=8030
RESOURCE_MANAGER_PORT=8040
LOCALIZER_PORT=8060
SEC_NAMENODE_PORT=50090 
 
  
#Change to the Config Directory
cd ${HADOOP_HOME}/etc/hadoop
 
 
#Set the common config
  
#################################Core-Site.xml##########################
  
sed -i "20i<property>\n\
<name>fs.defaultFS</name>\n\
<value>hdfs://${NAMENODE}:${NAMENODE_PORT}</value>\n\
</property>\n\
<property>\n\
<name>hadoop.tmp.dir</name>\n\
<value>${HADOOP_TMP_DIR}</value>\n\
<final>true</final>\n\
</property>" core-site.xml
 
echo "Core-Site Edited"
  
################################Hdfs-Site.xml###########################
 
sed -i "20i<property>\n\
<name>dfs.replication</name>\n\
<value>${REPLICATION_FACTOR}</value>\n\
</property>\n\
<property>\n\
<name>dfs.namenode.name.dir</name>\n\
<value>file:${NAMENODE_DIR}</value>\n\
</property>\n\
<property>\n\
<name>dfs.datanode.data.dir</name>\n\
<value>file:${DATANODE_DIR}</value>\n\
</property>\n\
<property>\n\
 <name>dfs.secondary.http.address</name>\n\
 <value>${NAMENODE}:${SEC_NAMENODE_PORT}</value>\n\
</property>" hdfs-site.xml
 
echo "HDFS-Site Edited"
 
##############################Mapred-Site.xml###############################
 
echo '<configuration>
<property>
<name>mapreduce.framework.name</name>
<value>yarn</value>
</property>
</configuration>' >> mapred-site.xml
 
echo "Mapred Site Created"
 
#############################yarn-site.xml##################################
 
sed -i "18i<property>\n\
<name>yarn.nodemanager.aux-services</name>\n\
<value>mapreduce_shuffle</value>\n\
</property>\n\
<property>\n\
<name>yarn.nodemanager.aux-services.mapreduce.shuffle.class</name>\n\
<value>org.apache.hadoop.mapred.ShuffleHandler</value>\n\
</property>\n\
<property>\n\
  <name>yarn.resourcemanager.resource-tracker.address</name>\n\
  <value>${NAMENODE}:${RESOURCE_TRACKER_PORT}</value>\n\
</property>\n\
<property>\n\
  <name>yarn.resourcemanager.scheduler.address</name>\n\
  <value>${NAMENODE}:${SCHEDULER_PORT}</value>\n\
</property>\n\
<property>\n\
  <name>yarn.resourcemanager.address</name>\n\
  <value>${NAMENODE}:${RESOURCE_MANAGER_PORT}</value>\n\
</property>" yarn-site.xml
 
echo "Yarn Site Edited"
 
 
#If Master Node then add this
#if [ ${TYPE} = "master" ];
#then
 
sed -i "38i<property>\n\
<name>yarn.nodemanager.localizer.address</name>\n\
<value>${NAMENODE}:${LOCALIZER_PORT}</value>\n\
</property>" yarn-site.xml
 
 
########Only if master####################################################
 
rm -f slaves

echo ${NAMENODE} >> slaves 

for i in ${SLAVES[@]}
do
 
echo $i >> slaves
 
done

echo "Slaves File Done "
 


##################Hadoop-env.sh##############################################

sed -i "28iexport JAVA_HOME=/usr/java/jdk1.6.0_18\n\
export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native\n\
export HADOOP_OPTS=\"-Djava.library.path=$HADOOP_HOME/lib\"" hadoop-env.sh
 
 
echo "Making Namenode Directory"
mkdir -p ${NAMENODE_DIR}
 
echo "Making Datanode Directory"
mkdir -p ${DATANODE_DIR}

echo "Making TMP Directory"
mkdir -p ${HADOOP_TMP_DIR}


for i in ${SLAVES[@]}
do
ssh ${USER_NAME}@$i mkdir -p ${NAMENODE_DIR}
ssh ${USER_NAME}@$i mkdir -p ${DATANODE_DIR}
ssh ${USER_NAME}@$i mkdir -p ${HADOOP_TMP_DIR}
done

echo "Setting Path variables"
 
echo "export HADOOP_HOME=${HADOOP_HOME}" >> /home/n/naman/.bashrc
#echo "export HADOOP_HOME=${HADOOP_HOME}" >> .bash_profile
 
echo "export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin" >> /home/n/naman/.bashrc
#echo "export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin" >> .bash_profile

