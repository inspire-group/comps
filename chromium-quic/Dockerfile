FROM ubuntu:xenial

# Docker directives for building chrome from https://github.com/anticrisis/docker-chromium-builder

RUN \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && apt-get update -y

RUN \
    apt-get install -y \
    build-essential \
    curl \
    git \
    lsb-base \
    lsb-release \
    sudo

RUN \
    cd / \
    && git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git

RUN \
    cd / \
    && git clone https://github.com/chromedp/docker-headless-shell.git

RUN \
    echo Etc/UTC > /etc/timezone

RUN \
    echo tzdata tzdata/Areas select Etc | debconf-set-selections

RUN \
    echo tzdata tzdata/Zones/Etc UTC | debconf-set-selections

RUN \
    echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections

ENV PATH=/depot_tools:$PATH

# needed for install-build-deps.sh
RUN \
    apt-get install -y python

RUN \
    curl -s https://chromium.googlesource.com/chromium/src/+/master/build/install-build-deps.sh?format=TEXT | base64 -d \
    | perl -pe 's/apt-get install \$\{do_quietly-}/DEBIAN_FRONTEND=noninteractive apt-get install -y/' \
    | bash -e -s - \
    --no-prompt \
    --no-chromeos-fonts \
    --no-arm \
    --no-syms \
    --no-nacl \
    --no-backwards-compatible

# needed to build mojo
RUN \
    apt-get install -y default-jdk

RUN \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /app

COPY server.sh /app/

COPY tls /site/tls
COPY example.com /site/example.com


CMD ["/app/server.sh"]
