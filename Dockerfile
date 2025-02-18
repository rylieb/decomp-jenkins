FROM jenkins/inbound-agent:latest-jdk11

ENV DEBIAN_FRONTEND=noninteractive

USER root

RUN dpkg --add-architecture i386

RUN apt-get update && apt-get install -y --no-install-recommends apt-utils

RUN apt-get update && apt-get install -y \
    binutils-mips-linux-gnu \
    build-essential \
    ccache \
    gdebi \
    libcapstone-dev \
    libpng-dev \
    libyaml-dev \
    ninja-build \
    pkg-config \
    python3 \
    python3-pip \
    python3-setuptools \
    software-properties-common \
    wget \
    wine32 \
    zlib1g-dev

RUN pip3 install ansiwrap attrs capstone colour cxxfilt colorama gitpython lark-parser libyaz0 msgpack ninja_syntax pypng \
    pyelftools python-Levenshtein pylibyaml PyYAML stringcase watchdog

# llvm
RUN wget https://apt.llvm.org/llvm.sh
RUN chmod +x llvm.sh
RUN ./llvm.sh 11
RUN apt-get update & apt-get install -y clang-format-11

# ccache
RUN cp /usr/bin/ccache /usr/local/bin/
RUN ln -s ccache /usr/local/bin/gcc
RUN ln -s ccache /usr/local/bin/g++
RUN ln -s ccache /usr/local/bin/cc
RUN ln -s ccache /usr/local/bin/c++

# qemu-irix
RUN cd /usr/bin && wget https://github.com/zeldaret/oot/releases/download/0.1q/qemu-irix
RUN chmod +x /usr/bin/qemu-irix

# devkitPro pacman
RUN wget https://github.com/devkitPro/pacman/releases/download/v1.0.2/devkitpro-pacman.amd64.deb
RUN gdebi -n devkitpro-pacman.amd64.deb

# dkp-pacman gba
RUN ln -f -s /proc/self/mounts /etc/mtab
RUN dkp-pacman -S gba-dev --noconfirm

USER jenkins

ENV DEVKITPRO=/opt/devkitpro
ENV DEVKITARM=${DEVKITPRO}/devkitARM
ENV DEVKITPPC=${DEVKITPRO}/devkitPPC
ENV PATH=${DEVKITPRO}/tools/bin:$PATH

# agbcc
RUN git clone https://github.com/pret/agbcc
RUN cd agbcc && ./build.sh
ENV AGBCC=/home/jenkins/agbcc
