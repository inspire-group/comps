FROM ubuntu:20.04

RUN apt-get update
RUN apt-get install -y ssh mosh locales
RUN apt-get install -y iproute2 tcpdump
RUN apt-get install -y python3 python3-pip
RUN pip install pyroute2 numpy


RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8 
ENV LC_ALL en_US.UTF-8


COPY setup.sh setup.sh
COPY migrate.sh migrate.sh
COPY mosh.sh mosh.sh
COPY scripts /scripts
COPY ssh_keys/id_rsa /root/.ssh/id_rsa
COPY ssh_keys/id_rsa.pub /root/.ssh/id_rsa.pub

