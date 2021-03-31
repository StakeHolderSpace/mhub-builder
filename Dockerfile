ARG MODULE_DIR=$GOPATH/src/github.com/MinterTeam/minter-hub

#*************************************************************************************
FROM minter/minter-hub:builder as builder
LABEL maintainer="StakeHolder Team <>"

ARG MODULE_DIR

WORKDIR $MODULE_DIR

# Clone files into the docker container
RUN git clone https://github.com/MinterTeam/minter-hub.git .

RUN set -eux; \
    # Minter Hub node
    cd $MODULE_DIR/chain \
    && make install

RUN set -eux; \
    # Hub ↔ Minter oracle
    cd $MODULE_DIR/minter-connector \
    && make install

RUN set -eux; \
    # Prices oracle
    cd $MODULE_DIR/oracle \
    && make install

RUN set -eux; \
    # Keys generator
    cd $MODULE_DIR/keys-generator \
    && make install

RUN set -eux; \
    # Hub ↔ Ethereum oracle
    cd $MODULE_DIR/orchestrator \
    && cargo install --path orchestrator \
    && cargo install --path register_delegate_keys


##*************************************************************************************
FROM ubuntu:focal as release
LABEL maintainer="StakeHolder Team <>"

ENV MHUB_HOME=/mhub \
    MHUB_USER=mhub \
    PATH=/mhub/bin:$PATH \
    TINI_VERSION=v0.19.0

RUN set -eux; \
    apt-get update -y ;\
    apt-get install --no-install-recommends -y -q \
        curl \
        ca-certificates


ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini

#
RUN set -eux; \
    addgroup $MHUB_USER \
    && useradd -u 1000 -s /bin/bash -r -m -d $MHUB_HOME -g $MHUB_USER $MHUB_USER \
    && mkdir -p $MHUB_HOME/.mhub/config $MHUB_HOME/bin \
    && chown -R $MHUB_USER:$MHUB_USER $MHUB_HOME \
    && chmod -R a+w $MHUB_HOME


COPY --from=builder --chown=$MHUB_USER:$MHUB_USER /gopath/bin/mhub* $MHUB_HOME/bin/

RUN set -eux; \
    chmod -R +x  $MHUB_HOME/bin; \
    chmod +x /tini; \
    \
    rm -rf /var/lib/apt/lists/*

WORKDIR $MHUB_HOME

USER $MHUB_USER


#EXPOSE $PORT

STOPSIGNAL SIGTERM

ENTRYPOINT ["/tini", "--"]

CMD ["mhub"]
