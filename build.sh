#!/usr/bin/env sh

docker build --rm --network=host -t stakeholder/dockerfile-gox -f gox.Dockerfile . \
&& docker build --rm --network=host -t stakeholder/minter-hub:builder -f builder.Dockerfile . \
&& docker build --network=host  -t stakeholder/minter-hub .
