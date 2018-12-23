FROM ubuntu:18.04

LABEL maintainer="zhangdd@hzwesoft.com"

USER root

# install tools
RUN apt-get update; \
    apt-get install -y openssh-server net-tools;

# ssh without password
RUN ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key; \
    ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key; \
    ssh-keygen -q -N "" -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key; \
    ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_ed25519_key; \
    ssh-keygen -q -N "" -t rsa -f /root/.ssh/id_rsa; \
    cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys; \
    echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config;

# java
RUN wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3a%2F%2Fwww.oracle.com%2Ftechnetwork%2Fjava%2Fjavase%2Fdownloads%2Fjdk8-downloads-2133151.html; oraclelicense=accept-securebackup-cookie;" "https://download.oracle.com/otn-pub/java/jdk/8u191-b12/2787e4a523244c269598db4e85c51e0c/jdk-8u191-linux-x64.tar.gz"; \
    tar -xvf jdk-8u191-linux-x64.tar.gz -C /usr/local/bin; \
    rm -rf jdk-8u191-linux-x64.tar.gz; \
    mv /usr/local/bin/jdk1.8.0_191/ /usr/local/bin/jdk1.8;

ENV JAVA_HOME /usr/local/bin/jdk1.8
ENV PATH $PATH:$JAVA_HOME/bin

# hadoop
RUN wget http://mirrors.shu.edu.cn/apache/hadoop/common/hadoop-3.1.1/hadoop-3.1.1.tar.gz; \
    tar -xvf hadoop-3.1.1.tar.gz -C /opt; \
    rm -rf hadoop-3.1.1.tar.gz; \
    mv /opt/hadoop-3.1.1/ /opt/hadoop; \
    rm -rf /opt/hadoop/etc/hadoop/core-site.xml; \
    rm -rf /opt/hadoop/etc/hadoop/hadoop-env.sh; \
    rm -rf /opt/hadoop/etc/hadoop/hdfs-site.xml; \
    rm -rf /opt/hadoop/etc/hadoop/mapred-site.xml; \
    rm -rf /opt/hadoop/etc/hadoop/yarn-site.xml; \
    rm -rf /opt/hadoop/etc/hadoop/workers; \
    rm -rf /opt/hadoop/sbin/start-dfs.sh; \
    rm -rf /opt/hadoop/sbin/start-yarn.sh; \
    rm -rf /opt/hadoop/sbin/stop-dfs.sh; \
    rm -rf /opt/hadoop/sbin/stop-yarn.sh;

COPY ./resource/config/* /opt/hadoop/etc/hadoop/
COPY ./resource/sbin/* /opt/hadoop/sbin/

ENV HADOOP_HOME /opt/hadoop
ENV HADOOP_CONF_DIR $HADOOP_HOME/etc/hadoop
ENV PATH $PATH:$HADOOP_HOME/bin

VOLUME [ "/usr/local/share/dfs" ]

COPY hadoop-bootstrap.sh /etc/hadoop-bootstrap.sh
RUN chmod 777 /etc/hadoop-bootstrap.sh

# mesg: ttyname failed: Inappropriate ioctl for device
RUN sed -i '$d' /root/.profile; \
    sed -i '$a tty -s && mesg n || true' /root/.profile;

ENTRYPOINT [ "./etc/hadoop-bootstrap.sh" ]
CMD [ "-d" ]

EXPOSE 22
EXPOSE 50010 50020 50070 50075 50090
EXPOSE 8030 8031 8032 8033 8040 8042 8088
