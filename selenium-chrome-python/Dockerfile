FROM ubuntu:18.04

LABEL maintainer="zhangdd@hzwesoft.com"

USER root

WORKDIR /opt

ENV DEBIAN_FRONTEND noninteractive

COPY app app

# install tools
RUN apt-get update; \
    apt-get install -y openssh-server net-tools tzdata python3.7 python3-pip; \
    dpkg -i app/google-chrome-stable_current_amd64.deb; \
    apt-get install -y -f; \
    cp app/chromedriver /usr/local/bin; \
    rm /etc/localtime; \
    ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime; \
    dpkg-reconfigure -f noninteractive tzdata;
