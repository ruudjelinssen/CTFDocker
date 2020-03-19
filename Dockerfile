FROM ubuntu:18.04

LABEL maintainer="ruudlinssen@protonmail.com"

# Environment Variables
ENV HOME /root
ENV DEBIAN_FRONTEND=noninteractive
ENV WORDLISTS_DIR ${HOME}/wordlists
ENV TOOLS_DIR ${HOME}/tools

# Working Directory
WORKDIR /root
RUN mkdir ${TOOLS_DIR} && \
    mkdir ${WORDLISTS_DIR}

# Install Essentials
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    gcc \
    git \
    vim \
    neovim \
    wget \
    awscli \
    tzdata \
    curl \
    make \
    nmap \
    whois \
    python \
    python-pip \
    python3 \
    python3-pip \
    perl \
    nikto \
    dnsutils \
    net-tools \
    gdb \
    locales \
    tmux \
    stow \
    && rm -rf /var/lib/apt/lists/*

# Install Dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    # sqlmap
    sqlmap \
    # python
    python3.7 \
    && rm -rf /var/lib/apt/lists/*

# tzdata
RUN ln -fs /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime && \
    dpkg-reconfigure --frontend noninteractive tzdata

# Locale
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8   

# configure python(s)
RUN python -m pip install --upgrade setuptools && python3 -m pip install --upgrade setuptools && python3.7 -m pip install --upgrade setuptools

# pip
RUN python -m pip install neovim && python3 -m pip install neovim && python3.7 -m pip install neovim

# Dotfiles
RUN git clone https://github.com/ruudjelinssen/dotfiles.git && \
    cd dotfiles && \
    ./install-dotfiles.sh

# SecLists
RUN cd ${WORDLISTS_DIR} && \
    git clone --depth 1 https://github.com/danielmiessler/SecLists.git && \
    tar xvf SecLists/Passwords/Leaked-Databases/rockyou.txt.tar.gz

# Pwndbg
RUN cd ${HOME}/tools && \
    git clone https://github.com/pwndbg/pwndbg && \
    cd pwndbg && \
    ./setup.sh

# go
RUN cd /opt && \
    wget https://dl.google.com/go/go1.13.3.linux-amd64.tar.gz && \
    tar -xvf go1.13.3.linux-amd64.tar.gz && \
    rm -rf /opt/go1.13.3.linux-amd64.tar.gz && \
    mv go /usr/local 
ENV GOROOT /usr/local/go
ENV GOPATH /root/go
ENV PATH ${GOPATH}/bin:${GOROOT}/bin:${PATH}

# gobuster
RUN cd ${TOOLS_DIR} && \
    git clone https://github.com/OJ/gobuster.git && \
    cd gobuster && \
    go get && go install