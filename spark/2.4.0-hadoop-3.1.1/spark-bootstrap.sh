#! /bin/bash

# start hadoop first
./etc/hadoop-bootstrap.sh

# spark roles && parameters
hadoop_initiator=$HADOOP_INITIATOR
spark_master=$SPARK_DRIVER
spark_slaves=$SPARK_WORKERS
spark_working_memory=$SPARK_WORKING_MEMORY

if [ -z "$hadoop_initiator" ]; then
  hadoop_initiator=false
else
  hadoop_initiator=true
fi

if [ -z "$spark_master" ]; then
  spark_master="$HOSTNAME"
fi

OLD_IFS=$IFS
IFS=","

spark_slaves=($spark_slaves)

IFS=$OLD_IFS

if [ -z "$spark_working_memory" ]; then
  spark_working_memory="1g"
fi

# init spark
if [ $hadoop_initiator = true ]; then
  echo "create spark configs..."

  # create spark-env.sh
  echo "export JAVA_HOME=/usr/local/bin/jdk1.8" >> $SPARK_CONF_DIR/spark-env.sh
  echo "export SCALA_HOME=/usr/local/bin/scala" >> $SPARK_CONF_DIR/spark-env.sh
  echo "export SPARK_MASTER_IP=$spark_master" >> $SPARK_CONF_DIR/spark-env.sh
  echo "export SPARK_WORKING_MEMORY=$spark_working_memory" >> $SPARK_CONF_DIR/spark-env.sh
  echo "export HADOOP_HOME=/opt/hadoop" >> $SPARK_CONF_DIR/spark-env.sh
  echo "export HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop" >> $SPARK_CONF_DIR/spark-env.sh

  # create slaves
  for host in ${spark_slaves[@]}; do
    echo -e "$host" >> $SPARK_CONF_DIR/slaves
  done

  # copy spark config to other servers
  for host in ${spark_slaves[@]}; do
    echo "sending spark configs to other containers"
    scp $SPARK_CONF_DIR/spark-env.sh root@$host:$SPARK_CONF_DIR/spark-env.sh
    scp $SPARK_CONF_DIR/slaves root@$host:$SPARK_CONF_DIR/slaves
  done

  # start spark
  echo "starting spark"
  $SPARK_HOME/sbin/start-all.sh

fi

if [[ $1 == "-d" ]]; then
  while true; do sleep 1000; done
fi
