#! /bin/bash

# start sshd
service ssh start

# hadoop roles && parameters
hadoop_initiator=$HADOOP_INITIATOR
hdfs_namenode=$HDFS_NAMENODE
hdfs_secondary_namenode=$HDFS_SECONDARY_NAMENODE
hdfs_datanodes=$HDFS_DATANODES
yarn_resourcemanager=$YARN_RESOURCEMANAGER
yarn_workers=$YARN_WORKERS
hdfs_replica=$HDFS_REPLICA

if [ -z "$hadoop_initiator" ]; then
  hadoop_initiator=false
else
  hadoop_initiator=true
fi

if [ -z "$hdfs_namenode" ]; then
  hdfs_namenode="$HOSTNAME"
fi
if [ -z "$hdfs_secondary_namenode" ]; then
  hdfs_secondary_namenode="$HOSTNAME"
fi
if [ -z "$hdfs_datanodes" ]; then
  hdfs_datanodes="$HOSTNAME"
fi
if [ -z "$yarn_resourcemanager" ]; then
  yarn_resourcemanager="$HOSTNAME"
fi
if [ -z "$yarn_workers" ]; then
  yarn_workers="$HOSTNAME"
fi
if [ -z "$hdfs_replica" ]; then
  hdfs_replica="1"
fi

OLD_IFS=$IFS
IFS=","

hdfs_datanodes=($hdfs_datanodes)
yarn_workers=($yarn_workers)

IFS=$OLD_IFS

# waiting for other container
wait_for=$WAIT_FOR
if [ -z wait_for ]; then
  wait_for=5000
fi
echo "waiting..."
sleep $wait_for;

# init hadoop
if [ $hadoop_initiator = true ]; then
  echo "create hadoop configs..."

  # create core-site.xml, hdfs-site.xml, yarn-site.xml
  sed "s/#{NAMENODE}/$hdfs_namenode/g" $HADOOP_CONF_DIR/core-site.xml.template > $HADOOP_CONF_DIR/core-site.xml
  sed "s/#{NAMENODE}/$hdfs_namenode/g" $HADOOP_CONF_DIR/hdfs-site.xml.template | sed "s/#{SECONDARY_NAMENODE}/$hdfs_secondary_namenode/g" | sed "s/#{REPLICA}/$hdfs_replica/g"  > $HADOOP_CONF_DIR/hdfs-site.xml
  sed "s/#{RESOURCEMANAGER}/$yarn_resourcemanager/g" $HADOOP_CONF_DIR/yarn-site.xml.template > $HADOOP_CONF_DIR/yarn-site.xml

  # create workers
  for host in ${yarn_workers[@]}; do
    echo -e "$host\n" >> $HADOOP_CONF_DIR/workers
  done

  # copy hadoop config to other servers
  hosts="$hdfs_namenode\n$hdfs_secondary_namenode\n$yarn_resourcemanager"
  for host in ${hdfs_datanodes[@]}; do
    hosts="${hosts}\n${host}"
  done
  for host in ${yarn_workers[@]}; do
    hosts="${hosts}\n${host}"
  done
  hosts=`echo -e $hosts | sort | uniq`
  hosts=`echo $hosts | sed "s/ /,/g"`

  OLD_IFS=$IFS
  IFS=","

  hosts=($hosts)

  IFS=$OLD_IFS

  for host in ${hosts[@]}; do
    echo "sending hadoop configs to other containers"
    scp $HADOOP_CONF_DIR/core-site.xml root@$host:$HADOOP_CONF_DIR/core-site.xml
    scp $HADOOP_CONF_DIR/hdfs-site.xml root@$host:$HADOOP_CONF_DIR/hdfs-site.xml
    scp $HADOOP_CONF_DIR/yarn-site.xml root@$host:$HADOOP_CONF_DIR/yarn-site.xml
  done

  # format hdfs
  mkdir /usr/local/share/dfs/name
  hdfs namenode -format

  # start hdfs & yarn
  echo "starting hadoop"
  $HADOOP_HOME/sbin/start-dfs.sh
  $HADOOP_HOME/sbin/start-yarn.sh

fi

if [[ $1 == "-d" ]]; then
  while true; do sleep 1000; done
fi
