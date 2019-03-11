FROM hub.hzwesoft.com/hadoop:3.1.1

LABEL maintainer="zhangdd@hzwesoft.com"

USER root

# scala
RUN wget https://downloads.lightbend.com/scala/2.12.8/scala-2.12.8.tgz; \
    tar -xvf scala-2.12.8.tgz -C /usr/local/bin; \
    rm -rf scala-2.12.8.tgz; \
    mv /usr/local/bin/scala-2.12.8/ /usr/local/bin/scala;

ENV SCALA_HOME /usr/local/bin/scala
ENV PATH $PATH:$SCALA_HOME/bin

# python
RUN wget https://repo.anaconda.com/archive/Anaconda3-2018.12-Linux-x86_64.sh -O anaconda3.sh; \
    bash anaconda3.sh -b -p /opt/anaconda3;

ENV PATH $PATH:/opt/anaconda3/bin

# spark
RUN wget http://mirror.bit.edu.cn/apache/spark/spark-2.4.0/spark-2.4.0-bin-hadoop2.7.tgz; \
    tar -xvf spark-2.4.0-bin-hadoop2.7.tgz -C /opt; \
    rm -rf spark-2.4.0-bin-hadoop2.7.tgz; \
    mv /opt/spark-2.4.0-bin-hadoop2.7/ /opt/spark;

ENV SPARK_HOME /opt/spark
ENV SPARK_CONF_DIR $SPARK_HOME/conf
ENV PYSPARK_PYTHON python3

# bootstrap script
COPY spark-bootstrap.sh /etc/spark-bootstrap.sh
RUN chmod 777 /etc/spark-bootstrap.sh

ENTRYPOINT [ "./etc/spark-bootstrap.sh" ]
CMD [ "-d" ]

EXPOSE 8080
