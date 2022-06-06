FROM frankpetrilli/boringtun:latest

RUN apt-get update --allow-releaseinfo-change
RUN apt-get update && apt-get install -y --no-install-suggests curl iputils-ping
RUN bash -c 'echo "wireshark-common wireshark-common/install-setuid boolean true" | debconf-set-selections'
RUN apt-get update && apt-get install -y gcc-9-base wireshark
RUN apt-get update && apt-get install -y tshark
RUN apt-get update && apt-get install -y python3 python3-pip
RUN pip3 install requests

WORKDIR /comps
COPY setup.sh /comps
COPY migrate-simple.sh /comps
COPY test.sh /comps
COPY perf.py /comps
