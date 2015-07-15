FROM ubuntu:trusty

RUN apt-get update && apt-get install -y \
    autoconf  \
    automake  \
    bzip2  \
    daemontools  \
    dblatex  \
    docbook-utils  \
    docbook-xsl  \
    g++  \
    git  \
    haskell-platform  \
    libgmp-dev  \
    libtool  \
    libxml2-utils  \
    linux-tools-generic  \
    make  \
    ncurses-dev  \
    nodejs  \
    nodejs-legacy  \
    npm  \
    openssh-server  \
    python  \
    texlive-font-utils \
    tmux \
    xutils-dev 

ENV PATH /.cabal/bin:$PATH

RUN mkdir -p /repos/cabal
WORKDIR /repos/cabal
RUN cabal update && \
    git clone -b cabal-install-v1.22.6.0 git://github.com/haskell/cabal.git . && \
    cabal install Cabal/ cabal-install/ && \
    echo $PATH && which cabal && cabal --version

RUN cabal install alex && \
    cabal install happy

# build and install node
RUN mkdir -p /repos/node
WORKDIR /repos/node
RUN git clone -b v0.12.7-release https://github.com/joyent/node.git . && \
    ./configure && \
    make && \
    make install 

### Build and install ghc 7.10
RUN mkdir -p /repos/ghc
WORKDIR /repos/ghc
RUN git clone -b ghc-7.10 --recursive git://git.haskell.org/ghc.git . && \
    cat mk/build.mk.sample  | sed -e '/#Build.*quick$/s/^#//' > mk/build.mk && \
    ./boot && \
    ./configure && \
    make && \
    make install

WORKDIR /repos
RUN git clone https://github.com/ghcjs/ghcjs.git && \
    git clone https://github.com/ghcjs/ghcjs-prim.git && \
    cabal install --reorder-goals --max-backjumps=-1 ./ghcjs ./ghcjs-prim
