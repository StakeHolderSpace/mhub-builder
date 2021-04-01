ARG MODULE_DIR=/gopath/src/github.com/MinterTeam/minter-hub

FROM stakeholder/dockerfile-gox
LABEL maintainer="StakeHolder Team <>"

ARG MODULE_DIR

WORKDIR $MODULE_DIR

# Clone files into the docker container
RUN mkdir -p ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts; \
    git clone https://github.com/MinterTeam/minter-hub.git .

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
    && cargo install --path register_delegate_keys; \
    \
    rm -rf /var/lib/apt/lists/*
