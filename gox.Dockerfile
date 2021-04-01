FROM ubuntu:focal
LABEL maintainer="StakeHolder Team <>"

RUN set -eux; \
    apt-get update -y ;\
    apt-get install --no-install-recommends -y -q \
        zip \
        build-essential \
        libssl-dev \
        make \
        gcc \
        musl-dev \
        pkg-config \
        git \
        mercurial \
        bzr \
        wget \
        curl \
        ca-certificates \
        openssh-client \
        ; \
    \
    rm -rf /var/lib/apt/lists/*

#------------------------------------------
ENV GOVERSION 1.16.2
ENV GOPATH /gopath
ENV GOROOT /goroot
ENV PATH=$GOROOT/bin:$GOPATH/bin:$PATH

RUN mkdir $GOPATH && mkdir $GOROOT
RUN curl https://storage.googleapis.com/golang/go${GOVERSION}.linux-amd64.tar.gz \
   | tar xvzf - -C $GOROOT --strip-components=1

RUN go get github.com/mitchellh/gox

#------------------------------------------
ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH

RUN set -eux; \
    url="https://static.rust-lang.org/rustup/dist/x86_64-unknown-linux-gnu/rustup-init"; \
    wget "$url"; \
    chmod +x rustup-init; \
    ./rustup-init -y --no-modify-path --default-toolchain nightly; \
    rm rustup-init; \
    chmod -R a+w $RUSTUP_HOME $CARGO_HOME; \
    rustup --version; \
    cargo --version; \
    rustc --version; \
    \
    rm -rf /var/lib/apt/lists/*


CMD go get -d ./... && gox
