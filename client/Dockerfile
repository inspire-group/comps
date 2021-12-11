FROM frankpetrilli/boringtun:latest

RUN apt-get update --allow-releaseinfo-change
RUN apt-get update && apt-get install -y --no-install-suggests curl iputils-ping
RUN bash -c 'echo "wireshark-common wireshark-common/install-setuid boolean true" | debconf-set-selections'
RUN apt-get update && apt-get install -y gcc-9-base wireshark
RUN apt-get update && apt-get install -y tshark vim
RUN apt-get update && apt-get install -y python python3-pip
RUN pip3 install requests pyroute2
RUN pip3 install numpy


COPY lab.tar.gz /tmp
RUN pip3 install --pre /tmp/lab.tar.gz

WORKDIR /comps
