FROM stakeholder/minter-hub:builder as builder

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
        ca-certificates \
        ; \
    apt-get clean autoclean; \
    apt-get autoremove --yes; \
    rm -rf /var/lib/apt/lists/*


ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini

#
RUN set -eux; \
    addgroup $MHUB_USER \
    && useradd -u 1000 -s /bin/bash -r -m -d $MHUB_HOME -g $MHUB_USER $MHUB_USER \
    && mkdir -p $MHUB_HOME/.mhub/config $MHUB_HOME/.mhub/data $MHUB_HOME/bin \
    && chown -R $MHUB_USER:$MHUB_USER $MHUB_HOME \
    && chmod -R a+w $MHUB_HOME

#
COPY --from=builder --chown=$MHUB_USER:$MHUB_USER \
      /gopath/bin/mhub* \
      /usr/local/cargo/bin/orchestrator \
      /usr/local/cargo/bin/register-peggy-delegate-keys \
      $MHUB_HOME/bin/
#
RUN set -eux; \
    chmod -R +x  $MHUB_HOME/bin; \
    chmod +x /tini

WORKDIR $MHUB_HOME

USER $MHUB_USER


#EXPOSE $PORT

STOPSIGNAL SIGTERM

ENTRYPOINT ["/tini", "--"]

CMD ["mhub"]
