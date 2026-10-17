FROM ubuntu:26.04
LABEL maintainer="Miguel Guedes <miguel.a.guedes@gmail.com>"

WORKDIR /build

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
  && apt-get install -y apt-transport-https \
                        build-essential \
                        ca-certificates \
                        curl \
                        gcc-14 \
                        git \
                        gnupg-agent \
                        software-properties-common \
                        sudo \
  && rm -rf /var/lib/apt/lists/*

# Enable source packages so we can get all of Emacs' build deps for free. Note that system packages
# are no longer in /etc/apt/sources.list .
RUN sed -i 's/Types: deb/Types: deb deb-src/' /etc/apt/sources.list.d/ubuntu.sources \
  && apt-get update \
  && apt-get build-dep -y emacs \
  && rm -rf /var/lib/apt/lists/*

#  CONFIGURE OPTION            LIBRARIES
# --------------------------  ----------------------------------------------------------------------
# --with-native-compilation   libgccjit0 libgccjit-14-dev
#   GCC 14 provides libgccjit0, the libgccjit runtime package in Ubuntu 26.04.
#
# --with-tree-sitter          libtree-sitter0.25 libtree-sitter-dev
RUN apt-get update -y \
  && apt-get install -y libgccjit0 \
                        libgccjit-14-dev \
                        libtree-sitter0.25 \
                        libtree-sitter-dev \
  && rm -rf /var/lib/apt/lists/*

RUN echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
USER ubuntu

# Build with the GCC version that matches libgccjit, preventing obscure errors when compiling
# libgccjit.
ENV CC="gcc-14"

# Defaulting to bash in support of manual runs.
CMD ["/usr/bin/bash"]
