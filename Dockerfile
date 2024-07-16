FROM ubuntu:22.04
LABEL maintainer="Miguel Guedes <miguel.a.guedes@gmail.com>"
WORKDIR /build
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
  && apt-get install -y apt-transport-https \
                        build-essential \
                        ca-certificates \
                        curl \
                        gcc-10 \
                        git \
                        gnupg-agent \
                        software-properties-common \
                        sudo \
  && rm -rf /var/lib/apt/lists/*

# Enable source packages so we can get all of Emacs' build deps for free.
RUN sed -i 's/# deb-src/deb-src/' /etc/apt/sources.list \
  && apt-get update \
  && apt-get build-dep -y emacs \
  && rm -rf /var/lib/apt/lists/*


#  CONFIGURE OPTION            LIBRARIES
# --------------------------  ----------------------------------------------------------------------
# --with-native-compilation   libgccjit0 libgccjit-10-dev
#
# --with-json                 libjansson4 libjansson-dev
#   These libraries enable native support for parsing and generating JSON data within Emacs.
#
# --with-tree-sitter          libtree-sitter0 libtree-sitter-dev
RUN add-apt-repository ppa:ubuntu-toolchain-r/ppa \
  && apt-get update -y \
  && apt-get install -y libgccjit0 \
                        libgccjit-10-dev \
                        libjansson4 \
                        libjansson-dev \
                        libtree-sitter0 \
                        libtree-sitter-dev \
  && rm -rf /var/lib/apt/lists/*

# Preventing the error:
#   fatal: detected dubious ownership in repository at '/build/src'
RUN git config --global --add safe.directory /build/src

# Preventing obscure error messages when compiling libgccjit.
ENV CC="gcc-10"

# Defaulting to bash in support of manual runs.
CMD ["/usr/bin/bash"]
